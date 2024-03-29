import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projeto_integrador3/database/FirebaseHelper.dart';
import 'package:projeto_integrador3/src/authentication.dart';

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
        .update({"status": "waiting"});
  }

  // static Future<void> rollbackAcceptance({
  //   required String emergencyId,
  //   required String responseId,
  //   required String professionalUid,
  // }) async {
  //   FirebaseHelper.getFirestore().doc(responseId).update({
  //     "status": "canceled"
  //   })
  // }

  static Future<void> rejectProfessional({
    required String professionalUid,
    required rescuerUid,
  }) async {
    await FirebaseHelper.getFirestore()
        .collection("responses")
        .where("rescuerUid", isEqualTo: rescuerUid)
        .where("professionalUid", isEqualTo: professionalUid)
        .get()
        .then((response) {
      FirebaseHelper.getFirestore()
          .collection("responses")
          .doc(response.docs.first.id)
          .update({"status": "rejected"});
    });
  }

  static void cancelOtherResponsesNotChosen() async =>
      Authentication.getLocalInfo().then((value) {
        FirebaseHelper.getFirestore()
            .collection("responses")
            .where("rescuerUid", isEqualTo: value["rescuerUid"])
            .where("status", isNotEqualTo: "onGoing").get()
            .then((responses) {
          for (var response in responses.docs) {
            FirebaseHelper.getFirestore().collection("responses").doc(
                response.id).update({
              "status": "rejected",
            });
          }
        });
      });
}
