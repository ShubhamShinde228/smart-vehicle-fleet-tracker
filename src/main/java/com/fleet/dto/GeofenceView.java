package com.fleet.dto;

import java.sql.Timestamp;

public class GeofenceView {
    private int id;
    private int vehicleId;
    private String fenceName;
    private double centerLatitude;
    private double centerLongitude;
    private double radiusKm;
    private boolean active;
    private Timestamp createdAt;
    private String vehicleNumber;
    private String vehicleModel;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getVehicleId() { return vehicleId; }
    public void setVehicleId(int vehicleId) { this.vehicleId = vehicleId; }

    public String getFenceName() { return fenceName; }
    public void setFenceName(String fenceName) { this.fenceName = fenceName; }

    public double getCenterLatitude() { return centerLatitude; }
    public void setCenterLatitude(double centerLatitude) { this.centerLatitude = centerLatitude; }

    public double getCenterLongitude() { return centerLongitude; }
    public void setCenterLongitude(double centerLongitude) { this.centerLongitude = centerLongitude; }

    public double getRadiusKm() { return radiusKm; }
    public void setRadiusKm(double radiusKm) { this.radiusKm = radiusKm; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public String getVehicleNumber() { return vehicleNumber; }
    public void setVehicleNumber(String vehicleNumber) { this.vehicleNumber = vehicleNumber; }

    public String getVehicleModel() { return vehicleModel; }
    public void setVehicleModel(String vehicleModel) { this.vehicleModel = vehicleModel; }
}
