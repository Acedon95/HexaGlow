#include <iostream>
#include <string>
#include <Adafruit_NeoPixel.h> 

// Hexagon class definition. Representing a part of the LED strip as a hexagon and providing basic functionalits to control it.

class Hexagon {
public:
    int led_count_strip;  // Amount of LEDs in the strip
    int led_count_hex;  // Amount of LEDs in the hexagon
    int position;   // Current position in the hexagon array
    int led_index_start; // Start index of the first led of the hexagon in the strip
    int led_index_end;   // End index of the hexagon leds in the strip
    Adafruit_NeoPixel strip;

    // Constructor
    Hexagon() : led_count_strip(0), led_count_hex(0), position(0), led_index_start(0), led_index_end(0), strip(Adafruit_NeoPixel()) {}

    Hexagon(int pin, int position_in_strip, int hex_leds, int strip_leds){
        led_count_hex = hex_leds;
        led_count_strip = strip_leds;
        strip = Adafruit_NeoPixel(led_count_strip, pin, NEO_GRB + NEO_KHZ800);
        position = position_in_strip;
        led_index_start = (position_in_strip * led_count_hex) - led_count_hex;
        led_index_end = (position_in_strip * led_count_hex);
        strip.begin();
        strip.show(); // Initialize all pixels to 'off'
    }

    void set_position(int pos) {
        if (pos >= 0 && pos < led_count_strip / led_count_hex) {
            position = pos;
        }
    }

    void clear() {
        set_all_pixels(0, 0, 0);
    }

    void set_all_pixels(uint8_t r, uint8_t g, uint8_t b) {
        strip.fill(strip.Color(r, g, b), led_index_start, led_count_hex);
        strip.show();
    }

    void set_pixel(int index, uint8_t r, uint8_t g, uint8_t b) {
        if (index >= led_index_start && index < led_index_end) {
            strip.setPixelColor(index, strip.Color(r, g, b));
            strip.show();
        }
    }

    void change_edge_colour(int edge,uint8_t r, uint8_t g, uint8_t b) {
        if (edge < 0 || edge > 5) {
            std::cerr << "Edge must be between 0 and 5." << std::endl;
            return;
        }
        int leds_per_edge = led_count_hex / 6;
        int start_index = led_index_start + (edge * leds_per_edge);
        int end_index = start_index + leds_per_edge;

        for (int i = start_index; i < end_index; i++) {
            strip.setPixelColor(i, strip.Color(r, g, b));
        }
        strip.show();
    }

    void set_brightness(uint8_t brightness) {
        strip.setBrightness(brightness);
        strip.show();
    }
};