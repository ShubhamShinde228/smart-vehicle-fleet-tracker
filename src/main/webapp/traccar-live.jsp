<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.fleet.model.TraccarPosition" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="refresh" content="5">
    <title>Live GPS Tracking - Traccar</title>

    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f4f7f6;
            margin: 0;
            padding: 20px;
            color: #333;
        }
        h2 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 20px;
        }
        .table-container {
            width: 80%;
            margin: 0 auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            text-align: center;
        }
        th, td {
            padding: 12px 15px;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #3498db;
            color: #ffffff;
            text-transform: uppercase;
            font-weight: 600;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        .empty-message {
            text-align: center;
            font-size: 1.1em;
            color: #e74c3c;
            padding: 20px;
        }
    </style>
</head>

<body>

<h2>Live GPS Tracking - Traccar Server Data</h2>

<div class="table-container">
    <table>
        <thead>
            <tr>
                <th>Latitude</th>
                <th>Longitude</th>
                <th>Speed (knots)</th>
                <th>Time</th>
            </tr>
        </thead>
        <tbody>

        <%
            List<TraccarPosition> positions = (List<TraccarPosition>) request.getAttribute("positions");

            if (positions != null && !positions.isEmpty()) {
                for (TraccarPosition pos : positions) {
        %>
            <tr>
                <td><%= pos.getLatitude() %></td>
                <td><%= pos.getLongitude() %></td>
                <td><%= pos.getSpeed() %></td>
                <td><%= (pos.getFixtime() != null) ? pos.getFixtime().toString() : "N/A" %></td>
            </tr>
        <%
                }
            } else {
        %>
            <tr>
                <td colspan="4" class="empty-message">
                    No GPS data available at the moment.
                </td>
            </tr>
        <%
            }
        %>

        </tbody>
    </table>
</div>

</body>
</html>