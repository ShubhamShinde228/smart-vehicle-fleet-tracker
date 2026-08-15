package com.fleet.servlet;

import com.fleet.dao.VehicleDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/delete-vehicle")
public class DeleteVehicleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private VehicleDAO vehicleDAO;

    @Override
    public void init() {
        vehicleDAO = new VehicleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        HttpSession session = request.getSession();

        if (idParam != null && !idParam.isEmpty()) {
            try {
                int id = Integer.parseInt(idParam);
                boolean success = vehicleDAO.deleteVehicle(id);
                if (success) {
                    session.setAttribute("successMessage", "Vehicle deleted successfully.");
                } else {
                    session.setAttribute("errorMessage", "Failed to delete vehicle.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "Invalid vehicle ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/vehicle-list.jsp");
    }
}
