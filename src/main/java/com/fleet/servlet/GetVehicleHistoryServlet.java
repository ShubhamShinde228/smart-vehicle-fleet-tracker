package com.fleet.servlet;

import com.fleet.dao.LocationDAO;
import com.fleet.dto.VehicleLocationView;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;
import java.util.List;

@WebServlet("/get-vehicle-history")
public class GetVehicleHistoryServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private LocationDAO dao;

    @Override
    public void init() {
        dao = new LocationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws IOException {

        res.setContentType("application/json");
        res.setCharacterEncoding("UTF-8");

        int vehicleId = parseInt(req.getParameter("vehicleId"), 0);
        int limit = parseInt(req.getParameter("limit"), 200);
        Timestamp startDate = parseTimestamp(req.getParameter("startDate"));
        Timestamp endDate = parseTimestamp(req.getParameter("endDate"));

        PrintWriter out = res.getWriter();
        if (vehicleId <= 0) {
            out.print("[]");
            return;
        }

        List<VehicleLocationView> history = dao.getVehicleHistory(vehicleId, startDate, endDate, limit);
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < history.size(); i++) {
            VehicleLocationView point = history.get(i);
            if (i > 0) sb.append(",");

            sb.append("{")
              .append("\"vehicleId\":").append(point.getVehicleId()).append(",")
              .append("\"latitude\":").append(point.getLatitude()).append(",")
              .append("\"longitude\":").append(point.getLongitude()).append(",")
              .append("\"speed\":").append(point.getSpeed()).append(",")
              .append("\"timestamp\":\"").append(formatTimestamp(point)).append("\",")
              .append("\"apiSource\":\"").append(escapeJson(point.getApiSource())).append("\"")
              .append("}");
        }
        sb.append("]");
        out.print(sb.toString());
    }

    private int parseInt(String value, int fallback) {
        try {
            return value == null ? fallback : Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private Timestamp parseTimestamp(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        try {
            String normalized = value.replace('T', ' ');
            if (normalized.length() == 16) normalized += ":00";
            return Timestamp.valueOf(normalized);
        } catch (IllegalArgumentException e) {
            return null;
        }
    }

    private String escapeJson(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private String formatTimestamp(VehicleLocationView location) {
        return location.getTimestamp() == null
                ? "" : location.getTimestamp().toString().replace(' ', 'T');
    }
}
