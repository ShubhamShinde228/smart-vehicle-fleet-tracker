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

@WebServlet("/add-vehicle")
public class AddVehicleServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private VehicleDAO vehicleDAO;

    @Override
    public void init() {
        vehicleDAO = new VehicleDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("add-vehicle.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String vehicleNumber  = request.getParameter("vehicleNumber").trim().toUpperCase();
        String model          = request.getParameter("model").trim();
        String vehicleType    = request.getParameter("vehicleType");
        String fuelType       = request.getParameter("fuelType");
        String fuelCapacityStr = request.getParameter("fuelCapacity");
        String regDateStr     = request.getParameter("registrationDate");
        String insDateStr     = request.getParameter("insuranceExpiry");
        String maintDateStr   = request.getParameter("maintenanceDueDate");
        String status         = request.getParameter("status");

        // ── Unique vehicle number validation ────────────────────────────────
        if (vehicleDAO.isVehicleNumberExists(vehicleNumber)) {
            request.setAttribute("errorMessage", "Vehicle number '" + vehicleNumber + "' already exists!");
            request.setAttribute("vehicleNumber",  vehicleNumber);
            request.setAttribute("model",          model);
            request.setAttribute("vehicleType",    vehicleType);
            request.setAttribute("fuelType",       fuelType);
            request.setAttribute("fuelCapacity",   fuelCapacityStr);
            request.setAttribute("status",         status);
            request.getRequestDispatcher("add-vehicle.jsp").forward(request, response);
            return;
        }

        // ── Build vehicle object ────────────────────────────────────────────
        Vehicle vehicle = new Vehicle();
        vehicle.setVehicleNumber(vehicleNumber);
        vehicle.setModel(model);
        vehicle.setVehicleType(vehicleType);
        vehicle.setFuelType(fuelType);
        vehicle.setFuelCapacity(fuelCapacityStr != null && !fuelCapacityStr.isEmpty()
                ? Double.parseDouble(fuelCapacityStr) : 0);
        vehicle.setRegistrationDate(parseDate(regDateStr));
        vehicle.setInsuranceExpiry(parseDate(insDateStr));
        vehicle.setMaintenanceDueDate(parseDate(maintDateStr));
        vehicle.setStatus(status);

        boolean success = vehicleDAO.addVehicle(vehicle);

        HttpSession session = request.getSession();
        if (success) {
            session.setAttribute("successMessage", "Vehicle '" + vehicleNumber + "' added successfully!");
        } else {
            session.setAttribute("errorMessage", "Failed to add vehicle. Please try again.");
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
