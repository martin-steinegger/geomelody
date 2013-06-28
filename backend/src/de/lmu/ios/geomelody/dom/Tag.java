package de.lmu.ios.geomelody.dom;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "Tag")
public class Tag {
	private String tag;

	public Tag() {
	}
	
	public Tag(String tag) {
		this.tag = tag;
	}

	@XmlElement(name = "mode")
	public String getTag() {
		return tag;
	}
}
