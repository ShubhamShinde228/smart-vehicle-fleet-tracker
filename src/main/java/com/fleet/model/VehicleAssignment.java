package com.fleet.model;

import java.sql.Date;

public class VehicleAssignment {
    private int id;
    private int vehicleId;
    private int driverId;
    private int assignedBy;
    private Date startDate;
    private Date endDate;
    private String notes;

    public VehicleAssignment() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getVehicleId() { return vehicleId; }
    public void setVehicleId(int vehicleId) { this.vehicleId = vehicleId; }

    public int getDriverId() { return driverId; }
    public void setDriverId(int driverId) { this.driverId = driverId; }

    public int getAssignedBy() { return assignedBy; }
    public void setAssignedBy(int assignedBy) { this.assignedBy = assignedBy; }

    public Date getStartDate() { return startDate; }
    public void setStartDate(Date startDate) { this.startDate = startDate; }

    public Date getEndDate() { return endDate; }
    public void setEndDate(Date endDate) { this.endDate = endDate; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public boolean isActive() { return endDate == null; }
}
