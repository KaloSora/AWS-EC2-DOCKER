package com.example;

import java.util.Date;

public class App {
    public static void main(String[] args) {
        System.out.println("=== Docker Java Application ===");
        System.out.println("Java Version: " + System.getProperty("java.version"));
        System.out.println("JVM Vendor: " + System.getProperty("java.vendor"));
        System.out.println("OS: " + System.getProperty("os.name"));
        System.out.println("Start Time: " + new Date());

        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.out.println("\nApplication is shutting down...");
            System.out.println("End Time: " + new Date());
        }));
        
        try {
            System.out.println("\nApplication will run for 20 seconds...");
            for (int i = 1; i <= 20; i++) {
                Thread.sleep(10000);
                System.out.print(".");
                if (i % 10 == 0) System.out.print(" " + i + "s");
            }
            System.out.println("\n\nApplication completed successfully!");
        } catch (InterruptedException e) {
            System.out.println("\nApplication was interrupted!");
            Thread.currentThread().interrupt();
        }
    }
}