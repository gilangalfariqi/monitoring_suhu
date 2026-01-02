import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_model.dart';

class FirebaseService {
  final _ref =
  FirebaseDatabase.instance.ref('iot_dht11/room_1');

  Stream<SensorModel> streamSensor() {
    return _ref.onValue.map((event) {
      final data =
      Map<String, dynamic>.from(event.snapshot.value as Map);
      return SensorModel.fromMap(data);
    });
  }
}
