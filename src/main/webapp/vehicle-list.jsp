<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.model.Vehicle, com.fleet.dao.VehicleDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    // ── Search / filter params ─────────────────────────────────────────────
    String search = request.getParameter("search") != null ? request.getParameter("search") : "";
    String filterStatus = request.getParameter("filterStatus") != null ? request.getParameter("filterStatus") : "All";
    String filterType   = request.getParameter("filterType")   != null ? request.getParameter("filterType")   : "All";

    VehicleDAO vehicleDAO = new VehicleDAO();
    List<Vehicle> vehicles = vehicleDAO.searchVehicles(search, filterStatus, filterType);

    // ── Flash messages from session ────────────────────────────────────────
    String successMsg = (String) session.getAttribute("successMessage");
    String errorMsg   = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle List - Fleet Tracker</title>
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
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i>Dashboard</a></li>
                <li class="nav-item"><a class="nav-link active" href="vehicle-list.jsp"><i class="bi bi-truck me-1"></i>Vehicles</a></li>
                <li class="nav-item"><a class="nav-link" href="maintenance-notifications.jsp"><i class="bi bi-tools me-1"></i>Maintenance</a></li>
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
            <h5 class="mb-0 fw-bold"><i class="bi bi-truck me-2 text-primary"></i>Vehicle Management</h5>
            <small class="text-muted">Manage all registered fleet vehicles</small>
        </div>
        <a href="add-vehicle.jsp" class="btn btn-primary btn-sm">
            <i class="bi bi-plus-circle me-1"></i>Add Vehicle
        </a>
        <a href="maintenance-notifications.jsp" class="btn btn-outline-warning btn-sm">
            <i class="bi bi-tools me-1"></i>Maintenance
        </a>
    </div>
</div>

<div class="container-fluid px-4 py-4">

    <!-- Flash messages -->
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

    <!-- ── Search & Filter Card ─────────────────────────────────────────── -->
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-body py-3">
            <form method="get" action="vehicle-list.jsp" class="row g-2 align-items-end">
                <div class="col-md-5">
                    <label class="form-label small fw-semibold text-muted mb-1">Search</label>
                    <div class="input-group input-group-sm">
                        <span class="input-group-text"><i class="bi bi-search"></i></span>
                        <input type="text" class="form-control" name="search"
                               placeholder="Vehicle number or model..." value="<%= search %>">
                    </div>
                </div>
                <div class="col-md-2">
                    <label class="form-label small fw-semibold text-muted mb-1">Status</label>
                    <select class="form-select form-select-sm" name="filterStatus">
                        <option value="All" <%= "All".equals(filterStatus) ? "selected" : "" %>>All Status</option>
                        <option value="Active"         <%= "Active".equals(filterStatus) ? "selected" : "" %>>Active</option>
                        <option value="Inactive"       <%= "Inactive".equals(filterStatus) ? "selected" : "" %>>Inactive</option>
                        <option value="In Maintenance" <%= "In Maintenance".equals(filterStatus) ? "selected" : "" %>>In Maintenance</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label small fw-semibold text-muted mb-1">Vehicle Type</label>
                    <select class="form-select form-select-sm" name="filterType">
                        <option value="All"        <%= "All".equals(filterType) ? "selected" : "" %>>All Types</option>
                        <option value="Sedan"      <%= "Sedan".equals(filterType) ? "selected" : "" %>>Sedan</option>
                        <option value="SUV"        <%= "SUV".equals(filterType) ? "selected" : "" %>>SUV</option>
                        <option value="Hatchback"  <%= "Hatchback".equals(filterType) ? "selected" : "" %>>Hatchback</option>
                        <option value="Truck"      <%= "Truck".equals(filterType) ? "selected" : "" %>>Truck</option>
                        <option value="Van"        <%= "Van".equals(filterType) ? "selected" : "" %>>Van</option>
                        <option value="Bus"        <%= "Bus".equals(filterType) ? "selected" : "" %>>Bus</option>
                        <option value="Motorcycle" <%= "Motorcycle".equals(filterType) ? "selected" : "" %>>Motorcycle</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex gap-2">
                    <button type="submit" class="btn btn-primary btn-sm flex-fill">
                        <i class="bi bi-funnel me-1"></i>Filter
                    </button>
                    <a href="vehicle-list.jsp" class="btn btn-outline-secondary btn-sm flex-fill">
                        <i class="bi bi-x-circle"></i>
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- ── Vehicle Table ───────────────────────────────────────────────────── -->
    <div class="card shadow-sm border-0">
        <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
            <span class="fw-semibold text-secondary">
                <i class="bi bi-list-ul me-1"></i>
                <%= vehicles.size() %> Vehicle(s) found
            </span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-3">#</th>
                            <th>Vehicle No.</th>
                            <th>Model</th>
                            <th>Type</th>
                            <th>Fuel</th>
                            <th>Reg. Date</th>
                            <th>Insurance Expiry</th>
                            <th>Maint. Due</th>
                            <th>Status</th>
                            <th class="text-center pe-3">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (vehicles.isEmpty()) { %>
                        <tr>
                            <td colspan="10" class="text-center py-5 text-muted">
                                <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                                No vehicles found. <a href="add-vehicle.jsp">Add your first vehicle</a>.
                            </td>
                        </tr>
                        <% } else { int i = 1; for (Vehicle v : vehicles) { %>
                        <tr>
                            <td class="ps-3 text-muted small"><%= i++ %></td>
                            <td><span class="badge bg-dark fw-semibold"><%= v.getVehicleNumber() %></span></td>
                            <td class="fw-semibold"><%= v.getModel() %></td>
                            <td><span class="badge bg-light text-dark border"><%= v.getVehicleType() %></span></td>
                            <td class="small text-muted"><%= v.getFuelType() %></td>
                            <td class="small"><%= v.getRegistrationDate() != null ? v.getRegistrationDate() : "-" %></td>
                            <td class="small"><%= v.getInsuranceExpiry() != null ? v.getInsuranceExpiry() : "-" %></td>
                            <td class="small"><%= v.getMaintenanceDueDate() != null ? v.getMaintenanceDueDate() : "-" %></td>
                            <td>
                                <%
                                    String sBadge = "bg-secondary";
                                    if ("Active".equals(v.getStatus())) sBadge = "bg-success";
                                    else if ("In Maintenance".equals(v.getStatus())) sBadge = "bg-warning text-dark";
                                %>
                                <span class="badge <%= sBadge %>"><%= v.getStatus() %></span>
                            </td>
                            <td class="text-center pe-3">
                                <a href="vehicle-details.jsp?id=<%= v.getId() %>"
                                   class="btn btn-outline-info btn-sm" title="View Details">
                                    <i class="bi bi-eye"></i>
                                </a>
                                <a href="edit-vehicle.jsp?id=<%= v.getId() %>"
                                   class="btn btn-outline-warning btn-sm" title="Edit">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <a href="<%= request.getContextPath() %>/delete-vehicle?id=<%= v.getId() %>"
                                   class="btn btn-outline-danger btn-sm" title="Delete"
                                   onclick="return confirm('Delete vehicle <%= v.getVehicleNumber() %>? This cannot be undone.')">
                                    <i class="bi bi-trash"></i>
                                </a>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div><!-- /container -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
