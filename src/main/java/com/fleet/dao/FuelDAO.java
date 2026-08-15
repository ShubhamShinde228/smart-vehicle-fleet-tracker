package com.fleet.dao;

import com.fleet.model.FuelLog;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class FuelDAO extends UserDAO {

    // ── CREATE ───────────────────────────────────────────────────────────────

    public boolean addFuelLog(FuelLog log) throws SQLException {
        String sql = "INSERT INTO fuel_logs (vehicle_id, fill_date, liters, cost_per_liter, " +
                     "total_cost, odometer_km, fuel_station, notes) VALUES (?,?,?,?,?,?,?,?)";
        try (Connection c = getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1,    log.getVehicleId());
            ps.setDate(2,   log.getFillDate());
            ps.setDouble(3, log.getLiters());
            ps.setDouble(4, log.getCostPerLiter());
            ps.setDouble(5, log.getTotalCost());
            ps.setDouble(6, log.getOdometerKm());
            ps.setString(7, log.getFuelStation());
            ps.setString(8, log.getNotes());
            return ps.executeUpdate() > 0;
        }
    }

    // ── READ – All logs (with vehicle info joined) ───────────────────────────

    public List<FuelLog> getAllFuelLogs(String vehicleFilter, String monthFilter) {
        List<FuelLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT f.*, v.vehicle_number, v.model " +
            "FROM fuel_logs f JOIN vehicles v ON f.vehicle_id = v.id WHERE 1=1 ");
        if (vehicleFilter != null && !vehicleFilter.isEmpty() && !"All".equals(vehicleFilter))
            sql.append("AND f.vehicle_id = ").append(Integer.parseInt(vehicleFilter)).append(" ");
        if (monthFilter != null && !monthFilter.isEmpty() && !"All".equals(monthFilter))
            sql.append("AND DATE_FORMAT(f.fill_date,'%Y-%m') = '").append(monthFilter.replace("'","''")).append("' ");
        sql.append("ORDER BY f.fill_date DESC");

        try (Connection c = getConnection();
             Statement st = c.createStatement();
             ResultSet rs = st.executeQuery(sql.toString())) {
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ── READ – Single log ────────────────────────────────────────────────────

    public FuelLog getFuelLogById(int id) {
        String sql = "SELECT f.*, v.vehicle_number, v.model FROM fuel_logs f " +
                     "JOIN vehicles v ON f.vehicle_id = v.id WHERE f.id = ?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // ── UPDATE ───────────────────────────────────────────────────────────────

    public boolean updateFuelLog(FuelLog log) {
        String sql = "UPDATE fuel_logs SET vehicle_id=?, fill_date=?, liters=?, cost_per_liter=?, " +
                     "total_cost=?, odometer_km=?, fuel_station=?, notes=? WHERE id=?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1,    log.getVehicleId());
            ps.setDate(2,   log.getFillDate());
            ps.setDouble(3, log.getLiters());
            ps.setDouble(4, log.getCostPerLiter());
            ps.setDouble(5, log.getTotalCost());
            ps.setDouble(6, log.getOdometerKm());
            ps.setString(7, log.getFuelStation());
            ps.setString(8, log.getNotes());
            ps.setInt(9,    log.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ── DELETE ───────────────────────────────────────────────────────────────

    public boolean deleteFuelLog(int id) {
        String sql = "DELETE FROM fuel_logs WHERE id = ?";
        try (Connection c = getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ── ANALYTICS ────────────────────────────────────────────────────────────

    /** Total spend per month for the last 6 months – returns {month -> totalCost} */
    public Map<String, Double> getMonthlySpend() {
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT DATE_FORMAT(fill_date,'%b %Y') AS mo, " +
                     "SUM(total_cost) AS spend " +
                     "FROM fuel_logs " +
                     "WHERE fill_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
                     "GROUP BY DATE_FORMAT(fill_date,'%Y-%m') " +
                     "ORDER BY MIN(fill_date)";
        try (Connection c = getConnection(); Statement st = c.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) map.put(rs.getString("mo"), rs.getDouble("spend"));
        } catch (SQLException e) { e.printStackTrace(); }
        return map;
    }

    /** Total liters per month for the last 6 months */
    public Map<String, Double> getMonthlyLiters() {
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT DATE_FORMAT(fill_date,'%b %Y') AS mo, " +
                     "SUM(liters) AS ltr " +
                     "FROM fuel_logs " +
                     "WHERE fill_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH) " +
                     "GROUP BY DATE_FORMAT(fill_date,'%Y-%m') " +
                     "ORDER BY MIN(fill_date)";
        try (Connection c = getConnection(); Statement st = c.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) map.put(rs.getString("mo"), rs.getDouble("ltr"));
        } catch (SQLException e) { e.printStackTrace(); }
        return map;
    }

    /** Per-vehicle summary: total liters, total cost, km driven, efficiency (km/L) */
    public List<Map<String, Object>> getVehicleEfficiency() {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql =
            "SELECT v.vehicle_number, v.model, " +
            "  SUM(f.liters) AS total_liters, " +
            "  SUM(f.total_cost) AS total_cost, " +
            "  (MAX(f.odometer_km) - MIN(f.odometer_km)) AS km_driven, " +
            "  CASE WHEN SUM(f.liters) > 0 " +
            "       THEN ROUND((MAX(f.odometer_km) - MIN(f.odometer_km)) / SUM(f.liters), 2) " +
            "       ELSE 0 END AS efficiency " +
            "FROM fuel_logs f " +
            "JOIN vehicles v ON f.vehicle_id = v.id " +
            "GROUP BY f.vehicle_id, v.vehicle_number, v.model " +
            "ORDER BY efficiency DESC";
        try (Connection c = getConnection(); Statement st = c.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("vehicleNumber", rs.getString("vehicle_number"));
                row.put("model",         rs.getString("model"));
                row.put("totalLiters",   rs.getDouble("total_liters"));
                row.put("totalCost",     rs.getDouble("total_cost"));
                row.put("kmDriven",      rs.getDouble("km_driven"));
                row.put("efficiency",    rs.getDouble("efficiency"));
                rows.add(row);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return rows;
    }

    /** Summary stats for KPI cards */
    public Map<String, Double> getSummaryStats() {
        Map<String, Double> stats = new LinkedHashMap<>();
        String sql = "SELECT SUM(total_cost) AS total_spend, " +
                     "SUM(liters) AS total_liters, " +
                     "AVG(cost_per_liter) AS avg_price, " +
                     "COUNT(*) AS total_entries " +
                     "FROM fuel_logs";
        try (Connection c = getConnection(); Statement st = c.createStatement(); ResultSet rs = st.executeQuery(sql)) {
            if (rs.next()) {
                stats.put("totalSpend",   rs.getDouble("total_spend"));
                stats.put("totalLiters",  rs.getDouble("total_liters"));
                stats.put("avgPrice",     rs.getDouble("avg_price"));
                stats.put("totalEntries", rs.getDouble("total_entries"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return stats;
    }

    // ── private mapper ───────────────────────────────────────────────────────

    private FuelLog mapRow(ResultSet rs) throws SQLException {
        FuelLog f = new FuelLog();
        f.setId(rs.getInt("id"));
        f.setVehicleId(rs.getInt("vehicle_id"));
        f.setVehicleNumber(rs.getString("vehicle_number"));
        f.setVehicleModel(rs.getString("model"));
        f.setFillDate(rs.getDate("fill_date"));
        f.setLiters(rs.getDouble("liters"));
        f.setCostPerLiter(rs.getDouble("cost_per_liter"));
        f.setTotalCost(rs.getDouble("total_cost"));
        f.setOdometerKm(rs.getDouble("odometer_km"));
        f.setFuelStation(rs.getString("fuel_station"));
        f.setNotes(rs.getString("notes"));
        f.setCreatedAt(rs.getTimestamp("created_at"));
        return f;
    }
}
