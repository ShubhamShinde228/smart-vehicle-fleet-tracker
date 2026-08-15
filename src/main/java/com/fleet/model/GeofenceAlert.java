package com.fleet.model;

import java.sql.Timestamp;

public class GeofenceAlert {
    private int id;
    private int geofenceId;
    private int vehicleId;
    private double latitude;
    private double longitude;
    private double distanceKm;
    private String alertMessage;
    private String status;
    private Timestamp createdAt;
    private Timestamp resolvedAt;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getGeofenceId() { return geofenceId; }
    public void setGeofenceId(int geofenceId) { this.geofenceId = geofenceId; }

    public int getVehicleId() { return vehicleId; }
    public void setVehicleId(int vehicleId) { this.vehicleId = vehicleId; }

    public double getLatitude() { return latitude; }
    public void setLatitude(double latitude) { this.latitude = latitude; }

    public double getLongitude() { return longitude; }
    public void setLongitude(double longitude) { this.longitude = longitude; }

    public double getDistanceKm() { return distanceKm; }
    public void setDistanceKm(double distanceKm) { this.distanceKm = distanceKm; }

    public String getAlertMessage() { return alertMessage; }
    public void setAlertMessage(String alertMessage) { this.alertMessage = alertMessage; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Timestamp resolvedAt) { this.resolvedAt = resolvedAt; }
}
