// "NEOPIXEL BEST PRACTICES for most reliable operation:
// - Add 1000 uF CAPACITOR between NeoPixel strip's + and - connections.
// - MINIMIZE WIRING LENGTH between microcontroller board and first pixel.
// - NeoPixel strip's DATA-IN *should* pass through a 300-500 OHM RESISTOR.
// - AVOID connecting NeoPixels on a LIVE CIRCUIT. If you must, ALWAYS
//   connect GROUND (-) first, then +, then data.
// - When using a 3.3V microcontroller with a 5V-powered NeoPixel strip,
//   a LOGIC-LEVEL CONVERTER on the data line is STRONGLY RECOMMENDED.
// (Skipping these may work OK on your workbench but can fail in the field)"
//
// Just use a WS2812b, an arduino and a compatible power supply.
// For led strips consuming <= 15W, you can solder the 5v wire of the usb cable directly
//  to the board and make use of power share (BIOS and Motherboard dependable)
// Costs: max.: 45€ for 5m

#include <Adafruit_NeoPixel.h>  // ignore this error in vscode. The Arduino IDE will compile it and upload it to the board.
#include <WiFi.h>
#include <iostream>
#include <ESP32Ping.h>
#include <WiFiUdp.h>
#include <string>
#include "connection.hpp"
#include "hexagon.hpp"
#include <memory>
#include <fstream>
#ifdef __AVR__
#include <avr/power.h>  // Required for 16 MHz Adafruit Trinket
#endif

// Which pin on the Arduino is connected to the strip?
#define LED_PIN 4

// How many LEDs are attached to the Arduino?
#define LED_COUNT 48

// Declare our NeoPixel strip object:
// Argument 1 = Number of pixels in NeoPixel strip
// Argument 2 = Arduino pin number (most are valid)
// Argument 3 = Pixel type flags, add together as needed:
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);

unsigned int localPort = 4210;  // Port für eingehende "Pings"

Connection conn; // will be initialized via move in setup
Hexagon hexagons[2];



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
std::pair<std::string, std::string> load_wifi_credentials(const std::string& config_path = "./config.txt") {
  std::ifstream file(config_path);
  if (!file.is_open()) {
    std::cout << "Failed to open config file: " << config_path << std::endl;
    return {"", ""};
  }

  std::string ssid;
  std::string password;
  std::string line;

  // Parse each line for ssid and password
  while (std::getline(file, line)) {
    if (line.find("ssid:") == 0) {
      ssid = line.substr(5);
    } else if (line.find("password:") == 0) {
      password = line.substr(9);
    }
  }

  if (ssid.empty()) {
    std::cerr << "SSID not found in config file." << std::endl;
  }
  if (password.empty()) {
    std::cerr << "Password not found in config file." << std::endl;
  }

  return {ssid, password};
}

// setup() function -- runs once at startup --------------------------------
void setup() {
  Serial.begin(9600);
  strip.fill(strip.Color(150, 150, 150), 0, LED_COUNT);
  strip.show();  // Update strip with new contents

  std::pair<std::string, std::string> credentials = load_wifi_credentials();
  std::string ssid = credentials.first;
  std::string password = credentials.second;
  if (ssid.empty() || password.empty()) {
    Serial.println("WiFi credentials are missing. Please check config.txt.");
    while (true) {
      delay(1000); // Halt execution
    }
  }
  
  // Initialize objects in-place and move them to globals
  Connection tempConn(ssid, password, true, localPort);
  conn = std::move(tempConn);

  Hexagon tempHex0(LED_PIN, 1, 24, LED_COUNT);
  Hexagon tempHex1(LED_PIN, 2, 24, LED_COUNT);
  hexagons[0] = std::move(tempHex0);
  hexagons[1] = std::move(tempHex1);

  conn.create_listener();
}




// loop() function -- runs repeatedly as long as board is on ---------------
void loop() {
  //Serial.println(ping_router());
  String packet = conn.listen_for_packets();
  if (packet.length() > 0) {
    Serial.print("Received packet: ");
    Serial.println(packet);
    Serial.println("Processing command...");
    hexagons[0].set_all_pixels(150, 0, 0);
    hexagons[1].set_all_pixels(0, 150, 0);
  }
}

