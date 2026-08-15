package com.fleet.model;

public class User {
    private int id;
    private String email;
    private String role; // Admin, Manager, Driver
    private String name;

    public User() {}

    public User(int id, String email, String role, String name) {
        this.id = id;
        this.email = email;
        this.role = role;
        this.name = name;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
}
