<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    String errorMessage = (String) request.getAttribute("errorMessage");
    // Retain form values on validation failure
    String rVehicleNumber = (String) request.getAttribute("vehicleNumber");
    String rModel         = (String) request.getAttribute("model");
    String rVehicleType   = (String) request.getAttribute("vehicleType");
    String rFuelType      = (String) request.getAttribute("fuelType");
    String rFuelCapacity  = (String) request.getAttribute("fuelCapacity");
    String rStatus        = (String) request.getAttribute("status");
    if (rStatus == null) rStatus = "Active";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Vehicle - Fleet Tracker</title>
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
                <li class="breadcrumb-item active">Add New Vehicle</li>
            </ol>
        </nav>
        <h5 class="fw-bold mt-1 mb-0"><i class="bi bi-plus-circle me-2 text-primary"></i>Add New Vehicle</h5>
    </div>
</div>

<div class="container-fluid px-4 py-4">
    <div class="row justify-content-center">
        <div class="col-lg-9 col-xl-8">

            <% if (errorMessage != null) { %>
            <div class="alert alert-danger py-2 alert-dismissible fade show" role="alert">
                <i class="bi bi-exclamation-triangle me-2"></i><%= errorMessage %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-semibold text-secondary"><i class="bi bi-info-circle me-2"></i>Vehicle Information</h6>
                </div>
                <div class="card-body p-4">
                    <form action="<%= request.getContextPath() %>/add-vehicle" method="post" novalidate id="addVehicleForm">

                        <!-- Row 1: Vehicle Number + Model -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="vehicleNumber" class="form-label small fw-semibold">Vehicle Number <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="vehicleNumber" name="vehicleNumber"
                                       placeholder="e.g. MH01AB1234"
                                       value="<%= rVehicleNumber != null ? rVehicleNumber : "" %>" required>
                                <div class="form-text text-muted">Must be unique across the fleet.</div>
                            </div>
                            <div class="col-md-6">
                                <label for="model" class="form-label small fw-semibold">Model <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="model" name="model"
                                       placeholder="e.g. Toyota Innova"
                                       value="<%= rModel != null ? rModel : "" %>" required>
                            </div>
                        </div>

                        <!-- Row 2: Vehicle Type + Fuel Type -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="vehicleType" class="form-label small fw-semibold">Vehicle Type <span class="text-danger">*</span></label>
                                <select class="form-select" id="vehicleType" name="vehicleType" required>
                                    <option value="" disabled <%= rVehicleType == null ? "selected" : "" %>>-- Select Type --</option>
                                    <option value="Sedan"      <%= "Sedan".equals(rVehicleType) ? "selected" : "" %>>Sedan</option>
                                    <option value="SUV"        <%= "SUV".equals(rVehicleType) ? "selected" : "" %>>SUV</option>
                                    <option value="Hatchback"  <%= "Hatchback".equals(rVehicleType) ? "selected" : "" %>>Hatchback</option>
                                    <option value="Truck"      <%= "Truck".equals(rVehicleType) ? "selected" : "" %>>Truck</option>
                                    <option value="Van"        <%= "Van".equals(rVehicleType) ? "selected" : "" %>>Van</option>
                                    <option value="Bus"        <%= "Bus".equals(rVehicleType) ? "selected" : "" %>>Bus</option>
                                    <option value="Motorcycle" <%= "Motorcycle".equals(rVehicleType) ? "selected" : "" %>>Motorcycle</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label for="fuelType" class="form-label small fw-semibold">Fuel Type <span class="text-danger">*</span></label>
                                <select class="form-select" id="fuelType" name="fuelType" required>
                                    <option value="" disabled <%= rFuelType == null ? "selected" : "" %>>-- Select Fuel --</option>
                                    <option value="Petrol"  <%= "Petrol".equals(rFuelType) ? "selected" : "" %>>Petrol</option>
                                    <option value="Diesel"  <%= "Diesel".equals(rFuelType) ? "selected" : "" %>>Diesel</option>
                                    <option value="Electric"<%= "Electric".equals(rFuelType) ? "selected" : "" %>>Electric</option>
                                    <option value="Hybrid"  <%= "Hybrid".equals(rFuelType) ? "selected" : "" %>>Hybrid</option>
                                    <option value="CNG"     <%= "CNG".equals(rFuelType) ? "selected" : "" %>>CNG</option>
                                </select>
                            </div>
                        </div>

                        <!-- Row 3: Fuel Capacity + Status -->
                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label for="fuelCapacity" class="form-label small fw-semibold">Fuel Capacity (Litres)</label>
                                <input type="number" class="form-control" id="fuelCapacity" name="fuelCapacity"
                                       placeholder="e.g. 60" min="0" step="0.5"
                                       value="<%= rFuelCapacity != null ? rFuelCapacity : "" %>">
                            </div>
                            <div class="col-md-6">
                                <label for="status" class="form-label small fw-semibold">Status <span class="text-danger">*</span></label>
                                <select class="form-select" id="status" name="status" required>
                                    <option value="Active"         <%= "Active".equals(rStatus) ? "selected" : "" %>>Active</option>
                                    <option value="Inactive"       <%= "Inactive".equals(rStatus) ? "selected" : "" %>>Inactive</option>
                                    <option value="In Maintenance" <%= "In Maintenance".equals(rStatus) ? "selected" : "" %>>In Maintenance</option>
                                </select>
                            </div>
                        </div>

                        <!-- Row 4: Dates -->
                        <div class="row g-3 mb-4">
                            <div class="col-md-4">
                                <label for="registrationDate" class="form-label small fw-semibold">Registration Date</label>
                                <input type="date" class="form-control" id="registrationDate" name="registrationDate">
                            </div>
                            <div class="col-md-4">
                                <label for="insuranceExpiry" class="form-label small fw-semibold">Insurance Expiry</label>
                                <input type="date" class="form-control" id="insuranceExpiry" name="insuranceExpiry">
                            </div>
                            <div class="col-md-4">
                                <label for="maintenanceDueDate" class="form-label small fw-semibold">Maintenance Due Date</label>
                                <input type="date" class="form-control" id="maintenanceDueDate" name="maintenanceDueDate">
                            </div>
                        </div>

                        <!-- Buttons -->
                        <hr class="my-3">
                        <div class="d-flex gap-2 justify-content-end">
                            <a href="vehicle-list.jsp" class="btn btn-outline-secondary">
                                <i class="bi bi-x-circle me-1"></i>Cancel
                            </a>
                            <button type="submit" class="btn btn-primary px-4">
                                <i class="bi bi-plus-circle me-1"></i>Add Vehicle
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
    // Bootstrap native validation
    document.getElementById('addVehicleForm').addEventListener('submit', function(e) {
        if (!this.checkValidity()) { e.preventDefault(); e.stopPropagation(); }
        this.classList.add('was-validated');
    });
</script>
</body>
</html>
