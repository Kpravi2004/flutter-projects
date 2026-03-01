import '../../services/models/service_model.dart';

class BookingModel {
  final ServiceModel service;
  final String workerName;
  final DateTime date;
  final String time;

  BookingModel({
    required this.service,
    required this.workerName,
    required this.date,
    required this.time,
  });
}
