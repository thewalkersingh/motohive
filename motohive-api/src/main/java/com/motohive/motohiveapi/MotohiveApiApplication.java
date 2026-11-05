package com.motohive.motohiveapi;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class MotohiveApiApplication {
	
	public static void main(String[] args) {
		SpringApplication.run(MotohiveApiApplication.class, args);
		System.out.println("+----------------------------------+");
		System.out.println("|     (•_•)   App Started...!!     |");
		System.out.println("+----------------------------------+");
		
	}
	
}