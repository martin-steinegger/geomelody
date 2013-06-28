package de.lmu.ios.geomelody.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sql.DataSource;

import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

import de.lmu.ios.geomelody.dom.Filters;
import de.lmu.ios.geomelody.dom.Location;
import de.lmu.ios.geomelody.dom.Song;
import de.lmu.ios.geomelody.mapper.SongMapper;

public class SongMappingServiceImpl implements SongMappingService {
	private NamedParameterJdbcTemplate jdbcTemplate;

	public void setDataSource(DataSource dataSource) {
		this.jdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
	}

	@Override
	public void saveSong(Song song) {
		Map<String, Object> params = new HashMap<String, Object>();
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

	}

	@Override
	public List<Song> getkNearestSongs(Location location, Filters filters, int k) {
		List<Integer> ids = new ArrayList<Integer>();
		ids.add(1);
		ids.add(2);
		ids.add(3);

		Map<String, Object> params = new HashMap<String, Object>();
		params.put("longitude", location.getLongitude());
		params.put("latitude", location.getLatitude());
		params.put("k", k);
		params.put("filters", filters);

		return jdbcTemplate
				.query("SELECT soundcloud_song_id, soundcloud_user_id, comment "
						+ "FROM songs AS s "
						+ "INNER JOIN songs_tags AS st ON s.id = st.song_id "
						+ "INNER JOIN tags AS t ON t.id = st.tag_id "
						+ "WHERE t.name IN (:filters) "
						+ "ORDER BY s.geom <-> ST_SetSRID(ST_MakePoint(:longitude, :latitude), 4326) "
						+ "LIMIT :k", params, new SongMapper());
	}
}
