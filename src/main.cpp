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
#include "EventHandler.hpp"
#include "Event.hpp"
#include <memory>
#include <SPIFFS.h>
#include <fstream>
#ifdef __AVR__
#include <avr/power.h>  // Required for 16 MHz Adafruit Trinket
#endif

// Which pin on the Arduino is connected to the strip?
#define LED_PIN 4

// How many LEDs are attached to the Arduino?
#define LED_COUNT 126

// Declare our NeoPixel strip object:
// Argument 1 = Number of pixels in NeoPixel strip
// Argument 2 = Arduino pin number (most are valid)
// Argument 3 = Pixel type flags, add together as needed:
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);

unsigned int localPort = 4210;  // Port für eingehende "Pings"

Connection conn; // will be initialized via move in setup
Hexagon hexagons[7];
EventHandler eventHandler; // will be initialized in setup


void boot(){
  // Function for led pattern on boot up, one hex after another lighting up green
  for(int i = 0; i < 7; i++){
    hexagons[i].set_all_pixels(0, 150, 0);
    strip.show();
    delay(200);
  }
}


// setup() function -- runs once at startup --------------------------------
void setup() {
  Serial.begin(9600);

  // Initialize SPIFFS
  if (!SPIFFS.begin(true)) {
      Serial.println("SPIFFS Mount Failed");
      return;
  }

  strip.begin();
  strip.fill(strip.Color(150, 150, 150), 0, LED_COUNT);
  strip.show();  // Update strip with new contents

  // Initialize objects in-place and move them to globals
  Connection tempConn(true, localPort);
  conn = std::move(tempConn);

  conn.create_listener();

  /* Here we go with two hexagons, each with 18 leds, sharing the same strip
    But I really want for the future a setup where we wait for the user to input the amount of hexagons
    and the amount of leds per hexagon via a configuration file or a simple web interface.
    And then create the hexagons dynamically via new Hexagon[hex_count]; and not via static array.
    This will also require changes in EventHandler and Event to be able to adress the hexagons dynamically.
  */
  eventHandler = EventHandler(hexagons, 9, &strip);

  Hexagon tempHex0(&strip, 1, 18, LED_COUNT);
  Hexagon tempHex1(&strip, 2, 18, LED_COUNT);
  Hexagon tempHex2(&strip, 3, 18, LED_COUNT);
  Hexagon tempHex3(&strip, 4, 18, LED_COUNT);
  Hexagon tempHex4(&strip, 5, 18, LED_COUNT);
  Hexagon tempHex5(&strip, 6, 18, LED_COUNT);
  Hexagon tempHex6(&strip, 7, 18, LED_COUNT);

  hexagons[0] = std::move(tempHex0);
  hexagons[1] = std::move(tempHex1);
  hexagons[2] = std::move(tempHex2);
  hexagons[3] = std::move(tempHex3);
  hexagons[4] = std::move(tempHex4);
  hexagons[5] = std::move(tempHex5);
  hexagons[6] = std::move(tempHex6);

  Serial.println("Setup complete.");
  Serial.print("IP address: ");
  Serial.println(conn.ipAddress);
  Serial.print("Listening on port ");
  Serial.println(localPort);
  boot();
  //strip.show();
}

// loop() function -- runs repeatedly as long as board is on ---------------
void loop() {
  String packet = conn.listen_for_packets();
  if (packet.length() > 0) {
    Serial.print("Received packet: ");
    Serial.println(packet);
    Serial.println("Processing command...");
    Event event = eventHandler.create_event_from_string(std::string(packet.c_str()));
    eventHandler.process_event(event);
    //strip.show();
  }
}

