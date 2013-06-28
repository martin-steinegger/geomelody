package de.lmu.ios.geomelody.service.model;

import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

@XmlRootElement(name = "Progress")
public enum ProgressStatus {
	READY("READY"), RUNNING("RUNNING"), DONE("DONE"), ERROR("ERROR");

	private String progressStatus;

	private ProgressStatus(String c) {
		progressStatus = c;
	}

	@XmlElement(name = "status")
	public String getProgressStatus() {
		return progressStatus;
	}
}
