import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:projeto_integrador3/src/authentication.dart';

class EmergencyViewModel {
  final CollectionReference emergencies =
  FirebaseFirestore.instance.collection('emergencies');
  final storageRef = FirebaseStorage.instance.ref();

  Future<Object?> checkOngoingEmergency() async {
    final auth = Authentication();
    try {
      final userData = await auth.retrieveLocalInfo();
      final ongoingEmergency = await FirebaseFirestore.instance
          .collection('emergencies')
          .where('rescuerUid', isEqualTo: userData['rescuerUid'])
          .where('status', isEqualTo: 'onGoing')
          .get()
          .catchError((e) => e);
      return ongoingEmergency;
    } catch (e) {
      print(e);
      return e;
    }
  }

  Future<DocumentReference> createEmergencyDraft(String name, String phone) async {
    final auth = Authentication();

    final userData = await auth.retrieveLocalInfo();

    final emergency = await emergencies.add({
      'rescuerUid': userData['rescuerUid'],
      'name': name,
      'phoneNumber': phone,
      'status': 'drafting',
      'photos': [],
      'location': [],
      'createdAt': DateTime.now(),
    });

    return emergency;
  }
}
