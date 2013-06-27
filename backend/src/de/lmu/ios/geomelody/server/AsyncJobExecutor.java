package de.lmu.ios.geomelody.server;

import java.util.UUID;

import javax.ws.rs.core.GenericEntity;
import javax.ws.rs.core.Response;

import com.sun.jersey.api.json.JSONWithPadding;

import de.lmu.ios.geomelody.service.model.AsynchronousJob;
import de.lmu.ios.geomelody.service.model.ProgressStatus;

public class AsyncJobExecutor {
	private Response response;
	
	public AsyncJobExecutor(final String callback, final Command job) {
		final String jobId = UUID.randomUUID().toString();
		
		new Thread(new Runnable() {
			@Override
			public void run() {
				try {
					Object jobResult = job.execute();
					if (jobResult != null) {
						Result.Instance.setResult(jobId, jobResult);
						Progress.Instance.setStatus(jobId, ProgressStatus.DONE);
					} else {
						Result.Instance.setResult(jobId, "Bad Request");
						Progress.Instance.setStatus(jobId, ProgressStatus.ERROR);
					}
				} catch (Exception e) {
					Result.Instance.setResult(jobId, "Error");
					Progress.Instance.setStatus(jobId, ProgressStatus.ERROR);
					throw new RuntimeException(e);
				}
			}
		}).start();
		
		Progress.Instance.setStatus(jobId, ProgressStatus.RUNNING);
        setResponse(Response.status(200).entity(new JSONWithPadding(new GenericEntity<AsynchronousJob>(new AsynchronousJob(jobId, ProgressStatus.RUNNING)) {}, callback)).build());

	}

	public Response getResponse() {
		return response;
	}
	
	private void setResponse(Response response) {
		this.response = response;
	}
	
}
