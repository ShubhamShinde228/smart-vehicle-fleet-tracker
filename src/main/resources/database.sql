-- Create database (if needed)
CREATE DATABASE IF NOT EXISTS fleet_db;
USE fleet_db;

-- Roles Table
CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role_id INT NOT NULL,
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- Insert Roles
INSERT IGNORE INTO roles (id, role_name) VALUES (1, 'Admin'), (2, 'Manager'), (3, 'Driver');

-- Insert Sample Users
-- Warning: In a real world application, passwords should be hashed (e.g. BCrypt)!
INSERT IGNORE INTO users (id, email, password, name, role_id) VALUES
(1, 'admin@fleet.com', 'admin123', 'System Admin', 1),
(2, 'manager@fleet.com', 'manager123', 'Fleet Manager', 2),
(3, 'driver@fleet.com', 'driver123', 'John Doe', 3);

-- ═══════════════════════════════════════════════════
-- VEHICLE MANAGEMENT MODULE
-- ═══════════════════════════════════════════════════

-- Vehicles Table
CREATE TABLE IF NOT EXISTS vehicles (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_number      VARCHAR(20)     NOT NULL UNIQUE,
    model               VARCHAR(100)    NOT NULL,
    vehicle_type        VARCHAR(50)     NOT NULL,
    fuel_type           VARCHAR(50)     NOT NULL,
    fuel_capacity       DECIMAL(6,2)    DEFAULT 0.00,
    registration_date   DATE,
    insurance_expiry    DATE,
    maintenance_due_date DATE,
    status              VARCHAR(20)     NOT NULL DEFAULT 'Active'
);

-- Sample Vehicles
INSERT IGNORE INTO vehicles (id, vehicle_number, model, vehicle_type, fuel_type, fuel_capacity, registration_date, insurance_expiry, maintenance_due_date, status) VALUES
(1, 'MH01AB1234', 'Toyota Innova Crysta', 'Van',   'Diesel',  60.00, '2022-01-15', '2026-01-15', '2026-07-15', 'Active'),
(2, 'MH02CD5678', 'Tata Ace Gold',          'Truck', 'Diesel',  45.00, '2021-06-10', '2026-06-10', '2026-04-10', 'In Maintenance'),
(3, 'MH03EF9012', 'Maruti Ertiga',          'Van',   'Petrol',  55.00, '2023-03-20', '2027-03-20', '2026-08-20', 'Active'),
(4, 'MH04GH3456', 'Ashok Leyland Dost',     'Truck', 'Diesel',  80.00, '2020-11-05', '2026-11-05', '2026-05-05', 'Inactive'),
(5, 'MH05JK7788', 'Mahindra Bolero Pickup', 'Truck', 'Diesel',  57.00, '2024-04-12', '2027-04-12', '2026-09-12', 'Active'),
(6, 'MH12LM4455', 'Hyundai Creta',          'SUV',   'Petrol',  50.00, '2023-09-01', '2027-09-01', '2026-10-01', 'Active');

-- ═══════════════════════════════════════════════════
-- DRIVER MANAGEMENT MODULE
-- ═══════════════════════════════════════════════════

-- Drivers Table
CREATE TABLE IF NOT EXISTS drivers (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    name              VARCHAR(100)  NOT NULL,
    email             VARCHAR(100)  NOT NULL UNIQUE,
    phone             VARCHAR(20),
    address           TEXT,
    license_number    VARCHAR(50)   NOT NULL UNIQUE,
    license_expiry    DATE,
    emergency_contact VARCHAR(150),
    status            VARCHAR(20)   NOT NULL DEFAULT 'Active'
);

-- Sample Drivers
INSERT IGNORE INTO drivers (id, name, email, phone, address, license_number, license_expiry, emergency_contact, status) VALUES
(1, 'Rajesh Kumar',  'rajesh.kumar@fleet.com',  '9876543210', '12, MG Road, Mumbai, MH',         'MH0120210001234', '2027-06-30', 'Sunita Kumar - 9876543211', 'Active'),
(2, 'Amit Sharma',   'amit.sharma@fleet.com',   '9123456780', '45, Lal Bagh, Pune, MH',           'MH1220200056789', '2026-03-15', 'Priya Sharma - 9123456781',  'Active'),
(3, 'Suresh Yadav',  'suresh.yadav@fleet.com',  '9988776655', '7, Sector 14, Navi Mumbai, MH',    'MH0219980098765', '2026-12-01', 'Kamla Yadav - 9988776656',   'On Leave'),
(4, 'Deepak Patil',  'deepak.patil@fleet.com',  '9871234560', '33, Andheri West, Mumbai, MH',     'MH0220152034567', '2026-05-20', 'Lata Patil - 9871234561',    'Inactive'),
(5, 'Neha More',     'neha.more@fleet.com',     '9001122334', '88, Baner Road, Pune, MH',         'MH1420220011223', '2028-02-18', 'Kiran More - 9001122335',    'Active'),
(6, 'Imran Shaikh',  'imran.shaikh@fleet.com',  '9012345678', '21, Thane West, Mumbai, MH',       'MH0420214433221', '2027-11-05', 'Aaliya Shaikh - 9012345679', 'Active');

-- ═══════════════════════════════════════════════════
-- VEHICLE ASSIGNMENT MODULE
-- ═══════════════════════════════════════════════════

-- Vehicle Assignments Table
CREATE TABLE IF NOT EXISTS vehicle_assignments (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id  INT  NOT NULL,
    driver_id   INT  NOT NULL,
    assigned_by INT,                      -- FK to users.id (who created the assignment)
    start_date  DATE NOT NULL,
    end_date    DATE DEFAULT NULL,        -- NULL = assignment still active
    notes       TEXT,
    FOREIGN KEY (vehicle_id)  REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id)   REFERENCES drivers(id)  ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(id)    ON DELETE SET NULL
);

-- Sample Assignments
-- Active: vehicle 1 (MH01AB1234) → driver 1 (Rajesh Kumar)
-- Active: vehicle 3 (MH03EF9012) → driver 2 (Amit Sharma)
-- Completed: vehicle 2 (MH02CD5678) → driver 1 historical (ended)
INSERT INTO vehicle_assignments (vehicle_id, driver_id, assigned_by, start_date, end_date, notes)
SELECT 1, 1, 1, '2026-01-10', NULL, 'Regular city delivery route'
WHERE NOT EXISTS (SELECT 1 FROM vehicle_assignments WHERE vehicle_id = 1 AND end_date IS NULL);

INSERT INTO vehicle_assignments (vehicle_id, driver_id, assigned_by, start_date, end_date, notes)
SELECT 3, 2, 1, '2026-02-01', NULL, 'Airport shuttle duty'
WHERE NOT EXISTS (SELECT 1 FROM vehicle_assignments WHERE vehicle_id = 3 AND end_date IS NULL);

INSERT INTO vehicle_assignments (vehicle_id, driver_id, assigned_by, start_date, end_date, notes)
SELECT 5, 5, 2, '2026-05-01', NULL, 'Pune warehouse distribution'
WHERE NOT EXISTS (SELECT 1 FROM vehicle_assignments WHERE vehicle_id = 5 AND end_date IS NULL);

INSERT INTO vehicle_assignments (vehicle_id, driver_id, assigned_by, start_date, end_date, notes)
SELECT 6, 6, 2, '2026-05-10', NULL, 'Mumbai executive route'
WHERE NOT EXISTS (SELECT 1 FROM vehicle_assignments WHERE vehicle_id = 6 AND end_date IS NULL);

INSERT INTO vehicle_assignments (vehicle_id, driver_id, assigned_by, start_date, end_date, notes)
SELECT 2, 1, 1, '2025-11-01', '2025-12-31', 'Completed - year end reassignment'
WHERE NOT EXISTS (SELECT 1 FROM vehicle_assignments WHERE vehicle_id = 2 AND driver_id = 1 AND start_date = '2025-11-01');

-- ═══════════════════════════════════════════════════
-- GPS TRACKING MODULE
-- ═══════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS vehicle_locations (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id INT            NOT NULL,
    driver_id  INT            NOT NULL,
    latitude   DECIMAL(10,7)  NOT NULL,
    longitude  DECIMAL(11,7)  NOT NULL,
    speed      DECIMAL(6,2)   DEFAULT 0.00,
    timestamp  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_veh_ts (vehicle_id, timestamp),
    INDEX idx_ts (timestamp),
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE,
    FOREIGN KEY (driver_id)  REFERENCES drivers(id)  ON DELETE CASCADE
);

-- Sample GPS data: guarded by vehicle + coordinate so repeated imports do not keep duplicating demo points.
INSERT INTO vehicle_locations (vehicle_id, driver_id, latitude, longitude, speed, timestamp)
SELECT seed.vehicle_id, seed.driver_id, seed.latitude, seed.longitude, seed.speed, seed.timestamp
FROM (
    SELECT 1 vehicle_id, 1 driver_id, 19.0728900 latitude, 72.8826100 longitude, 30.0 speed, DATE_SUB(NOW(), INTERVAL 90  MINUTE) timestamp
    UNION ALL SELECT 1, 1, 19.0741200, 72.8839000, 38.5, DATE_SUB(NOW(), INTERVAL 65  MINUTE)
    UNION ALL SELECT 1, 1, 19.0758600, 72.8856400, 45.0, DATE_SUB(NOW(), INTERVAL 40  MINUTE)
    UNION ALL SELECT 1, 1, 19.0772300, 72.8871200, 50.0, DATE_SUB(NOW(), INTERVAL 15  MINUTE)
    UNION ALL SELECT 3, 2, 18.5204300, 73.8567400, 55.0, DATE_SUB(NOW(), INTERVAL 120 MINUTE)
    UNION ALL SELECT 3, 2, 18.5219800, 73.8582600, 60.0, DATE_SUB(NOW(), INTERVAL 60  MINUTE)
    UNION ALL SELECT 3, 2, 18.5235100, 73.8597900, 58.0, DATE_SUB(NOW(), INTERVAL 20  MINUTE)
    UNION ALL SELECT 5, 5, 18.5204000, 73.8567000, 25.0, DATE_SUB(NOW(), INTERVAL 90  MINUTE)
    UNION ALL SELECT 5, 5, 18.5312000, 73.8440000, 34.0, DATE_SUB(NOW(), INTERVAL 45  MINUTE)
    UNION ALL SELECT 5, 5, 18.6659000, 73.7709000, 48.0, DATE_SUB(NOW(), INTERVAL 10  MINUTE)
    UNION ALL SELECT 6, 6, 19.0760000, 72.8777000, 22.0, DATE_SUB(NOW(), INTERVAL 100 MINUTE)
    UNION ALL SELECT 6, 6, 19.1203000, 72.9101000, 42.0, DATE_SUB(NOW(), INTERVAL 50  MINUTE)
    UNION ALL SELECT 6, 6, 19.2173000, 72.9781000, 52.0, DATE_SUB(NOW(), INTERVAL 8   MINUTE)
) seed
WHERE NOT EXISTS (
    SELECT 1
    FROM vehicle_locations existing
    WHERE existing.vehicle_id = seed.vehicle_id
      AND existing.latitude = seed.latitude
      AND existing.longitude = seed.longitude
);

-- ═══════════════════════════════════════════════════
-- GPS API SECURITY & SCHEMA UPDATES
-- ═══════════════════════════════════════════════════

-- Add api_source column to vehicle_locations (if upgrading from previous version)
SET @api_source_exists = (
    SELECT COUNT(*)
    FROM information_schema.columns
    WHERE table_schema = DATABASE()
      AND table_name = 'vehicle_locations'
      AND column_name = 'api_source'
);
SET @api_source_sql = IF(
    @api_source_exists = 0,
    'ALTER TABLE vehicle_locations ADD COLUMN api_source VARCHAR(100) DEFAULT ''internal'' AFTER speed',
    'SELECT ''api_source already exists'' AS message'
);
PREPARE api_source_stmt FROM @api_source_sql;
EXECUTE api_source_stmt;
DEALLOCATE PREPARE api_source_stmt;

-- GPS API Keys table for external device authentication
CREATE TABLE IF NOT EXISTS gps_api_keys (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    api_key    VARCHAR(64)  NOT NULL UNIQUE,
    key_name   VARCHAR(100) NOT NULL,
    is_active  BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_used  DATETIME
);

-- Default API keys (change these in production!)
INSERT IGNORE INTO gps_api_keys (api_key, key_name) VALUES
('fleet-gps-2026-primary-k3y',   'Default Fleet Key'),
('driver-app-key-2026-mobile',   'Driver Mobile App Key'),
('gpslogger-device-key-2026',    'GPSLogger Device Key');

-- ====================================================
-- GEO-FENCE ALERT MODULE
-- ====================================================

CREATE TABLE IF NOT EXISTS geofences (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id       INT            NOT NULL,
    fence_name       VARCHAR(100)   NOT NULL,
    center_latitude  DECIMAL(10,7)  NOT NULL,
    center_longitude DECIMAL(11,7)  NOT NULL,
    radius_km        DECIMAL(6,2)   NOT NULL,
    is_active        BOOLEAN        NOT NULL DEFAULT TRUE,
    created_at       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS geofence_alerts (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    geofence_id      INT            NOT NULL,
    vehicle_id       INT            NOT NULL,
    latitude         DECIMAL(10,7)  NOT NULL,
    longitude        DECIMAL(11,7)  NOT NULL,
    distance_km      DECIMAL(8,2)   NOT NULL,
    alert_message    VARCHAR(255)   NOT NULL,
    status           VARCHAR(20)    NOT NULL DEFAULT 'Open',
    created_at       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    resolved_at      DATETIME       DEFAULT NULL,
    FOREIGN KEY (geofence_id) REFERENCES geofences(id) ON DELETE CASCADE,
    FOREIGN KEY (vehicle_id)  REFERENCES vehicles(id) ON DELETE CASCADE,
    INDEX idx_geofence_alert_status (status),
    INDEX idx_geofence_alert_vehicle (vehicle_id, created_at)
);

INSERT INTO geofences (vehicle_id, fence_name, center_latitude, center_longitude, radius_km, is_active)
SELECT 1, 'Mumbai Operating Zone', 19.0760000, 72.8777000, 8.00, TRUE
WHERE NOT EXISTS (SELECT 1 FROM geofences WHERE vehicle_id = 1 AND fence_name = 'Mumbai Operating Zone');

INSERT INTO geofences (vehicle_id, fence_name, center_latitude, center_longitude, radius_km, is_active)
SELECT 3, 'Pune Operating Zone', 18.5204000, 73.8567000, 8.00, TRUE
WHERE NOT EXISTS (SELECT 1 FROM geofences WHERE vehicle_id = 3 AND fence_name = 'Pune Operating Zone');

INSERT INTO geofences (vehicle_id, fence_name, center_latitude, center_longitude, radius_km, is_active)
SELECT 5, 'Pune Warehouse Zone', 18.5204000, 73.8567000, 7.50, TRUE
WHERE NOT EXISTS (SELECT 1 FROM geofences WHERE vehicle_id = 5 AND fence_name = 'Pune Warehouse Zone');

INSERT INTO geofences (vehicle_id, fence_name, center_latitude, center_longitude, radius_km, is_active)
SELECT 6, 'Mumbai Executive Zone', 19.0760000, 72.8777000, 9.00, TRUE
WHERE NOT EXISTS (SELECT 1 FROM geofences WHERE vehicle_id = 6 AND fence_name = 'Mumbai Executive Zone');

-- Fake geofence alerts: one resolved historical alert and two open violations.
INSERT INTO geofence_alerts (geofence_id, vehicle_id, latitude, longitude, distance_km, alert_message, status, created_at, resolved_at)
SELECT g.id, 1, 19.1828000, 72.9493000, 14.10,
       'Vehicle moved outside Mumbai Operating Zone during morning route.', 'Resolved',
       DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)
FROM geofences g
WHERE g.vehicle_id = 1 AND g.fence_name = 'Mumbai Operating Zone'
  AND NOT EXISTS (
      SELECT 1 FROM geofence_alerts a
      WHERE a.geofence_id = g.id AND a.vehicle_id = 1 AND a.status = 'Resolved'
  );

INSERT INTO geofence_alerts (geofence_id, vehicle_id, latitude, longitude, distance_km, alert_message, status, created_at)
SELECT g.id, 5, 18.6659000, 73.7709000, 18.90,
       'Vehicle is 18.90 km from geofence center. Allowed radius is 7.50 km.', 'Open',
       DATE_SUB(NOW(), INTERVAL 10 MINUTE)
FROM geofences g
WHERE g.vehicle_id = 5 AND g.fence_name = 'Pune Warehouse Zone'
  AND NOT EXISTS (
      SELECT 1 FROM geofence_alerts a
      WHERE a.geofence_id = g.id AND a.vehicle_id = 5 AND a.status = 'Open'
  );

INSERT INTO geofence_alerts (geofence_id, vehicle_id, latitude, longitude, distance_km, alert_message, status, created_at)
SELECT g.id, 6, 19.2173000, 72.9781000, 18.80,
       'Vehicle is 18.80 km from geofence center. Allowed radius is 9.00 km.', 'Open',
       DATE_SUB(NOW(), INTERVAL 8 MINUTE)
FROM geofences g
WHERE g.vehicle_id = 6 AND g.fence_name = 'Mumbai Executive Zone'
  AND NOT EXISTS (
      SELECT 1 FROM geofence_alerts a
      WHERE a.geofence_id = g.id AND a.vehicle_id = 6 AND a.status = 'Open'
  );

-- ====================================================
-- MAINTENANCE NOTIFICATION MODULE
-- ====================================================

CREATE TABLE IF NOT EXISTS maintenance_notifications (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    vehicle_id  INT           NOT NULL,
    title       VARCHAR(150)  NOT NULL,
    description TEXT          DEFAULT NULL,
    due_date    DATE          NOT NULL,
    priority    VARCHAR(20)   NOT NULL DEFAULT 'Medium',
    status      VARCHAR(20)   NOT NULL DEFAULT 'Open',
    created_by  INT           DEFAULT NULL,
    created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME     DEFAULT NULL,
    notes       TEXT          DEFAULT NULL,
    CONSTRAINT fk_maintenance_vehicle
        FOREIGN KEY (vehicle_id) REFERENCES vehicles(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_maintenance_user
        FOREIGN KEY (created_by) REFERENCES users(id)
        ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_maintenance_vehicle (vehicle_id),
    INDEX idx_maintenance_status (status),
    INDEX idx_maintenance_due_date (due_date)
);

INSERT INTO maintenance_notifications
    (vehicle_id, title, description, due_date, priority, status, created_by, notes)
SELECT 1, 'Routine engine service', 'Oil change, filter check, brake inspection',
       DATE_ADD(CURDATE(), INTERVAL 7 DAY), 'High', 'Open', 1, 'Book workshop slot'
WHERE NOT EXISTS (
    SELECT 1 FROM maintenance_notifications
    WHERE vehicle_id = 1 AND title = 'Routine engine service' AND status IN ('Open', 'Scheduled')
);

INSERT INTO maintenance_notifications
    (vehicle_id, title, description, due_date, priority, status, created_by, notes)
SELECT 2, 'Maintenance follow-up', 'Vehicle is already in maintenance; confirm completion date',
       CURDATE(), 'Critical', 'Scheduled', 1, 'Check parts availability'
WHERE NOT EXISTS (
    SELECT 1 FROM maintenance_notifications
    WHERE vehicle_id = 2 AND title = 'Maintenance follow-up' AND status IN ('Open', 'Scheduled')
);
