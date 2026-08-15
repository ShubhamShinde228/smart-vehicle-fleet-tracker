package com.fleet.servlet;

import com.fleet.dao.MaintenanceDAO;
import com.fleet.model.MaintenanceNotification;
import com.fleet.model.User;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;

@WebServlet("/maintenance-notification")
public class MaintenanceNotificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private MaintenanceDAO dao;

    @Override
    public void init() {
        dao = new MaintenanceDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = currentUser.getRole();
        if (!"Admin".equalsIgnoreCase(role) && !"Manager".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
            return;
        }

        String action = request.getParameter("action");
        try {
            if ("complete".equals(action)) {
                updateStatus(request, session, "Completed", "Maintenance notification completed.");
            } else if ("schedule".equals(action)) {
                updateStatus(request, session, "Scheduled", "Maintenance notification scheduled.");
            } else if ("cancel".equals(action)) {
                updateStatus(request, session, "Cancelled", "Maintenance notification cancelled.");
            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean deleted = dao.deleteNotification(id);
                session.setAttribute(deleted ? "successMessage" : "errorMessage",
                        deleted ? "Maintenance notification deleted." : "Unable to delete notification.");
            } else {
                MaintenanceNotification notification = new MaintenanceNotification();
                notification.setVehicleId(Integer.parseInt(required(request, "vehicleId")));
                notification.setTitle(required(request, "title"));
                notification.setDescription(optional(request, "description"));
                notification.setDueDate(Date.valueOf(required(request, "dueDate")));
                notification.setPriority(optional(request, "priority", "Medium"));
                notification.setStatus(optional(request, "status", "Open"));
                notification.setCreatedBy(currentUser.getId());
                notification.setNotes(optional(request, "notes"));

                if (notification.getTitle().trim().isEmpty()) {
                    session.setAttribute("errorMessage", "Maintenance title is required.");
                } else {
                    boolean saved = dao.addNotification(notification);
                    session.setAttribute(saved ? "successMessage" : "errorMessage",
                            saved ? "Maintenance notification created successfully." :
                                    "Unable to create maintenance notification. Make sure maintenance_setup.sql is run.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("errorMessage", "Invalid maintenance notification request.");
        }

        response.sendRedirect(request.getContextPath() + "/maintenance-notifications.jsp");
    }

    private void updateStatus(HttpServletRequest request, HttpSession session, String status, String successMessage) {
        int id = Integer.parseInt(request.getParameter("id"));
        boolean updated = dao.updateStatus(id, status);
        session.setAttribute(updated ? "successMessage" : "errorMessage",
                updated ? successMessage : "Unable to update notification status.");
    }

    private String required(HttpServletRequest request, String name) {
        String value = request.getParameter(name);
        if (value == null || value.trim().isEmpty()) {
            throw new IllegalArgumentException(name + " is required");
        }
        return value.trim();
    }

    private String optional(HttpServletRequest request, String name) {
        return optional(request, name, "");
    }

    private String optional(HttpServletRequest request, String name, String defaultValue) {
        String value = request.getParameter(name);
        return value == null || value.trim().isEmpty() ? defaultValue : value.trim();
    }
}
