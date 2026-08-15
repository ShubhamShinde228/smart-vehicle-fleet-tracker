<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.model.Driver, com.fleet.dao.DriverDAO" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) { response.sendRedirect("driver-list.jsp"); return; }

    Driver driver = new DriverDAO().getDriverById(Integer.parseInt(idParam));
    if (driver == null) { response.sendRedirect("driver-list.jsp"); return; }

    String statusBadge = "bg-secondary";
    if ("Active".equals(driver.getStatus()))   statusBadge = "bg-success";
    else if ("On Leave".equals(driver.getStatus())) statusBadge = "bg-warning text-dark";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Driver Details - <%= driver.getName() %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<!-- ═══════════ Navbar ═══════════ -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold" href="#"><i class="bi bi-truck-front-fill me-2 text-primary"></i>FleetTracker</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="nav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item"><a class="nav-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i>Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="vehicle-list.jsp"><i class="bi bi-truck me-1"></i>Vehicles</a></li>
                <li class="nav-item"><a class="nav-link active" href="driver-list.jsp"><i class="bi bi-people me-1"></i>Drivers</a></li>
            </ul>
            <div class="d-flex align-items-center gap-2">
                <span class="text-light small"><i class="bi bi-person-circle me-1"></i><%= currentUser.getName() %></span>
                <span class="badge bg-secondary"><%= currentUser.getRole() %></span>
                <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline-light btn-sm ms-2">
                    <i class="bi bi-box-arrow-right me-1"></i>Logout
                </a>
            </div>
        </div>
    </div>
</nav>

<!-- ═══════════ Page Header ═══════════ -->
<div class="bg-white border-bottom py-3 px-4 shadow-sm">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <div>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0 small">
                    <li class="breadcrumb-item"><a href="driver-list.jsp" class="text-decoration-none">Drivers</a></li>
                    <li class="breadcrumb-item active">Details</li>
                </ol>
            </nav>
            <h5 class="fw-bold mt-1 mb-0">
                <i class="bi bi-person-badge me-2 text-primary"></i><%= driver.getName() %>
                <span class="badge <%= statusBadge %> fs-6 ms-2"><%= driver.getStatus() %></span>
            </h5>
        </div>
        <div class="d-flex gap-2">
            <a href="edit-driver.jsp?id=<%= driver.getId() %>" class="btn btn-warning btn-sm">
                <i class="bi bi-pencil me-1"></i>Edit
            </a>
            <a href="<%= request.getContextPath() %>/delete-driver?id=<%= driver.getId() %>"
               class="btn btn-outline-danger btn-sm"
               onclick="return confirm('Delete driver <%= driver.getName() %>? This cannot be undone.')">
                <i class="bi bi-trash me-1"></i>Delete
            </a>
        </div>
    </div>
</div>

<div class="container-fluid px-4 py-4">
    <div class="row justify-content-center">
        <div class="col-lg-9 col-xl-8">

            <!-- ── Profile Card ─────────────────────────────────────────────── -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-body">
                    <div class="d-flex align-items-center gap-4 py-2">
                        <div class="bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center flex-shrink-0"
                             style="width:72px;height:72px;">
                            <i class="bi bi-person-fill fs-2 text-primary"></i>
                        </div>
                        <div>
                            <h4 class="fw-bold mb-1"><%= driver.getName() %></h4>
                            <div class="text-muted small">
                                <i class="bi bi-envelope me-1"></i><%= driver.getEmail() %>
                                <% if (driver.getPhone() != null && !driver.getPhone().isEmpty()) { %>
                                &nbsp;&bull;&nbsp;<i class="bi bi-telephone me-1"></i><%= driver.getPhone() %>
                                <% } %>
                            </div>
                            <span class="badge <%= statusBadge %> mt-1"><%= driver.getStatus() %></span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ── Personal Info ────────────────────────────────────────────── -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-semibold text-secondary"><i class="bi bi-card-list me-2"></i>Personal Information</h6>
                </div>
                <div class="card-body">
                    <div class="row g-4">
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Full Name</div>
                            <div class="fw-semibold"><%= driver.getName() %></div>
                        </div>
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Email</div>
                            <div><a href="mailto:<%= driver.getEmail() %>" class="text-decoration-none"><%= driver.getEmail() %></a></div>
                        </div>
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Phone</div>
                            <div><%= driver.getPhone() != null && !driver.getPhone().isEmpty() ? driver.getPhone() : "<span class='text-muted'>Not provided</span>" %></div>
                        </div>
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Emergency Contact</div>
                            <div><%= driver.getEmergencyContact() != null && !driver.getEmergencyContact().isEmpty() ? driver.getEmergencyContact() : "<span class='text-muted'>Not provided</span>" %></div>
                        </div>
                        <div class="col-12">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Address</div>
                            <div><%= driver.getAddress() != null && !driver.getAddress().isEmpty() ? driver.getAddress() : "<span class='text-muted'>Not provided</span>" %></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ── License Info ─────────────────────────────────────────────── -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-semibold text-secondary"><i class="bi bi-card-text me-2"></i>License Information</h6>
                </div>
                <div class="card-body">
                    <div class="row g-4">
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">License Number</div>
                            <span class="badge bg-dark fs-6"><%= driver.getLicenseNumber() %></span>
                        </div>
                        <div class="col-sm-6">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">License Expiry Date</div>
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-calendar-event text-warning"></i>
                                <%= driver.getLicenseExpiry() != null ? driver.getLicenseExpiry() : "<span class='text-muted'>Not set</span>" %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Back Button -->
            <div class="d-flex gap-2">
                <a href="driver-list.jsp" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i>Back to List
                </a>
                <a href="edit-driver.jsp?id=<%= driver.getId() %>" class="btn btn-warning btn-sm">
                    <i class="bi bi-pencil me-1"></i>Edit This Driver
                </a>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
