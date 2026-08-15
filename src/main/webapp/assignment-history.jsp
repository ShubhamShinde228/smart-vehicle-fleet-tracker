<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.dto.VehicleAssignmentView" %>
<%@ page import="com.fleet.dao.VehicleAssignmentDAO, java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    String statusFilter = request.getParameter("statusFilter") != null
                          ? request.getParameter("statusFilter") : "All";

    VehicleAssignmentDAO dao = new VehicleAssignmentDAO();
    List<VehicleAssignmentView> history = dao.getAssignmentHistory(statusFilter);

    // Compute counts for stat cards
    long activeCount    = history.stream().filter(VehicleAssignmentView::isActive).count();
    long completedCount = history.stream().filter(a -> !a.isActive()).count();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Assignment History - Fleet Tracker</title>
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
            <h5 class="mb-0 fw-bold"><i class="bi bi-clock-history me-2 text-primary"></i>Assignment History</h5>
            <small class="text-muted">Full log of all past and present vehicle–driver assignments</small>
        </div>
        <div class="d-flex gap-2">
            <a href="assignment-list.jsp" class="btn btn-outline-secondary btn-sm">
                <i class="bi bi-arrow-left-right me-1"></i>Active View
            </a>
            <a href="assign-vehicle.jsp" class="btn btn-primary btn-sm">
                <i class="bi bi-link-45deg me-1"></i>New Assignment
            </a>
        </div>
    </div>
</div>

<div class="container-fluid px-4 py-4">

    <!-- ── Stats row ──────────────────────────────────────────────────────── -->
    <div class="row g-3 mb-4">
        <div class="col-sm-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body d-flex align-items-center gap-3 py-3">
                    <div class="bg-primary bg-opacity-10 rounded-3 p-3">
                        <i class="bi bi-clipboard-data fs-4 text-primary"></i>
                    </div>
                    <div>
                        <div class="fs-3 fw-bold"><%= history.size() %></div>
                        <div class="text-muted small">Total Records</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body d-flex align-items-center gap-3 py-3">
                    <div class="bg-success bg-opacity-10 rounded-3 p-3">
                        <i class="bi bi-check-circle fs-4 text-success"></i>
                    </div>
                    <div>
                        <div class="fs-3 fw-bold"><%= activeCount %></div>
                        <div class="text-muted small">Currently Active</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-body d-flex align-items-center gap-3 py-3">
                    <div class="bg-secondary bg-opacity-10 rounded-3 p-3">
                        <i class="bi bi-archive fs-4 text-secondary"></i>
                    </div>
                    <div>
                        <div class="fs-3 fw-bold"><%= completedCount %></div>
                        <div class="text-muted small">Completed</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ── Filter tabs ─────────────────────────────────────────────────────── -->
    <div class="card shadow-sm border-0">
        <div class="card-header bg-white border-bottom">
            <form method="get" action="assignment-history.jsp" class="d-flex align-items-center gap-3 py-1">
                <span class="text-muted small fw-semibold">Filter:</span>
                <div class="btn-group btn-group-sm" role="group">
                    <button type="submit" name="statusFilter" value="All"
                            class="btn <%= "All".equals(statusFilter) ? "btn-dark" : "btn-outline-dark" %>">
                        All (<%= history.size() %>)
                    </button>
                    <button type="submit" name="statusFilter" value="Active"
                            class="btn <%= "Active".equals(statusFilter) ? "btn-success" : "btn-outline-success" %>">
                        Active
                    </button>
                    <button type="submit" name="statusFilter" value="Completed"
                            class="btn <%= "Completed".equals(statusFilter) ? "btn-secondary" : "btn-outline-secondary" %>">
                        Completed
                    </button>
                </div>
            </form>
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
                            <th>End Date</th>
                            <th>Assigned By</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (history.isEmpty()) { %>
                        <tr>
                            <td colspan="8" class="text-center py-5 text-muted">
                                <i class="bi bi-clock-history fs-2 d-block mb-2"></i>
                                No assignment records found for this filter.
                            </td>
                        </tr>
                        <% } else { int i = 1; for (VehicleAssignmentView a : history) { %>
                        <tr>
                            <td class="ps-3 text-muted small"><%= i++ %></td>
                            <td>
                                <div><span class="badge bg-dark me-1"><%= a.getVehicleNumber() %></span></div>
                                <div class="text-muted" style="font-size:.75rem"><%= a.getVehicleModel() %></div>
                            </td>
                            <td>
                                <div class="fw-semibold small"><%= a.getDriverName() %></div>
                                <div class="text-muted" style="font-size:.75rem"><%= a.getDriverEmail() %></div>
                            </td>
                            <td><span class="badge bg-secondary"><%= a.getDriverLicense() %></span></td>
                            <td class="small"><%= a.getStartDate() %></td>
                            <td class="small">
                                <% if (a.getEndDate() != null) { %>
                                    <%= a.getEndDate() %>
                                <% } else { %>
                                    <span class="text-muted">—</span>
                                <% } %>
                            </td>
                            <td class="small text-muted"><%= a.getAssignedByName() != null ? a.getAssignedByName() : "—" %></td>
                            <td>
                                <% if (a.isActive()) { %>
                                <span class="badge bg-success">
                                    <i class="bi bi-circle-fill me-1" style="font-size:.5rem"></i>Active
                                </span>
                                <% } else { %>
                                <span class="badge bg-secondary">
                                    <i class="bi bi-check-circle me-1"></i>Completed
                                </span>
                                <% } %>
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
