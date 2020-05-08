package org.group72.server.model;

import javax.persistence.*;

/**
 * Class for undirected edges. Each edge has two positions A and B which should have no internal order.
 * Should be able to calculate its own distance. Is connected by JPA and linked with hibernate to
 * the database described by src/resources/application.properties.
 * @author Emil.M
 */
@Entity
@IdClass(EdgeKey.class)
public class Edge {

    @Id
    private double latitude_A;

    @Id
    private double longitude_A;

    @Id
    private double latitude_B;

    @Id
    private double longitude_B;

    //Required by JPA.
    public Edge() {
    }

    public Edge(double latitude_A, double longitude_A, double latitude_B, double longitude_B){
        this.latitude_A = latitude_A;
        this.longitude_A = longitude_A;
        this.latitude_B = latitude_B;
        this.longitude_B = longitude_B;
    }

    public double getLatitude_A() {
        return latitude_A;
    }

    public double getLongitude_A() {
        return longitude_A;
    }

    public double getLatitude_B() {
        return latitude_B;
    }

    public double getLongitude_B() {
        return longitude_B;
    }

    /**
     * Calculates the distance between the nodes
     * as a positive value in meters.
     * @return double distance in meters
     */
    private static int calculateDistace(double lat1, double lon1, double lat2, double lon2){
        double radius = 6378.137; // Radius of earth in KM
        double dLat = lat2 * Math.PI / 180 - lat1 * Math.PI / 180;
        double dLon = lon2 * Math.PI / 180 - lon1 * Math.PI / 180;
        double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                        Math.sin(dLon/2) * Math.sin(dLon/2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
        double d = radius * c;
        return (int) d * 1000; // meters
    }
}
