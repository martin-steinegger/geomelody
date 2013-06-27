package de.lmu.ios.geomelody.dom;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "Location")
public class Location {
	private double latitude;
	private double longitude;
	
	public Location() {
	}

	public Location(double latitude, double longitude) {
		this.latitude = latitude;
		this.longitude = longitude;
	}

	@XmlElement(name = "Latitude")
	public double getLatitude() {
		return latitude;
	}

	public void setLatitude(double latitude) {
		this.latitude = latitude;
	}

	@XmlElement(name = "Longitude")
	public double getLongitude() {
		return longitude;
	}

	public void setLongitude(double longitude) {
		this.longitude = longitude;
	}


}
