#pragma once
#define CONNECTION_H
#include <Arduino.h>
#include <WiFi.h>
#include <ESP32Ping.h>
#include <WiFiUdp.h>
#include <string>

class Connection {
    private:
        std::string ssid;
        std::string password;

    public:
    bool mode; // true for client mode, false for access point mode
        WiFiUDP listener;
        unsigned int localPort;  // Port für eingehende "Pings"
        IPAddress ipAddress;

    // Constructor
        Connection();
        Connection(std::string ssid, std::string password, bool mode, unsigned int port = 4210);

    // Movable but not copyable
    Connection(Connection&& other) noexcept;
    Connection& operator=(Connection&& other) noexcept;
    Connection(const Connection&) = delete;
    Connection& operator=(const Connection&) = delete;

        // Destructor
        ~Connection();

        IPAddress connect_to_wlan();
        void create_wlan();
        void create_listener();
        String listen_for_packets();
        String ping_remote(IPAddress remote_ip = IPAddress(192,168,0,1));
};
