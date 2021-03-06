package de.lmu.ios.geomelody.service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import javax.sql.DataSource;

import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.transaction.annotation.Transactional;

import de.lmu.ios.geomelody.dom.Filters;
import de.lmu.ios.geomelody.dom.Location;
import de.lmu.ios.geomelody.dom.Song;
import de.lmu.ios.geomelody.mapper.SongMapper;

public class SongMappingServiceImpl implements SongMappingService {
	private NamedParameterJdbcTemplate jdbcTemplate;

	private static Map<String, Object> emptyMap = Collections
			.unmodifiableMap(new LinkedHashMap<String, Object>());

	public void setDataSource(final DataSource dataSource) {
		this.jdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
	}

	@Override
	@Transactional
	public void saveSong(final Song song) {
		Map<String, Object> params = new HashMap<String, Object>(5);
		params.put("soundcloud_song_id", song.getSoundCloudSongId());
		params.put("soundcloud_user_id", song.getSoundCloudUserId());
		params.put("comment", song.getComment());
		params.put("longitude", song.getLocation().getLongitude());
		params.put("latitude", song.getLocation().getLatitude());

		jdbcTemplate
				.update("INSERT INTO songs (soundcloud_song_id, soundcloud_user_id, comment, geom) "
						+ "VALUES (:soundcloud_song_id, :soundcloud_user_id, :comment, "
						+ "ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326))",
						params);

		final long songId = jdbcTemplate.queryForLong(
				"SELECT CURRVAL('songs_id_seq')", emptyMap);
		
		final List<String> tags = song.getTags();
		if(tags != null) {
			final Map<String, Integer> tagIdMap = jdbcTemplate.query(
					"SELECT id, name FROM tags", emptyMap,
					new ResultSetExtractor<Map<String, Integer>>() {
						public Map<String, Integer> extractData(ResultSet rs)
								throws SQLException {
							Map<String, Integer> map = new TreeMap<String, Integer>(String.CASE_INSENSITIVE_ORDER);
							while (rs.next()) {
								int col1 = rs.getInt("id");
								String col2 = rs.getString("name");
								map.put(col2, col1);
							}
							return map;
						};
					});
			
			for(String tag : tags) {
				Integer tagId;
				if((tagId = tagIdMap.get(tag)) != null) {
					Map<String, Object> insertMap = new HashMap<String, Object>(2);
					insertMap.put("song_id", songId);
					insertMap.put("tag_id", tagId);
					jdbcTemplate.update(
							"INSERT INTO songs_tags (song_id, tag_id) VALUES (:song_id, :tag_id)", insertMap);
				}
			}
		}
	}

	@Override
	public List<Song> getkNearestSongs(final Location location, final Filters filters, final int k) {
		MapSqlParameterSource params = new MapSqlParameterSource();
		params.addValue("longitude", location.getLongitude());
		params.addValue("latitude", location.getLatitude());
		params.addValue("k", k);
	
		StringBuilder sb = new StringBuilder()
		.append("SELECT s.id, s.soundcloud_song_id, s.soundcloud_user_id, s.comment, ")
		.append("	array_to_string(ARRAY(SELECT t.name ")
		.append("	    FROM tags AS T ")
		.append("	    INNER JOIN songs_tags AS st ON t.id = st.tag_id ")
		.append("	    WHERE ")
		.append("		st.song_id = s.id), ',') as tags, ")
		.append("		ST_X(geom) as longitude, ")
		.append("		ST_Y(geom) as latitude ")
		.append("	FROM songs AS s ")
		.append("		LEFT JOIN songs_tags AS st ON s.id = st.song_id ")
		.append("		LEFT JOIN tags AS t ON t.id = st.tag_id ");
		
		if(filters != null && filters.getFilters() != null && filters.getFilters().size() > 0) {
			params.addValue("filters", filters.getFilters());
			sb.append("	WHERE ")
			.append("		t.name IN (:filters) ");
		}

		sb.append("	GROUP BY ")
		.append("		s.id ")
		.append("	ORDER BY ")
		.append("		s.geom <-> ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326) ")
		.append("	LIMIT :k");
		
		String query = sb.toString();
		
		
		return jdbcTemplate
				.query(query, params, new SongMapper());
	}
}
