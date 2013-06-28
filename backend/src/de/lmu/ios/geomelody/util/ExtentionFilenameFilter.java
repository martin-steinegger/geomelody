package de.lmu.ios.geomelody.util;

import java.io.File;
import java.io.FilenameFilter;

public class ExtentionFilenameFilter implements FilenameFilter {

	private String[] extArray;

	public ExtentionFilenameFilter(final String[] ext) {
		extArray = new String[ext.length];
		for (int i = 0; i < ext.length; i++) {
			this.extArray[i] = "." + ext[i];
		}
	}

	@Override
	public boolean accept(File dir, String name) {
		for (int i = 0; i < extArray.length; i++) {
			if (name.endsWith(extArray[i]) == true)
				return true;
		}
		return false;
	}
}