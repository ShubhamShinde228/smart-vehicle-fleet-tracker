package com.fleet.servlet;

import com.fleet.dao.DriverDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/delete-driver")
public class DeleteDriverServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DriverDAO driverDAO;

    @Override
    public void init() {
        driverDAO = new DriverDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        HttpSession session = request.getSession();

        if (idParam != null && !idParam.isEmpty()) {
            try {
                int id = Integer.parseInt(idParam);
                boolean success = driverDAO.deleteDriver(id);
                if (success) {
                    session.setAttribute("successMessage", "Driver deleted successfully.");
                } else {
                    session.setAttribute("errorMessage", "Failed to delete driver.");
                }
            } catch (NumberFormatException e) {
                session.setAttribute("errorMessage", "Invalid driver ID.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/driver-list.jsp");
    }
}
