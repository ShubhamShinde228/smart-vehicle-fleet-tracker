<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, jakarta.servlet.http.HttpServletRequest, java.net.NetworkInterface, java.net.InetAddress, java.util.Enumeration" %>
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
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    String apiUrl = request.getScheme() + "://" + getMobileReachableHost(request) + ":" +
                    request.getServerPort() + request.getContextPath() + "/updateLocation";
    String browserApiUrl = request.getContextPath() + "/updateLocation";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Android Live Tracking - Fleet Tracker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <style>
        body { background:#f6f8fb; }
        .tracker-shell { max-width: 980px; }
        .status-dot {
            width: 10px;
            height: 10px;
            display: inline-block;
            border-radius: 50%;
            background: #6c757d;
        }
        .status-dot.live { background:#198754; box-shadow:0 0 0 .25rem rgba(25,135,84,.15); }
        .mono-box { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", monospace; }
        .metric { min-height: 86px; }
    </style>
</head>
<body>
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

<main class="container tracker-shell py-4">
    <div class="d-flex flex-wrap justify-content-between align-items-end gap-3 mb-4">
        <div>
            <h4 class="fw-bold mb-1"><i class="bi bi-phone-vibrate me-2 text-primary"></i>Android Phone Live Tracker</h4>
            <div class="text-muted small">Use dummy fleet records, but send real live GPS from an Android phone.</div>
        </div>
        <span class="badge text-bg-light border">
            <span id="statusDot" class="status-dot me-1"></span>
            <span id="trackingStatus">Stopped</span>
        </span>
    </div>

    <div class="alert alert-primary border-0 shadow-sm">
        <strong>Demo flow:</strong> keep your dummy vehicles and drivers in MySQL, assign one active vehicle to one driver, then use an Android phone as that vehicle's GPS device. Open the Live Map on your laptop and this page or GPSLogger on the phone.
    </div>

    <div class="row g-3 mb-3">
        <div class="col-lg-5">
            <div class="card border-0 shadow-sm h-100">
                <div class="card-header bg-white fw-semibold">
                    <i class="bi bi-sliders me-2 text-primary"></i>Tracking Setup
                </div>
                <div class="card-body">
                    <label class="form-label small fw-semibold">API Endpoint</label>
                    <div class="input-group input-group-sm mb-3">
                        <input type="text" id="apiUrl" class="form-control mono-box" value="<%= apiUrl %>" readonly>
                        <button class="btn btn-outline-secondary" type="button" onclick="copyText('apiUrl')">
                            <i class="bi bi-clipboard"></i>
                        </button>
                    </div>

                    <div class="row g-2">
                        <div class="col-md-7">
                            <label class="form-label small fw-semibold">API Key</label>
                            <input type="text" id="apiKey" class="form-control form-control-sm mono-box"
                                   value="driver-app-key-2026-mobile">
                        </div>
                        <div class="col-md-5">
                            <label class="form-label small fw-semibold">Dummy Vehicle ID</label>
                            <select id="vehicleId" class="form-select form-select-sm">
                                <option value="1">1 - MH01AB1234</option>
                                <option value="3">3 - MH03EF9012</option>
                                <option value="2">2 - MH02CD5678</option>
                                <option value="4">4 - MH04GH3456</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold">Update Every</label>
                            <select id="intervalSeconds" class="form-select form-select-sm">
                                <option value="5">5 seconds</option>
                                <option value="10" selected>10 seconds</option>
                                <option value="15">15 seconds</option>
                                <option value="30">30 seconds</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label small fw-semibold">Source Name</label>
                            <input type="text" id="apiSource" class="form-control form-control-sm" value="android-phone">
                        </div>
                    </div>

                    <div class="d-grid gap-2 mt-3">
                        <button id="startBtn" class="btn btn-success" type="button" onclick="startTracking()">
                            <i class="bi bi-play-fill me-1"></i>Start Phone Tracking
                        </button>
                        <button id="stopBtn" class="btn btn-outline-danger" type="button" onclick="stopTracking()" disabled>
                            <i class="bi bi-stop-fill me-1"></i>Stop Tracking
                        </button>
                    </div>

                    <p class="text-muted small mb-0 mt-3">
                        Browser tracking requires GPS permission. On Android Chrome it may require HTTPS; if permission is blocked on local HTTP, use the GPSLogger URL below.
                    </p>
                </div>
            </div>
        </div>

        <div class="col-lg-7">
            <div class="row g-3">
                <div class="col-sm-6">
                    <div class="card border-0 shadow-sm metric">
                        <div class="card-body">
                            <div class="text-muted small">Latitude</div>
                            <div id="latText" class="fs-5 fw-bold">--</div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-6">
                    <div class="card border-0 shadow-sm metric">
                        <div class="card-body">
                            <div class="text-muted small">Longitude</div>
                            <div id="lonText" class="fs-5 fw-bold">--</div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="card border-0 shadow-sm metric">
                        <div class="card-body">
                            <div class="text-muted small">Speed</div>
                            <div id="speedText" class="fs-5 fw-bold">--</div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="card border-0 shadow-sm metric">
                        <div class="card-body">
                            <div class="text-muted small">Accuracy</div>
                            <div id="accuracyText" class="fs-5 fw-bold">--</div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <div class="card border-0 shadow-sm metric">
                        <div class="card-body">
                            <div class="text-muted small">Last Sent</div>
                            <div id="lastSentText" class="fs-6 fw-bold">--</div>
                        </div>
                    </div>
                </div>
                <div class="col-12">
                    <div id="resultBox" class="alert alert-secondary mb-0">Ready to send phone location.</div>
                </div>
            </div>
        </div>
    </div>

    <div class="card border-0 shadow-sm">
        <div class="card-header bg-white fw-semibold">
            <i class="bi bi-android2 me-2 text-success"></i>GPSLogger Android App URL
        </div>
        <div class="card-body">
            <p class="small text-muted">
                This is the most reliable option on local Wi-Fi because GPSLogger can send HTTP requests directly to your laptop server.
                Browser tracking uses the current page origin to avoid cross-origin request blocking.
            </p>
            <label class="form-label small fw-semibold">Custom URL for GPSLogger</label>
            <div class="input-group input-group-sm">
                <input type="text" id="gpsloggerUrl" class="form-control mono-box" readonly>
                <button class="btn btn-outline-success" type="button" onclick="copyText('gpsloggerUrl')">
                    <i class="bi bi-clipboard"></i>
                </button>
            </div>
            <div class="small text-muted mt-2">
                In GPSLogger: Preferences -> Logging Details -> Log to Custom URL -> paste this URL.
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
let watchId = null;
let intervalId = null;
let latestPosition = null;

const apiUrlEl = document.getElementById('apiUrl');
const apiKeyEl = document.getElementById('apiKey');
const vehicleIdEl = document.getElementById('vehicleId');
const apiSourceEl = document.getElementById('apiSource');
const intervalSecondsEl = document.getElementById('intervalSeconds');
const gpsloggerUrlEl = document.getElementById('gpsloggerUrl');
const browserApiUrl = '<%= browserApiUrl %>';

function copyText(id) {
    const el = document.getElementById(id);
    el.select();
    el.setSelectionRange(0, 99999);
    navigator.clipboard.writeText(el.value);
}

function updateGpsLoggerUrl() {
    const params = new URLSearchParams({
        apiKey: apiKeyEl.value.trim(),
        vehicleId: vehicleIdEl.value,
        latitude: '%LAT',
        longitude: '%LON',
        speed: '%SPD',
        apiSource: apiSourceEl.value.trim() || 'android-phone'
    });
    gpsloggerUrlEl.value = apiUrlEl.value + '?' + params.toString()
        .replace('%25LAT', '%LAT')
        .replace('%25LON', '%LON')
        .replace('%25SPD', '%SPD');
}

function setStatus(text, live) {
    document.getElementById('trackingStatus').textContent = text;
    document.getElementById('statusDot').classList.toggle('live', live);
}

function showResult(message, type) {
    const el = document.getElementById('resultBox');
    el.className = 'alert alert-' + type + ' mb-0';
    el.textContent = message;
}

function startTracking() {
    if (!navigator.geolocation) {
        showResult('Geolocation is not supported on this phone browser.', 'danger');
        return;
    }

    document.getElementById('startBtn').disabled = true;
    document.getElementById('stopBtn').disabled = false;
    setStatus('Waiting for GPS', true);
    showResult('Requesting GPS permission from Android phone...', 'info');

    watchId = navigator.geolocation.watchPosition(position => {
        latestPosition = position;
        renderPosition(position);
        sendPosition(position);
    }, error => {
        showResult('GPS permission/location error: ' + error.message, 'danger');
        setStatus('GPS Error', false);
    }, {
        enableHighAccuracy: true,
        maximumAge: 0,
        timeout: 15000
    });

    intervalId = setInterval(() => {
        if (latestPosition) {
            sendPosition(latestPosition);
        }
    }, Number(intervalSecondsEl.value) * 1000);
}

function stopTracking() {
    if (watchId !== null) {
        navigator.geolocation.clearWatch(watchId);
        watchId = null;
    }
    if (intervalId !== null) {
        clearInterval(intervalId);
        intervalId = null;
    }
    document.getElementById('startBtn').disabled = false;
    document.getElementById('stopBtn').disabled = true;
    setStatus('Stopped', false);
    showResult('Tracking stopped.', 'secondary');
}

function renderPosition(position) {
    const c = position.coords;
    document.getElementById('latText').textContent = c.latitude.toFixed(7);
    document.getElementById('lonText').textContent = c.longitude.toFixed(7);
    document.getElementById('speedText').textContent = formatSpeed(c.speed);
    document.getElementById('accuracyText').textContent = Math.round(c.accuracy) + ' m';
}

function formatSpeed(speedMetersPerSecond) {
    if (speedMetersPerSecond === null || Number.isNaN(speedMetersPerSecond)) {
        return '0 km/h';
    }
    return Math.round(speedMetersPerSecond * 3.6) + ' km/h';
}

function sendPosition(position) {
    const c = position.coords;
    const speedKmh = c.speed === null || Number.isNaN(c.speed) ? 0 : c.speed * 3.6;
    const params = new URLSearchParams({
        apiKey: apiKeyEl.value.trim(),
        vehicleId: vehicleIdEl.value,
        latitude: c.latitude,
        longitude: c.longitude,
        speed: speedKmh.toFixed(2),
        apiSource: apiSourceEl.value.trim() || 'android-phone'
    });

    fetch(browserApiUrl + '?' + params.toString())
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                document.getElementById('lastSentText').textContent = new Date().toLocaleTimeString();
                setStatus('Live', true);
                showResult('Location sent successfully. Open Live Map to see this phone moving.', 'success');
            } else {
                showResult(data.message || 'Location was rejected by server.', 'warning');
            }
        })
        .catch(error => {
            showResult('Could not send location: ' + error.message, 'danger');
        });
}

[apiKeyEl, vehicleIdEl, apiSourceEl, apiUrlEl].forEach(el => {
    el.addEventListener('input', updateGpsLoggerUrl);
    el.addEventListener('change', updateGpsLoggerUrl);
});
updateGpsLoggerUrl();
</script>
</body>
</html>
