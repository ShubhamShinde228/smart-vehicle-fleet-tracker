package com.fleet.servlet;

import com.fleet.dao.VehicleAssignmentDAO;
import com.fleet.model.VehicleAssignment;
import com.fleet.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;

@WebServlet("/assign-vehicle")
public class AssignVehicleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private VehicleAssignmentDAO dao;

    @Override
    public void init() { dao = new VehicleAssignmentDAO(); }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("assign-vehicle.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String vehicleIdStr = request.getParameter("vehicleId");
        String driverIdStr  = request.getParameter("driverId");
        String startDateStr = request.getParameter("startDate");
        String notes        = request.getParameter("notes");
        notes = (notes != null) ? notes.trim() : "";

        // ── Basic null checks ────────────────────────────────────────────────
        if (vehicleIdStr == null || vehicleIdStr.isEmpty()
                || driverIdStr == null || driverIdStr.isEmpty()
                || startDateStr == null || startDateStr.isEmpty()) {
            request.setAttribute("errorMessage", "Vehicle, Driver and Start Date are required.");
            request.getRequestDispatcher("assign-vehicle.jsp").forward(request, response);
            return;
        }

        int  vehicleId = Integer.parseInt(vehicleIdStr);
        int  driverId  = Integer.parseInt(driverIdStr);
        Date startDate = Date.valueOf(startDateStr);

        // ── Validation 1: vehicle must not already have an active assignment ─
        if (dao.isVehicleAssigned(vehicleId)) {
            request.setAttribute("errorMessage",
                    "This vehicle already has an active driver assigned. Please unassign first.");
            request.setAttribute("selVehicleId", vehicleIdStr);
            request.setAttribute("selDriverId",  driverIdStr);
            request.getRequestDispatcher("assign-vehicle.jsp").forward(request, response);
            return;
        }

        // ── Validation 2: driver must not already be on an active assignment ─
        if (dao.isDriverAssigned(driverId)) {
            request.setAttribute("errorMessage",
                    "This driver is already assigned to another vehicle. Please unassign first.");
            request.setAttribute("selVehicleId", vehicleIdStr);
            request.setAttribute("selDriverId",  driverIdStr);
            request.getRequestDispatcher("assign-vehicle.jsp").forward(request, response);
            return;
        }

        // ── Build and save assignment ─────────────────────────────────────────
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        VehicleAssignment assignment = new VehicleAssignment();
        assignment.setVehicleId(vehicleId);
        assignment.setDriverId(driverId);
        assignment.setAssignedBy(currentUser != null ? currentUser.getId() : 0);
        assignment.setStartDate(startDate);
        assignment.setNotes(notes.isEmpty() ? null : notes);

        boolean success = dao.assignVehicle(assignment);

        HttpSession session = request.getSession();
        if (success) {
            session.setAttribute("successMessage", "Vehicle assigned to driver successfully!");
        } else {
            session.setAttribute("errorMessage", "Failed to create assignment. Please try again.");
        }
        response.sendRedirect(request.getContextPath() + "/assignment-list.jsp");
    }
}
