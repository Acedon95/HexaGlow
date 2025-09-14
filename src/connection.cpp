#include "connection.hpp"
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <ESP32Ping.h>

// Default constructor (client mode, default port 4210)
Connection::Connection()
    : ssid(""), password(""), mode(true), listener(), localPort(4210), ipAddress() {}

// Parameterized constructor
Connection::Connection(std::string ssid, std::string password, bool mode, unsigned int port)
    : ssid(std::move(ssid)), password(std::move(password)), mode(mode), listener(), localPort(port), ipAddress() {
    if (mode) {
        connect_to_wlan();
    } else {
        create_wlan();
    }
}

// Destructor
Connection::~Connection() {
    WiFi.disconnect();
}

// Move constructor
Connection::Connection(Connection&& other) noexcept
    : ssid(std::move(other.ssid)), password(std::move(other.password)), mode(other.mode), listener(), localPort(other.localPort), ipAddress(other.ipAddress) {
    // Transfer UDP listener state if necessary (WiFiUDP doesn't provide move, so reopen)
    if (other.listener.parsePacket() > 0) {
        // nothing special we can do; listener will operate independently
    }
    other.ssid = "";
    other.password = "";
}

// Move assignment
Connection &Connection::operator=(Connection &&other) noexcept
{
    if (this != &other)
    {
        ssid = other.ssid;
        password = other.password;
        mode = other.mode;
        localPort = other.localPort;
        ipAddress = other.ipAddress;
        // reset other's pointers
        other.ssid = nullptr;
        other.password = nullptr;
    }
    return *this;
}

// Connect to WLAN (client mode). Returns assigned IP.
IPAddress Connection::connect_to_wlan() {
    if (ssid.empty() || password.empty()) {
        return IPAddress();
    }
    WiFi.begin(&ssid[0], &password[0]);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print('.');
    }
    ipAddress = WiFi.localIP();
    return ipAddress;
}

// Create Access Point (AP) mode
void Connection::create_wlan() {
    if (!ssid.empty() || !password.empty()) {
        return;
    }
    WiFi.softAP(&ssid[0], &password[0]);
    ipAddress = WiFi.softAPIP();
}

// Start UDP listener
void Connection::create_listener() {
    listener.begin(localPort);
}

// Listen for packets and return as String (empty if none)
String Connection::listen_for_packets() {
    int packetSize = listener.parsePacket();
    if (packetSize) {
        static char incomingPacket[512];
        int len = listener.read(incomingPacket, sizeof(incomingPacket) - 1);
        if (len > 0) {
            incomingPacket[len] = '\0';
            return String(incomingPacket);
        }
    }
    return String();
}

// Ping a remote IP and return "success" or "failed"
String Connection::ping_remote(IPAddress remote_ip) {
    if (Ping.ping(remote_ip)) {
        return String("success");
    }
    return String("failed");
}