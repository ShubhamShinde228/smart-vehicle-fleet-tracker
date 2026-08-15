-- ============================================================
--  MAINTENANCE NOTIFICATION MODULE - Database Setup
--  Smart Vehicle Fleet Management System
--  Run this SQL in your fleet_db MySQL database
-- ============================================================

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
