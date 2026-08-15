package com.fleet.dao;

import com.fleet.model.Vehicle;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VehicleDAO {

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

    // ── Helper: map ResultSet row → Vehicle ─────────────────────────────────
    private Vehicle mapVehicle(ResultSet rs) throws SQLException {
        Vehicle v = new Vehicle();
        v.setId(rs.getInt("id"));
        v.setVehicleNumber(rs.getString("vehicle_number"));
        v.setModel(rs.getString("model"));
        v.setVehicleType(rs.getString("vehicle_type"));
        v.setFuelType(rs.getString("fuel_type"));
        v.setFuelCapacity(rs.getDouble("fuel_capacity"));
        v.setRegistrationDate(rs.getDate("registration_date"));
        v.setInsuranceExpiry(rs.getDate("insurance_expiry"));
        v.setMaintenanceDueDate(rs.getDate("maintenance_due_date"));
        v.setStatus(rs.getString("status"));
        return v;
    }

    // ── READ: all vehicles ───────────────────────────────────────────────────
    public List<Vehicle> getAllVehicles() {
        return searchVehicles(null, null, null);
    }

    // ── READ: filtered search ───────────────────────────────────────────────
    public List<Vehicle> searchVehicles(String search, String status, String type) {
        List<Vehicle> vehicles = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM vehicles WHERE 1=1");
        List<String> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (vehicle_number LIKE ? OR model LIKE ?)");
            params.add("%" + search.trim() + "%");
            params.add("%" + search.trim() + "%");
        }
        if (status != null && !status.trim().isEmpty() && !status.equals("All")) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        }
        if (type != null && !type.trim().isEmpty() && !type.equals("All")) {
            sql.append(" AND vehicle_type = ?");
            params.add(type.trim());
        }
        sql.append(" ORDER BY id DESC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                vehicles.add(mapVehicle(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return vehicles;
    }

    // ── READ: single vehicle by ID ──────────────────────────────────────────
    public Vehicle getVehicleById(int id) {
        String sql = "SELECT * FROM vehicles WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapVehicle(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ── CREATE ──────────────────────────────────────────────────────────────
    public boolean addVehicle(Vehicle v) {
        String sql = "INSERT INTO vehicles (vehicle_number, model, vehicle_type, fuel_type, " +
                     "fuel_capacity, registration_date, insurance_expiry, maintenance_due_date, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, v.getVehicleNumber());
            ps.setString(2, v.getModel());
            ps.setString(3, v.getVehicleType());
            ps.setString(4, v.getFuelType());
            ps.setDouble(5, v.getFuelCapacity());
            ps.setDate(6, v.getRegistrationDate());
            ps.setDate(7, v.getInsuranceExpiry());
            ps.setDate(8, v.getMaintenanceDueDate());
            ps.setString(9, v.getStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── UPDATE ──────────────────────────────────────────────────────────────
    public boolean updateVehicle(Vehicle v) {
        String sql = "UPDATE vehicles SET vehicle_number=?, model=?, vehicle_type=?, fuel_type=?, " +
                     "fuel_capacity=?, registration_date=?, insurance_expiry=?, " +
                     "maintenance_due_date=?, status=? WHERE id=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, v.getVehicleNumber());
            ps.setString(2, v.getModel());
            ps.setString(3, v.getVehicleType());
            ps.setString(4, v.getFuelType());
            ps.setDouble(5, v.getFuelCapacity());
            ps.setDate(6, v.getRegistrationDate());
            ps.setDate(7, v.getInsuranceExpiry());
            ps.setDate(8, v.getMaintenanceDueDate());
            ps.setString(9, v.getStatus());
            ps.setInt(10, v.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── DELETE ──────────────────────────────────────────────────────────────
    public boolean deleteVehicle(int id) {
        String sql = "DELETE FROM vehicles WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── VALIDATION: unique vehicle number (for ADD) ─────────────────────────
    public boolean isVehicleNumberExists(String vehicleNumber) {
        String sql = "SELECT COUNT(*) FROM vehicles WHERE vehicle_number = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, vehicleNumber);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── VALIDATION: unique vehicle number (for UPDATE, excludes self) ───────
    public boolean isVehicleNumberExists(String vehicleNumber, int excludeId) {
        String sql = "SELECT COUNT(*) FROM vehicles WHERE vehicle_number = ? AND id != ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, vehicleNumber);
            ps.setInt(2, excludeId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
