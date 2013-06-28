package de.lmu.ios.geomelody.dom;

import java.util.List;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "Filters")
public class Filters {
	private List<String> filters;

	public Filters() {
	}

	public Filters(List<String> filters) {
		this.filters = filters;
	}

	@XmlElement(name = "Filters")
	public List<String> getFilters() {
		return filters;
	}

	public void setFilters(List<String> filters) {
		this.filters = filters;
	}


}
