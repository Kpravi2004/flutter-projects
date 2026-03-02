import '../models/service_model.dart';

class DummyData {

  static List<ServiceModel> services = [

    ServiceModel(
      id: "1",
      title: "Fan Repair",
      image: "assets/images/fan_repair.jpg",
      category: "Electrical",
      description: "Professional fan repair service.",
    ),

    ServiceModel(
      id: "2",
      title: "Switch Repair",
      image: "assets/images/switch_socket_repair.jpg",
      category: "Electrical",
      description: "Fix damaged switches safely.",
    ),

    ServiceModel(
      id: "3",
      title: "Leakage Fix",
      image: "assets/images/leakage_fix.jpg",
      category: "Plumbing",
      description: "Pipe leakage repair service.",
    ),

    ServiceModel(
      id: "4",
      title: "Toilet Repair",
      image: "assets/images/toilet_repair.jpg",
      category: "Plumbing",
      description: "Toilet blockage repair.",
    ),

  ];
}
