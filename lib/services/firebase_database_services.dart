import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp_students/services/firebase_messaging_service.dart';

class FirebaseDatabaseServices {
  final db = FirebaseFirestore.instance;

  Future<void> storeTokenToDb(String uid) async {
    String busNumber = "";
    await db
        .collection("User-Student")
        .doc(uid)
        .get()
        .then((value) => {busNumber = value.data()!["Bus Allocated"]});
    if (busNumber == "") {
      return;
    } else {
      String driverUid = "";
      await db
          .collection("User-Driver")
          .limit(1)
          .where("Bus Number", isEqualTo: busNumber)
          .get()
          .then((value) {
        for (var doc in value.docs) {
          driverUid = doc.id;
        }
      });
      if (driverUid != "") {
        await db
            .collection("User-Driver")
            .doc(driverUid)
            .collection("tokens")
            .doc(uid)
            .set({"token": await NotificationServices().getToken()});
      }
    }
  }
}
