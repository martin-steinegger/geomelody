package de.lmu.ios.geomelody.server;

import java.util.concurrent.ConcurrentMap;

import com.googlecode.concurrentlinkedhashmap.ConcurrentLinkedHashMap;

public class Result {
	public final static Result Instance = new Result();
	private final ConcurrentMap<String, Object> resultMap = new ConcurrentLinkedHashMap.Builder<String, Object>()
		    .maximumWeightedCapacity(1000)
		    .build();
	
	private Result() {
		super();
	}


	public Object getResult(String id) {
		return resultMap.get(id);
	}
	
	public void setResult(String id, Object result) {
		resultMap.put(id, result);
	}
}
