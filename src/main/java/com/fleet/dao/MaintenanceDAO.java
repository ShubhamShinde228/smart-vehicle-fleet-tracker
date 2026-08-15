package com.fleet.dao;

import com.fleet.model.MaintenanceNotification;
import com.fleet.model.Vehicle;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MaintenanceDAO {
    private String jdbcURL = "jdbc:mysql://localhost:3306/fleet_db";
    private String jdbcUsername = "root";
    private String jdbcPassword = "shubham@1234";

    protected Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);
        } catch (SQLException | ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }

    public List<MaintenanceNotification> getNotifications(String statusFilter, String vehicleFilter) {
        List<MaintenanceNotification> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT mn.*, v.vehicle_number, v.model AS vehicle_model, u.name AS created_by_name " +
                "FROM maintenance_notifications mn " +
                "JOIN vehicles v ON mn.vehicle_id = v.id " +
                "LEFT JOIN users u ON mn.created_by = u.id WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"All".equals(statusFilter)) {
            sql.append("AND mn.status = ? ");
            params.add(statusFilter.trim());
        }
        if (vehicleFilter != null && !vehicleFilter.trim().isEmpty() && !"All".equals(vehicleFilter)) {
            sql.append("AND mn.vehicle_id = ? ");
            params.add(Integer.parseInt(vehicleFilter.trim()));
        }
        sql.append("ORDER BY FIELD(mn.status, 'Open', 'Scheduled', 'Completed', 'Cancelled'), mn.due_date ASC, mn.id DESC");

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapNotification(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Vehicle> getVehiclesDueSoon(int daysAhead) {
        List<Vehicle> list = new ArrayList<>();
        String sql = "SELECT * FROM vehicles " +
                     "WHERE maintenance_due_date IS NOT NULL " +
                     "AND maintenance_due_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY) " +
                     "ORDER BY maintenance_due_date ASC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, Math.max(0, daysAhead));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
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
                    list.add(v);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addNotification(MaintenanceNotification notification) {
        String sql = "INSERT INTO maintenance_notifications " +
                     "(vehicle_id, title, description, due_date, priority, status, created_by, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, notification.getVehicleId());
            ps.setString(2, notification.getTitle());
            ps.setString(3, notification.getDescription());
            ps.setDate(4, notification.getDueDate());
            ps.setString(5, notification.getPriority());
            ps.setString(6, notification.getStatus());
            if (notification.getCreatedBy() == null) {
                ps.setNull(7, Types.INTEGER);
            } else {
                ps.setInt(7, notification.getCreatedBy());
            }
            ps.setString(8, notification.getNotes());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateStatus(int id, String status) {
        String sql = "UPDATE maintenance_notifications " +
                     "SET status = ?, completed_at = CASE WHEN ? = 'Completed' THEN CURRENT_TIMESTAMP ELSE completed_at END " +
                     "WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, status);
            ps.setInt(3, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteNotification(int id) {
        String sql = "DELETE FROM maintenance_notifications WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public int countOpenNotifications() {
        String sql = "SELECT COUNT(*) FROM maintenance_notifications WHERE status IN ('Open', 'Scheduled')";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int countDueVehicleMaintenance(int daysAhead) {
        String sql = "SELECT COUNT(*) FROM vehicles " +
                     "WHERE maintenance_due_date IS NOT NULL " +
                     "AND maintenance_due_date <= DATE_ADD(CURDATE(), INTERVAL ? DAY)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, Math.max(0, daysAhead));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private MaintenanceNotification mapNotification(ResultSet rs) throws SQLException {
        MaintenanceNotification n = new MaintenanceNotification();
        n.setId(rs.getInt("id"));
        n.setVehicleId(rs.getInt("vehicle_id"));
        n.setVehicleNumber(rs.getString("vehicle_number"));
        n.setVehicleModel(rs.getString("vehicle_model"));
        n.setTitle(rs.getString("title"));
        n.setDescription(rs.getString("description"));
        n.setDueDate(rs.getDate("due_date"));
        n.setPriority(rs.getString("priority"));
        n.setStatus(rs.getString("status"));
        int createdBy = rs.getInt("created_by");
        n.setCreatedBy(rs.wasNull() ? null : createdBy);
        n.setCreatedByName(rs.getString("created_by_name"));
        n.setCreatedAt(rs.getTimestamp("created_at"));
        n.setCompletedAt(rs.getTimestamp("completed_at"));
        n.setNotes(rs.getString("notes"));
        return n;
    }
}
