<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.dto.VehicleAssignmentView" %>
<%@ page import="com.fleet.dao.VehicleAssignmentDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    VehicleAssignmentDAO dao = new VehicleAssignmentDAO();
    List<VehicleAssignmentView> assignments = dao.getActiveAssignments();

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
    <title>Active Assignments - Fleet Tracker</title>
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
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <div>
            <h5 class="mb-0 fw-bold"><i class="bi bi-arrow-left-right me-2 text-primary"></i>Active Assignments</h5>
            <small class="text-muted">Current vehicle–driver pairings in the fleet</small>
        </div>
        <div class="d-flex gap-2">
            <a href="assignment-history.jsp" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-clock-history me-1"></i>View History
            </a>
            <a href="assign-vehicle.jsp" class="btn btn-primary btn-sm">
                <i class="bi bi-link-45deg me-1"></i>New Assignment
            </a>
        </div>
    </div>
</div>

<div class="container-fluid px-4 py-4">

    <!-- Flash messages -->
    <% if (successMsg != null) { %>
    <div class="alert alert-success alert-dismissible fade show py-2">
        <i class="bi bi-check-circle me-2"></i><%= successMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert alert-danger alert-dismissible fade show py-2">
        <i class="bi bi-exclamation-circle me-2"></i><%= errorMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- ── Active Assignments Table ─────────────────────────────────────────── -->
    <div class="card shadow-sm border-0">
        <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
            <span class="fw-semibold text-secondary">
                <i class="bi bi-list-ul me-1"></i>
                <%= assignments.size() %> Active Assignment(s)
            </span>
            <span class="badge bg-success"><i class="bi bi-circle-fill me-1" style="font-size:.5rem"></i>Live</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-3">#</th>
                            <th>Vehicle</th>
                            <th>Driver</th>
                            <th>License No.</th>
                            <th>Start Date</th>
                            <th>Assigned By</th>
                            <th>Notes</th>
                            <th class="text-center pe-3">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (assignments.isEmpty()) { %>
                        <tr>
                            <td colspan="8" class="text-center py-5 text-muted">
                                <i class="bi bi-arrow-left-right fs-2 d-block mb-2"></i>
                                No active assignments. <a href="assign-vehicle.jsp">Create one now</a>.
                            </td>
                        </tr>
                        <% } else { int i = 1; for (VehicleAssignmentView a : assignments) { %>
                        <tr>
                            <td class="ps-3 text-muted small"><%= i++ %></td>
                            <td>
                                <div class="fw-semibold"><span class="badge bg-dark me-1"><%= a.getVehicleNumber() %></span></div>
                                <div class="text-muted small"><%= a.getVehicleModel() %> &bull; <%= a.getVehicleType() %></div>
                            </td>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center"
                                         style="width:32px;height:32px;flex-shrink:0">
                                        <i class="bi bi-person-fill text-primary small"></i>
                                    </div>
                                    <div>
                                        <div class="fw-semibold small"><%= a.getDriverName() %></div>
                                        <div class="text-muted" style="font-size:.75rem"><%= a.getDriverEmail() %></div>
                                    </div>
                                </div>
                            </td>
                            <td><span class="badge bg-secondary"><%= a.getDriverLicense() %></span></td>
                            <td class="small"><i class="bi bi-calendar3 me-1 text-muted"></i><%= a.getStartDate() %></td>
                            <td class="small text-muted"><%= a.getAssignedByName() != null ? a.getAssignedByName() : "—" %></td>
                            <td class="small text-muted"><%= a.getNotes() != null ? a.getNotes() : "—" %></td>
                            <td class="text-center pe-3">
                                <form action="<%= request.getContextPath() %>/unassign-vehicle" method="post" class="d-inline">
                                    <input type="hidden" name="assignmentId" value="<%= a.getId() %>">
                                    <button type="submit" class="btn btn-outline-danger btn-sm"
                                            onclick="return confirm('Unassign <%= a.getDriverName() %> from <%= a.getVehicleNumber() %>?')">
                                        <i class="bi bi-x-circle me-1"></i>Unassign
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
