package com.fleet.servlet;

import com.fleet.dao.LocationDAO;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.annotation.WebServlet;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@WebServlet("/updateLocation")
public class UpdateLocationServlet extends HttpServlet {

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

        try {
            Map<String, String> jsonBody = readJsonBody(req);

            String apiKey = firstRequestValue(req, jsonBody, "apiKey", "key");
            String vehicleId = firstRequestValue(req, jsonBody, "vehicleId", "vehicle_id");
            String lat = firstRequestValue(req, jsonBody, "latitude", "lat");
            String lon = firstRequestValue(req, jsonBody, "longitude", "lon", "lng");
            String speed = firstRequestValue(req, jsonBody, "speed", "spd");
            String apiSource = firstRequestValue(req, jsonBody, "apiSource", "source");

            if (apiKey == null || vehicleId == null || lat == null || lon == null) {
                writeJson(res, false, "Missing required parameters: apiKey, vehicleId, latitude, longitude.");
                return;
            }

            if (!dao.validateApiKey(apiKey)) {
                writeJson(res, false, "Invalid API key.");
                return;
            }

            int parsedVehicleId = parseInt(vehicleId, "vehicleId");
            double parsedLat = parseDouble(lat, "latitude");
            double parsedLon = parseDouble(lon, "longitude");
            double parsedSpeed = parseOptionalDouble(speed, 0.0);

            boolean inserted = dao.insertLocation(
                    parsedVehicleId,
                    parsedLat,
                    parsedLon,
                    parsedSpeed,
                    apiSource
            );

            if (inserted) {
                writeJson(res, true, "Location updated.");
            } else {
                writeJson(res, false, "Vehicle has no active driver assignment.");
            }
        } catch (IllegalArgumentException e) {
            writeJson(res, false, e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            writeJson(res, false, "Invalid request data.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws IOException {
        doGet(req, res);
    }

    private void writeJson(HttpServletResponse res, boolean success, String message)
            throws IOException {
        res.getWriter().print("{\"success\":" + success + ",\"message\":\""
                + escapeJson(message) + "\"}");
    }

    private String firstRequestValue(HttpServletRequest req, Map<String, String> jsonBody, String... names) {
        for (String name : names) {
            String value = req.getParameter(name);
            if (value != null && !value.trim().isEmpty()) {
                return value.trim();
            }
        }

        for (String name : names) {
            String value = jsonBody.get(name);
            if (value != null && !value.trim().isEmpty()) {
                return value.trim();
            }
        }

        return null;
    }

    private Map<String, String> readJsonBody(HttpServletRequest req) throws IOException {
        Map<String, String> values = new HashMap<>();
        String contentType = req.getContentType();
        if (contentType == null || !contentType.toLowerCase().contains("application/json")) {
            return values;
        }

        StringBuilder body = new StringBuilder();
        String line;
        while ((line = req.getReader().readLine()) != null) {
            body.append(line);
        }

        Pattern fieldPattern = Pattern.compile(
                "\"([^\"]+)\"\\s*:\\s*(\"((?:\\\\.|[^\"])*)\"|[^,}\\s]+)"
        );
        Matcher matcher = fieldPattern.matcher(body.toString());
        while (matcher.find()) {
            String key = matcher.group(1);
            String value = matcher.group(3) != null ? unescapeJson(matcher.group(3)) : matcher.group(2);
            values.put(key, value);
        }
        return values;
    }

    private int parseInt(String value, String fieldName) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid " + fieldName + ": " + value);
        }
    }

    private double parseDouble(String value, String fieldName) {
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Invalid " + fieldName + ": " + value);
        }
    }

    private double parseOptionalDouble(String value, double defaultValue) {
        if (value == null || value.trim().isEmpty() || value.startsWith("%")) {
            return defaultValue;
        }

        try {
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }

    private String escapeJson(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private String unescapeJson(String value) {
        return value
                .replace("\\\"", "\"")
                .replace("\\\\", "\\")
                .replace("\\/", "/")
                .replace("\\b", "\b")
                .replace("\\f", "\f")
                .replace("\\n", "\n")
                .replace("\\r", "\r")
                .replace("\\t", "\t");
    }
}
