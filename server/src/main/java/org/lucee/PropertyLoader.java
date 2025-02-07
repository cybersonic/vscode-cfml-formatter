package org.lucee;

import java.io.InputStream;
import java.io.IOException;
import java.util.Properties;
import java.util.logging.LogManager;

public class PropertyLoader {

    public static void loadProperties(String filePath) throws IOException {
        Properties properties = new Properties();
        try (InputStream fis = PropertyLoader.class.getResourceAsStream(filePath)) {
            properties.load(fis);
        }

        // Set system properties
        for (String key : properties.stringPropertyNames()) {
            System.setProperty(key, properties.getProperty(key));
        }
    }

    public static void loadLoggingProperties(String filePath) throws IOException {
        try (InputStream fis = PropertyLoader.class.getResourceAsStream(filePath)) {
            LogManager.getLogManager().readConfiguration(fis);
        }
    }
}
