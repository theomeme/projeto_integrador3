import 'package:cloud_firestore/cloud_firestore.dart';

class Responses {
  static Stream<QuerySnapshot> getResponsesStream() =>
      FirebaseFirestore.instance.collection("responses")
          .where("status", isNotEqualTo: "rejected")
          .snapshots();
}
