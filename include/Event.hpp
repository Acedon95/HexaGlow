#pragma once
#include <Adafruit_NeoPixel.h>
#include <map>
#include <string>


class Event{
public:
    enum EventType {
        POSITION,
        COLORALL,
        COLORHEX,
        COLORPIXEL,
        COLOREDGE,
        BRIGHTNESS,
        CLEAR,
        SETHEXCOUNT,
        NONE
    };

    EventType type;
    String raw_data;
    std::map<String, String> params;

    Event();
    Event(EventType t);
    Event(const String& d);
    Event(EventType t, const String& d);

    void add_param(const String& key, const String& value);

    String get_param(const String& key);

    bool has_param(const String& key);

    void clear_params();

    void set_type(EventType t);
};