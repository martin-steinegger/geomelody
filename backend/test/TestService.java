import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.UriBuilder;

import org.junit.Test;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.ClientResponse;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.api.client.WebResource.Builder;
import com.sun.jersey.api.client.config.ClientConfig;
import com.sun.jersey.api.client.config.DefaultClientConfig;

import de.lmu.ios.geomelody.dom.Filters;
import de.lmu.ios.geomelody.dom.Location;
import de.lmu.ios.geomelody.dom.NearestSongQuery;
import de.lmu.ios.geomelody.dom.Songs;

public class TestService {

	@Test
	public void test() {
		ClientConfig config = new DefaultClientConfig();
		Client client = Client.create(config);
		WebResource service = client.resource(getBaseURI());
		// Get XML
//		System.out.println(service.path("protein").path("prediction")
//				.path("35").accept(MediaType.APPLICATION_JSON)
//				.get(String.class));
//		System.out
//				.println(service.path("protein").path("prediction").path("NP_005378")
//						.path("ACD")
//						.accept(MediaType.APPLICATION_XML).get(String.class));
//		MultivaluedMap formData = new MultivaluedMapImpl();
//		formData.add("q", "NP_005378");
////
//		String resp = service.path("protein").path("search")
//				.accept(MediaType.APPLICATION_JSON)
//				.type(MediaType.APPLICATION_FORM_URLENCODED)
//				.post(String.class, formData);
//		System.out.println(resp);
//		resp = service.path("protein").path("search")
//				.accept(MediaType.APPLICATION_JSON)
//				.type(MediaType.APPLICATION_FORM_URLENCODED)
//				.post(String.class, formData);
//		System.out.println(resp);

//		System.out.println(service.path("protein").path("externalsnp").path("NP_005378")
//				.accept(MediaType.APPLICATION_JSON).get(String.class));

/*
		List<String> tags = new ArrayList<String>(2);
		tags.add("Rock");
		tags.add("Pop");
		
		Song s = new Song(1,1,"Test", new Location(0, 0), tags);
	    Builder builder = service.path("v1").path("song").type(MediaType.APPLICATION_JSON);
	    builder.accept(MediaType.APPLICATION_JSON).entity(s);
	    System.out.println(builder.post(ClientResponse.class));
*/
	    List<String> filter = new ArrayList<String>();
	    filter.add("Rock");
	    filter.add("Pop");
		Location location = new Location(1, 1);
		Filters filters = new Filters();
		filters.setFilters(filter);
		NearestSongQuery query = new NearestSongQuery(location, filters, 20);
		
	    Builder builder = service.path("v1").path("song").path("nearby").type(MediaType.APPLICATION_JSON);
	    builder.accept(MediaType.APPLICATION_JSON).entity(query);
	    
	    
	    ClientResponse response = builder.post(ClientResponse.class);
	    
	    Songs s = response.getEntity(Songs.class);
	    
	    System.out.println(s);
	    
	//	System.out
		//		.println(service.path("v1").path("NP_005378").path("functionaleffect")
			//			.path("detail").path("SIFT").path("1").
				//		accept(MediaType.APPLICATION_JSON).get(String.class));
//
//		System.out
//				.println(service.path("protein").path("mutations").path("NP_005378").path("17").path("20").
//						accept(MediaType.APPLICATION_XML).get(String.class));

		// Get XML for application
		// System.out.println(service.path("rest").path("todo").accept(
		// MediaType.APPLICATION_JSON).get(String.class));
		// // Get JSON for application
		// System.out.println(service.path("rest").path("todo").accept(
		// MediaType.APPLICATION_XML).get(String.class));

	}

	private static URI getBaseURI() {
		//return UriBuilder.fromUri("http://api.geomelody.com/resources/").build();
		return UriBuilder.fromUri("http://localhost:3000/resources/").build();
	}

}
