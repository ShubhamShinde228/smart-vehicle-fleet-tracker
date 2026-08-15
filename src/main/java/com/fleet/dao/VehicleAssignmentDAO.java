package com.fleet.dao;

import com.fleet.model.Driver;
import com.fleet.model.Vehicle;
import com.fleet.model.VehicleAssignment;
import com.fleet.dto.VehicleAssignmentView;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VehicleAssignmentDAO {

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

    // ── Helper: map full JOIN row → VehicleAssignment ────────────────────────
    private VehicleAssignmentView mapAssignmentView(ResultSet rs) throws SQLException {
        VehicleAssignmentView a = new VehicleAssignmentView();
        a.setId(rs.getInt("id"));
        a.setVehicleId(rs.getInt("vehicle_id"));
        a.setDriverId(rs.getInt("driver_id"));
        a.setAssignedBy(rs.getInt("assigned_by"));
        a.setStartDate(rs.getDate("start_date"));
        a.setEndDate(rs.getDate("end_date"));
        a.setNotes(rs.getString("notes"));
        a.setVehicleNumber(rs.getString("vehicle_number"));
        a.setVehicleModel(rs.getString("vehicle_model"));
        a.setVehicleType(rs.getString("vehicle_type"));
        a.setDriverName(rs.getString("driver_name"));
        a.setDriverEmail(rs.getString("driver_email"));
        a.setDriverLicense(rs.getString("driver_license"));
        a.setAssignedByName(rs.getString("assigned_by_name"));
        return a;
    }

    private static final String BASE_SELECT =
        "SELECT va.id, va.vehicle_id, va.driver_id, va.assigned_by, " +
        "       va.start_date, va.end_date, va.notes, " +
        "       v.vehicle_number, v.model AS vehicle_model, v.vehicle_type, " +
        "       d.name AS driver_name, d.email AS driver_email, d.license_number AS driver_license, " +
        "       u.name AS assigned_by_name " +
        "FROM vehicle_assignments va " +
        "JOIN vehicles v ON va.vehicle_id = v.id " +
        "JOIN drivers  d ON va.driver_id  = d.id " +
        "LEFT JOIN users u ON va.assigned_by = u.id ";

    // ── READ: active assignments ─────────────────────────────────────────────
    public List<VehicleAssignmentView> getActiveAssignments() {
        List<VehicleAssignmentView> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE va.end_date IS NULL ORDER BY va.start_date DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapAssignmentView(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── READ: assignment history (filtered) ──────────────────────────────────
    public List<VehicleAssignmentView> getAssignmentHistory(String statusFilter) {
        List<VehicleAssignmentView> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT).append("WHERE 1=1 ");
        if ("Active".equals(statusFilter))    sql.append("AND va.end_date IS NULL ");
        if ("Completed".equals(statusFilter)) sql.append("AND va.end_date IS NOT NULL ");
        sql.append("ORDER BY va.start_date DESC");
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString());
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapAssignmentView(rs));
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // ── CREATE: assign vehicle to driver ─────────────────────────────────────
    public boolean assignVehicle(VehicleAssignment a) {
        String sql = "INSERT INTO vehicle_assignments " +
                     "(vehicle_id, driver_id, assigned_by, start_date, notes) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, a.getVehicleId());
            ps.setInt(2, a.getDriverId());
            ps.setInt(3, a.getAssignedBy());
            ps.setDate(4, a.getStartDate());
            ps.setString(5, a.getNotes());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── UPDATE: unassign (set end_date to today) ─────────────────────────────
    public boolean unassignVehicle(int assignmentId, Date endDate) {
        String sql = "UPDATE vehicle_assignments SET end_date = ? WHERE id = ? AND end_date IS NULL";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setDate(1, endDate);
            ps.setInt(2, assignmentId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── VALIDATION: vehicle already has an active assignment? ────────────────
    public boolean isVehicleAssigned(int vehicleId) {
        String sql = "SELECT COUNT(*) FROM vehicle_assignments WHERE vehicle_id = ? AND end_date IS NULL";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── VALIDATION: driver already has an active assignment? ─────────────────
    public boolean isDriverAssigned(int driverId) {
        String sql = "SELECT COUNT(*) FROM vehicle_assignments WHERE driver_id = ? AND end_date IS NULL";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, driverId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // ── Lookup: available (Active + unassigned) vehicles for dropdown ─────────
    public List<Vehicle> getAvailableVehicles() {
        List<Vehicle> vehicles = new ArrayList<>();
        String sql = "SELECT * FROM vehicles WHERE status = 'Active' " +
                     "AND id NOT IN (SELECT vehicle_id FROM vehicle_assignments WHERE end_date IS NULL) " +
                     "ORDER BY vehicle_number";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Vehicle v = new Vehicle();
                v.setId(rs.getInt("id"));
                v.setVehicleNumber(rs.getString("vehicle_number"));
                v.setModel(rs.getString("model"));
                v.setVehicleType(rs.getString("vehicle_type"));
                vehicles.add(v);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return vehicles;
    }

    // ── Lookup: available (Active + unassigned) drivers for dropdown ──────────
    public List<Driver> getAvailableDrivers() {
        List<Driver> drivers = new ArrayList<>();
        String sql = "SELECT * FROM drivers WHERE status = 'Active' " +
                     "AND id NOT IN (SELECT driver_id FROM vehicle_assignments WHERE end_date IS NULL) " +
                     "ORDER BY name";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Driver d = new Driver();
                d.setId(rs.getInt("id"));
                d.setName(rs.getString("name"));
                d.setEmail(rs.getString("email"));
                d.setLicenseNumber(rs.getString("license_number"));
                drivers.add(d);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return drivers;
    }

    // ── Stats helper ─────────────────────────────────────────────────────────
    public int countActiveAssignments() {
        String sql = "SELECT COUNT(*) FROM vehicle_assignments WHERE end_date IS NULL";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
