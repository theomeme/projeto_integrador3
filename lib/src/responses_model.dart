import 'package:cloud_firestore/cloud_firestore.dart';

class Responses {
  static Stream<QuerySnapshot> getResponsesStream() =>
      FirebaseFirestore.instance
          .collection("responses")
          .where("status", isNotEqualTo: "rejected")
          .snapshots();

  static Future<void> acceptProfessional({
    required String emergencyId,
    required String professionalUid,
  }) async {
    FirebaseFirestore.instance
        .collection("profiles")
        .doc(professionalUid)
        .collection("myEmergencies")
        .doc(emergencyId)
        .set({
      "emergencyId": emergencyId,
      "status": "onGoing",
      "createdAt": Timestamp.fromDate(DateTime.now())
    });
    FirebaseFirestore.instance
        .collection("emergencies")
        .doc(emergencyId)
        .update({"status": "onGoing"});
  }

  static Future<void> rejectProfessional({
    required String responseId
  }) async {
    FirebaseFirestore.instance
        .collection("responses")
        .doc(responseId)
        .update({
      "status": "rejected"
    });
  }
}
