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
#ifdef __AVR__
#include <avr/power.h>  // Required for 16 MHz Adafruit Trinket
#endif

// Which pin on the Arduino is connected to the strip?
#define LED_PIN 4

// How many LEDs are attached to the Arduino?
#define LED_COUNT 20

// Declare our NeoPixel strip object:
Adafruit_NeoPixel strip(LED_COUNT, LED_PIN, NEO_GRB + NEO_KHZ800);
// Argument 1 = Number of pixels in NeoPixel strip
// Argument 2 = Arduino pin number (most are valid)
// Argument 3 = Pixel type flags, add together as needed:

WiFiUDP udp;
unsigned int localPort = 4210;  // Port für eingehende "Pings"

void test(){
  strip.fill(strip.Color(150, 0, 0), 0, LED_COUNT);
  strip.show();  // Update strip with new contents
  delay(40);   // Pause for a moment
}


void connect_to_wlan(){
    const char* ssid = "WLAN"; // Ersetzen Sie dies durch den Namen Ihres WLANs
    const char* password = "PASSWORT"; // Ersetzen Sie dies durch Ihr WLAN-Passwort
    strip.fill(strip.Color(150, 0, 0), 0, LED_COUNT);
    strip.show();
    Serial.println();
    Serial.print("Connecting to ");
    Serial.println(ssid);

    WiFi.begin(ssid, password); // Beginnt die Verbindung zum WLAN
    while (WiFi.status() != WL_CONNECTED) { // Wartet, bis die Verbindung hergestellt ist
      delay(500);
      Serial.print(".");
    }

    Serial.println("");
    Serial.println("WiFi connected!");
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP()); // Gibt die zugewiesene IP-Adresse aus

    udp.begin(localPort);

    strip.fill(strip.Color(0, 150, 0), 0, LED_COUNT);
    strip.show();  // Update strip with new contents
}

void create_wlan(){
  const char* ap_ssid = "ESP32_AP"; // Name Ihres Access Points
  const char* ap_password = "12345678"; // Passwort für Ihren Access Point
  Serial.print("Creating Access Point: ");
  Serial.println(ap_ssid);

  WiFi.softAP(ap_ssid, ap_password); // Startet den Access Point

  Serial.println("Access Point created!");
  Serial.print("AP IP Address: ");
  Serial.println(WiFi.softAPIP()); // Gibt die IP-Adresse des Access Points aus
}

String ping_router(){
  const IPAddress remote_ip(192,168,0,1);

  if(Ping.ping(remote_ip)){
    return "success";
  } else {
    return "failed";
  }
}

void make_green(){
  strip.fill(strip.Color(0, 150, 0), 0, LED_COUNT);
  strip.show();  // Update strip with new contents
}

void make_red(){
  strip.fill(strip.Color(150, 0, 0), 0, LED_COUNT);
  strip.show();  // Update strip with new contents
}

void make_blue(){
  strip.fill(strip.Color(0, 0, 150), 0, LED_COUNT);
  strip.show();  // Update strip with new contents
}

// Rainbow cycle along whole strip. Pass delay time (in ms) between frames.
void rainbow(int wait) {
  // Hue of first pixel runs 5 complete loops through the color wheel.
  // Color wheel has a range of 65536 but it's OK if we roll over, so
  // just count from 0 to 5*65536. Adding 256 to firstPixelHue each time
  // means we'll make 5*65536/256 = 1280 passes through this outer loop:
  for (long firstPixelHue = 0; firstPixelHue < 5 * 65536; firstPixelHue += 100) {  // 256
    for (int i = 0; i < strip.numPixels(); i++) {                                  // For each pixel in strip...
      //if (Serial.available() > 0) {
      //  return;
      //}
      if (i == 115 || i == 116) {
        strip.setPixelColor(i, strip.Color(0, 0, 0));
        continue;
      }
      // Offset pixel hue by an amount to make one full revolution of the
      // color wheel (range of 65536) along the length of the strip
      // (strip.numPixels() steps):
      int pixelHue = firstPixelHue + (i * 65536L / strip.numPixels());
      // strip.ColorHSV() can take 1 or 3 arguments: a hue (0 to 65535) or
      // optionally add saturation and value (brightness) (each 0 to 255).
      // Here we're using just the single-argument hue variant. The result
      // is passed through strip.gamma32() to provide 'truer' colors
      // before assigning to each pixel:
      strip.setPixelColor(i, strip.gamma32(strip.ColorHSV(pixelHue)));
      Serial.println("inner loop done");

    }
    strip.show();  // Update strip with new contents
    delay(wait);   // Pause for a moment
    Serial.println("outer loop done");

  }
}

void liste_for_changes(){
  int packetSize = udp.parsePacket();
  if(packetSize){
    char incomingPacket[255];
    int len = udp.read(incomingPacket, 255);
    if(len > 0){
      incomingPacket[len] = 0;
    }
    Serial.printf("Received packet of size %d from %s:%d\n", packetSize, udp.remoteIP().toString().c_str(), udp.remotePort());
    Serial.printf("Packet contents: %s\n", incomingPacket);

    if(strcmp(incomingPacket, "red") == 0){
      make_red();
    } else if(strcmp(incomingPacket, "green") == 0){
      make_green();
    } else if(strcmp(incomingPacket, "blue") == 0){
      make_blue();
    } else if(strcmp(incomingPacket, "rainbow") == 0){
      rainbow(10);
    } else {
      Serial.println("Unknown command");
    }
  }
}


// setup() function -- runs once at startup --------------------------------
void setup() {
  Serial.begin(9600);
  strip.fill(strip.Color(150, 150, 150), 0, LED_COUNT);
  strip.show();  // Update strip with new contents
  connect_to_wlan();
  //create_wlan();
}




// loop() function -- runs repeatedly as long as board is on ---------------
void loop() {
  //Serial.println(ping_router());
  liste_for_changes();
  delay(100);
}

