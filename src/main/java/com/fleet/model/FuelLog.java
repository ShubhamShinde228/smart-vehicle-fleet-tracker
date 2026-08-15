package com.fleet.model;

import java.sql.Date;
import java.sql.Timestamp;

public class FuelLog {
    private int id;
    private int vehicleId;
    private String vehicleNumber;   // joined from vehicles
    private String vehicleModel;    // joined from vehicles
    private Date fillDate;
    private double liters;
    private double costPerLiter;
    private double totalCost;
    private double odometerKm;
    private String fuelStation;
    private String notes;
    private Timestamp createdAt;

    public FuelLog() {}

    // ── Getters & Setters ────────────────────────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getVehicleId() { return vehicleId; }
    public void setVehicleId(int vehicleId) { this.vehicleId = vehicleId; }

    public String getVehicleNumber() { return vehicleNumber; }
    public void setVehicleNumber(String vehicleNumber) { this.vehicleNumber = vehicleNumber; }

    public String getVehicleModel() { return vehicleModel; }
    public void setVehicleModel(String vehicleModel) { this.vehicleModel = vehicleModel; }

    public Date getFillDate() { return fillDate; }
    public void setFillDate(Date fillDate) { this.fillDate = fillDate; }

    public double getLiters() { return liters; }
    public void setLiters(double liters) { this.liters = liters; }

    public double getCostPerLiter() { return costPerLiter; }
    public void setCostPerLiter(double costPerLiter) { this.costPerLiter = costPerLiter; }

    public double getTotalCost() { return totalCost; }
    public void setTotalCost(double totalCost) { this.totalCost = totalCost; }

    public double getOdometerKm() { return odometerKm; }
    public void setOdometerKm(double odometerKm) { this.odometerKm = odometerKm; }

    public String getFuelStation() { return fuelStation; }
    public void setFuelStation(String fuelStation) { this.fuelStation = fuelStation; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
