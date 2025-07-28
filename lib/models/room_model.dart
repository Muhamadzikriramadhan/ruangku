// lib/models/room_model.dart
class RoomModel {
  final String uid;
  final String name;
  final int capacity;
  final String location;
  final String lecture;
  final bool isAvailable;

  RoomModel({
    required this.uid,
    required this.name,
    required this.capacity,
    required this.location,
    required this.lecture,
    required this.isAvailable,
  });

  factory RoomModel.fromMap(String uid, Map<String, dynamic> map) {
    return RoomModel(
      uid: uid,
      name: map['name'] ?? '',
      capacity: map['capacity'] ?? 0,
      location: map['location'] ?? '',
      lecture: map['lecture'] ?? '',
      isAvailable: map['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'capacity': capacity,
      'location': location,
      'lecture': lecture,
      'isAvailable': isAvailable,
    };
  }
}
