#!/usr/bin/env bash
libpath=
for i in $(ls lib/*|grep ".jar"); do 
	libpath=$( echo "$i:$libpath"); 
done
echo $libpath
java -server -Xms32M -cp "$(echo $libpath)build/jar/GeoMelody.jar" de.lmu.ios.geomelody.Startup