package com.fleet.dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    public static Connection getConnection() throws SQLException {
        String dbUrl = System.getenv("DB_URL");
        String dbUsername = System.getenv("DB_USERNAME");
        String dbPassword = System.getenv("DB_PASSWORD");

        if (dbUrl == null || dbUrl.trim().isEmpty() ||
            dbUsername == null || dbUsername.trim().isEmpty() ||
            dbPassword == null || dbPassword.trim().isEmpty()) {
            throw new SQLException("Database environment variables DB_URL, DB_USERNAME, and DB_PASSWORD must be configured.");
        }

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found.", e);
        }

        Connection conn = DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
        if (conn == null) {
            throw new SQLException("DriverManager returned a null connection.");
        }
        return conn;
    }
}