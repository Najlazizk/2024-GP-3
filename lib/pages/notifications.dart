import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications extends StatelessWidget {
  final currentFCMToken; // Assuming you pass the current FCM token to this widget

  Notifications({this.currentFCMToken});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 2, 129, 55),
        title: Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios_new_sharp,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('notificationList')
                      .where('androidNotificationToken',
                          isEqualTo: currentFCMToken)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return DataTable(
                      columns: [
                        DataColumn(
                          label: SizedBox(
                            width: 50, // Adjust width as needed
                            child: Text('Date'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 40, // Adjust width as needed
                            child: Text('Time'),
                          ),
                        ),
                        DataColumn(
                          label: SizedBox(
                            width: 60, // Adjust width as needed
                            child: Text('Duration'),
                          ),
                        ),
                      ],
                      rows: _buildRows(snapshot.data!.docs),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DataRow> _buildRows(List<DocumentSnapshot> snapshot) {
    List<DataRow> rows = [];
    snapshot.forEach((document) {
      Map<String, dynamic> data =
          document.data() as Map<String, dynamic>; // Explicit cast
      dynamic date = data['date'];
      dynamic time = data['time'];
      dynamic duration = data['duration'];
      String dateString = date is int ? date.toString() : date as String;
      String timeString = time is int ? time.toString() : time as String;
      String durationString =
          duration is int ? duration.toString() : duration as String;
      rows.add(DataRow(
        cells: [
          DataCell(Text(dateString)),
          DataCell(Text(timeString)),
          DataCell(Text(durationString)),
        ],
      ));
    });
    return rows;
  }
}
