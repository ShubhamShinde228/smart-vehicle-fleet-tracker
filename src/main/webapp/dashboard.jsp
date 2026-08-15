<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.dao.GeofenceDAO, com.fleet.dao.MaintenanceDAO" %>
<%
    User user = (User) session.getAttribute("currentUser");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String role = user.getRole();
    int openGeofenceAlerts = 0;
    int openMaintenanceNotifications = 0;
    if ("Admin".equalsIgnoreCase(role) || "Manager".equalsIgnoreCase(role)) {
        openGeofenceAlerts = new GeofenceDAO().countOpenAlerts();
        openMaintenanceNotifications = new MaintenanceDAO().countOpenNotifications();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Smart Vehicle Fleet</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>
<body class="bg-light">

    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
        <div class="container-fluid px-4">
            <a class="navbar-brand fw-bold" href="#">
                <i class="bi bi-truck-front-fill me-2 text-primary"></i>FleetTracker
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarContent">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                    <li class="nav-item">
                        <a class="nav-link active" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i>Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="vehicle-list.jsp"><i class="bi bi-truck me-1"></i>Vehicles</a>
                    </li>
                    <% if ("Admin".equalsIgnoreCase(role) || "Manager".equalsIgnoreCase(role)) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="driver-list.jsp"><i class="bi bi-people me-1"></i>Drivers</a>
                    </li>
                    <% } %>
                    <% if ("Admin".equalsIgnoreCase(role) || "Manager".equalsIgnoreCase(role)) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="assignment-list.jsp"><i class="bi bi-arrow-left-right me-1"></i>Assignments</a>
                    </li>
                    <% } %>
                    <% if ("Admin".equalsIgnoreCase(role) || "Manager".equalsIgnoreCase(role)) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="live-tracking.jsp"><i class="bi bi-broadcast me-1"></i>Live Map</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="maintenance-notifications.jsp"><i class="bi bi-tools me-1"></i>Maintenance</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="geofence-list.jsp"><i class="bi bi-bounding-box-circles me-1"></i>Geofences</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="geofence-alerts.jsp"><i class="bi bi-exclamation-triangle me-1"></i>Alerts</a>
                    </li>
                    <% } %>
                    <li class="nav-item">
                        <a class="nav-link" href="mobile-tracking.jsp"><i class="bi bi-phone me-1"></i>My Tracking</a>
                    </li>
                    <% if ("Admin".equalsIgnoreCase(role) || "Manager".equalsIgnoreCase(role)) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="fuel-logs.jsp"><i class="bi bi-fuel-pump me-1"></i>Fuel</a>
                    </li>
                    <% } %>
                    <% if ("Admin".equalsIgnoreCase(role)) { %>
                    <li class="nav-item">
                        <a class="nav-link" href="gps-api-config.jsp"><i class="bi bi-key me-1"></i>GPS Config</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="#"><i class="bi bi-gear me-1"></i>Settings</a>
                    </li>
                    <% } %>
                </ul>
                <div class="d-flex align-items-center gap-2">
                    <span class="text-light">
                        <i class="bi bi-person-circle me-1"></i>
                        <strong><%= user.getName() != null ? user.getName() : user.getEmail() %></strong>
                    </span>
                    <%
                        String badgeClass = "bg-secondary";
                        if ("Admin".equalsIgnoreCase(role)) badgeClass = "bg-danger";
                        else if ("Manager".equalsIgnoreCase(role)) badgeClass = "bg-warning text-dark";
                        else if ("Driver".equalsIgnoreCase(role)) badgeClass = "bg-success";
                    %>
                    <span class="badge <%= badgeClass %>"><%= role %></span>
                    <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline-light btn-sm ms-2">
                        <i class="bi bi-box-arrow-right me-1"></i>Logout
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Page Header -->
    <div class="bg-white border-bottom py-3 px-4 shadow-sm">
        <div class="container-fluid">
            <h5 class="mb-0 fw-bold text-dark">
                <i class="bi bi-speedometer2 me-2 text-primary"></i>Dashboard Overview
            </h5>
            <small class="text-muted">Welcome back, <%= user.getName() != null ? user.getName() : user.getEmail() %>! You are logged in as <strong><%= role %></strong>.</small>
        </div>
    </div>

    <div class="container-fluid px-4 py-4">

        <!-- Stats Row -->
        <div class="row g-3 mb-4">
            <div class="col-sm-6 col-xl-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="bg-primary bg-opacity-10 rounded-3 p-3">
                            <i class="bi bi-truck fs-3 text-primary"></i>
                        </div>
                        <div>
                            <div class="fs-4 fw-bold">24</div>
                            <div class="text-muted small">Total Vehicles</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="bg-success bg-opacity-10 rounded-3 p-3">
                            <i class="bi bi-check-circle fs-3 text-success"></i>
                        </div>
                        <div>
                            <div class="fs-4 fw-bold">18</div>
                            <div class="text-muted small">Active Vehicles</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                            <i class="bi bi-people fs-3 text-warning"></i>
                        </div>
                        <div>
                            <div class="fs-4 fw-bold">12</div>
                            <div class="text-muted small">Total Drivers</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3">
                <a href="geofence-alerts.jsp" class="text-decoration-none text-dark">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="bg-danger bg-opacity-10 rounded-3 p-3">
                            <i class="bi bi-exclamation-triangle fs-3 text-danger"></i>
                        </div>
                        <div>
                            <div class="fs-4 fw-bold"><%= openGeofenceAlerts %></div>
                            <div class="text-muted small">Open Geofence Alerts</div>
                        </div>
                    </div>
                </div>
                </a>
            </div>
            <% if ("Admin".equalsIgnoreCase(role) || "Manager".equalsIgnoreCase(role)) { %>
            <div class="col-sm-6 col-xl-3">
                <a href="maintenance-notifications.jsp" class="text-decoration-none text-dark">
                <div class="card border-0 shadow-sm h-100">
                    <div class="card-body d-flex align-items-center gap-3">
                        <div class="bg-info bg-opacity-10 rounded-3 p-3">
                            <i class="bi bi-tools fs-3 text-info"></i>
                        </div>
                        <div>
                            <div class="fs-4 fw-bold"><%= openMaintenanceNotifications %></div>
                            <div class="text-muted small">Maintenance Notifications</div>
                        </div>
                    </div>
                </div>
                </a>
            </div>
            <% } %>
        </div>

        <!-- Role-Based Panels -->
        <div class="row g-3">

            <!-- Admin Panel -->
            <% if ("Admin".equalsIgnoreCase(role)) { %>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100 border-start border-danger border-4">
                    <div class="card-body">
                        <h6 class="card-title fw-bold text-danger">
                            <i class="bi bi-shield-lock-fill me-2"></i>Admin Control Panel
                        </h6>
                        <p class="card-text text-muted small">Manage all users, roles, and system-wide settings for the fleet platform.</p>
                        <ul class="list-unstyled small text-muted mb-3">
                            <li><i class="bi bi-check2 text-danger me-1"></i>Add / Remove Users</li>
                            <li><i class="bi bi-check2 text-danger me-1"></i>Assign Roles</li>
                            <li><i class="bi bi-check2 text-danger me-1"></i>View Full Audit Logs</li>
                        </ul>
                    </div>
                    <div class="card-footer bg-white border-0 pb-3">
                        <button class="btn btn-danger btn-sm w-100">
                            <i class="bi bi-people-fill me-1"></i>Manage Users
                        </button>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Manager Panel -->
            <% if ("Admin".equalsIgnoreCase(role) || "Manager".equalsIgnoreCase(role)) { %>
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100 border-start border-warning border-4">
                    <div class="card-body">
                        <h6 class="card-title fw-bold text-warning">
                            <i class="bi bi-diagram-3-fill me-2"></i>Fleet Management
                        </h6>
                        <p class="card-text text-muted small">Monitor vehicle status, assign drivers and manage trip scheduling.</p>
                        <ul class="list-unstyled small text-muted mb-3">
                            <li><i class="bi bi-check2 text-warning me-1"></i>Vehicle Status Overview</li>
                            <li><i class="bi bi-check2 text-warning me-1"></i>Driver Assignment</li>
                            <li><i class="bi bi-check2 text-warning me-1"></i>Maintenance Notifications</li>
                        </ul>
                    </div>
                    <div class="card-footer bg-white border-0 pb-3">
                        <a href="maintenance-notifications.jsp" class="btn btn-warning btn-sm w-100 text-dark">
                            <i class="bi bi-tools me-1"></i>View Maintenance
                        </a>
                    </div>
                </div>
            </div>
            <% } %>

            <!-- Driver Panel -->
            <div class="col-md-4">
                <div class="card border-0 shadow-sm h-100 border-start border-success border-4">
                    <div class="card-body">
                        <h6 class="card-title fw-bold text-success">
                            <i class="bi bi-map-fill me-2"></i>My Assignments
                        </h6>
                        <p class="card-text text-muted small">View your assigned vehicle, today's route, and update your trip status.</p>
                        <ul class="list-unstyled small text-muted mb-3">
                            <li><i class="bi bi-check2 text-success me-1"></i>Today's Route</li>
                            <li><i class="bi bi-check2 text-success me-1"></i>Trip Log Update</li>
                            <li><i class="bi bi-check2 text-success me-1"></i>Report Vehicle Issue</li>
                        </ul>
                    </div>
                    <div class="card-footer bg-white border-0 pb-3">
                        <a href="mobile-tracking.jsp" class="btn btn-success btn-sm w-100">
                            <i class="bi bi-geo-alt-fill me-1"></i>View My Route
                        </a>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
