<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    String ctxPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Live Tracking - Fleet Tracker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" rel="stylesheet">
    <style>
        body { overflow: hidden; }
        #mapWrapper { display:flex; height:calc(100vh - 56px); }
        #sidebar    { width:290px; min-width:290px; overflow-y:auto;
                      border-right:1px solid #dee2e6; background:#fff; }
        #liveMap    { flex:1; }
        .v-card     { border-bottom:1px solid #f0f0f0; padding:12px 14px;
                      cursor:pointer; transition:background .15s; }
        .v-card:hover { background:#f8f9fa; }
        .online-dot  { display:inline-block; width:8px; height:8px;
                       border-radius:50%; margin-right:5px; }
        @keyframes pulse { 0%,100%{opacity:1} 50%{opacity:.4} }
        .pulse-green { animation:pulse 1.5s infinite; }
    </style>
</head>
<body class="bg-light">

<!-- Navbar (56px) -->
<nav class="navbar navbar-expand-lg navbar-dark bg-dark shadow-sm" style="height:56px">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold" href="dashboard.jsp">
            <i class="bi bi-truck-front-fill me-2 text-primary"></i>FleetTracker
        </a>
        <div class="d-flex align-items-center gap-3">
            <!-- Stats pills in navbar -->
            <span class="badge bg-success px-2">
                <span id="onlineCount">0</span> Online
            </span>
            <span class="badge bg-danger px-2">
                <span id="offlineCount">0</span> Offline
            </span>
            <span class="text-light small d-none d-md-inline">
                <i class="bi bi-arrow-repeat me-1"></i>
                Refreshed: <span id="lastRefresh">—</span>
            </span>
            <a href="mobile-tracking.jsp" class="btn btn-outline-light btn-sm">
                <i class="bi bi-phone me-1"></i>My Tracking
            </a>
            <a href="<%= ctxPath %>/logout" class="btn btn-outline-light btn-sm">
                <i class="bi bi-box-arrow-right"></i>
            </a>
        </div>
    </div>
</nav>

<div id="mapWrapper">

    <!-- ── Sidebar ── -->
    <div id="sidebar">
        <div class="p-3 border-bottom bg-light">
            <h6 class="mb-0 fw-bold">
                <i class="bi bi-truck me-1 text-primary"></i>
                Tracked Vehicles (<span id="totalCount">0</span>)
            </h6>
        </div>
        <div id="vehicleList">
            <div class="p-4 text-center text-muted small">
                <i class="bi bi-hourglass-split d-block fs-3 mb-2"></i>Loading...
            </div>
        </div>
    </div>

    <!-- ── Map ── -->
    <div id="liveMap"></div>

</div>

<input type="hidden" id="ctxPath" value="<%= ctxPath %>">

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
const ctxPath        = document.getElementById('ctxPath').value;
const ONLINE_THRESH  = 30000; // 30 seconds

// ── Init Map ────────────────────────────────────────────────────────────────
const map = L.map('liveMap').setView([20.5937, 78.9629], 5);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
}).addTo(map);

let markers     = {};   // vehicleId → L.circleMarker
let vehicleData = {};   // vehicleId → latest location object

function fmt(iso) { return new Date(iso).toLocaleTimeString(); }

// ── Refresh Loop ────────────────────────────────────────────────────────────
function refreshLocations() {
    fetch(ctxPath + '/get-latest-locations')
        .then(r => r.json())
        .then(locs => {
            const now = Date.now();
            let online = 0;

            locs.forEach(loc => {
                vehicleData[loc.vehicleId] = loc;
                const isOnline = (now - new Date(loc.timestamp).getTime()) < ONLINE_THRESH;
                if (isOnline) online++;

                const color  = isOnline ? '#28a745' : '#dc3545';
                const latLng = [loc.latitude, loc.longitude];

                if (markers[loc.vehicleId]) {
                    markers[loc.vehicleId].setLatLng(latLng)
                        .setStyle({ fillColor: color });
                } else {
                    const m = L.circleMarker(latLng, {
                        radius: 13, fillColor: color, color: '#fff',
                        weight: 2.5, fillOpacity: 0.88
                    }).addTo(map);

                    m.bindPopup(() => buildPopup(vehicleData[loc.vehicleId]), { maxWidth: 230 });
                    markers[loc.vehicleId] = m;
                }

                // Refresh open popup content
                if (markers[loc.vehicleId].isPopupOpen()) {
                    markers[loc.vehicleId].setPopupContent(buildPopup(loc));
                }
            });

            document.getElementById('onlineCount').textContent  = online;
            document.getElementById('offlineCount').textContent = locs.length - online;
            document.getElementById('totalCount').textContent   = locs.length;
            document.getElementById('lastRefresh').textContent  = new Date().toLocaleTimeString();

            updateSidebar(locs, now);
        })
        .catch(err => console.error('Refresh error:', err));
}

function buildPopup(loc) {
    const now      = Date.now();
    const isOnline = (now - new Date(loc.timestamp).getTime()) < ONLINE_THRESH;
    const badge    = isOnline
        ? '<span class="badge bg-success">Online</span>'
        : '<span class="badge bg-danger">Offline</span>';
    return `<div style="min-width:190px;font-size:.85rem">
        <div class="fw-bold fs-6">${loc.vehicleNumber} ${badge}</div>
        <div class="text-muted">${loc.vehicleModel}</div>
        <hr style="margin:6px 0">
        <div><i class="bi bi-person me-1"></i>${loc.driverName}</div>
        <div><i class="bi bi-speedometer2 me-1"></i>${loc.speed} km/h</div>
        <div><i class="bi bi-geo me-1"></i>${loc.latitude.toFixed(5)}, ${loc.longitude.toFixed(5)}</div>
        <div class="text-muted mt-1" style="font-size:.72rem">📡 ${loc.apiSource || 'unknown'}</div>
        <div class="text-muted mt-1">🕐 ${fmt(loc.timestamp)}</div>
        <a href="vehicle-map.jsp?vehicleId=${loc.vehicleId}"
           class="btn btn-sm btn-outline-primary w-100 mt-2">
           <i class="bi bi-map me-1"></i>View Route
        </a></div>`;
}

function updateSidebar(locs, now) {
    const list = document.getElementById('vehicleList');
    if (locs.length === 0) {
        list.innerHTML = '<div class="p-4 text-center text-muted small">'
            + '<i class="bi bi-truck fs-3 d-block mb-2"></i>No tracked vehicles yet.</div>';
        return;
    }
    list.innerHTML = locs.map(loc => {
        const isOnline   = (now - new Date(loc.timestamp).getTime()) < ONLINE_THRESH;
        const dotColor   = isOnline ? '#28a745' : '#dc3545';
        const statusText = isOnline ? 'Online' : 'Offline';
        return `<div class="v-card" onclick="focusVehicle(${loc.vehicleId})">
            <div class="d-flex justify-content-between align-items-center">
                <span class="fw-semibold small">
                    <span class="online-dot ${isOnline ? 'pulse-green' : ''}"
                          style="background:${dotColor}"></span>${loc.vehicleNumber}
                </span>
                <span class="badge ${isOnline ? 'bg-success' : 'bg-danger'} rounded-pill"
                      style="font-size:.65rem">${statusText}</span>
            </div>
            <div class="text-muted" style="font-size:.75rem">${loc.vehicleModel}</div>
            <div class="text-muted" style="font-size:.72rem">
                <i class="bi bi-person me-1"></i>${loc.driverName}
                &bull; ${loc.speed} km/h &bull; ${fmt(loc.timestamp)}
            </div>
        </div>`;
    }).join('');
}

function focusVehicle(vehicleId) {
    const loc = vehicleData[vehicleId];
    if (loc && markers[vehicleId]) {
        map.setView([loc.latitude, loc.longitude], 14);
        markers[vehicleId].openPopup();
    }
}

refreshLocations();
setInterval(refreshLocations, 5000);
</script>
</body>
</html>
