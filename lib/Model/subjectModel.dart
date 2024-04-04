import 'package:erp_students/Model/attendanceModel.dart';

class SubjectModel {
  final String name;
  final List<AttendanceModel> attendance;

  SubjectModel({required this.name, required this.attendance});
}