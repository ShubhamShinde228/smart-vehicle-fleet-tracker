package com.fleet.servlet;

import com.fleet.dao.FuelDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/delete-fuel-log")
public class DeleteFuelLogServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private FuelDAO fuelDAO;

    @Override
    public void init() { fuelDAO = new FuelDAO(); }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {
        HttpSession session = req.getSession();
        if (session.getAttribute("currentUser") == null) {
            res.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            if (fuelDAO.deleteFuelLog(id)) {
                session.setAttribute("successMessage", "Fuel log deleted.");
            } else {
                session.setAttribute("errorMessage", "Could not delete fuel log.");
            }
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Invalid request.");
        }
        res.sendRedirect(req.getContextPath() + "/fuel-logs.jsp");
    }
}
