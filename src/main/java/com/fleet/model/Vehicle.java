package com.fleet.model;

import java.sql.Date;

public class Vehicle {
    private int id;
    private String vehicleNumber;
    private String model;
    private String vehicleType;
    private String fuelType;
    private double fuelCapacity;
    private Date registrationDate;
    private Date insuranceExpiry;
    private Date maintenanceDueDate;
    private String status;

    public Vehicle() {}

    // ── Getters & Setters ────────────────────────────────────────────────────

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getVehicleNumber() { return vehicleNumber; }
    public void setVehicleNumber(String vehicleNumber) { this.vehicleNumber = vehicleNumber; }

    public String getModel() { return model; }
    public void setModel(String model) { this.model = model; }

    public String getVehicleType() { return vehicleType; }
    public void setVehicleType(String vehicleType) { this.vehicleType = vehicleType; }

    public String getFuelType() { return fuelType; }
    public void setFuelType(String fuelType) { this.fuelType = fuelType; }

    public double getFuelCapacity() { return fuelCapacity; }
    public void setFuelCapacity(double fuelCapacity) { this.fuelCapacity = fuelCapacity; }

    public Date getRegistrationDate() { return registrationDate; }
    public void setRegistrationDate(Date registrationDate) { this.registrationDate = registrationDate; }

    public Date getInsuranceExpiry() { return insuranceExpiry; }
    public void setInsuranceExpiry(Date insuranceExpiry) { this.insuranceExpiry = insuranceExpiry; }

    public Date getMaintenanceDueDate() { return maintenanceDueDate; }
    public void setMaintenanceDueDate(Date maintenanceDueDate) { this.maintenanceDueDate = maintenanceDueDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
