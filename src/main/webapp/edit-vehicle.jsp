<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.model.Vehicle, com.fleet.dao.VehicleDAO" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    // ── Load vehicle for editing ───────────────────────────────────────────
    Vehicle vehicle = (Vehicle) request.getAttribute("vehicle"); // may be set by servlet on error
    if (vehicle == null) {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect("vehicle-list.jsp"); return;
        }
        vehicle = new VehicleDAO().getVehicleById(Integer.parseInt(idParam));
        if (vehicle == null) { response.sendRedirect("vehicle-list.jsp"); return; }
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Vehicle - Fleet Tracker</title>
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
    <div class="container-fluid">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0 small">
                <li class="breadcrumb-item"><a href="vehicle-list.jsp" class="text-decoration-none">Vehicles</a></li>
                <li class="breadcrumb-item active">Edit Vehicle</li>
            </ol>
        </nav>
        <h5 class="fw-bold mt-1 mb-0">
            <i class="bi bi-pencil-square me-2 text-warning"></i>Edit Vehicle —
            <span class="text-muted"><%= vehicle.getVehicleNumber() %></span>
        </h5>
    </div>
</div>

<div class="container-fluid px-4 py-4">
    <div class="row justify-content-center">
        <div class="col-lg-9 col-xl-8">

            <% if (errorMessage != null) { %>
            <div class="alert alert-danger py-2 alert-dismissible fade show">
                <i class="bi bi-exclamation-triangle me-2"></i><%= errorMessage %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-semibold text-secondary"><i class="bi bi-info-circle me-2"></i>Edit Vehicle Information</h6>
                </div>
                <div class="card-body p-4">
                    <form action="<%= request.getContextPath() %>/update-vehicle" method="post" novalidate id="editVehicleForm">
                        <!-- Hidden ID -->
                        <input type="hidden" name="id" value="<%= vehicle.getId() %>">

                        <!-- Row 1: Vehicle Number + Model -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="vehicleNumber" class="form-label small fw-semibold">Vehicle Number <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="vehicleNumber" name="vehicleNumber"
                                       value="<%= vehicle.getVehicleNumber() %>" required>
                            </div>
                            <div class="col-md-6">
                                <label for="model" class="form-label small fw-semibold">Model <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="model" name="model"
                                       value="<%= vehicle.getModel() %>" required>
                            </div>
                        </div>

                        <!-- Row 2: Vehicle Type + Fuel Type -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="vehicleType" class="form-label small fw-semibold">Vehicle Type <span class="text-danger">*</span></label>
                                <select class="form-select" id="vehicleType" name="vehicleType" required>
                                    <option value="Sedan"     <%= "Sedan".equals(vehicle.getVehicleType()) ? "selected" : "" %>>Sedan</option>
                                    <option value="SUV"       <%= "SUV".equals(vehicle.getVehicleType()) ? "selected" : "" %>>SUV</option>
                                    <option value="Hatchback" <%= "Hatchback".equals(vehicle.getVehicleType()) ? "selected" : "" %>>Hatchback</option>
                                    <option value="Truck"     <%= "Truck".equals(vehicle.getVehicleType()) ? "selected" : "" %>>Truck</option>
                                    <option value="Van"       <%= "Van".equals(vehicle.getVehicleType()) ? "selected" : "" %>>Van</option>
                                    <option value="Bus"       <%= "Bus".equals(vehicle.getVehicleType()) ? "selected" : "" %>>Bus</option>
                                    <option value="Motorcycle"<%= "Motorcycle".equals(vehicle.getVehicleType()) ? "selected" : "" %>>Motorcycle</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="fuelType" class="form-label small fw-semibold">Fuel Type <span class="text-danger">*</span></label>
                                <select class="form-select" id="fuelType" name="fuelType" required>
                                    <option value="Petrol"  <%= "Petrol".equals(vehicle.getFuelType()) ? "selected" : "" %>>Petrol</option>
                                    <option value="Diesel"  <%= "Diesel".equals(vehicle.getFuelType()) ? "selected" : "" %>>Diesel</option>
                                    <option value="Electric"<%= "Electric".equals(vehicle.getFuelType()) ? "selected" : "" %>>Electric</option>
                                    <option value="Hybrid"  <%= "Hybrid".equals(vehicle.getFuelType()) ? "selected" : "" %>>Hybrid</option>
                                    <option value="CNG"     <%= "CNG".equals(vehicle.getFuelType()) ? "selected" : "" %>>CNG</option>
                                </select>
                            </div>
                        </div>

                        <!-- Row 3: Fuel Capacity + Status -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="fuelCapacity" class="form-label small fw-semibold">Fuel Capacity (Litres)</label>
                                <input type="number" class="form-control" id="fuelCapacity" name="fuelCapacity"
                                       value="<%= vehicle.getFuelCapacity() %>" min="0" step="0.5">
                            </div>
                            <div class="col-md-6">
                                <label for="status" class="form-label small fw-semibold">Status <span class="text-danger">*</span></label>
                                <select class="form-select" id="status" name="status" required>
                                    <option value="Active"         <%= "Active".equals(vehicle.getStatus()) ? "selected" : "" %>>Active</option>
                                    <option value="Inactive"       <%= "Inactive".equals(vehicle.getStatus()) ? "selected" : "" %>>Inactive</option>
                                    <option value="In Maintenance" <%= "In Maintenance".equals(vehicle.getStatus()) ? "selected" : "" %>>In Maintenance</option>
                                </select>
                            </div>
                        </div>

                        <!-- Row 4: Dates -->
                        <div class="row g-3 mb-4">
                            <div class="col-md-4">
                                <label for="registrationDate" class="form-label small fw-semibold">Registration Date</label>
                                <input type="date" class="form-control" id="registrationDate" name="registrationDate"
                                       value="<%= vehicle.getRegistrationDate() != null ? vehicle.getRegistrationDate().toString() : "" %>">
                            </div>
                            <div class="col-md-4">
                                <label for="insuranceExpiry" class="form-label small fw-semibold">Insurance Expiry</label>
                                <input type="date" class="form-control" id="insuranceExpiry" name="insuranceExpiry"
                                       value="<%= vehicle.getInsuranceExpiry() != null ? vehicle.getInsuranceExpiry().toString() : "" %>">
                            </div>
                            <div class="col-md-4">
                                <label for="maintenanceDueDate" class="form-label small fw-semibold">Maintenance Due Date</label>
                                <input type="date" class="form-control" id="maintenanceDueDate" name="maintenanceDueDate"
                                       value="<%= vehicle.getMaintenanceDueDate() != null ? vehicle.getMaintenanceDueDate().toString() : "" %>">
                            </div>
                        </div>

                        <hr class="my-3">
                        <div class="d-flex gap-2 justify-content-end">
                            <a href="vehicle-list.jsp" class="btn btn-outline-secondary">
                                <i class="bi bi-x-circle me-1"></i>Cancel
                            </a>
                            <a href="vehicle-details.jsp?id=<%= vehicle.getId() %>" class="btn btn-outline-info">
                                <i class="bi bi-eye me-1"></i>View Details
                            </a>
                            <button type="submit" class="btn btn-warning px-4">
                                <i class="bi bi-save me-1"></i>Save Changes
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
    document.getElementById('editVehicleForm').addEventListener('submit', function(e) {
        if (!this.checkValidity()) { e.preventDefault(); e.stopPropagation(); }
        this.classList.add('was-validated');
    });
</script>
</body>
</html>
