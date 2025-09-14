#include <Arduino.h>
#include "hexagon.hpp"

// Default constructor
Hexagon::Hexagon()
    : led_count_strip(0), led_count_hex(0), position(0), led_index_start(0), led_index_end(0), strip(nullptr) {}

// Parameterized constructor
Hexagon::Hexagon(int pin, int position_in_strip, int hex_leds, int strip_leds)
    : led_count_strip(strip_leds), led_count_hex(hex_leds), position(position_in_strip), strip(nullptr) {
    // Allocate the Adafruit_NeoPixel instance on the heap because it is not trivially copyable
    strip = new Adafruit_NeoPixel(led_count_strip, pin, NEO_GRB + NEO_KHZ800);
    led_index_start = (position_in_strip * led_count_hex) - led_count_hex;
    led_index_end = (position_in_strip * led_count_hex);
    strip->begin();
    strip->show(); // Initialize all pixels to 'off'
}

Hexagon::~Hexagon() {
    if (strip) {
        delete strip;
        strip = nullptr;
    }
}

// Move constructor
Hexagon::Hexagon(Hexagon&& other) noexcept
    : led_count_strip(other.led_count_strip), led_count_hex(other.led_count_hex), position(other.position), led_index_start(other.led_index_start), led_index_end(other.led_index_end), strip(other.strip) {
    other.strip = nullptr;
    other.led_count_strip = 0;
    other.led_count_hex = 0;
}

// Move assignment
Hexagon& Hexagon::operator=(Hexagon&& other) noexcept {
    if (this != &other) {
        if (strip) {
            delete strip;
        }
        led_count_strip = other.led_count_strip;
        led_count_hex = other.led_count_hex;
        position = other.position;
        led_index_start = other.led_index_start;
        led_index_end = other.led_index_end;
        strip = other.strip;
        other.strip = nullptr;
        other.led_count_strip = 0;
        other.led_count_hex = 0;
    }
    return *this;
}

void Hexagon::set_position(int pos) {
    if (pos >= 0 && pos < led_count_strip / led_count_hex) {
        position = pos;
    }
}

void Hexagon::clear() {
    set_all_pixels(0, 0, 0);
}

void Hexagon::set_all_pixels(uint8_t r, uint8_t g, uint8_t b) {
    if (!strip) return;
    for (int i = led_index_start; i < led_index_end; ++i) {
        strip->setPixelColor(i, strip->Color(r, g, b));
    }
    strip->show();
}

void Hexagon::set_pixel(int index, uint8_t r, uint8_t g, uint8_t b) {
    if (!strip) return;
    if (index >= led_index_start && index < led_index_end) {
        strip->setPixelColor(index, strip->Color(r, g, b));
        strip->show();
    }
}

void Hexagon::change_edge_colour(int edge, uint8_t r, uint8_t g, uint8_t b) {
    if (!strip) return;
    if (edge < 0 || edge > 5) {
        return;
    }
    int leds_per_edge = led_count_hex / 6;
    int start_index = led_index_start + (edge * leds_per_edge);
    int end_index = start_index + leds_per_edge;

    for (int i = start_index; i < end_index; i++) {
        strip->setPixelColor(i, strip->Color(r, g, b));
    }
    strip->show();
}

void Hexagon::set_brightness(uint8_t brightness) {
    if (!strip) return;
    strip->setBrightness(brightness);
    strip->show();
}