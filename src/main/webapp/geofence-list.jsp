<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.model.Vehicle, com.fleet.dto.GeofenceView, com.fleet.dao.VehicleDAO, com.fleet.dao.GeofenceDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    String role = currentUser.getRole();
    if (!"Admin".equalsIgnoreCase(role) && !"Manager".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    }

    GeofenceDAO geofenceDAO = new GeofenceDAO();
    VehicleDAO vehicleDAO = new VehicleDAO();
    List<GeofenceView> geofences = geofenceDAO.getAllGeofences();
    List<Vehicle> vehicles = vehicleDAO.getAllVehicles();

    String successMsg = (String) session.getAttribute("successMessage");
    String errorMsg = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Geofences - Fleet Tracker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold" href="dashboard.jsp"><i class="bi bi-truck-front-fill me-2 text-primary"></i>FleetTracker</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="nav">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i>Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="vehicle-list.jsp"><i class="bi bi-truck me-1"></i>Vehicles</a></li>
                <li class="nav-item"><a class="nav-link" href="driver-list.jsp"><i class="bi bi-people me-1"></i>Drivers</a></li>
                <li class="nav-item"><a class="nav-link" href="assignment-list.jsp"><i class="bi bi-arrow-left-right me-1"></i>Assignments</a></li>
                <li class="nav-item"><a class="nav-link" href="live-tracking.jsp"><i class="bi bi-broadcast me-1"></i>Live Map</a></li>
                <li class="nav-item"><a class="nav-link" href="maintenance-notifications.jsp"><i class="bi bi-tools me-1"></i>Maintenance</a></li>
                <li class="nav-item"><a class="nav-link active" href="geofence-list.jsp"><i class="bi bi-bounding-box-circles me-1"></i>Geofences</a></li>
                <li class="nav-item"><a class="nav-link" href="geofence-alerts.jsp"><i class="bi bi-exclamation-triangle me-1"></i>Alerts</a></li>
            </ul>
            <div class="d-flex align-items-center gap-2">
                <span class="text-light small"><i class="bi bi-person-circle me-1"></i><%= currentUser.getName() != null ? currentUser.getName() : currentUser.getEmail() %></span>
                <span class="badge bg-secondary"><%= role %></span>
                <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline-light btn-sm ms-2">
                    <i class="bi bi-box-arrow-right me-1"></i>Logout
                </a>
            </div>
        </div>
    </div>
</nav>

<div class="bg-white border-bottom py-3 px-4 shadow-sm">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <div>
            <h5 class="mb-0 fw-bold"><i class="bi bi-bounding-box-circles me-2 text-primary"></i>Geofence Management</h5>
            <small class="text-muted">Create active operating zones and monitor vehicles outside assigned boundaries</small>
        </div>
        <a href="geofence-alerts.jsp" class="btn btn-outline-danger btn-sm">
            <i class="bi bi-exclamation-triangle me-1"></i>View Alerts
        </a>
    </div>
</div>

<div class="container-fluid px-4 py-4">
    <% if (successMsg != null) { %>
    <div class="alert alert-success alert-dismissible fade show py-2" role="alert">
        <i class="bi bi-check-circle me-2"></i><%= successMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert alert-danger alert-dismissible fade show py-2" role="alert">
        <i class="bi bi-exclamation-circle me-2"></i><%= errorMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <div class="row g-4">
        <div class="col-lg-4">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-3">
                    <span class="fw-semibold"><i class="bi bi-plus-circle me-2 text-primary"></i>Add Geofence</span>
                </div>
                <div class="card-body">
                    <form method="post" action="<%= request.getContextPath() %>/geofence" class="row g-3">
                        <div class="col-12">
                            <label class="form-label small fw-semibold text-muted">Vehicle</label>
                            <select class="form-select form-select-sm" name="vehicleId" required>
                                <option value="">Select vehicle</option>
                                <% for (Vehicle v : vehicles) { %>
                                <option value="<%= v.getId() %>"><%= v.getVehicleNumber() %> - <%= v.getModel() %></option>
                                <% } %>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-semibold text-muted">Fence Name</label>
                            <input type="text" class="form-control form-control-sm" name="fenceName" placeholder="Mumbai Operating Zone" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold text-muted">Center Latitude</label>
                            <input type="number" step="0.000001" class="form-control form-control-sm" name="centerLatitude" placeholder="19.0760" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold text-muted">Center Longitude</label>
                            <input type="number" step="0.000001" class="form-control form-control-sm" name="centerLongitude" placeholder="72.8777" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold text-muted">Radius (km)</label>
                            <input type="number" step="0.1" min="0.1" class="form-control form-control-sm" name="radiusKm" placeholder="10" required>
                        </div>
                        <div class="col-md-6 d-flex align-items-end">
                            <div class="form-check form-switch mb-1">
                                <input class="form-check-input" type="checkbox" role="switch" name="active" id="active" checked>
                                <label class="form-check-label small" for="active">Active</label>
                            </div>
                        </div>
                        <div class="col-12">
                            <button type="submit" class="btn btn-primary btn-sm w-100">
                                <i class="bi bi-save me-1"></i>Save Geofence
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                    <span class="fw-semibold text-secondary"><i class="bi bi-list-ul me-1"></i><%= geofences.size() %> Geofence(s)</span>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th class="ps-3">Fence</th>
                                    <th>Vehicle</th>
                                    <th>Center</th>
                                    <th>Radius</th>
                                    <th>Status</th>
                                    <th class="text-center pe-3">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (geofences.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-bounding-box fs-2 d-block mb-2"></i>
                                        No geofences configured yet.
                                    </td>
                                </tr>
                            <% } else { for (GeofenceView g : geofences) {
                                String statusClass = g.isActive() ? "bg-success" : "bg-secondary";
                                String statusText = g.isActive() ? "Active" : "Inactive";
                                String toggleTitle = g.isActive() ? "Deactivate" : "Activate";
                                String toggleIcon = g.isActive() ? "bi-pause-circle" : "bi-play-circle";
                            %>
                                <tr>
                                    <td class="ps-3">
                                        <div class="fw-semibold"><%= g.getFenceName() %></div>
                                        <div class="small text-muted">Created <%= g.getCreatedAt() != null ? g.getCreatedAt() : "-" %></div>
                                    </td>
                                    <td>
                                        <span class="badge bg-dark"><%= g.getVehicleNumber() %></span>
                                        <div class="small text-muted mt-1"><%= g.getVehicleModel() %></div>
                                    </td>
                                    <td class="small">
                                        <%= String.format("%.6f", g.getCenterLatitude()) %>,<br>
                                        <%= String.format("%.6f", g.getCenterLongitude()) %>
                                    </td>
                                    <td><span class="badge bg-light text-dark border"><%= String.format("%.1f", g.getRadiusKm()) %> km</span></td>
                                    <td>
                                        <span class="badge <%= statusClass %>">
                                            <%= statusText %>
                                        </span>
                                    </td>
                                    <td class="text-center pe-3">
                                        <form method="post" action="<%= request.getContextPath() %>/geofence" class="d-inline">
                                            <input type="hidden" name="action" value="toggle">
                                            <input type="hidden" name="id" value="<%= g.getId() %>">
                                            <input type="hidden" name="active" value="<%= !g.isActive() %>">
                                            <button type="submit" class="btn btn-outline-secondary btn-sm" title="<%= toggleTitle %>">
                                                <i class="bi <%= toggleIcon %>"></i>
                                            </button>
                                        </form>
                                        <form method="post" action="<%= request.getContextPath() %>/geofence" class="d-inline" onsubmit="return confirm('Delete geofence <%= g.getFenceName() %>?')">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= g.getId() %>">
                                            <button type="submit" class="btn btn-outline-danger btn-sm" title="Delete">
                                                <i class="bi bi-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
