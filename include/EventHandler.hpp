#pragma once
#include <string>
#include "Event.hpp"
#include "Hexagon.hpp"
#include <Adafruit_NeoPixel.h>



class EventHandler {
public:
    Hexagon* hexagons;
    int hex_count;
    Adafruit_NeoPixel* strip;
    // Constructor
    EventHandler();
    EventHandler(Hexagon* hexagons, int hex_count, Adafruit_NeoPixel* strip);
    ~EventHandler();

    // Movable but not copyable
    EventHandler(EventHandler&& other) noexcept;
    EventHandler& operator=(EventHandler&& other) noexcept;
    EventHandler(const EventHandler&) = delete;
    EventHandler& operator=(const EventHandler&) = delete;

    Event create_event_from_string(const std::string& event_str);
    void process_event(Event event);
};