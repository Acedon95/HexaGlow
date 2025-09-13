# pragma once
#define CONNECTION_H
#include <iostream>
#include <string>
#include <WiFi.h>
#include <iostream>
#include <ESP32Ping.h>
#include <WiFiUdp.h>


class Connection {
    private:
        const char* ssid;
        const char* password;

    public:
        const bool mode; // true for client mode, false for access point mode
        WiFiUDP listener;
        unsigned int localPort;  // Port für eingehende "Pings"
        IPAddress ipAddress;

        // Constructor
        Connection();
        Connection(const char* ssid, const char* password, bool mode, unsigned int port = 4210);

        // Destructor
        ~Connection();

        IPAddress connect_to_wlan();
        void create_listener();
        char* listen_for_packets();
        String ping_remote(IPAddress remote_ip = IPAddress(192,168,0,1));
    };
