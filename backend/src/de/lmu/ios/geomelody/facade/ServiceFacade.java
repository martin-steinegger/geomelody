package de.lmu.ios.geomelody.facade;

import javax.ws.rs.core.Response;

import de.lmu.ios.geomelody.dom.Filters;
import de.lmu.ios.geomelody.dom.Location;
import de.lmu.ios.geomelody.dom.Song;

public interface ServiceFacade {
	public Response getProgress(String id, String callback);

	public Response getResult(String id, String callback);

	public Response saveSong(Song song);
	public Response getNearestSongs(Location location, Filters filters, String callback);
}
