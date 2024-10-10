// lib/models/route_model.dart
class RouteModel {
  final String id;
  final String routeNumber;
  final String beginning;
  final String destination;
  final List<String> busStops;

  RouteModel({
    required this.id,
    required this.routeNumber,
    required this.beginning,
    required this.destination,
    required this.busStops,
  });

  factory RouteModel.fromMap(Map<String, dynamic> data, String id) {
    return RouteModel(
      id: id,
      routeNumber: data['routeNumber'] ?? '',
      beginning: data['beginning'] ?? '',
      destination: data['destination'] ?? '',
      busStops: List<String>.from(data['busStops'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'routeNumber': routeNumber,
      'beginning': beginning,
      'destination': destination,
      'busStops': busStops,
    };
  }
}
