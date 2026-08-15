<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.dao.LocationDAO, jakarta.servlet.http.HttpServletRequest, java.util.List, java.net.NetworkInterface, java.net.InetAddress, java.util.Enumeration" %>
<%!
    private String getMobileReachableHost(HttpServletRequest request) {
        String host = request.getServerName();
        if (!"localhost".equalsIgnoreCase(host) && !"127.0.0.1".equals(host) && !"0:0:0:0:0:0:0:1".equals(host)) {
            return host;
        }

        try {
            String fallbackIp = null;
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface networkInterface = interfaces.nextElement();
                if (!networkInterface.isUp() || networkInterface.isLoopback() || networkInterface.isVirtual()) {
                    continue;
                }

                Enumeration<InetAddress> addresses = networkInterface.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    InetAddress address = addresses.nextElement();
                    String ip = address.getHostAddress();
                    if (address.isSiteLocalAddress() && ip.indexOf(':') == -1) {
                        if (ip.startsWith("192.168.")) {
                            return ip;
                        }
                        if (fallbackIp == null || ip.startsWith("10.")) {
                            fallbackIp = ip;
                        }
                    }
                }
            }
            if (fallbackIp != null) {
                return fallbackIp;
            }
        } catch (Exception ignored) {
        }

        return host;
    }
%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    if (!"Admin".equalsIgnoreCase(currentUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/live-tracking.jsp"); return;
    }
    LocationDAO dao      = new LocationDAO();
    List<Object[]> keys  = dao.getAllApiKeys();
    String apiUrl = request.getScheme() + "://" + getMobileReachableHost(request) + ":" +
                    request.getServerPort() + request.getContextPath() + "/updateLocation";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GPS API Config - Fleet Tracker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-dark shadow-sm px-4">
    <a class="navbar-brand fw-bold" href="dashboard.jsp">
        <i class="bi bi-truck-front-fill me-2 text-primary"></i>FleetTracker
    </a>
    <div class="d-flex gap-2">
        <a href="live-tracking.jsp" class="btn btn-outline-light btn-sm">
            <i class="bi bi-broadcast me-1"></i>Live Map
        </a>
        <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline-light btn-sm">
            <i class="bi bi-box-arrow-right"></i>
        </a>
    </div>
</nav>

<div class="bg-white border-bottom py-3 px-4 shadow-sm">
    <div class="container-fluid">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0 small">
                <li class="breadcrumb-item"><a href="dashboard.jsp" class="text-decoration-none">Dashboard</a></li>
                <li class="breadcrumb-item active">GPS API Configuration</li>
            </ol>
        </nav>
        <h5 class="fw-bold mt-1 mb-0"><i class="bi bi-key me-2 text-primary"></i>GPS API Configuration</h5>
    </div>
</div>

<div class="container-fluid px-4 py-4">
    <div class="row g-4">

        <!-- Left: API Endpoint + Keys -->
        <div class="col-lg-7">

            <!-- Endpoint card -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-dark text-white py-3">
                    <h6 class="mb-0"><i class="bi bi-cloud-upload me-2"></i>Ingestion Endpoint</h6>
                </div>
                <div class="card-body">
                    <label class="form-label small fw-semibold text-muted">API URL</label>
                    <div class="input-group mb-3">
                        <input type="text" class="form-control font-monospace" id="apiEndpoint"
                               value="<%= apiUrl %>" readonly>
                        <button class="btn btn-outline-secondary"
                                onclick="copyText('apiEndpoint')">
                            <i class="bi bi-clipboard"></i>
                        </button>
                    </div>
                    <p class="small text-muted mb-0">
                        Accepts both <code>GET</code> and <code>POST</code> requests.
                        Suitable for GPSLogger, OsmAnd, Traccar clients, or any HTTP-capable GPS app.
                    </p>
                </div>
            </div>

            <!-- API Keys table -->
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-bottom d-flex justify-content-between align-items-center py-3">
                    <h6 class="mb-0 fw-semibold text-secondary"><i class="bi bi-shield-lock me-2"></i>API Keys</h6>
                    <span class="badge bg-secondary"><%= keys.size() %> key(s)</span>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-dark">
                                <tr>
                                    <th class="ps-3">Key Name</th>
                                    <th>API Key</th>
                                    <th>Status</th>
                                    <th>Last Used</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (keys.isEmpty()) { %>
                                <tr>
                                    <td colspan="4" class="text-center py-4 text-muted">
                                        No API keys found. Run <code>database.sql</code> to add default keys.
                                    </td>
                                </tr>
                                <% } else { for (Object[] k : keys) {
                                    boolean active = (Boolean) k[3];
                                %>
                                <tr>
                                    <td class="ps-3 fw-semibold"><%= k[2] %></td>
                                    <td>
                                        <div class="input-group input-group-sm">
                                            <input type="text" class="form-control font-monospace"
                                                   value="<%= k[1] %>" readonly id="key_<%= k[0] %>">
                                            <button class="btn btn-outline-secondary"
                                                    onclick="copyText('key_<%= k[0] %>')">
                                                <i class="bi bi-clipboard"></i>
                                            </button>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge <%= active ? "bg-success" : "bg-danger" %>">
                                            <%= active ? "Active" : "Inactive" %>
                                        </span>
                                    </td>
                                    <td class="small text-muted"><%= k[5] != null ? k[5] : "Never" %></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right: GPSLogger Setup Guide -->
        <div class="col-lg-5">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-success text-white py-3">
                    <h6 class="mb-0"><i class="bi bi-phone me-2"></i>GPSLogger Setup Guide</h6>
                </div>
                <div class="card-body">
                    <ol class="small ps-3">
                        <li class="mb-2">Install <strong>GPSLogger</strong> from Google Play Store</li>
                        <li class="mb-2">Open app → tap <strong>⋮ Menu → Preferences</strong></li>
                        <li class="mb-2">Go to <strong>Logging Details → Log to Custom URL</strong></li>
                        <li class="mb-2">Enable and enter URL:</li>
                    </ol>
                    <div class="input-group input-group-sm mb-3">
                        <input type="text" class="form-control font-monospace" id="gpsloggerUrl"
                               value="<%= apiUrl %>?apiKey=YOUR_KEY&vehicleId=1&latitude=%LAT&longitude=%LON&speed=%SPD&timestamp=%TIME"
                               readonly style="font-size:.7rem">
                        <button class="btn btn-outline-success" onclick="copyText('gpsloggerUrl')">
                            <i class="bi bi-clipboard"></i>
                        </button>
                    </div>
                    <p class="small text-muted mb-3">Replace <code>YOUR_KEY</code> with an active API key above and set the correct <code>vehicleId</code>.</p>

                    <hr>
                    <h6 class="small fw-bold">URL Substitution Variables</h6>
                    <table class="table table-sm table-bordered mb-0 small">
                        <tr><td><code>%LAT</code></td><td>GPS Latitude</td></tr>
                        <tr><td><code>%LON</code></td><td>GPS Longitude</td></tr>
                        <tr><td><code>%SPD</code></td><td>Speed (m/s)</td></tr>
                        <tr><td><code>%TIME</code></td><td>Timestamp (epoch)</td></tr>
                        <tr><td><code>%ACC</code></td><td>GPS Accuracy</td></tr>
                    </table>
                </div>
            </div>

            <!-- Test API Panel -->
            <div class="card shadow-sm border-0">
                <div class="card-header bg-white border-bottom py-3">
                    <h6 class="mb-0 fw-semibold text-secondary"><i class="bi bi-terminal me-2"></i>Test API</h6>
                </div>
                <div class="card-body">
                    <div id="testResult" class="d-none mb-3"></div>
                    <div class="row g-2 mb-2">
                        <div class="col-6">
                            <input type="text" id="tApiKey" class="form-control form-control-sm"
                                   placeholder="API Key">
                        </div>
                        <div class="col-6">
                            <input type="number" id="tVehicleId" class="form-control form-control-sm"
                                   placeholder="Vehicle ID" value="1">
                        </div>
                        <div class="col-6">
                            <input type="number" id="tLat" class="form-control form-control-sm"
                                   placeholder="Latitude" value="19.0760" step="0.0001">
                        </div>
                        <div class="col-6">
                            <input type="number" id="tLng" class="form-control form-control-sm"
                                   placeholder="Longitude" value="72.8777" step="0.0001">
                        </div>
                        <div class="col-6">
                            <input type="number" id="tSpeed" class="form-control form-control-sm"
                                   placeholder="Speed (km/h)" value="40">
                        </div>
                    </div>
                    <button class="btn btn-primary btn-sm w-100" onclick="testApi()">
                        <i class="bi bi-send me-1"></i>Send Test GPS Ping
                    </button>
                </div>
            </div>
        </div>

    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
function copyText(id) {
    const el = document.getElementById(id);
    el.select(); el.setSelectionRange(0, 99999);
    navigator.clipboard.writeText(el.value).then(() => {
        const btn = el.nextElementSibling;
        btn.innerHTML = '<i class="bi bi-check"></i>';
        setTimeout(() => btn.innerHTML = '<i class="bi bi-clipboard"></i>', 1500);
    });
}

function testApi() {
    const apiKey    = document.getElementById('tApiKey').value;
    const vehicleId = document.getElementById('tVehicleId').value;
    const lat       = document.getElementById('tLat').value;
    const lng       = document.getElementById('tLng').value;
    const speed     = document.getElementById('tSpeed').value;
    const ctx       = '<%= request.getContextPath() %>';

    const url = `${ctx}/updateLocation?apiKey=${encodeURIComponent(apiKey)}&vehicleId=${vehicleId}&latitude=${lat}&longitude=${lng}&speed=${speed}`;

    fetch(url)
        .then(r => r.json())
        .then(d => {
            const el = document.getElementById('testResult');
            el.className = 'alert ' + (d.success ? 'alert-success' : 'alert-danger') + ' py-2 d-block';
            el.innerHTML = '<strong>' + (d.success ? '✓ Success' : '✗ Failed') + '</strong>: '
                         + (d.message || d.error || JSON.stringify(d));
        })
        .catch(e => {
            const el = document.getElementById('testResult');
            el.className = 'alert alert-danger py-2 d-block';
            el.textContent = 'Request failed: ' + e.message;
        });
}
</script>
</body>
</html>
