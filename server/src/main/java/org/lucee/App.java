package org.lucee;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.URL;

import org.apache.catalina.Context;
import org.apache.catalina.connector.Connector;
import org.apache.catalina.startup.Tomcat;

public class App {

    public static void main(String[] argx) throws Exception {

        boolean runningFromJar = isRunningFromJar(App.class);
//        boolean runningFromJar = true;

      
//    	Read in the Lucee property file
        // Properties props = new Properties();
        PropertyLoader.loadProperties("/lucee.properties");
        PropertyLoader.loadProperties("/catalina.properties");
        PropertyLoader.loadLoggingProperties("/logging.properties");

//		Setup default ports and read in from the command line via `java -Dlucee.lsp.port=1234 -jar etc.jar`
//		TODO: Get  Michas' env variable script
        String lspPort = System.getProperty("lucee.lsp.port");
        if (lspPort == null) {
            lspPort = "2089";
            System.setProperty("lucee.lsp.port", lspPort);
        }
        String serverPort = System.getProperty("lucee.server.port");
        if (serverPort == null) {
            serverPort = "4000";
            System.setProperty("lucee.server.port", serverPort);
        }

        String warDir = System.getProperty("lucee.server.wardir");
        if (warDir == null) {
            warDir = System.getProperty("java.io.tmpdir");
            System.setProperty("lucee.server.wardir", warDir);
        }

        String lspEnabled = System.getProperty("lucee.lsp.enabled");
        if(lspEnabled == null) {
        	lspEnabled = "false";
        }
        System.out.println("LSP Server port: " + lspPort);
        System.out.println("LSP Server enabled: " + lspEnabled);
        System.out.println("LSP Server HTTP port: " + serverPort);
        System.out.println("Server WAR Dir: " + warDir);
        
        

        Tomcat tomcat = new Tomcat();

        File baseDir = null;
        String contextPath = "";

        if (!runningFromJar) {
            // Run it from a local file so that we can dynamically load it
            File webappDir = new File("./src/main/cfml/");
            System.out.println("Starting Lucee LSP from: " + webappDir.getCanonicalPath());

            tomcat.setBaseDir(webappDir.getAbsolutePath());
            tomcat.addWebapp("", webappDir.getCanonicalPath());
            baseDir = webappDir;
            
//            String globalWebXmlPath = new File("./src/main/cfml/WEB-INF/web.xml/").getCanonicalPath();
//            tomcat.getHost().setConfigClass(globalWebXmlPath);
//            
            

        } else {
        	long unique_time = System.currentTimeMillis();
            baseDir = new File(warDir, "cfml_formatter_" + serverPort + "_" + unique_time);
            baseDir.deleteOnExit();

            System.out.println("Starting Lucee LSP from WAR: " + baseDir);
            

            try (InputStream warInputStream = App.class.getResourceAsStream("/lucee_lsp.war")){
                ;
                if (warInputStream == null) {
                    throw new IllegalArgumentException("WAR file not found in JAR resources.");
                }
                if (!baseDir.exists() && !baseDir.mkdirs()) {
                    throw new IOException("Failed to create base directory: " + baseDir.getAbsolutePath());
                }
                File warFile = createTempFileFromStream(warInputStream, "lucee_lsp", ".war");
                System.out.println("Expanded WAR To: " + baseDir.getAbsolutePath());
                tomcat.setBaseDir(baseDir.getAbsolutePath());

                Context luceeContext = tomcat.addWebapp(contextPath, warFile.getAbsolutePath());
            }

        }

        tomcat.setPort(Integer.parseInt(serverPort));
        tomcat.setSilent(false);
//        tomcat.setAddDefaultWebXmlToWebapp(false);
        Connector connector = tomcat.getConnector();

        // Add the WAR context
//		Do we need this>? 
        tomcat.getHost().setAppBase(baseDir.getAbsolutePath());

        Runtime.getRuntime().addShutdownHook(addShutdownListener(tomcat));

        // *** Disable TLD scanning ***
        //        StandardJarScanner jarScanner = new StandardJarScanner();
        //        StandardJarScanFilter jarScanFilter = new StandardJarScanFilter();
        //        jarScanFilter.setTldSkip("*.jar"); // Skip scanning for all JARs
        //        jarScanner.setJarScanFilter(jarScanFilter);
        //        context.setJarScanner(jarScanner);
        // Start Tomcat
        tomcat.start();

        // Keep the server running
        tomcat.getServer().await();

    }

    private static Thread addShutdownListener(Tomcat tomcat) {
        return new Thread(() -> {
            try {
                System.out.println("Shutting down Tomcat...");

                tomcat.stop();
                tomcat.destroy();
                System.out.println("Tomcat stopped.");
            } catch (Exception e) {
                System.err.println("Error during Tomcat shutdown: " + e.getMessage());
                e.printStackTrace();
            }
        });
    }

    private static File createTempFileFromStream(InputStream inputStream, String prefix, String suffix)
            throws IOException {
        // Create a temporary file with the specified prefix and suffix
        File tempFile = File.createTempFile(prefix, suffix);
        tempFile.deleteOnExit();

        // Copy the contents of the InputStream to the temporary file
        try (OutputStream outputStream = java.nio.file.Files.newOutputStream(tempFile.toPath())) {
            byte[] buffer = new byte[1024]; // 1KB buffer size
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                outputStream.write(buffer, 0, bytesRead);
            }
        }
        return tempFile;
    }


    public static boolean isRunningFromJar(Class<?> clazz) {
        try {
            URL location = clazz.getProtectionDomain().getCodeSource().getLocation();
            String path = location.getPath();
            return path.endsWith(".jar");
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


}
