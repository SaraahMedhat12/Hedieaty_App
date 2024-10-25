// event_controller.dart

import 'package:flutter/material.dart';

class EventController {
  List<Map<String, dynamic>> events = [
    {
      'name': 'Sarah’s Birthday',
      'category': 'Birthday',
      'status': 'Upcoming',
    },
    {
      'name': 'Wedding Anniversary',
      'category': 'Anniversary',
      'status': 'Current',
    },
    {
      'name': 'Graduation Party',
      'category': 'Graduation',
      'status': 'Past',
    },
  ];

  // Function to add event
  void addEvent(String name, String category) {
    events.add({
      'name': name,
      'category': category,
      'status': 'Upcoming',
    });
  }

  // Function to edit event
  void editEvent(int index, String name, String category) {
    events[index]['name'] = name;
    events[index]['category'] = category;
  }

  // Function to delete event
  void deleteEvent(int index) {
    events.removeAt(index);
  }

  // Sort function
  void sortEvents(String criteria) {
    if (criteria == 'name') {
      events.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (criteria == 'category') {
      events.sort((a, b) => a['category'].compareTo(b['category']));
    } else if (criteria == 'status') {
      events.sort((a, b) => a['status'].compareTo(b['status']));
    }
  }
}
