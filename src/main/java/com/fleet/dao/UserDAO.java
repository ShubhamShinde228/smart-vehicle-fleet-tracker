package com.fleet.dao;

import com.fleet.model.User;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {
    
    // Update these with your actual database configuration
    private String jdbcURL = "jdbc:mysql://localhost:3306/fleet_db";
    private String jdbcUsername = "root";
    private String jdbcPassword = "shubham@1234";

    protected Connection getConnection() {
        Connection connection = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
        }
        return connection;
    }

    public User authenticate(String email, String password) {
        User user = null;
        String sql = "SELECT u.id, u.email, u.name, r.role_name " +
                     "FROM users u JOIN roles r ON u.role_id = r.id " +
                     "WHERE u.email = ? AND u.password = ?";
        
        try (Connection connection = getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            
            preparedStatement.setString(1, email);
            preparedStatement.setString(2, password);
            
            ResultSet rs = preparedStatement.executeQuery();
            
            if (rs.next()) {
                user = new User();
                user.setId(rs.getInt("id"));
                user.setEmail(rs.getString("email"));
                user.setName(rs.getString("name"));
                user.setRole(rs.getString("role_name"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }
}
