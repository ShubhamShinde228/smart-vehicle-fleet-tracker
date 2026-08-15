<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.model.Vehicle, com.fleet.dao.VehicleDAO" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) { response.sendRedirect("vehicle-list.jsp"); return; }

    Vehicle vehicle = new VehicleDAO().getVehicleById(Integer.parseInt(idParam));
    if (vehicle == null) { response.sendRedirect("vehicle-list.jsp"); return; }

    // ── Status badge class ─────────────────────────────────────────────────
    String statusBadge = "bg-secondary";
    if ("Active".equals(vehicle.getStatus())) statusBadge = "bg-success";
    else if ("In Maintenance".equals(vehicle.getStatus())) statusBadge = "bg-warning text-dark";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle Details - <%= vehicle.getVehicleNumber() %></title>
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
                <li class="nav-item"><a class="nav-link active" href="vehicle-list.jsp"><i class="bi bi-truck me-1"></i>Vehicles</a></li>
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
                    <li class="breadcrumb-item"><a href="vehicle-list.jsp" class="text-decoration-none">Vehicles</a></li>
                    <li class="breadcrumb-item active">Details</li>
                </ol>
            </nav>
            <h5 class="fw-bold mt-1 mb-0"><i class="bi bi-truck me-2 text-primary"></i><%= vehicle.getVehicleNumber() %>
                <span class="badge <%= statusBadge %> fs-6 ms-2"><%= vehicle.getStatus() %></span>
            </h5>
        </div>
        <div class="d-flex gap-2">
            <a href="edit-vehicle.jsp?id=<%= vehicle.getId() %>" class="btn btn-warning btn-sm">
                <i class="bi bi-pencil me-1"></i>Edit
            </a>
            <a href="<%= request.getContextPath() %>/delete-vehicle?id=<%= vehicle.getId() %>"
               class="btn btn-outline-danger btn-sm"
               onclick="return confirm('Delete vehicle <%= vehicle.getVehicleNumber() %>? This cannot be undone.')">
                <i class="bi bi-trash me-1"></i>Delete
            </a>
        </div>
    </div>
</div>

<div class="container-fluid px-4 py-4">
    <div class="row justify-content-center">
        <div class="col-lg-9 col-xl-8">

            <!-- ── Basic Info Card ──────────────────────────────────────────── -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom d-flex justify-content-between py-3">
                    <h6 class="mb-0 fw-semibold text-secondary"><i class="bi bi-card-list me-2"></i>Basic Information</h6>
                    <span class="badge bg-dark"><%= vehicle.getVehicleType() %></span>
                </div>
                <div class="card-body">
                    <div class="row g-4">
                        <div class="col-sm-6 col-md-4">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Vehicle Number</div>
                            <div class="fw-bold fs-5"><%= vehicle.getVehicleNumber() %></div>
                        </div>
                        <div class="col-sm-6 col-md-4">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Model</div>
                            <div class="fw-semibold"><%= vehicle.getModel() %></div>
                        </div>
                        <div class="col-sm-6 col-md-4">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Status</div>
                            <span class="badge <%= statusBadge %> fs-6"><%= vehicle.getStatus() %></span>
                        </div>
                        <div class="col-sm-6 col-md-4">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Vehicle Type</div>
                            <div><%= vehicle.getVehicleType() %></div>
                        </div>
                        <div class="col-sm-6 col-md-4">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Fuel Type</div>
                            <div><%= vehicle.getFuelType() %></div>
                        </div>
                        <div class="col-sm-6 col-md-4">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Fuel Capacity</div>
                            <div><%= vehicle.getFuelCapacity() > 0 ? vehicle.getFuelCapacity() + " L" : "N/A" %></div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ── Dates Card ───────────────────────────────────────────────── -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-semibold text-secondary"><i class="bi bi-calendar3 me-2"></i>Key Dates</h6>
                </div>
                <div class="card-body">
                    <div class="row g-4">
                        <div class="col-sm-4">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Registration Date</div>
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-calendar-check text-success"></i>
                                <%= vehicle.getRegistrationDate() != null ? vehicle.getRegistrationDate() : "<span class='text-muted'>Not set</span>" %>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Insurance Expiry</div>
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-shield-check text-warning"></i>
                                <%= vehicle.getInsuranceExpiry() != null ? vehicle.getInsuranceExpiry() : "<span class='text-muted'>Not set</span>" %>
                            </div>
                        </div>
                        <div class="col-sm-4">
                            <div class="text-muted small fw-semibold text-uppercase mb-1">Maintenance Due</div>
                            <div class="d-flex align-items-center gap-2">
                                <i class="bi bi-tools text-danger"></i>
                                <%= vehicle.getMaintenanceDueDate() != null ? vehicle.getMaintenanceDueDate() : "<span class='text-muted'>Not set</span>" %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Back Button -->
            <div class="d-flex gap-2">
                <a href="vehicle-list.jsp" class="btn btn-outline-secondary btn-sm">
                    <i class="bi bi-arrow-left me-1"></i>Back to List
                </a>
                <a href="edit-vehicle.jsp?id=<%= vehicle.getId() %>" class="btn btn-warning btn-sm">
                    <i class="bi bi-pencil me-1"></i>Edit This Vehicle
                </a>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
