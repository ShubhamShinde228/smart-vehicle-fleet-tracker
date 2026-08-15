package com.fleet.dao;

import com.fleet.model.TraccarPosition;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class TraccarDAO {

    
    protected Connection getConnection() throws Exception {
        return DBConnection.getConnection();
    }

    public List<TraccarPosition> getLatestPositions() {
        List<TraccarPosition> positions = new ArrayList<>();

        String sql = "SELECT * FROM vehicle_location ORDER BY fixtime DESC";

        try (Connection connection = getConnection();
             PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                TraccarPosition pos = new TraccarPosition();
                pos.setLatitude(rs.getDouble("latitude"));
                pos.setLongitude(rs.getDouble("longitude"));
                pos.setSpeed(rs.getDouble("speed"));
                pos.setFixtime(rs.getTimestamp("fixtime"));
                positions.add(pos);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return positions;
    }
}
