package org.ecocean.rest;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.web.SpringBootServletInitializer;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableAutoConfiguration
@ComponentScan
public class RestApplication extends SpringBootServletInitializer {
    /**
     *  This method should allow you to start up the rest service from a compiled jar rather
     *  than having to make a war and stick it in tomcat.
     */
    public static void main(final String[] args) {
        SpringApplication.run(RestApplication.class, args);
    }

    @Override
    protected final SpringApplicationBuilder configure(final SpringApplicationBuilder application) {
        return application.sources(RestApplication.class);
    }
}
