package de.lmu.ios.geomelody.mapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;

import org.springframework.jdbc.core.RowMapper;

import de.lmu.ios.geomelody.dom.Location;
import de.lmu.ios.geomelody.dom.Song;

public class SongMapper implements RowMapper<Song> {

    public Song mapRow(ResultSet rs, int rowNum) throws SQLException {
        Song song = new Song();
        song.setSoundCloudSongId(rs.getInt("soundcloud_song_id"));
        song.setSoundCloudUserId(rs.getInt("soundcloud_user_id"));
        song.setComment(rs.getString("comment"));
        
        Location location = new Location(rs.getDouble("longitude"), rs.getDouble("latitude"));
        song.setLocation(location);
        
        song.setTags(Arrays.asList(rs.getString("tags").split(",")));
        return song;
    }        
}
