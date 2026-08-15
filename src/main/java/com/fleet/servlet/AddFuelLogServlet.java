package com.fleet.servlet;

import com.fleet.dao.FuelDAO;
import com.fleet.model.FuelLog;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;

@WebServlet("/add-fuel-log")
public class AddFuelLogServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private FuelDAO fuelDAO;

    @Override
    public void init() { fuelDAO = new FuelDAO(); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        res.sendRedirect("fuel-log-form.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        if (session.getAttribute("currentUser") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        try {
            // ── Validate required parameters ─────────────────────────────────
            String vehicleIdParam    = req.getParameter("vehicleId");
            String fillDateParam     = req.getParameter("fillDate");
            String litersParam       = req.getParameter("liters");
            String costPerLiterParam = req.getParameter("costPerLiter");
            String odometerParam     = req.getParameter("odometerKm");

            if (vehicleIdParam == null || vehicleIdParam.isEmpty()) {
                session.setAttribute("errorMessage", "Please select a vehicle.");
                res.sendRedirect(req.getContextPath() + "/fuel-log-form.jsp");
                return;
            }
            if (fillDateParam == null || fillDateParam.isEmpty()) {
                session.setAttribute("errorMessage", "Please enter a fill date.");
                res.sendRedirect(req.getContextPath() + "/fuel-log-form.jsp");
                return;
            }
            if (litersParam == null || litersParam.isEmpty() ||
                costPerLiterParam == null || costPerLiterParam.isEmpty() ||
                odometerParam == null || odometerParam.isEmpty()) {
                session.setAttribute("errorMessage", "Please fill in all required fields.");
                res.sendRedirect(req.getContextPath() + "/fuel-log-form.jsp");
                return;
            }

            // ── Build FuelLog object ──────────────────────────────────────────
            FuelLog log = new FuelLog();
            log.setVehicleId(Integer.parseInt(vehicleIdParam.trim()));
            log.setFillDate(Date.valueOf(fillDateParam.trim()));
            log.setLiters(Double.parseDouble(litersParam.trim()));
            log.setCostPerLiter(Double.parseDouble(costPerLiterParam.trim()));
            log.setTotalCost(log.getLiters() * log.getCostPerLiter());
            log.setOdometerKm(Double.parseDouble(odometerParam.trim()));
            log.setFuelStation(req.getParameter("fuelStation") != null
                    ? req.getParameter("fuelStation").trim() : "");
            log.setNotes(req.getParameter("notes") != null
                    ? req.getParameter("notes").trim() : "");

            // ── Save to DB ────────────────────────────────────────────────────
            boolean saved = fuelDAO.addFuelLog(log);
            if (saved) {
                session.setAttribute("successMessage", "Fuel log added successfully!");
            } else {
                session.setAttribute("errorMessage",
                        "Database returned 0 rows affected. Check that the fuel_logs table exists.");
            }

        } catch (SQLException e) {
            // Show the real SQL error so it's easy to diagnose
            e.printStackTrace();
            session.setAttribute("errorMessage",
                    "Database error: " + e.getMessage()
                    + " — Make sure you have run fuel_monitoring_setup.sql in MySQL.");

        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage",
                    "Invalid number entered: " + e.getMessage());

        } catch (IllegalArgumentException e) {
            // Date.valueOf() throws this for bad date strings
            session.setAttribute("errorMessage",
                    "Invalid date format. Please use YYYY-MM-DD format.");
        }

        res.sendRedirect(req.getContextPath() + "/fuel-logs.jsp");
    }
}
