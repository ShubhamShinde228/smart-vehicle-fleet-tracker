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

@WebServlet("/add-driver")
public class AddDriverServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DriverDAO driverDAO;

    @Override
    public void init() {
        driverDAO = new DriverDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("add-driver.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name             = request.getParameter("name").trim();
        String email            = request.getParameter("email").trim().toLowerCase();
        String phone            = request.getParameter("phone").trim();
        String address          = request.getParameter("address").trim();
        String licenseNumber    = request.getParameter("licenseNumber").trim().toUpperCase();
        String licenseExpiryStr = request.getParameter("licenseExpiry");
        String emergencyContact = request.getParameter("emergencyContact").trim();
        String status           = request.getParameter("status");

        // ── Unique license number validation ────────────────────────────────
        if (driverDAO.isLicenseNumberExists(licenseNumber)) {
            request.setAttribute("errorMessage",
                    "License number '" + licenseNumber + "' is already registered!");
            repopulate(request, name, email, phone, address, licenseNumber,
                       licenseExpiryStr, emergencyContact, status);
            request.getRequestDispatcher("add-driver.jsp").forward(request, response);
            return;
        }

        Driver driver = new Driver();
        driver.setName(name);
        driver.setEmail(email);
        driver.setPhone(phone);
        driver.setAddress(address);
        driver.setLicenseNumber(licenseNumber);
        driver.setLicenseExpiry(parseDate(licenseExpiryStr));
        driver.setEmergencyContact(emergencyContact);
        driver.setStatus(status);

        boolean success = driverDAO.addDriver(driver);

        HttpSession session = request.getSession();
        if (success) {
            session.setAttribute("successMessage",
                    "Driver '" + name + "' added successfully!");
        } else {
            session.setAttribute("errorMessage",
                    "Failed to add driver. Please try again.");
        }
        response.sendRedirect(request.getContextPath() + "/driver-list.jsp");
    }

    private void repopulate(HttpServletRequest req, String name, String email, String phone,
                            String address, String licenseNumber, String licenseExpiry,
                            String emergencyContact, String status) {
        req.setAttribute("dName",            name);
        req.setAttribute("dEmail",           email);
        req.setAttribute("dPhone",           phone);
        req.setAttribute("dAddress",         address);
        req.setAttribute("dLicenseNumber",   licenseNumber);
        req.setAttribute("dLicenseExpiry",   licenseExpiry);
        req.setAttribute("dEmergencyContact",emergencyContact);
        req.setAttribute("dStatus",          status);
    }

    private Date parseDate(String dateStr) {
        if (dateStr != null && !dateStr.isEmpty()) {
            try { return Date.valueOf(dateStr); } catch (IllegalArgumentException ignored) {}
        }
        return null;
    }
}
