package com.fleet.servlet;

import com.fleet.dao.VehicleAssignmentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;

@WebServlet("/unassign-vehicle")
public class UnassignVehicleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private VehicleAssignmentDAO dao;

    @Override
    public void init() { dao = new VehicleAssignmentDAO(); }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String assignmentIdStr = request.getParameter("assignmentId");
        HttpSession session    = request.getSession();

        if (assignmentIdStr == null || assignmentIdStr.isEmpty()) {
            session.setAttribute("errorMessage", "Invalid assignment reference.");
            response.sendRedirect(request.getContextPath() + "/assignment-list.jsp");
            return;
        }

        try {
            int  assignmentId = Integer.parseInt(assignmentIdStr);
            Date today        = new Date(System.currentTimeMillis());
            boolean success   = dao.unassignVehicle(assignmentId, today);

            if (success) {
                session.setAttribute("successMessage", "Driver unassigned from vehicle successfully.");
            } else {
                session.setAttribute("errorMessage",
                        "Could not unassign. The assignment may already be closed.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid assignment ID.");
        }
        response.sendRedirect(request.getContextPath() + "/assignment-list.jsp");
    }
}
