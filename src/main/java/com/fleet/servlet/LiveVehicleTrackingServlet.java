package com.fleet.servlet;

import com.fleet.dao.LocationDAO;
import com.fleet.dto.VehicleLocationView;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/live-vehicle-tracking")
public class LiveVehicleTrackingServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
	private LocationDAO locationDAO;

    @Override
    public void init() {
        locationDAO = new LocationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // ✅ Get data from YOUR DB (vehicle_locations)
        List<VehicleLocationView> list = locationDAO.getLiveLocation();

        // ✅ Send to JSP
        request.setAttribute("locations", list);

        // ✅ Forward to JSP
        request.getRequestDispatcher("/live-vehicle-tracking.jsp").forward(request, response);
    }
}
