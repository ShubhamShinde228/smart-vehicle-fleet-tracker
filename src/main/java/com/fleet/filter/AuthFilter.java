package com.fleet.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter(urlPatterns = {
    "/dashboard.jsp",
    "/vehicle-list.jsp",
    "/add-vehicle.jsp",
    "/edit-vehicle.jsp",
    "/vehicle-details.jsp",
    "/driver-list.jsp",
    "/add-driver.jsp",
    "/edit-driver.jsp",
    "/driver-details.jsp",
    "/assign-vehicle.jsp",
    "/assignment-list.jsp",
    "/assignment-history.jsp",
    "/live-tracking.jsp",
    "/mobile-tracking.jsp",
    "/vehicle-map.jsp",
    "/gps-api-config.jsp",
    "/maintenance-notifications.jsp",
    "/admin/*", "/manager/*"
})
public class AuthFilter implements Filter {

    public void init(FilterConfig fConfig) throws ServletException {}

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        boolean isLoggedIn = (session != null && session.getAttribute("currentUser") != null);
        
        String loginURI = httpRequest.getContextPath() + "/login.jsp";
        
        // Prevent caching for protected pages
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1.
        httpResponse.setHeader("Pragma", "no-cache"); // HTTP 1.0.
        httpResponse.setDateHeader("Expires", 0); // Proxies.
        
        if (isLoggedIn) {
            chain.doFilter(request, response);
        } else {
            httpResponse.sendRedirect(loginURI);
        }
    }

    public void destroy() {}
}
