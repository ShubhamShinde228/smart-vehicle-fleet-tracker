<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.sql.Timestamp" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // Retrieve Traccar GPS positions set by the servlet
    @SuppressWarnings("unchecked")
    List<Object[]> traccarPositions = (List<Object[]>) request.getAttribute("traccarPositions");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="5">
    <title>Live Tracking - Smart Vehicle Fleet</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        .table-custom thead th {
            background-color: #1a6fc4;
            color: #ffffff;
            font-weight: 600;
            white-space: nowrap;
        }
        .table-custom tbody tr {
            transition: background-color 0.2s ease-in-out;
        }
        .table-custom tbody tr:hover {
            background-color: #eef4fb;
        }
        .status-moving {
            color: #198754;
            font-weight: bold;
            background-color: #d1e7dd;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 0.82em;
            display: inline-block;
        }
        .status-stopped {
            color: #dc3545;
            font-weight: bold;
            background-color: #f8d7da;
            padding: 3px 10px;
            border-radius: 20px;
            font-size: 0.82em;
            display: inline-block;
        }
        .refresh-badge {
            font-size: 0.78rem;
            background-color: #e8f4fd;
            color: #1a6fc4;
            border: 1px solid #bee3f8;
            border-radius: 20px;
            padding: 3px 12px;
        }
        .loc-link {
            text-decoration: none;
            color: #0d6efd;
            font-weight: 500;
        }
        .loc-link:hover { text-decoration: underline; }
    </style>
</head>
<body class="bg-light">

    <!-- Navbar -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
        <div class="container-fluid px-4">
            <a class="navbar-brand fw-bold" href="dashboard.jsp">
                <i class="bi bi-truck-front-fill me-2 text-primary"></i>FleetTracker
            </a>
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarContent">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                    <li class="nav-item">
                        <a class="nav-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i>Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="live-vehicle-tracking"><i class="bi bi-table me-1"></i>Live Tracking</a>
                    </li>
                </ul>
                <div class="d-flex align-items-center gap-2">
                    <span class="text-light">
                        <i class="bi bi-person-circle me-1"></i>
                        <strong><%= currentUser.getName() != null ? currentUser.getName() : currentUser.getEmail() %></strong>
                    </span>
                    <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline-light btn-sm ms-2">
                        <i class="bi bi-box-arrow-right me-1"></i>Logout
                    </a>
                </div>
            </div>
        </div>
    </nav>

    <!-- Page Content -->
    <div class="container py-5">
        <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
            <h4 class="mb-0 fw-bold">
                <i class="bi bi-broadcast text-primary me-2"></i>Live GPS Tracking
                <small class="text-muted fs-6 fw-normal ms-1">(Traccar Server)</small>
            </h4>
            <div class="d-flex align-items-center gap-2">
                <span class="refresh-badge">
                    <i class="bi bi-arrow-repeat me-1"></i>Auto-refresh: 5s
                </span>
                <button class="btn btn-primary btn-sm shadow-sm" onclick="location.reload();">
                    <i class="bi bi-arrow-clockwise me-1"></i>Refresh Now
                </button>
            </div>
        </div>

        <div class="card border-0 shadow-sm rounded-3 overflow-hidden">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-custom mb-0 align-middle">
                        <thead>
                            <tr>
                                <th class="ps-4">#</th>
                                <th>Latitude</th>
                                <th>Longitude</th>
                                <th>Speed</th>
                                <th>Time (Fix)</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (traccarPositions != null && !traccarPositions.isEmpty()) {
                                    int rowNum = 1;
                                    for (Object[] pos : traccarPositions) {
                                        double lat   = (Double)    pos[0];
                                        double lng   = (Double)    pos[1];
                                        double speed = (Double)    pos[2];
                                        Timestamp fixtime = (Timestamp) pos[3];
                                        boolean isMoving  = speed > 0;
                            %>
                            <tr>
                                <td class="ps-4 text-muted small"><%= rowNum++ %></td>
                                <td>
                                    <a href="https://www.google.com/maps/search/?api=1&query=<%= lat %>,<%= lng %>"
                                       target="_blank" class="loc-link">
                                        <i class="bi bi-pin-map-fill text-danger me-1"></i>
                                        <%= String.format("%.6f", lat) %>
                                    </a>
                                </td>
                                <td class="text-secondary"><%= String.format("%.6f", lng) %></td>
                                <td>
                                    <% if (isMoving) { %>
                                        <span class="fw-bold text-dark"><%= String.format("%.2f", speed) %> km/h</span>
                                    <% } else { %>
                                        <span class="text-muted">0.00 km/h</span>
                                    <% } %>
                                </td>
                                <td class="text-secondary small">
                                    <i class="bi bi-clock me-1"></i>
                                    <%= fixtime != null ? fixtime.toString().replace(".0", "") : "N/A" %>
                                </td>
                                <td>
                                    <% if (isMoving) { %>
                                        <span class="status-moving"><i class="bi bi-truck me-1"></i>Moving</span>
                                    <% } else { %>
                                        <span class="status-stopped"><i class="bi bi-sign-stop-fill me-1"></i>Stopped</span>
                                    <% } %>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="6" class="text-center py-5 text-muted">
                                    <i class="bi bi-satellite fs-2 d-block mb-3 text-secondary"></i>
                                    <h5>No GPS data available</h5>
                                    <p class="mb-0">Ensure your Traccar server is running and devices are transmitting.</p>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
            <% if (traccarPositions != null && !traccarPositions.isEmpty()) { %>
            <div class="card-footer bg-light py-3 px-4 border-top">
                <small class="text-muted">
                    <i class="bi bi-info-circle me-1"></i>
                    Showing latest <strong><%= traccarPositions.size() %></strong> position(s) from Traccar.
                    Page auto-refreshes every <strong>5 seconds</strong>.
                </small>
            </div>
            <% } %>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
