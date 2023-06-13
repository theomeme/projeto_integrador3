import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  Future<void> rateProfessional(
      {required String professionalUid,
      required emergencyId,
      required double rating,
      required String review}) async {
    final DocumentSnapshot emergency = await FirebaseFirestore.instance
        .collection("emergencies")
        .doc(emergencyId)
        .get();

    return FirebaseFirestore.instance
        .collection("profiles")
        .doc(professionalUid)
        .collection("reviews")
        .doc(emergencyId)
        .set({
      "emergencyId": emergency.id,
      "name": emergency.get("name"),
      "rating": rating,
      "review": review,
      "revision": false,
      "createdAt": Timestamp.fromDate(DateTime.now()),
    });
  }
}
