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
        IPAddress ip;

        // Constructor
        Connection() : ssid(nullptr), password(nullptr), mode(true), localPort(4210) {}
        Connection(const char* ssid, const char* password, bool mode, unsigned int port = 4210)
            : ssid(ssid), password(password), mode(mode), localPort(port) {
                if (mode) {
                    connect_to_wlan(ssid, password);
                } else {
                    create_wlan(ssid, password);
                }
            }

        // Destructor
        ~Connection() {
            WiFi.disconnect();
            std::cout << "Disconnected from WiFi network: " << ssid << std::endl;
        }

        IPAddress connect_to_wlan(const char* ssid, const char* password){
            Serial.print("Connecting to ");
            Serial.println(ssid);

            WiFi.begin(ssid, password); // Beginnt die Verbindung zum WLAN
            while (WiFi.status() != WL_CONNECTED) { // Wartet, bis die Verbindung hergestellt ist
                delay(500);
                Serial.print(".");
            }
            Serial.println("WiFi connected!");
            Serial.println("IP address: ");
            Serial.println(WiFi.localIP()); // Gibt die zugewiesene IP-Adresse aus
            ip = WiFi.localIP();
            return ip;
        }

        void create_listener(){
            listener.begin(localPort);
            std::cout << "Listening for incoming UDP packets on port: " << localPort << std::endl;
        }

        std::string listen_for_packets(){
            int packetSize = listener.parsePacket();
            if(packetSize){
                char incomingPacket[255];
                int len = listener.read(incomingPacket, 255);
                if(len > 0){
                    incomingPacket[len] = 0;
                }
                std::cout << "Received packet of size " << packetSize << " from " 
                          << listener.remoteIP().toString().c_str() << ":" 
                          << listener.remotePort() << std::endl;
                std::cout << "Packet contents: " << incomingPacket << std::endl;
                return std::string(incomingPacket, len);
            };
            return std::string();
        }

        String ping_remote(IPAddress remote_ip = IPAddress(192,168,0,1)){
            if(Ping.ping(remote_ip)){
                return "success";
            } else {
                return "failed";
            }
        }

        void create_wlan(const char* ssid, const char* password){
            Serial.print("Creating Access Po ");
            Serial.println(ssid);

            WiFi.softAP(ssid, password); // Startet den Access Point

            Serial.println("Access Point created!");
            Serial.print("AP IP Address: ");
            Serial.println(WiFi.softAPIP()); // Gibt die IP-Adresse des Access Points aus
            ip = WiFi.softAPIP();
        }
    };