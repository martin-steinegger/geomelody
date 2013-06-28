package de.lmu.ios.geomelody.facade;

import javax.ws.rs.core.Response;

import de.lmu.ios.geomelody.dom.NearestSongQuery;
import de.lmu.ios.geomelody.dom.Song;

public interface ServiceFacade {
	public Response getProgress(String id, String callback);

	public Response getResult(String id, String callback);

	public Response saveSong(Song song);
	public Response getNearestSongs(NearestSongQuery query, String callback);
}
