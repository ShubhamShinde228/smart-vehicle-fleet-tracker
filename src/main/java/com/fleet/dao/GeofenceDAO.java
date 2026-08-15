package com.fleet.dao;

import com.fleet.dto.GeofenceAlertView;
import com.fleet.dto.GeofenceView;
import com.fleet.model.Geofence;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GeofenceDAO {
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

    public List<GeofenceView> getAllGeofences() {
        List<GeofenceView> list = new ArrayList<>();
        String sql = "SELECT g.*, v.vehicle_number, v.model AS vehicle_model " +
                     "FROM geofences g JOIN vehicles v ON g.vehicle_id = v.id " +
                     "ORDER BY g.is_active DESC, g.id DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapGeofenceView(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean saveGeofence(Geofence geofence) {
        String sql = "INSERT INTO geofences " +
                     "(vehicle_id, fence_name, center_latitude, center_longitude, radius_km, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, geofence.getVehicleId());
            ps.setString(2, geofence.getFenceName());
            ps.setDouble(3, geofence.getCenterLatitude());
            ps.setDouble(4, geofence.getCenterLongitude());
            ps.setDouble(5, geofence.getRadiusKm());
            ps.setBoolean(6, geofence.isActive());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteGeofence(int id) {
        String sql = "DELETE FROM geofences WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean toggleGeofence(int id, boolean active) {
        String sql = "UPDATE geofences SET is_active = ? WHERE id = ?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setBoolean(1, active);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<GeofenceAlertView> getAlerts(String statusFilter) {
        List<GeofenceAlertView> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT a.*, g.fence_name, v.vehicle_number, v.model AS vehicle_model " +
            "FROM geofence_alerts a " +
            "JOIN geofences g ON a.geofence_id = g.id " +
            "JOIN vehicles v ON a.vehicle_id = v.id WHERE 1=1 ");

        if (statusFilter != null && !statusFilter.trim().isEmpty() && !"All".equals(statusFilter)) {
            sql.append("AND a.status = ? ");
        }
        sql.append("ORDER BY a.created_at DESC");

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            if (statusFilter != null && !statusFilter.trim().isEmpty() && !"All".equals(statusFilter)) {
                ps.setString(1, statusFilter);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapAlertView(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countOpenAlerts() {
        String sql = "SELECT COUNT(*) FROM geofence_alerts WHERE status = 'Open'";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean resolveAlert(int alertId) {
        String sql = "UPDATE geofence_alerts SET status = 'Resolved', resolved_at = CURRENT_TIMESTAMP " +
                     "WHERE id = ? AND status = 'Open'";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, alertId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public void evaluateVehicleLocation(int vehicleId, double latitude, double longitude) {
        String sql = "SELECT * FROM geofences WHERE vehicle_id = ? AND is_active = 1";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    int geofenceId = rs.getInt("id");
                    double centerLat = rs.getDouble("center_latitude");
                    double centerLon = rs.getDouble("center_longitude");
                    double radiusKm = rs.getDouble("radius_km");
                    double distanceKm = calculateDistanceKm(latitude, longitude, centerLat, centerLon);

                    if (distanceKm > radiusKm) {
                        createAlertIfNeeded(con, geofenceId, vehicleId, latitude, longitude, distanceKm, radiusKm);
                    } else {
                        autoResolveAlert(con, geofenceId, vehicleId);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void createAlertIfNeeded(Connection con, int geofenceId, int vehicleId, double latitude,
                                     double longitude, double distanceKm, double radiusKm) throws SQLException {
        String openSql = "SELECT id FROM geofence_alerts " +
                         "WHERE geofence_id = ? AND vehicle_id = ? AND status = 'Open' LIMIT 1";
        try (PreparedStatement open = con.prepareStatement(openSql)) {
            open.setInt(1, geofenceId);
            open.setInt(2, vehicleId);
            try (ResultSet rs = open.executeQuery()) {
                if (rs.next()) return;
            }
        }

        String message = String.format("Vehicle is %.2f km from geofence center. Allowed radius is %.2f km.",
                distanceKm, radiusKm);
        String insertSql = "INSERT INTO geofence_alerts " +
                           "(geofence_id, vehicle_id, latitude, longitude, distance_km, alert_message) " +
                           "VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement insert = con.prepareStatement(insertSql)) {
            insert.setInt(1, geofenceId);
            insert.setInt(2, vehicleId);
            insert.setDouble(3, latitude);
            insert.setDouble(4, longitude);
            insert.setDouble(5, distanceKm);
            insert.setString(6, message);
            insert.executeUpdate();
        }
    }

    private void autoResolveAlert(Connection con, int geofenceId, int vehicleId) throws SQLException {
        String sql = "UPDATE geofence_alerts SET status = 'Resolved', resolved_at = CURRENT_TIMESTAMP " +
                     "WHERE geofence_id = ? AND vehicle_id = ? AND status = 'Open'";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, geofenceId);
            ps.setInt(2, vehicleId);
            ps.executeUpdate();
        }
    }

    private double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
        final double earthRadiusKm = 6371.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadiusKm * c;
    }

    private GeofenceView mapGeofenceView(ResultSet rs) throws SQLException {
        GeofenceView g = new GeofenceView();
        g.setId(rs.getInt("id"));
        g.setVehicleId(rs.getInt("vehicle_id"));
        g.setFenceName(rs.getString("fence_name"));
        g.setCenterLatitude(rs.getDouble("center_latitude"));
        g.setCenterLongitude(rs.getDouble("center_longitude"));
        g.setRadiusKm(rs.getDouble("radius_km"));
        g.setActive(rs.getBoolean("is_active"));
        g.setCreatedAt(rs.getTimestamp("created_at"));
        g.setVehicleNumber(rs.getString("vehicle_number"));
        g.setVehicleModel(rs.getString("vehicle_model"));
        return g;
    }

    private GeofenceAlertView mapAlertView(ResultSet rs) throws SQLException {
        GeofenceAlertView a = new GeofenceAlertView();
        a.setId(rs.getInt("id"));
        a.setGeofenceId(rs.getInt("geofence_id"));
        a.setVehicleId(rs.getInt("vehicle_id"));
        a.setLatitude(rs.getDouble("latitude"));
        a.setLongitude(rs.getDouble("longitude"));
        a.setDistanceKm(rs.getDouble("distance_km"));
        a.setAlertMessage(rs.getString("alert_message"));
        a.setStatus(rs.getString("status"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setResolvedAt(rs.getTimestamp("resolved_at"));
        a.setFenceName(rs.getString("fence_name"));
        a.setVehicleNumber(rs.getString("vehicle_number"));
        a.setVehicleModel(rs.getString("vehicle_model"));
        return a;
    }
}
