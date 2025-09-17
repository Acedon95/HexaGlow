#include "EventHandler.hpp"
#include <string>
#include <sstream>
#include <vector>


// Default constructor
EventHandler::EventHandler(Hexagon* hexagons, int hex_count, Adafruit_NeoPixel* strip)
    : hexagons(hexagons), hex_count(hex_count), strip(strip) {}
// Destructor
EventHandler::~EventHandler() {}
// Move constructor
EventHandler::EventHandler(EventHandler&& other) noexcept
    : hexagons(other.hexagons), hex_count(other.hex_count), strip(other.strip) {
    other.hexagons = nullptr;
    other.hex_count = 0;
    other.strip = nullptr;
}
// Move assignment
EventHandler& EventHandler::operator=(EventHandler&& other) noexcept {
    if (this != &other) {
        hexagons = other.hexagons;
        hex_count = other.hex_count;
        strip = other.strip;

        other.hexagons = nullptr;
        other.hex_count = 0;
        other.strip = nullptr;
    }
    return *this;
}

std::vector<std::string> parse_event_string(const std::string& event_str) {
    // Simple parser to split by spaces; can be enhanced as needed
    std::vector<std::string> tokens;
    std::stringstream ss(event_str);
    std::string token;
    while (std::getline(ss, token, ' ')) {
        tokens.push_back(token);
    }
    return tokens;
}

Event EventHandler::create_event_from_string(const std::string& event_str) {
    // Split the string and determine event type
    std::vector<std::string> tokens = parse_event_string(event_str);
    if (tokens.empty()) {
        return Event(); // Return a default event if parsing fails
    }

    // Determine event type based on the first token
    if (tokens[0] == "CLEAR") {
        return Event(Event::CLEAR);
    } else if (tokens[0] == "POSITION") {
        if (tokens.size() > 1) {
            Event e(Event::POSITION);
            e.add_param("hex_index", String(tokens[1].c_str()));
            e.add_param("target", String(tokens[2].c_str()));
            return e;
        }
    } else if (tokens[0] == "COLORALL") {
        if (tokens.size() > 1) {
            Event e(Event::COLORALL);
            e.add_param("r", String(tokens[1].c_str()));
            e.add_param("g", String(tokens[2].c_str()));
            e.add_param("b", String(tokens[3].c_str()));
            return e;
        }
    } else if (tokens[0] == "COLORPIXEL") {
        if (tokens.size() > 2) {
            Event e(Event::COLORPIXEL);
            e.add_param("hex_index", String(tokens[1].c_str()));
            e.add_param("index", String(tokens[2].c_str()));
            e.add_param("r", String(tokens[3].c_str()));
            e.add_param("g", String(tokens[4].c_str()));
            e.add_param("b", String(tokens[5].c_str()));
            return e;
        }
    } else if (tokens[0] == "COLOREDGE") {
        if (tokens.size() > 2) {
            Event e(Event::COLOREDGE);
            e.add_param("hex_index", String(tokens[1].c_str()));
            e.add_param("edge", String(tokens[2].c_str()));
            e.add_param("r", String(tokens[3].c_str()));
            e.add_param("g", String(tokens[4].c_str()));
            e.add_param("b", String(tokens[5].c_str()));
            return e;
        }
    } else if (tokens[0] == "BRIGHTNESS") {
        if (tokens.size() > 1) {
            Event e(Event::BRIGHTNESS);
            e.add_param("value", String(tokens[1].c_str()));
            return e;
        }
    }else {
        // Unknown event type; return raw data event
        return Event(String(event_str.c_str()));
    }
}

void EventHandler::process_event(Event event) {
    // Process event based on its type and parameters
    switch (event.type) {
        case Event::POSITION:
            // Handle position event
            break;
        case Event::COLORALL:
            // Handle color all event by setting all hexagons to the specified color
            if (event.has_param("r") && event.has_param("g") && event.has_param("b")) {
                int r = event.get_param("r").toInt();
                int g = event.get_param("g").toInt();
                int b = event.get_param("b").toInt();
                for (int i = 0; i < hex_count; ++i) {
                    hexagons[i].set_all_pixels(r, g, b);
                }
                strip->show(); // Update the strip after changing all hexagons
            }
            break;
        case Event::COLORPIXEL:
            // Handle color pixel event by setting a specific pixel in a specific hexagon
            if (event.has_param("hex_index") && event.has_param("index") && event.has_param("r") && event.has_param("g") && event.has_param("b")) {
                int hex_index = event.get_param("hex_index").toInt() - 1; // Convert to 0-based index
                int pixel_index = event.get_param("index").toInt();
                int r = event.get_param("r").toInt();
                int g = event.get_param("g").toInt();
                int b = event.get_param("b").toInt();
                if (hex_index >= 0 && hex_index < hex_count) {
                    hexagons[hex_index].set_pixel(pixel_index, r, g, b);
                    strip->show(); // Update the strip after changing the pixel
                }
            }
            break;
        case Event::COLOREDGE:
            // Handle color edge event
            if (event.has_param("hex_index") && event.has_param("edge") && event.has_param("r") && event.has_param("g") && event.has_param("b")) {
                int hex_index = event.get_param("hex_index").toInt() - 1; // Convert to 0-based index
                int edge = event.get_param("edge").toInt();
                int r = event.get_param("r").toInt();
                int g = event.get_param("g").toInt();
                int b = event.get_param("b").toInt();
                if (hex_index >= 0 && hex_index < hex_count) {
                    hexagons[hex_index].change_edge_colour(edge, r, g, b);
                    strip->show(); // Update the strip after changing the edge color
                }
            }
            break;
        case Event::BRIGHTNESS:
            // Handle brightness event
            if (event.has_param("value")) {
                int brightness = event.get_param("value").toInt();
                strip->setBrightness(brightness);
                strip->show(); // Update the strip after changing brightness
            }
            break;
        case Event::CLEAR:
            // Handle clear event
            for (int i = 0; i < hex_count; ++i) {
                hexagons[i].clear();
            }
            break;
        default:
            // Unknown event type
            // Maybe built in that each hexagon flashes red for a second and then returns to previous state?
            for (int i = 0; i < hex_count; ++i) {
                hexagons[i].set_all_pixels(150, 0, 0); // Flash red
                delay(1000);
            }
            strip->show();

            for (int i = 0; i < hex_count; ++i) {
                hexagons[i].clear(); // Clear after flash
            }
            strip->show();
            break;
    }
}