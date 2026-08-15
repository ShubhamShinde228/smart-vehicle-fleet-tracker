package com.fleet.servlet;

import com.fleet.dao.GeofenceDAO;
import com.fleet.model.Geofence;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/geofence")
public class GeofenceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private GeofenceDAO dao;

    @Override
    public void init() {
        dao = new GeofenceDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        String action = request.getParameter("action");

        try {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean deleted = dao.deleteGeofence(id);
                session.setAttribute(deleted ? "successMessage" : "errorMessage",
                        deleted ? "Geofence deleted successfully." : "Unable to delete geofence.");
            } else if ("toggle".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean active = Boolean.parseBoolean(request.getParameter("active"));
                boolean updated = dao.toggleGeofence(id, active);
                session.setAttribute(updated ? "successMessage" : "errorMessage",
                        updated ? "Geofence status updated." : "Unable to update geofence status.");
            } else {
                Geofence geofence = new Geofence();
                geofence.setVehicleId(Integer.parseInt(request.getParameter("vehicleId")));
                geofence.setFenceName(request.getParameter("fenceName"));
                geofence.setCenterLatitude(Double.parseDouble(request.getParameter("centerLatitude")));
                geofence.setCenterLongitude(Double.parseDouble(request.getParameter("centerLongitude")));
                geofence.setRadiusKm(Double.parseDouble(request.getParameter("radiusKm")));
                geofence.setActive(request.getParameter("active") != null);

                if (geofence.getFenceName() == null || geofence.getFenceName().trim().isEmpty()
                        || geofence.getRadiusKm() <= 0) {
                    session.setAttribute("errorMessage", "Fence name and valid radius are required.");
                } else {
                    boolean saved = dao.saveGeofence(geofence);
                    session.setAttribute(saved ? "successMessage" : "errorMessage",
                            saved ? "Geofence created successfully." : "Unable to create geofence.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Invalid geofence request data.");
        }

        response.sendRedirect(request.getContextPath() + "/geofence-list.jsp");
    }
}
