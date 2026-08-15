package com.fleet.model;

import java.sql.Timestamp;

public class TraccarPosition {
    private double latitude;
    private double longitude;
    private double speed;
    private Timestamp fixtime;

    public TraccarPosition() {}

    public double getLatitude() {
        return latitude;
    }

    public void setLatitude(double latitude) {
        this.latitude = latitude;
    }

    public double getLongitude() {
        return longitude;
    }

    public void setLongitude(double longitude) {
        this.longitude = longitude;
    }

    public double getSpeed() {
        return speed;
    }

    public void setSpeed(double speed) {
        this.speed = speed;
    }

    public Timestamp getFixtime() {
        return fixtime;
    }

    public void setFixtime(Timestamp fixtime) {
        this.fixtime = fixtime;
    }
}
