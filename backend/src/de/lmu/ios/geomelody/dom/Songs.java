package de.lmu.ios.geomelody.dom;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "Songs")
public class Songs {
	private List<Song> songs;

	public Songs() {
	}

	public Songs(List<Song> songs) {
		this.songs = songs;
	}

	@XmlElement(name = "Song")
	public List<Song> getSongs() {
		return songs;
	}

	public void setSongs(List<Song> songs) {
		this.songs = songs;
	}


}
