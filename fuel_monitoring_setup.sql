-- ============================================================
--  FUEL MONITORING MODULE - Database Setup
--  Smart Vehicle Fleet Management System
--  Run this SQL in your fleet_db MySQL database
-- ============================================================

-- Create the fuel_logs table
CREATE TABLE IF NOT EXISTS `fuel_logs` (
    `id`              INT AUTO_INCREMENT PRIMARY KEY,
    `vehicle_id`      INT            NOT NULL,
    `fill_date`       DATE           NOT NULL,
    `liters`          DECIMAL(10,2)  NOT NULL,
    `cost_per_liter`  DECIMAL(10,2)  NOT NULL,
    `total_cost`      DECIMAL(12,2)  NOT NULL,
    `odometer_km`     DECIMAL(10,1)  NOT NULL DEFAULT 0,
    `fuel_station`    VARCHAR(100)   DEFAULT NULL,
    `notes`           TEXT           DEFAULT NULL,
    `created_at`      TIMESTAMP      DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_fuel_vehicle`
        FOREIGN KEY (`vehicle_id`) REFERENCES `vehicles`(`id`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX `idx_fuel_vehicle`  (`vehicle_id`),
    INDEX `idx_fuel_date`     (`fill_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ── Optional: Seed sample data (adjust vehicle IDs to match yours) ────────
-- Replace 1, 2, 3 with actual vehicle IDs from your vehicles table

INSERT INTO `fuel_logs` (`vehicle_id`, `fill_date`, `liters`, `cost_per_liter`, `total_cost`, `odometer_km`, `fuel_station`, `notes`) VALUES
(1, DATE_SUB(CURDATE(), INTERVAL 45 DAY), 42.00, 103.50, 4347.00, 48200, 'HP Petrol Pump, MG Road',  'Full tank'),
(1, DATE_SUB(CURDATE(), INTERVAL 30 DAY), 38.50, 104.20, 4011.70, 48890, 'Indian Oil, Sector 12',    NULL),
(1, DATE_SUB(CURDATE(), INTERVAL 15 DAY), 45.00, 105.00, 4725.00, 49610, 'HP Petrol Pump, MG Road',  'Highway trip'),
(1, DATE_SUB(CURDATE(), INTERVAL  3 DAY), 40.00, 105.50, 4220.00, 50250, 'BPCL, Ring Road',          NULL),
(2, DATE_SUB(CURDATE(), INTERVAL 40 DAY), 35.00, 103.50, 3622.50, 32100, 'Indian Oil, GT Road',      NULL),
(2, DATE_SUB(CURDATE(), INTERVAL 25 DAY), 32.00, 104.00, 3328.00, 32760, 'HP, City Centre',          NULL),
(2, DATE_SUB(CURDATE(), INTERVAL 10 DAY), 37.00, 105.50, 3903.50, 33490, 'BPCL, NH48',               'Long route'),
(3, DATE_SUB(CURDATE(), INTERVAL 35 DAY), 55.00, 93.00,  5115.00, 61000, 'Diesel Station, Industrial Area', 'Diesel'),
(3, DATE_SUB(CURDATE(), INTERVAL 20 DAY), 50.00, 93.50,  4675.00, 62100, 'HP Diesel, NH8',           NULL),
(3, DATE_SUB(CURDATE(), INTERVAL  7 DAY), 48.00, 94.00,  4512.00, 63050, 'Indian Oil Diesel, Bypass', NULL);

-- ── Verify ────────────────────────────────────────────────────────────────
SELECT
    v.vehicle_number,
    COUNT(f.id) AS fill_ups,
    SUM(f.liters) AS total_liters,
    SUM(f.total_cost) AS total_cost
FROM fuel_logs f
JOIN vehicles v ON f.vehicle_id = v.id
GROUP BY v.vehicle_number;
