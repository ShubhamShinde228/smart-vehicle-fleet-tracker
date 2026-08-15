package com.fleet.servlet;

import com.fleet.dao.GeofenceDAO;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/resolve-geofence-alert")
public class ResolveGeofenceAlertServlet extends HttpServlet {
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
        try {
            int alertId = Integer.parseInt(request.getParameter("alertId"));
            boolean resolved = dao.resolveAlert(alertId);
            session.setAttribute(resolved ? "successMessage" : "errorMessage",
                    resolved ? "Alert marked as resolved." : "Unable to resolve alert.");
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Invalid alert reference.");
        }
        response.sendRedirect(request.getContextPath() + "/geofence-alerts.jsp");
    }
}
