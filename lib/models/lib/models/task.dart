import 'package:flutter/material.dart';
class Task {
  String title;
  String statType;
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool isCompleted;
  DateTime date; // НОВО: дата задачи

  Task({
    required this.title,
    required this.statType,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
    required this.date,
  });
}
