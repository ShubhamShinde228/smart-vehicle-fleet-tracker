package com.fleet.servlet;

import com.fleet.dao.LocationDAO;
import com.fleet.dto.VehicleLocationView;

import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.annotation.WebServlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/get-latest-locations")
public class GetLatestLocationServlet extends HttpServlet {

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
        PrintWriter out = res.getWriter();

        List<VehicleLocationView> list = dao.getLiveLocation();

        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < list.size(); i++) {
            VehicleLocationView l = list.get(i);
            if (i > 0) sb.append(",");

            sb.append("{")
              .append("\"vehicleId\":").append(l.getVehicleId()).append(",")
              .append("\"latitude\":").append(l.getLatitude()).append(",")
              .append("\"longitude\":").append(l.getLongitude()).append(",")
              .append("\"speed\":").append(l.getSpeed()).append(",")
              .append("\"timestamp\":\"").append(formatTimestamp(l)).append("\",")
              .append("\"apiSource\":\"").append(escapeJson(l.getApiSource())).append("\",")
              .append("\"vehicleNumber\":\"").append(escapeJson(l.getVehicleNumber())).append("\",")
              .append("\"vehicleModel\":\"").append(escapeJson(l.getVehicleModel())).append("\",")
              .append("\"driverName\":\"").append(escapeJson(l.getDriverName())).append("\"")
              .append("}");
        }
        sb.append("]");

        out.print(sb.toString());
    }

    private String escapeJson(String value) {
        return value == null ? "" : value.replace("\\", "\\\\").replace("\"", "\\\"");
    }

    private String formatTimestamp(VehicleLocationView location) {
        return location.getTimestamp() == null
                ? "" : location.getTimestamp().toString().replace(' ', 'T');
    }
}
