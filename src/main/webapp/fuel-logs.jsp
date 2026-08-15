<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.fleet.model.User, com.fleet.model.FuelLog,
                 com.fleet.dao.FuelDAO, com.fleet.dao.VehicleDAO, com.fleet.model.Vehicle,
                 java.util.List, java.util.Map, java.util.Map.Entry" %>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login.jsp"); return; }
    String role = currentUser.getRole();

    String vehicleFilter = request.getParameter("vehicleId") != null ? request.getParameter("vehicleId") : "All";
    String monthFilter   = request.getParameter("month")     != null ? request.getParameter("month")     : "All";

    FuelDAO   fuelDAO    = new FuelDAO();
    VehicleDAO vDAO      = new VehicleDAO();
    List<Vehicle>   vehicles = vDAO.getAllVehicles();
    List<FuelLog>   logs     = fuelDAO.getAllFuelLogs(vehicleFilter, monthFilter);
    Map<String,Double> stats = fuelDAO.getSummaryStats();
    Map<String,Double> monthlySpend  = fuelDAO.getMonthlySpend();
    Map<String,Double> monthlyLiters = fuelDAO.getMonthlyLiters();
    List<Map<String,Object>> efficiency = fuelDAO.getVehicleEfficiency();

    String successMsg = (String) session.getAttribute("successMessage");
    String errorMsg   = (String) session.getAttribute("errorMessage");
    session.removeAttribute("successMessage");
    session.removeAttribute("errorMessage");

    double totalSpend   = stats.getOrDefault("totalSpend",   0.0);
    double totalLiters  = stats.getOrDefault("totalLiters",  0.0);
    double avgPrice     = stats.getOrDefault("avgPrice",     0.0);
    int    totalEntries = stats.getOrDefault("totalEntries", 0.0).intValue();

    // Build JSON arrays for Chart.js
    StringBuilder monthLabels = new StringBuilder("[");
    StringBuilder spendData   = new StringBuilder("[");
    StringBuilder litersData  = new StringBuilder("[");
    boolean first = true;
    for (Entry<String,Double> e : monthlySpend.entrySet()) {
        if (!first) { monthLabels.append(","); spendData.append(","); litersData.append(","); }
        monthLabels.append("'").append(e.getKey()).append("'");
        spendData.append(String.format("%.2f", e.getValue().doubleValue()));
        Double ltr = monthlyLiters.get(e.getKey());
        litersData.append(ltr != null ? String.format("%.2f", ltr.doubleValue()) : "0");
        first = false;
    }
    monthLabels.append("]"); spendData.append("]"); litersData.append("]");

    // Efficiency chart data
    StringBuilder effLabels = new StringBuilder("[");
    StringBuilder effData   = new StringBuilder("[");
    boolean efFirst = true;
    for (Map<String,Object> row : efficiency) {
        if (!efFirst) { effLabels.append(","); effData.append(","); }
        effLabels.append("'").append(row.get("vehicleNumber")).append("'");
        double effVal = ((Number) row.get("efficiency")).doubleValue();
        effData.append(String.format("%.2f", effVal));
        efFirst = false;
    }
    effLabels.append("]"); effData.append("]");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fuel Analytics - FleetTracker</title>
    <meta name="description" content="Monitor fuel consumption, costs, and efficiency across your entire fleet.">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        :root {
            --fuel-primary:   #0d6efd;
            --fuel-success:   #198754;
            --fuel-warning:   #fd7e14;
            --fuel-danger:    #dc3545;
            --fuel-info:      #0dcaf0;
            --card-radius:    14px;
        }
        body { font-family: 'Inter', sans-serif; background: #f0f4f8; }

        /* ── KPI Cards ─────────────────────────────── */
        .kpi-card {
            border-radius: var(--card-radius);
            border: none;
            box-shadow: 0 2px 12px rgba(0,0,0,.07);
            transition: transform .2s, box-shadow .2s;
            overflow: hidden;
            position: relative;
        }
        .kpi-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,.12); }
        .kpi-card .kpi-icon {
            width: 56px; height: 56px; border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.5rem;
        }
        .kpi-card .kpi-value { font-size: 1.8rem; font-weight: 700; line-height: 1; }
        .kpi-card .kpi-label { font-size: .78rem; color: #6c757d; text-transform: uppercase; letter-spacing: .05em; }
        .kpi-card .kpi-glow {
            position: absolute; top: -40px; right: -40px;
            width: 110px; height: 110px; border-radius: 50%; opacity: .08;
        }

        /* ── Charts ────────────────────────────────── */
        .chart-card {
            border-radius: var(--card-radius);
            border: none;
            box-shadow: 0 2px 12px rgba(0,0,0,.07);
        }
        .chart-card .card-header {
            background: white; border-bottom: 1px solid #f1f3f5;
            border-radius: var(--card-radius) var(--card-radius) 0 0;
            padding: 1rem 1.25rem;
        }

        /* ── Table ─────────────────────────────────── */
        .fuel-table th { font-size: .76rem; text-transform: uppercase; letter-spacing: .05em; }
        .fuel-table td { font-size: .88rem; vertical-align: middle; }
        .badge-fuel { background: #e8f4fd; color: #0d6efd; font-weight: 600; }

        /* ── Efficiency bar ─────────────────────────── */
        .eff-bar { height: 6px; border-radius: 4px; background: #e9ecef; overflow: hidden; }
        .eff-bar-fill { height: 100%; border-radius: 4px;
            background: linear-gradient(90deg, #28a745, #fd7e14, #dc3545); }

        /* ── Page Header ────────────────────────────── */
        .page-header {
            background: linear-gradient(135deg, #1e3a5f 0%, #0d6efd 100%);
            color: white; padding: 1.4rem 1.5rem;
        }

        /* ── Nav ────────────────────────────────────── */
        .navbar { background: #0a1628 !important; }
        .navbar-brand { font-weight: 700; }
        .nav-link { font-size: .88rem; }
        .nav-link:hover { color: #60a5fa !important; }
    </style>
</head>
<body>

<!-- ═══════════ NAVBAR ═══════════ -->
<nav class="navbar navbar-expand-lg navbar-dark shadow-sm">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold" href="dashboard.jsp">
            <i class="bi bi-truck-front-fill me-2 text-primary"></i>FleetTracker
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMain">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navMain">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="dashboard.jsp"><i class="bi bi-speedometer2 me-1"></i>Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="vehicle-list.jsp"><i class="bi bi-truck me-1"></i>Vehicles</a></li>
                <% if ("Admin".equalsIgnoreCase(role) || "Manager".equalsIgnoreCase(role)) { %>
                <li class="nav-item"><a class="nav-link" href="driver-list.jsp"><i class="bi bi-people me-1"></i>Drivers</a></li>
                <li class="nav-item"><a class="nav-link" href="assignment-list.jsp"><i class="bi bi-arrow-left-right me-1"></i>Assignments</a></li>
                <li class="nav-item"><a class="nav-link" href="live-tracking.jsp"><i class="bi bi-broadcast me-1"></i>Live Map</a></li>
                <li class="nav-item"><a class="nav-link" href="maintenance-notifications.jsp"><i class="bi bi-tools me-1"></i>Maintenance</a></li>
                <li class="nav-item"><a class="nav-link" href="geofence-list.jsp"><i class="bi bi-bounding-box-circles me-1"></i>Geofences</a></li>
                <li class="nav-item"><a class="nav-link" href="geofence-alerts.jsp"><i class="bi bi-exclamation-triangle me-1"></i>Alerts</a></li>
                <% } %>
                <li class="nav-item"><a class="nav-link active" href="fuel-logs.jsp"><i class="bi bi-fuel-pump me-1"></i>Fuel</a></li>
                <li class="nav-item"><a class="nav-link" href="mobile-tracking.jsp"><i class="bi bi-phone me-1"></i>My Tracking</a></li>
                <% if ("Admin".equalsIgnoreCase(role)) { %>
                <li class="nav-item"><a class="nav-link" href="gps-api-config.jsp"><i class="bi bi-key me-1"></i>GPS Config</a></li>
                <% } %>
            </ul>
            <div class="d-flex align-items-center gap-2">
                <span class="text-light small"><i class="bi bi-person-circle me-1"></i><%= currentUser.getName() != null ? currentUser.getName() : currentUser.getEmail() %></span>
                <% String bc = "bg-secondary";
                   if ("Admin".equalsIgnoreCase(role)) bc = "bg-danger";
                   else if ("Manager".equalsIgnoreCase(role)) bc = "bg-warning text-dark";
                   else if ("Driver".equalsIgnoreCase(role)) bc = "bg-success"; %>
                <span class="badge <%= bc %>"><%= role %></span>
                <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline-light btn-sm ms-2">
                    <i class="bi bi-box-arrow-right me-1"></i>Logout
                </a>
            </div>
        </div>
    </div>
</nav>

<!-- ═══════════ PAGE HEADER ═══════════ -->
<div class="page-header">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h5 class="mb-1 fw-bold"><i class="bi bi-fuel-pump-fill me-2"></i>Fuel Monitoring &amp; Analytics</h5>
                <small class="opacity-75">Track fuel consumption, costs &amp; vehicle efficiency across the fleet</small>
            </div>
            <a href="fuel-log-form.jsp" class="btn btn-light fw-semibold" id="btn-add-fuel-log">
                <i class="bi bi-plus-circle me-1"></i>Log Fuel Fill-up
            </a>
        </div>
    </div>
</div>

<div class="container-fluid px-4 py-4">

    <!-- Flash Messages -->
    <% if (successMsg != null) { %>
    <div class="alert alert-success alert-dismissible fade show py-2 mb-3" role="alert">
        <i class="bi bi-check-circle me-2"></i><%= successMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert alert-danger alert-dismissible fade show py-2 mb-3" role="alert">
        <i class="bi bi-exclamation-circle me-2"></i><%= errorMsg %>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <% } %>

    <!-- ═══ KPI CARDS ═══ -->
    <div class="row g-3 mb-4">

        <div class="col-sm-6 col-xl-3">
            <div class="card kpi-card bg-white">
                <div class="kpi-glow bg-primary"></div>
                <div class="card-body d-flex align-items-center gap-3 p-3">
                    <div class="kpi-icon bg-primary bg-opacity-10 text-primary"><i class="bi bi-currency-rupee"></i></div>
                    <div>
                        <div class="kpi-value text-primary">₹<%= String.format("%,.0f", totalSpend) %></div>
                        <div class="kpi-label mt-1">Total Fuel Spend</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-sm-6 col-xl-3">
            <div class="card kpi-card bg-white">
                <div class="kpi-glow bg-success"></div>
                <div class="card-body d-flex align-items-center gap-3 p-3">
                    <div class="kpi-icon bg-success bg-opacity-10 text-success"><i class="bi bi-droplet-fill"></i></div>
                    <div>
                        <div class="kpi-value text-success"><%= String.format("%,.0f", totalLiters) %> L</div>
                        <div class="kpi-label mt-1">Total Liters Filled</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-sm-6 col-xl-3">
            <div class="card kpi-card bg-white">
                <div class="kpi-glow bg-warning"></div>
                <div class="card-body d-flex align-items-center gap-3 p-3">
                    <div class="kpi-icon bg-warning bg-opacity-10 text-warning"><i class="bi bi-tag-fill"></i></div>
                    <div>
                        <div class="kpi-value text-warning">₹<%= String.format("%.2f", avgPrice) %></div>
                        <div class="kpi-label mt-1">Avg Price / Liter</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-sm-6 col-xl-3">
            <div class="card kpi-card bg-white">
                <div class="kpi-glow bg-info"></div>
                <div class="card-body d-flex align-items-center gap-3 p-3">
                    <div class="kpi-icon bg-info bg-opacity-10 text-info"><i class="bi bi-journal-check"></i></div>
                    <div>
                        <div class="kpi-value text-info"><%= totalEntries %></div>
                        <div class="kpi-label mt-1">Fill-up Records</div>
                    </div>
                </div>
            </div>
        </div>

    </div><!-- /KPI Row -->

    <!-- ═══ CHARTS ROW ═══ -->
    <div class="row g-3 mb-4">

        <!-- Monthly Spend Chart -->
        <div class="col-lg-8">
            <div class="card chart-card h-100">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <span class="fw-semibold"><i class="bi bi-bar-chart-fill me-2 text-primary"></i>Monthly Fuel Spend &amp; Volume (Last 6 Months)</span>
                </div>
                <div class="card-body">
                    <canvas id="monthlyChart" height="100"></canvas>
                </div>
            </div>
        </div>

        <!-- Efficiency Doughnut -->
        <div class="col-lg-4">
            <div class="card chart-card h-100">
                <div class="card-header">
                    <span class="fw-semibold"><i class="bi bi-speedometer me-2 text-warning"></i>Vehicle Efficiency (km/L)</span>
                </div>
                <div class="card-body">
                    <canvas id="efficiencyChart" height="160"></canvas>
                </div>
            </div>
        </div>

    </div><!-- /Charts Row -->

    <!-- ═══ EFFICIENCY TABLE ═══ -->
    <div class="card chart-card mb-4">
        <div class="card-header">
            <span class="fw-semibold"><i class="bi bi-table me-2 text-success"></i>Per-Vehicle Fuel Efficiency Summary</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 fuel-table">
                    <thead class="table-dark">
                        <tr>
                            <th class="ps-3">#</th>
                            <th>Vehicle</th>
                            <th>Model</th>
                            <th>Total Liters</th>
                            <th>Total Cost</th>
                            <th>KM Driven</th>
                            <th>Efficiency</th>
                            <th class="pe-3">Rating</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (efficiency.isEmpty()) { %>
                        <tr><td colspan="8" class="text-center py-4 text-muted"><i class="bi bi-inbox fs-3 d-block mb-2"></i>No data yet. Add your first fuel log.</td></tr>
                        <% } else { int ei = 1; for (Map<String,Object> ev : efficiency) {
                            double eff      = ((Number) ev.get("efficiency")).doubleValue();
                            double evLiters = ((Number) ev.get("totalLiters")).doubleValue();
                            double evCost   = ((Number) ev.get("totalCost")).doubleValue();
                            double evKm     = ((Number) ev.get("kmDriven")).doubleValue();
                            String effColor = eff >= 12 ? "success" : (eff >= 8 ? "warning" : "danger");
                            String effLabel = eff >= 12 ? "Excellent" : (eff >= 8 ? "Good" : "Poor");
                            double maxEff = 20.0;
                            int barWidth = (int) Math.min(100, (eff / maxEff) * 100);
                        %>
                        <tr>
                            <td class="ps-3 text-muted small"><%= ei++ %></td>
                            <td><span class="badge bg-dark fw-semibold"><%= ev.get("vehicleNumber") %></span></td>
                            <td class="fw-semibold"><%= ev.get("vehicleModel") %></td>
                            <td><%= String.format("%.1f", evLiters) %> L</td>
                            <td class="fw-semibold text-primary">&#8377;<%= String.format("%,.0f", evCost) %></td>
                            <td><%= String.format("%.0f", evKm) %> km</td>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="eff-bar flex-grow-1">
                                        <div class="eff-bar-fill" style="width:<%= barWidth %>%"></div>
                                    </div>
                                    <span class="small fw-semibold"><%= String.format("%.1f", eff) %></span>
                                </div>
                            </td>
                            <td class="pe-3"><span class="badge bg-<%= effColor %>"><%= effLabel %></span></td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- ═══ FUEL LOG TABLE ═══ -->
    <div class="card chart-card">
        <div class="card-header d-flex justify-content-between align-items-center flex-wrap gap-2">
            <span class="fw-semibold"><i class="bi bi-list-ul me-2 text-info"></i>Fuel Log Entries (<%= logs.size() %> records)</span>
            <!-- Filters -->
            <form method="get" action="fuel-logs.jsp" class="d-flex gap-2 align-items-center flex-wrap" id="fuel-filter-form">
                <select class="form-select form-select-sm" name="vehicleId" style="width:160px" id="filter-vehicle">
                    <option value="All" <%= "All".equals(vehicleFilter) ? "selected" : "" %>>All Vehicles</option>
                    <% for (Vehicle v : vehicles) { %>
                    <option value="<%= v.getId() %>" <%= String.valueOf(v.getId()).equals(vehicleFilter) ? "selected" : "" %>><%= v.getVehicleNumber() %></option>
                    <% } %>
                </select>
                <input type="month" class="form-control form-control-sm" name="month"
                       value="<%= "All".equals(monthFilter) ? "" : monthFilter %>"
                       style="width:150px" id="filter-month">
                <button type="submit" class="btn btn-primary btn-sm"><i class="bi bi-funnel me-1"></i>Filter</button>
                <a href="fuel-logs.jsp" class="btn btn-outline-secondary btn-sm"><i class="bi bi-x-circle"></i></a>
            </form>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0 fuel-table">
                    <thead class="table-light">
                        <tr>
                            <th class="ps-3">#</th>
                            <th>Date</th>
                            <th>Vehicle</th>
                            <th>Liters</th>
                            <th>Price/L</th>
                            <th>Total Cost</th>
                            <th>Odometer</th>
                            <th>Station</th>
                            <th class="text-center pe-3">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (logs.isEmpty()) { %>
                        <tr><td colspan="9" class="text-center py-4 text-muted">
                            <i class="bi bi-fuel-pump fs-2 d-block mb-2"></i>No fuel logs found.
                            <a href="fuel-log-form.jsp">Add your first fill-up</a>.
                        </td></tr>
                        <% } else { int li = 1; for (FuelLog fl : logs) { %>
                        <tr>
                            <td class="ps-3 text-muted small"><%= li++ %></td>
                            <td class="small"><%= fl.getFillDate() %></td>
                            <td>
                                <span class="badge badge-fuel"><%= fl.getVehicleNumber() %></span>
                                <div class="text-muted" style="font-size:.76rem"><%= fl.getVehicleModel() %></div>
                            </td>
                            <td class="fw-semibold"><%= String.format("%.2f", fl.getLiters()) %> L</td>
                            <td class="small">₹<%= String.format("%.2f", fl.getCostPerLiter()) %></td>
                            <td class="fw-semibold text-success">₹<%= String.format("%,.2f", fl.getTotalCost()) %></td>
                            <td class="small"><%= String.format("%,.0f", fl.getOdometerKm()) %> km</td>
                            <td class="small text-muted"><%= fl.getFuelStation() != null && !fl.getFuelStation().isEmpty() ? fl.getFuelStation() : "-" %></td>
                            <td class="text-center pe-3">
                                <a href="<%= request.getContextPath() %>/delete-fuel-log?id=<%= fl.getId() %>"
                                   class="btn btn-outline-danger btn-sm"
                                   onclick="return confirm('Delete this fuel log entry?')" title="Delete">
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
<script>
// ── Monthly Bar + Line Chart ──────────────────────────────────────────────
const monthLabels  = <%= monthLabels %>;
const spendData    = <%= spendData %>;
const litersData   = <%= litersData %>;

const ctx1 = document.getElementById('monthlyChart').getContext('2d');
new Chart(ctx1, {
    data: {
        labels: monthLabels,
        datasets: [
            {
                type: 'bar',
                label: 'Fuel Spend (₹)',
                data: spendData,
                backgroundColor: 'rgba(13,110,253,0.75)',
                borderRadius: 6,
                yAxisID: 'y',
            },
            {
                type: 'line',
                label: 'Liters Filled (L)',
                data: litersData,
                borderColor: '#fd7e14',
                backgroundColor: 'rgba(253,126,20,0.1)',
                fill: true,
                tension: 0.4,
                pointRadius: 5,
                pointBackgroundColor: '#fd7e14',
                yAxisID: 'y1',
            }
        ]
    },
    options: {
        responsive: true,
        interaction: { mode: 'index', intersect: false },
        plugins: {
            legend: { position: 'top' },
            tooltip: {
                callbacks: {
                    label: ctx => {
                        const v = ctx.parsed.y;
                        return ctx.datasetIndex === 0
                            ? ' ₹' + v.toLocaleString('en-IN', {minimumFractionDigits:2})
                            : ' ' + v.toFixed(1) + ' L';
                    }
                }
            }
        },
        scales: {
            y:  { type:'linear', position:'left',  title:{display:true,text:'Spend (₹)'} },
            y1: { type:'linear', position:'right', title:{display:true,text:'Liters (L)'}, grid:{drawOnChartArea:false} }
        }
    }
});

// ── Efficiency Bar Chart ──────────────────────────────────────────────────
const effLabels = <%= effLabels %>;
const effData   = <%= effData %>;

const ctx2 = document.getElementById('efficiencyChart').getContext('2d');
new Chart(ctx2, {
    type: 'bar',
    data: {
        labels: effLabels,
        datasets: [{
            label: 'km/L',
            data: effData,
            backgroundColor: effData.map(v =>
                v >= 12 ? 'rgba(25,135,84,.75)' :
                v >= 8  ? 'rgba(253,126,20,.75)' :
                          'rgba(220,53,69,.75)'
            ),
            borderRadius: 6,
        }]
    },
    options: {
        indexAxis: 'y',
        responsive: true,
        plugins: { legend: { display: false } },
        scales: { x: { title: { display: true, text: 'km per Liter' } } }
    }
});
</script>
</body>
</html>
