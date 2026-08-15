package com.fleet.servlet;

import com.fleet.dao.TraccarDAO;
import com.fleet.model.TraccarPosition;
import java.io.IOException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/traccar-live")
public class LiveTraccarServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TraccarDAO traccarDAO;

    public void init() {
        traccarDAO = new TraccarDAO();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        List<TraccarPosition> positions = traccarDAO.getLatestPositions();
        request.setAttribute("positions", positions);
        
        request.getRequestDispatcher("/traccar-live.jsp").forward(request, response);
    }
}
