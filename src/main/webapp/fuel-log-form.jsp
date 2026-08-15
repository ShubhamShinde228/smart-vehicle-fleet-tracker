<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.model.Vehicle, com.fleet.dao.VehicleDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    String role = currentUser.getRole();

    VehicleDAO vDAO = new VehicleDAO();
    List<Vehicle> vehicles = vDAO.getAllVehicles();

    String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Log Fuel Fill-up - FleetTracker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background: #f0f4f8; }
        .navbar { background: #0a1628 !important; }
        .form-card {
            border-radius: 16px; border: none;
            box-shadow: 0 4px 24px rgba(0,0,0,.1);
            max-width: 700px; margin: 0 auto;
        }
        .form-card .card-header {
            background: linear-gradient(135deg, #1e3a5f 0%, #0d6efd 100%);
            color: white; border-radius: 16px 16px 0 0; padding: 1.4rem 1.5rem;
        }
        .form-label { font-size: .84rem; font-weight: 600; color: #495057; }
        .form-control, .form-select {
            border-radius: 8px; border: 1.5px solid #dee2e6;
            transition: border-color .2s, box-shadow .2s;
        }
        .form-control:focus, .form-select:focus {
            border-color: #0d6efd;
            box-shadow: 0 0 0 .2rem rgba(13,110,253,.15);
        }
        .cost-preview {
            background: linear-gradient(135deg, #e8f4fd, #f8f9fa);
            border-radius: 10px; padding: 1rem 1.25rem;
            border: 1.5px solid #cce5ff;
        }
        .cost-preview .cost-value { font-size: 1.6rem; font-weight: 700; color: #0d6efd; }
        .input-group-text { background: #f8f9fa; border-color: #dee2e6; font-size: .85rem; }
    </style>
</head>
<body>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark shadow-sm">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold" href="dashboard.jsp">
            <i class="bi bi-truck-front-fill me-2 text-primary"></i>FleetTracker
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav2">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="nav2">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i>Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="vehicle-list.jsp"><i class="bi bi-truck me-1"></i>Vehicles</a></li>
                <li class="nav-item"><a class="nav-link active" href="fuel-logs.jsp"><i class="bi bi-fuel-pump me-1"></i>Fuel</a></li>
            </ul>
            <div class="d-flex align-items-center gap-2">
                <span class="text-light small"><i class="bi bi-person-circle me-1"></i><%= currentUser.getName() %></span>
                <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline-light btn-sm">
                    <i class="bi bi-box-arrow-right me-1"></i>Logout
                </a>
            </div>
        </div>
    </div>
</nav>

<div class="container-fluid px-4 py-4">

    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-3">
        <ol class="breadcrumb small">
            <li class="breadcrumb-item"><a href="dashboard.jsp">Dashboard</a></li>
            <li class="breadcrumb-item"><a href="fuel-logs.jsp">Fuel Logs</a></li>
            <li class="breadcrumb-item active">Log Fill-up</li>
        </ol>
    </nav>

    <div class="form-card card">
        <div class="card-header">
            <h5 class="mb-0 fw-bold"><i class="bi bi-fuel-pump-fill me-2"></i>Log New Fuel Fill-up</h5>
            <small class="opacity-75">Record a fuel fill-up entry for a vehicle</small>
        </div>
        <div class="card-body p-4">

            <form method="post" action="<%= request.getContextPath() %>/add-fuel-log" id="fuelForm">

                <!-- Vehicle & Date -->
                <div class="row g-3 mb-3">
                    <div class="col-md-7">
                        <label class="form-label" for="vehicleId"><i class="bi bi-truck me-1 text-primary"></i>Vehicle *</label>
                        <select class="form-select" name="vehicleId" id="vehicleId" required>
                            <option value="">— Select Vehicle —</option>
                            <% for (Vehicle v : vehicles) { %>
                            <option value="<%= v.getId() %>"><%= v.getVehicleNumber() %> — <%= v.getModel() %> (<%= v.getFuelType() %>)</option>
                            <% } %>
                        </select>
                    </div>
                    <div class="col-md-5">
                        <label class="form-label" for="fillDate"><i class="bi bi-calendar3 me-1 text-primary"></i>Fill Date *</label>
                        <input type="date" class="form-control" name="fillDate" id="fillDate"
                               value="<%= today %>" max="<%= today %>" required>
                    </div>
                </div>

                <!-- Liters & Price -->
                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <label class="form-label" for="liters"><i class="bi bi-droplet-fill me-1 text-info"></i>Liters Filled *</label>
                        <div class="input-group">
                            <input type="number" class="form-control" name="liters" id="liters"
                                   min="0.1" step="0.01" placeholder="e.g. 40.5" required oninput="calcCost()">
                            <span class="input-group-text">L</span>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label" for="costPerLiter"><i class="bi bi-currency-rupee me-1 text-warning"></i>Price per Liter *</label>
                        <div class="input-group">
                            <span class="input-group-text">₹</span>
                            <input type="number" class="form-control" name="costPerLiter" id="costPerLiter"
                                   min="0.01" step="0.01" placeholder="e.g. 105.00" required oninput="calcCost()">
                        </div>
                    </div>
                </div>

                <!-- Auto-calculated Total Cost -->
                <div class="cost-preview mb-3">
                    <div class="small text-muted fw-semibold mb-1"><i class="bi bi-calculator me-1"></i>Calculated Total Cost</div>
                    <div class="cost-value" id="totalCostDisplay">₹ —</div>
                    <div class="small text-muted">Liters × Price per Liter</div>
                </div>

                <!-- Odometer -->
                <div class="mb-3">
                    <label class="form-label" for="odometerKm"><i class="bi bi-speedometer2 me-1 text-success"></i>Current Odometer Reading (km) *</label>
                    <div class="input-group">
                        <input type="number" class="form-control" name="odometerKm" id="odometerKm"
                               min="0" step="1" placeholder="e.g. 52400" required>
                        <span class="input-group-text">km</span>
                    </div>
                    <div class="form-text">Enter the current odometer reading at the time of fill-up.</div>
                </div>

                <!-- Fuel Station -->
                <div class="mb-3">
                    <label class="form-label" for="fuelStation"><i class="bi bi-geo-alt me-1 text-danger"></i>Fuel Station / Location</label>
                    <input type="text" class="form-control" name="fuelStation" id="fuelStation"
                           maxlength="100" placeholder="e.g. HP Petrol Pump, MG Road">
                </div>

                <!-- Notes -->
                <div class="mb-4">
                    <label class="form-label" for="notes"><i class="bi bi-journal-text me-1 text-secondary"></i>Notes</label>
                    <textarea class="form-control" name="notes" id="notes" rows="2"
                              placeholder="Optional notes about this fill-up..."></textarea>
                </div>

                <!-- Buttons -->
                <div class="d-flex gap-2">
                    <button type="submit" class="btn btn-primary px-4" id="btn-submit-fuel">
                        <i class="bi bi-check-circle me-1"></i>Save Fuel Log
                    </button>
                    <a href="fuel-logs.jsp" class="btn btn-outline-secondary">
                        <i class="bi bi-arrow-left me-1"></i>Cancel
                    </a>
                </div>

            </form>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
function calcCost() {
    const liters = parseFloat(document.getElementById('liters').value);
    const price  = parseFloat(document.getElementById('costPerLiter').value);
    const display = document.getElementById('totalCostDisplay');
    if (!isNaN(liters) && !isNaN(price) && liters > 0 && price > 0) {
        const total = liters * price;
        display.textContent = '₹ ' + total.toLocaleString('en-IN', {minimumFractionDigits: 2, maximumFractionDigits: 2});
    } else {
        display.textContent = '₹ —';
    }
}

// Pre-fill today's date
document.getElementById('fillDate').value = new Date().toISOString().split('T')[0];
</script>
</body>
</html>
