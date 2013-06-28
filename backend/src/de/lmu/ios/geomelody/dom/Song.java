package de.lmu.ios.geomelody.dom;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "Song")
public class Song {
	private int soundCloudSongId;
	private int soundCloudUserId;
	private String comment;
	private Location location;
	private List<String> tags;

	public Song() {
	}

	public Song(int soundCloudSongId, int soundCloudUserId,
			String comment, Location location, List<String> tags) {
		this.soundCloudSongId = soundCloudSongId;
		this.soundCloudUserId = soundCloudUserId;
		this.comment = comment;
		this.location = location;
		this.tags = tags;
	}

	@XmlElement(name = "Tags")
	public List<String> getTags() {
		return tags;
	}

	public void setTags(List<String> tags) {
		this.tags = tags;
	}

	@XmlElement(name = "SoundCloudSongId")
	public int getSoundCloudSongId() {
		return soundCloudSongId;
	}

	public void setSoundCloudSongId(int soundCloudSongId) {
		this.soundCloudSongId = soundCloudSongId;
	}

	@XmlElement(name = "SoundCloudUserId")
	public int getSoundCloudUserId() {
		return soundCloudUserId;
	}

	public void setSoundCloudUserId(int soundCloudUserId) {
		this.soundCloudUserId = soundCloudUserId;
	}

	@XmlElement(name = "Comment")
	public String getComment() {
		return comment;
	}

	public void setComment(String comment) {
		this.comment = comment;
	}

	@XmlElement(name = "Location")
	public Location getLocation() {
		return location;
	}

	public void setLocation(Location location) {
		this.location = location;
	}
}
