package de.lmu.ios.geomelody.server;

//import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import com.googlecode.concurrentlinkedhashmap.ConcurrentLinkedHashMap;

import de.lmu.ios.geomelody.service.model.ProgressStatus;

public class Progress {
	public final static Progress Instance = new Progress();
	private final ConcurrentMap<String, ProgressStatus> progressMap = new ConcurrentLinkedHashMap.Builder<String, ProgressStatus>()
		    .maximumWeightedCapacity(1000)
		    .build();
	
	private Progress() {
		super();
	}


	public ProgressStatus getStatus(String id) {
		return progressMap.get(id);
	}
	
	public void setStatus(String id, ProgressStatus status) {
		progressMap.put(id, status);
	}
}
