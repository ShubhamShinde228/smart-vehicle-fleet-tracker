<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.model.Vehicle, com.fleet.model.MaintenanceNotification,
                 com.fleet.dao.VehicleDAO, com.fleet.dao.MaintenanceDAO,
                 java.util.List, java.time.LocalDate, java.time.temporal.ChronoUnit" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    String role = currentUser.getRole();
    if (!"Admin".equalsIgnoreCase(role) && !"Manager".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    }

    String statusFilter = request.getParameter("status") != null ? request.getParameter("status") : "All";
    String vehicleFilter = request.getParameter("vehicleId") != null ? request.getParameter("vehicleId") : "All";

    MaintenanceDAO maintenanceDAO = new MaintenanceDAO();
    VehicleDAO vehicleDAO = new VehicleDAO();
    List<Vehicle> vehicles = vehicleDAO.getAllVehicles();
    List<Vehicle> dueVehicles = maintenanceDAO.getVehiclesDueSoon(30);
    List<MaintenanceNotification> notifications = maintenanceDAO.getNotifications(statusFilter, vehicleFilter);

    String successMsg = (String) session.getAttribute("successMessage");
    String errorMsg = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");

    LocalDate today = LocalDate.now();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maintenance Notifications - Fleet Tracker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        body { background: #f6f8fb; }
        .metric-card { min-height: 98px; }
        .table td { vertical-align: middle; }
    </style>
</head>
<body>
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
                <li class="nav-item"><a class="nav-link active" href="maintenance-notifications.jsp"><i class="bi bi-tools me-1"></i>Maintenance</a></li>
                <li class="nav-item"><a class="nav-link" href="geofence-list.jsp"><i class="bi bi-bounding-box-circles me-1"></i>Geofences</a></li>
                <li class="nav-item"><a class="nav-link" href="geofence-alerts.jsp"><i class="bi bi-exclamation-triangle me-1"></i>Alerts</a></li>
                <li class="nav-item"><a class="nav-link" href="fuel-logs.jsp"><i class="bi bi-fuel-pump me-1"></i>Fuel</a></li>
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
            <h5 class="mb-0 fw-bold"><i class="bi bi-tools me-2 text-primary"></i>Vehicle Maintenance Notifications</h5>
            <small class="text-muted">Track upcoming service, overdue maintenance, and completed maintenance work.</small>
        </div>
        <a href="vehicle-list.jsp" class="btn btn-outline-primary btn-sm">
            <i class="bi bi-truck me-1"></i>Vehicle List
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

    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm metric-card">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="bg-danger bg-opacity-10 rounded-3 p-3"><i class="bi bi-exclamation-octagon fs-3 text-danger"></i></div>
                    <div>
                        <div class="fs-4 fw-bold"><%= maintenanceDAO.countDueVehicleMaintenance(0) %></div>
                        <div class="text-muted small">Overdue Vehicles</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm metric-card">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="bg-warning bg-opacity-10 rounded-3 p-3"><i class="bi bi-calendar-event fs-3 text-warning"></i></div>
                    <div>
                        <div class="fs-4 fw-bold"><%= dueVehicles.size() %></div>
                        <div class="text-muted small">Due in 30 Days</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm metric-card">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="bg-primary bg-opacity-10 rounded-3 p-3"><i class="bi bi-bell fs-3 text-primary"></i></div>
                    <div>
                        <div class="fs-4 fw-bold"><%= maintenanceDAO.countOpenNotifications() %></div>
                        <div class="text-muted small">Open Notifications</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-3">
            <div class="card border-0 shadow-sm metric-card">
                <div class="card-body d-flex align-items-center gap-3">
                    <div class="bg-success bg-opacity-10 rounded-3 p-3"><i class="bi bi-check2-circle fs-3 text-success"></i></div>
                    <div>
                        <div class="fs-4 fw-bold"><%= vehicles.size() %></div>
                        <div class="text-muted small">Fleet Vehicles</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-4">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white py-3">
                    <span class="fw-semibold"><i class="bi bi-plus-circle me-2 text-primary"></i>Create Notification</span>
                </div>
                <div class="card-body">
                    <form method="post" action="<%= request.getContextPath() %>/maintenance-notification" class="row g-3">
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
                            <label class="form-label small fw-semibold text-muted">Title</label>
                            <input type="text" class="form-control form-control-sm" name="title" placeholder="Engine service required" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label small fw-semibold text-muted">Description</label>
                            <textarea class="form-control form-control-sm" name="description" rows="2" placeholder="Oil change, brake inspection, tire pressure check"></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold text-muted">Due Date</label>
                            <input type="date" class="form-control form-control-sm" name="dueDate" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold text-muted">Priority</label>
                            <select class="form-select form-select-sm" name="priority">
                                <option value="Low">Low</option>
                                <option value="Medium" selected>Medium</option>
                                <option value="High">High</option>
                                <option value="Critical">Critical</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold text-muted">Status</label>
                            <select class="form-select form-select-sm" name="status">
                                <option value="Open" selected>Open</option>
                                <option value="Scheduled">Scheduled</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold text-muted">Notes</label>
                            <input type="text" class="form-control form-control-sm" name="notes" placeholder="Workshop / mechanic">
                        </div>
                        <div class="col-12">
                            <button type="submit" class="btn btn-primary btn-sm w-100">
                                <i class="bi bi-save me-1"></i>Save Notification
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <div class="card shadow-sm border-0">
                <div class="card-header bg-white py-3">
                    <span class="fw-semibold"><i class="bi bi-calendar2-week me-2 text-warning"></i>Vehicle Due Dates</span>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-sm table-hover mb-0">
                            <thead class="table-light">
                                <tr><th class="ps-3">Vehicle</th><th>Due</th><th class="pe-3">Status</th></tr>
                            </thead>
                            <tbody>
                            <% if (dueVehicles.isEmpty()) { %>
                                <tr><td colspan="3" class="text-center py-4 text-muted">No vehicle maintenance due within 30 days.</td></tr>
                            <% } else { for (Vehicle v : dueVehicles) {
                                long days = ChronoUnit.DAYS.between(today, v.getMaintenanceDueDate().toLocalDate());
                                String dueClass = days < 0 ? "bg-danger" : (days <= 7 ? "bg-warning text-dark" : "bg-info text-dark");
                                String dueText = days < 0 ? Math.abs(days) + " day(s) overdue" : "in " + days + " day(s)";
                            %>
                                <tr>
                                    <td class="ps-3">
                                        <span class="badge bg-dark"><%= v.getVehicleNumber() %></span>
                                        <div class="small text-muted"><%= v.getModel() %></div>
                                    </td>
                                    <td class="small"><%= v.getMaintenanceDueDate() %></td>
                                    <td class="pe-3"><span class="badge <%= dueClass %>"><%= dueText %></span></td>
                                </tr>
                            <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white d-flex justify-content-between align-items-center flex-wrap gap-2 py-3">
                    <span class="fw-semibold text-secondary"><i class="bi bi-list-check me-1"></i><%= notifications.size() %> Notification(s)</span>
                    <form method="get" action="maintenance-notifications.jsp" class="d-flex gap-2 flex-wrap">
                        <select class="form-select form-select-sm" name="status" style="width: 150px">
                            <option value="All" <%= "All".equals(statusFilter) ? "selected" : "" %>>All Status</option>
                            <option value="Open" <%= "Open".equals(statusFilter) ? "selected" : "" %>>Open</option>
                            <option value="Scheduled" <%= "Scheduled".equals(statusFilter) ? "selected" : "" %>>Scheduled</option>
                            <option value="Completed" <%= "Completed".equals(statusFilter) ? "selected" : "" %>>Completed</option>
                            <option value="Cancelled" <%= "Cancelled".equals(statusFilter) ? "selected" : "" %>>Cancelled</option>
                        </select>
                        <select class="form-select form-select-sm" name="vehicleId" style="width: 170px">
                            <option value="All" <%= "All".equals(vehicleFilter) ? "selected" : "" %>>All Vehicles</option>
                            <% for (Vehicle v : vehicles) { %>
                            <option value="<%= v.getId() %>" <%= String.valueOf(v.getId()).equals(vehicleFilter) ? "selected" : "" %>><%= v.getVehicleNumber() %></option>
                            <% } %>
                        </select>
                        <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-funnel me-1"></i>Filter</button>
                        <a href="maintenance-notifications.jsp" class="btn btn-outline-secondary btn-sm"><i class="bi bi-x-circle"></i></a>
                    </form>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th class="ps-3">Maintenance</th>
                                    <th>Vehicle</th>
                                    <th>Due Date</th>
                                    <th>Priority</th>
                                    <th>Status</th>
                                    <th class="text-center pe-3">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (notifications.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="text-center py-5 text-muted">
                                        <i class="bi bi-bell-slash fs-2 d-block mb-2"></i>
                                        No maintenance notifications found.
                                    </td>
                                </tr>
                            <% } else { for (MaintenanceNotification n : notifications) {
                                long days = n.getDueDate() != null ? ChronoUnit.DAYS.between(today, n.getDueDate().toLocalDate()) : 9999;
                                String priorityClass = "bg-secondary";
                                if ("Critical".equals(n.getPriority())) priorityClass = "bg-danger";
                                else if ("High".equals(n.getPriority())) priorityClass = "bg-warning text-dark";
                                else if ("Medium".equals(n.getPriority())) priorityClass = "bg-primary";

                                String statusClass = "bg-secondary";
                                if ("Open".equals(n.getStatus())) statusClass = days < 0 ? "bg-danger" : "bg-primary";
                                else if ("Scheduled".equals(n.getStatus())) statusClass = "bg-warning text-dark";
                                else if ("Completed".equals(n.getStatus())) statusClass = "bg-success";
                            %>
                                <tr>
                                    <td class="ps-3">
                                        <div class="fw-semibold"><%= n.getTitle() %></div>
                                        <div class="small text-muted"><%= n.getDescription() != null && !n.getDescription().isEmpty() ? n.getDescription() : "-" %></div>
                                        <% if (n.getNotes() != null && !n.getNotes().isEmpty()) { %>
                                        <div class="small text-muted"><i class="bi bi-sticky me-1"></i><%= n.getNotes() %></div>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="badge bg-dark"><%= n.getVehicleNumber() %></span>
                                        <div class="small text-muted mt-1"><%= n.getVehicleModel() %></div>
                                    </td>
                                    <td>
                                        <div class="small"><%= n.getDueDate() != null ? n.getDueDate() : "-" %></div>
                                        <% if (!"Completed".equals(n.getStatus()) && !"Cancelled".equals(n.getStatus()) && n.getDueDate() != null) {
                                            String dueBadge = days < 0 ? "bg-danger" : (days <= 7 ? "bg-warning text-dark" : "bg-light text-dark border");
                                            String dueText = days < 0 ? Math.abs(days) + " day(s) overdue" : "in " + days + " day(s)";
                                        %>
                                        <span class="badge <%= dueBadge %>"><%= dueText %></span>
                                        <% } %>
                                    </td>
                                    <td><span class="badge <%= priorityClass %>"><%= n.getPriority() %></span></td>
                                    <td><span class="badge <%= statusClass %>"><%= n.getStatus() %></span></td>
                                    <td class="text-center pe-3">
                                        <% if (!"Completed".equals(n.getStatus())) { %>
                                        <form method="post" action="<%= request.getContextPath() %>/maintenance-notification" class="d-inline">
                                            <input type="hidden" name="action" value="complete">
                                            <input type="hidden" name="id" value="<%= n.getId() %>">
                                            <button type="submit" class="btn btn-outline-success btn-sm" title="Mark Completed">
                                                <i class="bi bi-check2-circle"></i>
                                            </button>
                                        </form>
                                        <% } %>
                                        <% if ("Open".equals(n.getStatus())) { %>
                                        <form method="post" action="<%= request.getContextPath() %>/maintenance-notification" class="d-inline">
                                            <input type="hidden" name="action" value="schedule">
                                            <input type="hidden" name="id" value="<%= n.getId() %>">
                                            <button type="submit" class="btn btn-outline-warning btn-sm" title="Mark Scheduled">
                                                <i class="bi bi-calendar-check"></i>
                                            </button>
                                        </form>
                                        <% } %>
                                        <% if (!"Cancelled".equals(n.getStatus()) && !"Completed".equals(n.getStatus())) { %>
                                        <form method="post" action="<%= request.getContextPath() %>/maintenance-notification" class="d-inline">
                                            <input type="hidden" name="action" value="cancel">
                                            <input type="hidden" name="id" value="<%= n.getId() %>">
                                            <button type="submit" class="btn btn-outline-secondary btn-sm" title="Cancel">
                                                <i class="bi bi-x-circle"></i>
                                            </button>
                                        </form>
                                        <% } %>
                                        <form method="post" action="<%= request.getContextPath() %>/maintenance-notification" class="d-inline" onsubmit="return confirm('Delete this maintenance notification?')">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="id" value="<%= n.getId() %>">
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
