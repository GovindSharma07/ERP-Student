import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erp_students/Model/attendanceModel.dart';
import 'package:erp_students/Model/notes_model.dart';
import 'package:erp_students/Model/subjectModel.dart';
import 'package:erp_students/services/firebase_messaging_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseDatabaseServices {
  final db = FirebaseFirestore.instance;
  final uid = FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<void> storeTokenToDb(String uid) async {
    String busNumber = "";
    await db
        .collection("User-Student")
        .doc(uid)
        .get()
        .then((value) => {busNumber = value.data()!["busAllocated"]});
    if (busNumber == "") {
      return;
    } else {
      String driverUid = "";
      await db
          .collection("User-Driver")
          .limit(1)
          .where("busNumber", isEqualTo: busNumber)
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

  Future<List<dynamic>> getSubjectList() async {
    List<dynamic> subjects = [];

    String course = "";

    await db
        .collection("User-Student")
        .doc(uid)
        .get()
        .then((value) => {course = value.data()?["section"]});
    var snapshot = await db.collection("Subjects").doc(course).get();
    subjects = snapshot.data()?["subjects"];

    for (var element in subjects) {
      getAttendance(element);
    }
    ;
    return subjects;
  }

  Future<List<AttendanceModel>> getAttendance(String sub) async {
    List<AttendanceModel> attendance = [];

    String course = "";

    await db
        .collection("User-Student")
        .doc(uid)
        .get()
        .then((value) => {course = value.data()?["section"]});

    var snapshot =
        await db.collection("Attendance").doc(course).collection(sub).get();
    for (var element in snapshot.docs) {
      if (element[uid] != null) {
        attendance.add(AttendanceModel(element.id, element[uid]));
      }
    }
    for (var element in attendance) {
      print("${element.date} and ${element.attendance}");
    }
    return attendance;
  }

  Future<List<SubjectModel>> getListOfSubjectModels() async {
    List<SubjectModel> subjectModelList = [];
    var subjectList = await getSubjectList();
    for (var element in subjectList) {
      SubjectModel subjectModel =
          SubjectModel(name: element, attendance: await getAttendance(element));
      subjectModelList.add(subjectModel);
    }
    return subjectModelList;
  }

  Future<List<NotesModel>> getAllNotes() async {
    List<NotesModel> allNotes = [];

    String course = "";

    await db
        .collection("User-Student")
        .doc(uid)
        .get()
        .then((value) => {course = value.data()?["section"]});

    var snapshot = await db.collection("Notes").doc("classes").collection(course).get();
    for (var element in snapshot.docs) {
      allNotes.add(NotesModel.fromJson(element.data()));
    }
    return allNotes;
  }
}
