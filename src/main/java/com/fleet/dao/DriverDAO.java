package com.fleet.dao;

import com.fleet.model.Driver;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DriverDAO {

    private String jdbcURL      = "jdbc:mysql://localhost:3306/fleet_db";
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

    // ── Helper: map ResultSet row → Driver ───────────────────────────────
    private Driver mapDriver(ResultSet rs) throws SQLException {
        Driver d = new Driver();
        d.setId(rs.getInt("id"));
        d.setName(rs.getString("name"));
        d.setEmail(rs.getString("email"));
        d.setPhone(rs.getString("phone"));
        d.setAddress(rs.getString("address"));
        d.setLicenseNumber(rs.getString("license_number"));
        d.setLicenseExpiry(rs.getDate("license_expiry"));
        d.setEmergencyContact(rs.getString("emergency_contact"));
        d.setStatus(rs.getString("status"));
        return d;
    }

    // ── READ: all drivers ────────────────────────────────────────────────────
    public List<Driver> getAllDrivers() {
        return searchDrivers(null, null);
    }

    // ── READ: filtered search ────────────────────────────────────────────────
    public List<Driver> searchDrivers(String search, String status) {
        List<Driver> drivers = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM drivers WHERE 1=1");
        List<String> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (name LIKE ? OR license_number LIKE ? OR email LIKE ?)");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (status != null && !status.trim().isEmpty() && !status.equals("All")) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        }
        sql.append(" ORDER BY id DESC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                drivers.add(mapDriver(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return drivers;
    }

    // ── READ: single driver by ID ────────────────────────────────────────────
    public Driver getDriverById(int id) {
        String sql = "SELECT * FROM drivers WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapDriver(rs);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ── CREATE ───────────────────────────────────────────────────────────────
    public boolean addDriver(Driver d) {
        String sql = "INSERT INTO drivers (name, email, phone, address, license_number, " +
                     "license_expiry, emergency_contact, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, d.getName());
            ps.setString(2, d.getEmail());
            ps.setString(3, d.getPhone());
            ps.setString(4, d.getAddress());
            ps.setString(5, d.getLicenseNumber());
            ps.setDate(6, d.getLicenseExpiry());
            ps.setString(7, d.getEmergencyContact());
            ps.setString(8, d.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── UPDATE ───────────────────────────────────────────────────────────────
    public boolean updateDriver(Driver d) {
        String sql = "UPDATE drivers SET name=?, email=?, phone=?, address=?, license_number=?, " +
                     "license_expiry=?, emergency_contact=?, status=? WHERE id=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, d.getName());
            ps.setString(2, d.getEmail());
            ps.setString(3, d.getPhone());
            ps.setString(4, d.getAddress());
            ps.setString(5, d.getLicenseNumber());
            ps.setDate(6, d.getLicenseExpiry());
            ps.setString(7, d.getEmergencyContact());
            ps.setString(8, d.getStatus());
            ps.setInt(9, d.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── DELETE ───────────────────────────────────────────────────────────────
    public boolean deleteDriver(int id) {
        String sql = "DELETE FROM drivers WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── VALIDATION: unique license number (for ADD) ──────────────────────────
    public boolean isLicenseNumberExists(String licenseNumber) {
        String sql = "SELECT COUNT(*) FROM drivers WHERE license_number = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, licenseNumber);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── VALIDATION: unique license number (for UPDATE, excludes self) ────────
    public boolean isLicenseNumberExists(String licenseNumber, int excludeId) {
        String sql = "SELECT COUNT(*) FROM drivers WHERE license_number = ? AND id != ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, licenseNumber);
            ps.setInt(2, excludeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
