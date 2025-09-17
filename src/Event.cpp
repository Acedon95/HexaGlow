#include "Event.hpp"


// Default constructor
Event::Event() : type(NONE), raw_data("") {}
Event::Event(EventType t) : type(t), raw_data("") {}
Event::Event(const String& d) : type(NONE), raw_data(d) {}
Event::Event(EventType t, const String& d) : type(t), raw_data(d) {}

void Event::add_param(const String& key, const String& value) {
    params[key] = value;
}

String Event::get_param(const String& key) {
    auto it = params.find(key);
    if (it != params.end()) {
        return it->second;
    }
    return "";
}
bool Event::has_param(const String& key) {
    return params.find(key) != params.end();
}

void Event::clear_params() {
    params.clear();
}

void Event::set_type(EventType t) {
    type = t;
}