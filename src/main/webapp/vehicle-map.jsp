<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.model.Vehicle, com.fleet.dao.VehicleDAO" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }

    String idParam = request.getParameter("vehicleId");
    if (idParam == null || idParam.isEmpty()) { response.sendRedirect("live-tracking.jsp"); return; }

    int vehicleId = Integer.parseInt(idParam);
    Vehicle vehicle = new VehicleDAO().getVehicleById(vehicleId);
    if (vehicle == null) { response.sendRedirect("live-tracking.jsp"); return; }

    String ctxPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Route History - <%= vehicle.getVehicleNumber() %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" rel="stylesheet">
    <style> #routeMap { height: 420px; border-radius: .5rem; } </style>
</head>
<body class="bg-light">

<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold" href="dashboard.jsp">
            <i class="bi bi-truck-front-fill me-2 text-primary"></i>FleetTracker
        </a>
        <div class="d-flex gap-2">
            <a href="live-tracking.jsp" class="btn btn-outline-light btn-sm">
                <i class="bi bi-broadcast me-1"></i>Live Map
            </a>
            <a href="<%= ctxPath %>/logout" class="btn btn-outline-light btn-sm">
                <i class="bi bi-box-arrow-right"></i>
            </a>
        </div>
    </div>
</nav>

<!-- Page Header -->
<div class="bg-white border-bottom py-3 px-4 shadow-sm">
    <div class="container-fluid d-flex justify-content-between align-items-center">
        <div>
            <nav aria-label="breadcrumb">
                <ol class="breadcrumb mb-0 small">
                    <li class="breadcrumb-item"><a href="live-tracking.jsp" class="text-decoration-none">Live Map</a></li>
                    <li class="breadcrumb-item active">Route History</li>
                </ol>
            </nav>
            <h5 class="fw-bold mt-1 mb-0">
                <i class="bi bi-map me-2 text-primary"></i>
                Route History — <span class="badge bg-dark"><%= vehicle.getVehicleNumber() %></span>
                <span class="text-muted fw-normal fs-6 ms-1"><%= vehicle.getModel() %></span>
            </h5>
        </div>
        <div class="d-flex gap-2 align-items-end flex-wrap">
            <div>
                <label class="form-label small fw-semibold text-muted mb-1">From</label>
                <input type="datetime-local" id="startDate" class="form-control form-control-sm">
            </div>
            <div>
                <label class="form-label small fw-semibold text-muted mb-1">To</label>
                <input type="datetime-local" id="endDate" class="form-control form-control-sm">
            </div>
            <div>
                <label class="form-label small fw-semibold text-muted mb-1">Points</label>
                <select id="limitSelect" class="form-select form-select-sm">
                    <option value="100">100</option>
                    <option value="200" selected>200</option>
                    <option value="500">500</option>
                </select>
            </div>
            <button class="btn btn-primary btn-sm" onclick="loadHistory()">
                <i class="bi bi-funnel me-1"></i>Apply Filter
            </button>
            <button class="btn btn-outline-secondary btn-sm" onclick="clearFilter()">
                <i class="bi bi-x-circle me-1"></i>Clear
            </button>
        </div>
    </div>
</div>

<div class="container-fluid px-4 py-4">

    <!-- Alert area -->
    <div id="alertArea"></div>

    <!-- Map Card -->
    <div class="card shadow-sm border-0 mb-4">
        <div class="card-header bg-white border-bottom py-3 d-flex justify-content-between align-items-center">
            <h6 class="mb-0 fw-semibold text-secondary">
                <i class="bi bi-geo-alt me-1"></i>Route Map
            </h6>
            <div class="d-flex gap-3 small text-muted">
                <span><span class="badge bg-success rounded-pill">●</span> Start</span>
                <span><span class="badge bg-danger rounded-pill">●</span> Latest</span>
                <span>─── Route path</span>
            </div>
        </div>
        <div class="card-body p-2">
            <div id="routeMap"></div>
        </div>
    </div>

    <!-- GPS History Table -->
    <div class="card shadow-sm border-0">
        <div class="card-header bg-white border-bottom py-3">
            <h6 class="mb-0 fw-semibold text-secondary">
                <i class="bi bi-table me-1"></i>GPS History
                <span class="badge bg-secondary ms-2" id="pointCount">0</span> points
            </h6>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive" style="max-height:340px; overflow-y:auto">
                <table class="table table-sm table-hover align-middle mb-0">
                    <thead class="table-dark sticky-top">
                        <tr>
                            <th class="ps-3">#</th>
                            <th>Latitude</th>
                            <th>Longitude</th>
                            <th>Speed (km/h)</th>
                            <th>Source</th>
                            <th>Timestamp</th>
                        </tr>
                    </thead>
                    <tbody id="historyBody">
                        <tr><td colspan="6" class="text-center py-4 text-muted">Loading...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</div>

<input type="hidden" id="ctxPath"    value="<%= ctxPath %>">
<input type="hidden" id="vehicleId"  value="<%= vehicleId %>">

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
const ctxPath   = document.getElementById('ctxPath').value;
const vehicleId = document.getElementById('vehicleId').value;

const rMap = L.map('routeMap').setView([20.5937, 78.9629], 5);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap contributors'
}).addTo(rMap);

let routeLayer = null;

function loadHistory() {
    const limit     = document.getElementById('limitSelect').value;
    const startDate = document.getElementById('startDate').value;
    const endDate   = document.getElementById('endDate').value;
    let url = `${ctxPath}/get-vehicle-history?vehicleId=${vehicleId}&limit=${limit}`;
    if (startDate) url += `&startDate=${encodeURIComponent(startDate)}`;
    if (endDate)   url += `&endDate=${encodeURIComponent(endDate)}`;
    fetch(url)
        .then(r => r.json())
        .then(points => {
            if (points.length === 0) {
                document.getElementById('alertArea').innerHTML =
                    '<div class="alert alert-warning"><i class="bi bi-info-circle me-2"></i>'
                    + 'No GPS history found for this vehicle. Start tracking to record data.</div>';
                document.getElementById('pointCount').textContent = '0';
                document.getElementById('historyBody').innerHTML =
                    '<tr><td colspan="6" class="text-center py-4 text-muted">No data available.</td></tr>';
                return;
            }

            document.getElementById('alertArea').innerHTML = '';
            document.getElementById('pointCount').textContent = points.length;

            // Clear previous layers
            if (routeLayer) { rMap.removeLayer(routeLayer); routeLayer = null; }
            rMap.eachLayer(l => { if (l instanceof L.CircleMarker) rMap.removeLayer(l); });

            const latLngs = points.map(p => [p.latitude, p.longitude]);

            // Route polyline
            routeLayer = L.polyline(latLngs, { color:'#0d6efd', weight:3, opacity:0.75 }).addTo(rMap);

            // Start marker (green)
            L.circleMarker(latLngs[0], { radius:9, fillColor:'#28a745', color:'#fff',
                weight:2.5, fillOpacity:1 }).addTo(rMap)
             .bindPopup('<b>Start</b><br>' + points[0].timestamp);

            // Latest / end marker (red)
            const last = latLngs[latLngs.length - 1];
            L.circleMarker(last, { radius:9, fillColor:'#dc3545', color:'#fff',
                weight:2.5, fillOpacity:1 }).addTo(rMap)
             .bindPopup('<b>Latest Position</b><br>' + points[points.length-1].timestamp
                        + '<br>Speed: ' + points[points.length-1].speed + ' km/h');

            rMap.fitBounds(L.latLngBounds(latLngs), { padding:[24,24] });

            // Build table (reverse order = newest first)
            const rows = [...points].reverse().map((p, i) => `
                <tr>
                    <td class="ps-3 text-muted">${i + 1}</td>
                    <td>${p.latitude.toFixed(7)}</td>
                    <td>${p.longitude.toFixed(7)}</td>
                    <td>${p.speed}</td>
                    <td class="text-muted small">${p.apiSource || '—'}</td>
                    <td class="text-muted">${p.timestamp}</td>
                </tr>`).join('');
            document.getElementById('historyBody').innerHTML = rows;
        })
        .catch(() => {
            document.getElementById('alertArea').innerHTML =
                '<div class="alert alert-danger">Failed to load GPS history. Check server connection.</div>';
        });
}

loadHistory();

function clearFilter() {
    document.getElementById('startDate').value = '';
    document.getElementById('endDate').value   = '';
    loadHistory();
}
</script>
</body>
</html>
