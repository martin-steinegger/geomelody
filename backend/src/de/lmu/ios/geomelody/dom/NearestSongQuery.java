package de.lmu.ios.geomelody.dom;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "NearestSongQuery")
public class NearestSongQuery {
	private Location location;
	private Filters filters;
	
	private int count;

	public NearestSongQuery() {
	}

	public NearestSongQuery(Location location, Filters filters, int count) {
		this.location = location;
		this.filters = filters;
		this.count = count;
	}

	@XmlElement(name = "Location")
	public Location getLocation() {
		return location;
	}

	public void setLocation(Location location) {
		this.location = location;
	}

	@XmlElement(name = "Filters")
	public Filters getFilters() {
		return filters;
	}

	public void setFilters(Filters filters) {
		this.filters = filters;
	}

	@XmlElement(name = "Count")
	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}
}
