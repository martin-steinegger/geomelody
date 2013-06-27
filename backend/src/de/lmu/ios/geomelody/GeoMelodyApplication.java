package de.lmu.ios.geomelody;

import java.util.HashSet;
import java.util.Set;

import javax.ws.rs.core.Application;

import de.lmu.ios.geomelody.facade.ServiceFacade;

public class GeoMelodyApplication extends Application {
	private ServiceFacade facade;

	public GeoMelodyApplication(ServiceFacade facade) {
		this.facade = facade;
	}

	@Override
	public Set<Class<?>> getClasses() {
		Set<Class<?>> s = new HashSet<Class<?>>();
		s.add(this.facade.getClass());
		return s;
	}
 
	@Override
	public Set<Object> getSingletons() {
		Set<Object> s = new HashSet<Object>();
		s.add(this.facade);
		return s;
	}
}
