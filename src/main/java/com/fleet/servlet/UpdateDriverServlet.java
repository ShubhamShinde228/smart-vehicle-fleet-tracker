package com.fleet.servlet;

import com.fleet.dao.DriverDAO;
import com.fleet.model.Driver;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;

@WebServlet("/update-driver")
public class UpdateDriverServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DriverDAO driverDAO;

    @Override
    public void init() {
        driverDAO = new DriverDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int    id               = Integer.parseInt(request.getParameter("id"));
        String name             = request.getParameter("name").trim();
        String email            = request.getParameter("email").trim().toLowerCase();
        String phone            = request.getParameter("phone").trim();
        String address          = request.getParameter("address").trim();
        String licenseNumber    = request.getParameter("licenseNumber").trim().toUpperCase();
        String licenseExpiryStr = request.getParameter("licenseExpiry");
        String emergencyContact = request.getParameter("emergencyContact").trim();
        String status           = request.getParameter("status");

        // ── Unique license number check (excluding self) ─────────────────────
        if (driverDAO.isLicenseNumberExists(licenseNumber, id)) {
            request.setAttribute("errorMessage",
                    "License number '" + licenseNumber + "' is already used by another driver!");
            request.setAttribute("driver", driverDAO.getDriverById(id));
            request.getRequestDispatcher("edit-driver.jsp").forward(request, response);
            return;
        }

        Driver driver = new Driver();
        driver.setId(id);
        driver.setName(name);
        driver.setEmail(email);
        driver.setPhone(phone);
        driver.setAddress(address);
        driver.setLicenseNumber(licenseNumber);
        driver.setLicenseExpiry(parseDate(licenseExpiryStr));
        driver.setEmergencyContact(emergencyContact);
        driver.setStatus(status);

        boolean success = driverDAO.updateDriver(driver);

        HttpSession session = request.getSession();
        if (success) {
            session.setAttribute("successMessage",
                    "Driver '" + name + "' updated successfully!");
        } else {
            session.setAttribute("errorMessage",
                    "Failed to update driver. Please try again.");
        }
        response.sendRedirect(request.getContextPath() + "/driver-list.jsp");
    }

    private Date parseDate(String dateStr) {
        if (dateStr != null && !dateStr.isEmpty()) {
            try { return Date.valueOf(dateStr); } catch (IllegalArgumentException ignored) {}
        }
        return null;
    }
}
