                          The Fat Jar Eclipse Plugin
------------------------------------------------------------------------------

Requirements:
-------------

Eclipse 3.0 or greater

About:
------

The Fat Jar Eclipse Plug-In is a Deployment-Tool which deploys an 
Eclipse java-project into one executable jar.

It adds the Entry "Build Fat-JAR" to the Export-Wizard.
In addition to the eclipse standard jar-exporter referenced classes and jars
are included to the "Fat-Jar", so the resulting jar contains all needed 
classes and can be executed directly with "java -jar", no classpath has to be
set, no additional jars have to be deployed.

Jars, External-Jars, User-Libraries, System-Libraries, Classes-Folders and 
Project-Exports are considered by the plugin.
The Main-Class can be selected and Manifest-files are merged.
The One-JAR option integrates a specialised Class-Loader written by 
Simon Tuffs ( http://one-jar.sourceforge.net/ ) which handles jar-files 
inside a jar.
Individual files and folders can be excluded or added to the jar.
Different settings can be stored and re-executed as "Quick Build" 
via the context-menu.

How To Install:
---------------

The zip file contains the plugin directory. 
Unzip from within the Eclipse directory.
Stop eclipse. 
Start eclipse from the command-line with the clean option "eclipse -clean",
otherwise the plugin will not be found.

To uninstall, remove the net.sf.fjep.fatjar_x.x.x (where x.x.x
denotes the version of the plugin you have installed).

Quick Tutorial:
---------------

(for an illustrated version look at http://fjep.sf.net )

Step 1: Create a new Java Project "demolib"

Create a new Java Project named "demolib".
Add the Class "demolib.DemoLib.java" containing the following code:

    package demolib;
    public class DemoLib {
        public static void sayHello() {
            System.out.println("Hello");
        }
    }

Step 2: Create a jar file using Fat Jar Plug-In

In the "Package-Explorer" (not the "Resource-View") right click on the 
project "demolib". Select "+ Build Fat Jar". 
A Configuration Dialog appears. Just press "Finish".

The File "demolib_fat.jar" has been created in the project root directory

Step 3: Create a new Java-Project "demorun"

Create a new Java Project named "demorun".
In the project properties add the Library "demolib/demolib_fat.jar" to the 
Java Build Path":

Step 4: Create Main Class

Add the Class "demorun.DemoRunMain.java" containing the following code:

    package demorun;
    import demolib.DemoLib;
    public class DemoRunMain {
        public static void main(String[] args) {
            DemoLib.sayHello();
        }
    }

Step 5: Start the Build Fat Jar Dialog

Start the Export Wizard from the File-Menu ("File" -> "Export").
Select "+ Fat Jar Exporter" and click "next >". 

In the Java-Project selection mark the project "demorun" and click "next >".
 
A Configuration-Dialog appears showing the current Settings.

Step 6: Select the Main Class

The Main Class - the one containing the static methode main - must be defined 
in the jar. Click on the "Browse..." Button on the right side behind the 
Main-Class Edit field.

Select "DemoRunMain" and click the "OK" Button.
The FullyQualifiedName "demorun.DemoRunMain" is now set for "Main-Class".

Step7: Finish

Save the current Settings by clicking on the "Finish" Button.

The File "demorun_fat.jar" has been created in the project root directory.
In addition the file ".fatjar" storing the configuration settings has been 
created in the project root directory.

The created jar file contains all classes from all dependant jar files 
(demolib_fat.jar) and the project classes. This file can be executed anywhere, 
no classpath has to be set, because all necessary libraries are extracted 
inside the "Fat Jar":

   > java -jar deomrun_fat.jar
   Hello


Thanks:
-------

Many thanks to

Emmanuel Salé      - for publishing his source for the toString Plug-In.
                     There are many similair UI elements which I was able
                     to copy   :)

For feedback about problems and possible enhancemants:

Andreas Groscurth  - support external jars
Thomas Cornet      - merge Manifest files
Richard Welteroth  - preferences page, 
                     export wizard, 
                     progress bar, 
                     add/remove Files
Steve Bromley      - support referenced projects
Francesc Rosés     - support user libraries
Patrick Rouillon   - detected problem with '\0' in MANIFEST.MF
Donna L. Gresh     - allow external output path
Ray Cardillo       - support system libraries  
                     (TODO: syslib precedence on conflicting classes)
Rainer Lay         - detected problem with Quick-Build
Nikolai Mann       - "eclipse -clean" tip,
                     allow other extension than ".jar" for output

Bugs, Feedback:
---------------

In case you run into problems, or if you have any suggestions, please send
an email.

  Ferenc Hechler                            Simon Tuffs
  ferenc_hechler@users.sourceforge.net      simon_tuffs@users.sourceforge.net
