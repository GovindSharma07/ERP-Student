import 'package:erp_students/Model/attendanceModel.dart';
import 'package:erp_students/services/firebase_database_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Attendance extends StatefulWidget {
  const Attendance({super.key});

  @override
  State<Attendance> createState() => _AttendanceState();
}

class _AttendanceState extends State<Attendance> {
  int selectedSubjectIndex = 0;
  int total = 0;
  int present = 0;
  int absent = 0;
  int leave = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Attendance"),
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: FirebaseDatabaseServices().getListOfSubjectModels(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              present = 0;
              leave = 0;
              total = 0;
              absent = 0;

              for (var i in snapshot.data!) {
                for (var j in i.attendance) {
                  if (j.attendance == "P") {
                    present++;
                  } else if (j.attendance == "A") {
                    absent++;
                  } else {
                    leave++;
                  }
                  total++;
                }
              }
              return Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Subject List
                        Expanded(
                          flex: 1,
                          child: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final subject = snapshot.data![index];
                              return ListTile(
                                title: Text(subject.name),
                                selected: index == selectedSubjectIndex,
                                onTap: () => setState(
                                    () => selectedSubjectIndex = index),
                              );
                            },
                          ),
                        ),

                        const VerticalDivider(
                          width: 2,
                          color: Colors.black,
                        ),
                        Expanded(
                          flex: 2,
                          child: snapshot.data!.isEmpty
                              ? const Center(child: Text("No Subjects"))
                              : ListView(
                                  children: [
                                    // Header row
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Text("Date"),
                                          Spacer(),
                                          Text("Value"),
                                        ],
                                      ),
                                    ),
                                    // Attendance records
                                    for (AttendanceModel record in snapshot
                                        .data![selectedSubjectIndex].attendance)
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Text(record.date),
                                            const Spacer(),
                                            Text(record.attendance),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Total: $total"),
                      Text("Present: $present"),
                      Text("Absent: $absent"),
                      Text("Leave: $leave"),
                    ],
                  ))
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
