<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.model.Vehicle, com.fleet.model.Driver" %>
<%@ page import="com.fleet.dao.VehicleAssignmentDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    VehicleAssignmentDAO dao = new VehicleAssignmentDAO();
    List<Vehicle> availableVehicles = dao.getAvailableVehicles();
    List<Driver>  availableDrivers  = dao.getAvailableDrivers();

    String errorMessage   = (String) request.getAttribute("errorMessage");
    String selVehicleId   = (String) request.getAttribute("selVehicleId");
    String selDriverId    = (String) request.getAttribute("selDriverId");

    // Default start date = today
    String today = new java.sql.Date(System.currentTimeMillis()).toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assign Vehicle - Fleet Tracker</title>
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
                <li class="nav-item"><a class="nav-link" href="driver-list.jsp"><i class="bi bi-people me-1"></i>Drivers</a></li>
                <li class="nav-item"><a class="nav-link active" href="assignment-list.jsp"><i class="bi bi-arrow-left-right me-1"></i>Assignments</a></li>
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
    <div class="container-fluid">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0 small">
                <li class="breadcrumb-item"><a href="assignment-list.jsp" class="text-decoration-none">Assignments</a></li>
                <li class="breadcrumb-item active">New Assignment</li>
            </ol>
        </nav>
        <h5 class="fw-bold mt-1 mb-0"><i class="bi bi-link-45deg me-2 text-primary"></i>Assign Driver to Vehicle</h5>
    </div>
</div>

<div class="container-fluid px-4 py-4">
    <div class="row justify-content-center">
        <div class="col-lg-8 col-xl-7">

            <% if (errorMessage != null) { %>
            <div class="alert alert-danger py-2 alert-dismissible fade show">
                <i class="bi bi-exclamation-triangle me-2"></i><%= errorMessage %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <!-- Availability Info -->
            <div class="row g-3 mb-4">
                <div class="col-6">
                    <div class="card border-0 shadow-sm text-center py-3">
                        <div class="fs-2 fw-bold text-success"><%= availableVehicles.size() %></div>
                        <div class="text-muted small">Available Vehicles</div>
                    </div>
                </div>
                <div class="col-6">
                    <div class="card border-0 shadow-sm text-center py-3">
                        <div class="fs-2 fw-bold text-primary"><%= availableDrivers.size() %></div>
                        <div class="text-muted small">Available Drivers</div>
                    </div>
                </div>
            </div>

            <% if (availableVehicles.isEmpty() || availableDrivers.isEmpty()) { %>
            <div class="alert alert-warning">
                <i class="bi bi-exclamation-circle me-2"></i>
                <% if (availableVehicles.isEmpty() && availableDrivers.isEmpty()) { %>
                    No available vehicles <strong>and</strong> no available drivers. All are currently assigned.
                <% } else if (availableVehicles.isEmpty()) { %>
                    No available vehicles. All active vehicles are already assigned.
                <% } else { %>
                    No available drivers. All active drivers are currently assigned.
                <% } %>
                <a href="assignment-list.jsp" class="alert-link ms-2">View current assignments →</a>
            </div>
            <% } %>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-semibold text-secondary"><i class="bi bi-info-circle me-2"></i>Assignment Details</h6>
                </div>
                <div class="card-body p-4">
                    <form action="<%= request.getContextPath() %>/assign-vehicle" method="post"
                          novalidate id="assignForm">

                        <!-- Vehicle Selection -->
                        <div class="mb-3">
                            <label for="vehicleId" class="form-label small fw-semibold">
                                Select Vehicle <span class="text-danger">*</span>
                            </label>
                            <select class="form-select" id="vehicleId" name="vehicleId" required
                                    <%= availableVehicles.isEmpty() ? "disabled" : "" %>>
                                <option value="">-- Choose an available vehicle --</option>
                                <% for (Vehicle v : availableVehicles) {
                                     boolean sel = (selVehicleId != null && selVehicleId.equals(String.valueOf(v.getId())));
                                %>
                                <option value="<%= v.getId() %>" <%= sel ? "selected" : "" %>>
                                    <%= v.getVehicleNumber() %> — <%= v.getModel() %> (<%= v.getVehicleType() %>)
                                </option>
                                <% } %>
                            </select>
                            <div class="form-text">Only Active, unassigned vehicles are listed.</div>
                        </div>

                        <!-- Driver Selection -->
                        <div class="mb-3">
                            <label for="driverId" class="form-label small fw-semibold">
                                Select Driver <span class="text-danger">*</span>
                            </label>
                            <select class="form-select" id="driverId" name="driverId" required
                                    <%= availableDrivers.isEmpty() ? "disabled" : "" %>>
                                <option value="">-- Choose an available driver --</option>
                                <% for (Driver d : availableDrivers) {
                                     boolean sel = (selDriverId != null && selDriverId.equals(String.valueOf(d.getId())));
                                %>
                                <option value="<%= d.getId() %>" <%= sel ? "selected" : "" %>>
                                    <%= d.getName() %> — License: <%= d.getLicenseNumber() %>
                                </option>
                                <% } %>
                            </select>
                            <div class="form-text">Only Active, unassigned drivers are listed.</div>
                        </div>

                        <!-- Start Date -->
                        <div class="mb-3">
                            <label for="startDate" class="form-label small fw-semibold">
                                Assignment Start Date <span class="text-danger">*</span>
                            </label>
                            <input type="date" class="form-control" id="startDate" name="startDate"
                                   value="<%= today %>" required>
                        </div>

                        <!-- Notes -->
                        <div class="mb-4">
                            <label for="notes" class="form-label small fw-semibold">Notes <span class="text-muted fw-normal">(optional)</span></label>
                            <textarea class="form-control" id="notes" name="notes" rows="2"
                                      placeholder="Any additional notes about this assignment..."></textarea>
                        </div>

                        <hr class="my-3">
                        <div class="d-flex gap-2 justify-content-end">
                            <a href="assignment-list.jsp" class="btn btn-outline-secondary">
                                <i class="bi bi-x-circle me-1"></i>Cancel
                            </a>
                            <button type="submit" class="btn btn-primary px-4"
                                    <%= (availableVehicles.isEmpty() || availableDrivers.isEmpty()) ? "disabled" : "" %>>
                                <i class="bi bi-link-45deg me-1"></i>Create Assignment
                            </button>
                        </div>
                    </form>
                </div>
            </div>

        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById('assignForm').addEventListener('submit', function (e) {
        if (!this.checkValidity()) { e.preventDefault(); e.stopPropagation(); }
        this.classList.add('was-validated');
    });
</script>
</body>
</html>
