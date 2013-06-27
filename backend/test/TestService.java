import java.net.URI;

import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.UriBuilder;

import org.junit.Test;

import com.sun.jersey.api.client.Client;
import com.sun.jersey.api.client.WebResource;
import com.sun.jersey.api.client.config.ClientConfig;
import com.sun.jersey.api.client.config.DefaultClientConfig;

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


		
		System.out
				.println(service.path("v1").path("NP_005378").path("functionaleffect")
						.path("detail").path("SIFT").path("1").
						accept(MediaType.APPLICATION_JSON).get(String.class));
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
		return UriBuilder.fromUri("http://localhost:8081/resources/").build();
	}

}
