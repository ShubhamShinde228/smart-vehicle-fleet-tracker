package com.fleet.servlet;

import com.fleet.dao.VehicleDAO;
import com.fleet.model.Vehicle;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;

@WebServlet("/update-vehicle")
public class UpdateVehicleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private VehicleDAO vehicleDAO;

    @Override
    public void init() {
        vehicleDAO = new VehicleDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int    id            = Integer.parseInt(request.getParameter("id"));
        String vehicleNumber = request.getParameter("vehicleNumber").trim().toUpperCase();
        String model         = request.getParameter("model").trim();
        String vehicleType   = request.getParameter("vehicleType");
        String fuelType      = request.getParameter("fuelType");
        String fuelCapStr    = request.getParameter("fuelCapacity");
        String regDateStr    = request.getParameter("registrationDate");
        String insDateStr    = request.getParameter("insuranceExpiry");
        String maintDateStr  = request.getParameter("maintenanceDueDate");
        String status        = request.getParameter("status");

        // ── Unique vehicle number validation (exclude self) ─────────────────
        if (vehicleDAO.isVehicleNumberExists(vehicleNumber, id)) {
            request.setAttribute("errorMessage", "Vehicle number '" + vehicleNumber + "' already used by another vehicle!");
            request.setAttribute("vehicle", vehicleDAO.getVehicleById(id));
            request.getRequestDispatcher("edit-vehicle.jsp").forward(request, response);
            return;
        }

        Vehicle vehicle = new Vehicle();
        vehicle.setId(id);
        vehicle.setVehicleNumber(vehicleNumber);
        vehicle.setModel(model);
        vehicle.setVehicleType(vehicleType);
        vehicle.setFuelType(fuelType);
        vehicle.setFuelCapacity(fuelCapStr != null && !fuelCapStr.isEmpty()
                ? Double.parseDouble(fuelCapStr) : 0);
        vehicle.setRegistrationDate(parseDate(regDateStr));
        vehicle.setInsuranceExpiry(parseDate(insDateStr));
        vehicle.setMaintenanceDueDate(parseDate(maintDateStr));
        vehicle.setStatus(status);

        boolean success = vehicleDAO.updateVehicle(vehicle);

        HttpSession session = request.getSession();
        if (success) {
            session.setAttribute("successMessage", "Vehicle '" + vehicleNumber + "' updated successfully!");
        } else {
            session.setAttribute("errorMessage", "Failed to update vehicle. Please try again.");
        }
        response.sendRedirect(request.getContextPath() + "/vehicle-list.jsp");
    }

    private Date parseDate(String dateStr) {
        if (dateStr != null && !dateStr.isEmpty()) {
            try { return Date.valueOf(dateStr); } catch (IllegalArgumentException ignored) {}
        }
        return null;
    }
}
