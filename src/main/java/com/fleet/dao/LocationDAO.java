package com.fleet.dao;

import com.fleet.dto.VehicleLocationView;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LocationDAO {

    protected Connection getConnection() throws SQLException {
        return DBConnection.getConnection();
    }

    public boolean insertLocation(int vehicleId, double lat, double lon, double speed) {
        return insertLocation(vehicleId, lat, lon, speed, "gps-api");
    }

    public boolean insertLocation(int vehicleId, double lat, double lon, double speed, String apiSource) {
        String driverSql = "SELECT driver_id FROM vehicle_assignments " +
                           "WHERE vehicle_id = ? AND end_date IS NULL LIMIT 1";
        String insertSql = "INSERT INTO vehicle_locations " +
                           "(vehicle_id, driver_id, latitude, longitude, speed, api_source) " +
                           "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection con = getConnection()) {
            if (con == null) return false;

            int driverId;
            try (PreparedStatement ps = con.prepareStatement(driverSql)) {
                ps.setInt(1, vehicleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) return false;
                    driverId = rs.getInt("driver_id");
                }
            }

            try (PreparedStatement ps = con.prepareStatement(insertSql)) {
                ps.setInt(1, vehicleId);
                ps.setInt(2, driverId);
                ps.setDouble(3, lat);
                ps.setDouble(4, lon);
                ps.setDouble(5, speed);
                ps.setString(6, apiSource == null || apiSource.trim().isEmpty()
                        ? "gps-api" : apiSource.trim());
                boolean inserted = ps.executeUpdate() > 0;
                if (inserted) {
                    insertLegacyLocation(con, vehicleId, lat, lon, speed);
                    new GeofenceDAO().evaluateVehicleLocation(vehicleId, lat, lon);
                }
                return inserted;
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private void insertLegacyLocation(Connection con, int vehicleId, double lat, double lon, double speed) {
        String sql = "INSERT INTO vehicle_location (vehicle_id, latitude, longitude, speed) VALUES (?, ?, ?, ?)";

        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, vehicleId);
            ps.setDouble(2, lat);
            ps.setDouble(3, lon);
            ps.setDouble(4, speed);
            ps.executeUpdate();
        } catch (Exception ignored) {
            // Some setups only have the newer vehicle_locations table.
        }
    }

    public List<VehicleLocationView> getLiveLocation() {
        List<VehicleLocationView> list = new ArrayList<>();
        String sql =
            "SELECT vl.vehicle_id, vl.latitude, vl.longitude, vl.speed, vl.timestamp, vl.api_source, " +
            "       v.vehicle_number, v.model AS vehicle_model, d.name AS driver_name " +
            "FROM vehicle_locations vl " +
            "JOIN (SELECT vehicle_id, MAX(timestamp) AS latest_time " +
            "      FROM vehicle_locations GROUP BY vehicle_id) latest " +
            "  ON latest.vehicle_id = vl.vehicle_id AND latest.latest_time = vl.timestamp " +
            "JOIN vehicles v ON vl.vehicle_id = v.id " +
            "JOIN drivers d ON vl.driver_id = d.id " +
            "ORDER BY vl.timestamp DESC";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapLocationView(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<VehicleLocationView> getVehicleHistory(int vehicleId, Timestamp startDate,
                                                   Timestamp endDate, int limit) {
        List<VehicleLocationView> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT vl.vehicle_id, vl.latitude, vl.longitude, vl.speed, vl.timestamp, vl.api_source, " +
            "       v.vehicle_number, v.model AS vehicle_model, d.name AS driver_name " +
            "FROM vehicle_locations vl " +
            "JOIN vehicles v ON vl.vehicle_id = v.id " +
            "JOIN drivers d ON vl.driver_id = d.id " +
            "WHERE vl.vehicle_id = ? ");
        List<Timestamp> dateParams = new ArrayList<>();

        if (startDate != null) {
            sql.append("AND vl.timestamp >= ? ");
            dateParams.add(startDate);
        }
        if (endDate != null) {
            sql.append("AND vl.timestamp <= ? ");
            dateParams.add(endDate);
        }
        sql.append("ORDER BY vl.timestamp DESC LIMIT ?");

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            ps.setInt(1, vehicleId);
            int index = 2;
            for (Timestamp dateParam : dateParams) {
                ps.setTimestamp(index++, dateParam);
            }
            ps.setInt(index, Math.max(1, Math.min(limit, 500)));

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(0, mapLocationView(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean validateApiKey(String apiKey) {
        if (apiKey == null) return false;

        String sql = "SELECT id FROM gps_api_keys WHERE api_key = ? AND is_active = 1";
        String updateSql = "UPDATE gps_api_keys SET last_used = CURRENT_TIMESTAMP WHERE api_key = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, apiKey.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return false;
            }

            try (PreparedStatement update = con.prepareStatement(updateSql)) {
                update.setString(1, apiKey.trim());
                update.executeUpdate();
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Object[]> getAllApiKeys() {
        List<Object[]> keys = new ArrayList<>();
        String sql = "SELECT id, api_key, key_name, is_active, created_at, last_used " +
                     "FROM gps_api_keys ORDER BY id";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                keys.add(new Object[] {
                    rs.getInt("id"),
                    rs.getString("api_key"),
                    rs.getString("key_name"),
                    rs.getBoolean("is_active"),
                    rs.getTimestamp("created_at"),
                    rs.getTimestamp("last_used")
                });
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return keys;
    }

    private VehicleLocationView mapLocationView(ResultSet rs) throws SQLException {
        VehicleLocationView loc = new VehicleLocationView();
        loc.setVehicleId(rs.getInt("vehicle_id"));
        loc.setLatitude(rs.getDouble("latitude"));
        loc.setLongitude(rs.getDouble("longitude"));
        loc.setSpeed(rs.getDouble("speed"));
        loc.setTimestamp(rs.getTimestamp("timestamp"));
        loc.setApiSource(rs.getString("api_source"));
        loc.setVehicleNumber(rs.getString("vehicle_number"));
        loc.setVehicleModel(rs.getString("vehicle_model"));
        loc.setDriverName(rs.getString("driver_name"));
        return loc;
    }
}
