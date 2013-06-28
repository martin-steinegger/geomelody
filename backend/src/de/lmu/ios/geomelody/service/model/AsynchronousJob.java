package de.lmu.ios.geomelody.service.model;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement
public class AsynchronousJob {
	private String id;
	private ProgressStatus status;

	public AsynchronousJob() {
		
	}
	
	public AsynchronousJob(String id, ProgressStatus status) {
		this.id = id;
		this.status = status;
	}

	@XmlElement
	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	@XmlElement
	public ProgressStatus getStatus() {
		return status;
	}

	public void setStatus(ProgressStatus status) {
		this.status = status;
	}
}
