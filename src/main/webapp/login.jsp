<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart Vehicle Fleet - Login</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .login-container {
            min-height: 100vh;
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
        }
        .card-custom {
            border-radius: 1rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body class="login-container d-flex align-items-center">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5 col-xl-4">
                <div class="card card-custom border-0">
                    <div class="card-body p-4 p-md-5">
                        <div class="text-center mb-4">
                            <h2 class="fw-bold text-primary mb-1">Fleet Tracker</h2>
                            <p class="text-muted small">Sign in to manage your vehicles</p>
                        </div>
                        
                        <% 
                            String error = (String) request.getAttribute("errorMessage");
                            if (error != null) { 
                        %>
                            <div class="alert alert-danger py-2 small" role="alert">
                                <%= error %>
                            </div>
                        <% } %>

                        <form action="login" method="post">
                            <div class="mb-3">
                                <label for="email" class="form-label text-muted small fw-bold">Email Address</label>
                                <input type="email" class="form-control form-control-lg" id="email" name="email" placeholder="name@example.com" required>
                            </div>
                            <div class="mb-4">
                                <label for="password" class="form-label text-muted small fw-bold">Password</label>
                                <input type="password" class="form-control form-control-lg" id="password" name="password" placeholder="Enter password" required>
                            </div>
                            <div class="d-grid gap-2 mb-3">
                                <button type="submit" class="btn btn-primary btn-lg fw-bold">Login</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <!-- Bootstrap 5 JS Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
