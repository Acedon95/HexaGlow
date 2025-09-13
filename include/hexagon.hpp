#pragma once
#define HEXAGON_H
#include <Adafruit_NeoPixel.h> 

class Hexagon {
    public:
    int led_count_strip;  // Amount of LEDs in the strip
    int led_count_hex;  // Amount of LEDs in the hexagon
    int position;   // Current position in the hexagon array
    int led_index_start; // Start index of the first led of the hexagon in the strip
    int led_index_end;   // End index of the hexagon leds in the strip
    Adafruit_NeoPixel strip;

    Hexagon();
    Hexagon(int pin, int position_in_strip, int hex_leds, int strip_leds);
    void set_position(int pos);
    void clear();
    void set_all_pixels(uint8_t r, uint8_t g, uint8_t b);
    void set_pixel(int index, uint8_t r, uint8_t g, uint8_t b);
    void change_edge_colour(int edge, uint8_t r, uint8_t g, uint8_t b);
    void set_brightness(uint8_t brightness);
};