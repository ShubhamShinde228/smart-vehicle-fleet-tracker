<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User" %>
<%
    User user = (User) session.getAttribute("currentUser");
    // Not strictly needed because of AuthFilter, but good practice
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Smart Vehicle Fleet</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
        <div class="container">
            <a class="navbar-brand fw-bold" href="#">FleetTracker</a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarContent">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link active" href="dashboard.jsp">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#">Vehicles</a>
                    </li>
                </ul>
                <div class="d-flex align-items-center">
                    <span class="text-light me-3">Welcome, <strong><%= user.getName() != null ? user.getName() : user.getEmail() %></strong> <span class="badge bg-secondary"><%= user.getRole() %></span></span>
                    <a href="logout" class="btn btn-outline-light btn-sm">Logout</a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container mt-5">
        <div class="row mb-4">
            <div class="col-12">
                <h3 class="fw-bold text-secondary">Dashboard</h3>
                <p class="text-muted">Overview of your operations based on your role privileges.</p>
            </div>
        </div>
        
        <div class="row">
            <% if ("Admin".equalsIgnoreCase(user.getRole())) { %>
                <div class="col-md-4 mb-4">
                    <div class="card shadow-sm border-0 h-100 border-top border-primary border-3">
                        <div class="card-body">
                            <h5 class="card-title text-primary fw-bold">Admin Panel</h5>
                            <p class="card-text text-muted">Complete control over users, application settings, and total fleet analytics.</p>
                        </div>
                        <div class="card-footer bg-white border-0 pb-3">
                            <button class="btn btn-primary btn-sm w-100">Manage Users</button>
                        </div>
                    </div>
                </div>
            <% } %>

            <% if ("Admin".equalsIgnoreCase(user.getRole()) || "Manager".equalsIgnoreCase(user.getRole())) { %>
                <div class="col-md-4 mb-4">
                    <div class="card shadow-sm border-0 h-100 border-top border-success border-3">
                        <div class="card-body">
                            <h5 class="card-title text-success fw-bold">Fleet Management</h5>
                            <p class="card-text text-muted">Monitor vehicle conditions, assign drivers to vehicles, and view maintenance reports.</p>
                        </div>
                        <div class="card-footer bg-white border-0 pb-3">
                            <button class="btn btn-success btn-sm w-100">View Vehicles</button>
                        </div>
                    </div>
                </div>
            <% } %>

            <% if ("Driver".equalsIgnoreCase(user.getRole()) || "Admin".equalsIgnoreCase(user.getRole()) || "Manager".equalsIgnoreCase(user.getRole())) { %>
                <div class="col-md-4 mb-4">
                    <div class="card shadow-sm border-0 h-100 border-top border-info border-3">
                        <div class="card-body">
                            <h5 class="card-title text-info fw-bold">My Assignments</h5>
                            <p class="card-text text-muted">Check your assigned routes for today, update delivery statuses, and log your trips.</p>
                        </div>
                        <div class="card-footer bg-white border-0 pb-3">
                            <button class="btn btn-info btn-sm w-100 text-white">View Route</button>
                        </div>
                    </div>
                </div>
            <% } %>
        </div>
    </div>

    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
