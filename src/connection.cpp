#include "connection.hpp"
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>
#include <ESP32Ping.h>
#include <string>
#include <utility>
#include <iostream>
#include <fstream>
#include <SPIFFS.h>

// Default constructor (client mode, default port 4210)
Connection::Connection()
    : ssid(""), password(""), mode(true), listener(), localPort(4210), ipAddress() {}

// Parameterized constructor
Connection::Connection(std::string ssid, std::string password, bool mode, unsigned int port)
    : ssid(std::move(ssid)), password(std::move(password)), mode(mode), listener(), localPort(port), ipAddress() {
    if (mode) {
        load_wifi_credentials();
        connect_to_wlan();
    } else {
        create_wlan();
    }
}

Connection::Connection(bool mode, unsigned int port)
    : ssid(""), password(""), mode(mode), listener(), localPort(port), ipAddress() {
    if (mode) {
        load_wifi_credentials();
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
        other.ssid.clear();
        other.password.clear();
    }
    return *this;
}

// Connect to WLAN (client mode). Returns assigned IP.
IPAddress Connection::connect_to_wlan() {
    if (ssid.empty() || password.empty()) {
        return IPAddress();
    }
    Serial.print("Connecting to ");
    Serial.print(ssid.c_str());
    Serial.print(" with password ");
    Serial.print(password.c_str());
    WiFi.begin(&ssid[0], &password[0]);
    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print('.');
    }
    ipAddress = WiFi.localIP();
    Serial.println("");
    Serial.print("Connected to ");
    Serial.println(ssid.c_str());
    Serial.print("IP address: "); 
    Serial.println(ipAddress);
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


/**
 * @brief Loads WiFi SSID and password from a config file using standard library functions.
 *
 * The config file should contain lines in the format:
 * ssid:your-ssid
 * password:your-password
 *
 * @param config_path Path to the config file.
 * @return std::pair<std::string, std::string> containing SSID and password.
 */
std::pair<std::string, std::string> Connection::load_wifi_credentials(const std::string& config_path) {
    String null = "Null";
    File file = SPIFFS.open(config_path.c_str(), "r");
    if (!file) {
        Serial.println("Failed to open file");
        return {null.c_str(), null.c_str()};
    }

    while (file.available()) {
        String line = file.readStringUntil('\n');
        if (line.startsWith("ssid:")) {
            String raw_ssid = line.substring(5);
            raw_ssid.replace(" ", "");
            raw_ssid.replace("\n", "");
            raw_ssid.replace("\r", "");
            raw_ssid.replace("\t", "");
            ssid = raw_ssid.c_str();
        } else if (line.startsWith("password:")) {
            String raw_password = line.substring(9);
            raw_password.replace(" ", "");
            raw_password.replace("\n", "");
            raw_password.replace("\r", "");
            raw_password.replace("\t", "");
            password = raw_password.c_str();
        }
    }
    file.close();

    if (ssid.empty()) {
        Serial.println("SSID not found in config file.");
    }
    if (password.empty()) {
        Serial.println("Password not found in config file.");
    }

    return {ssid, password};
}