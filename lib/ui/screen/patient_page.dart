// lib/screens/patient_home.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ruangku/ui/theme/colors.dart';
import '../../models/room_model.dart';
import '../../models/user_model.dart';
import '../../service/auth_service.dart';
import 'login_page.dart';

class PatientPage extends StatelessWidget {
  final UserModel user;

  PatientPage({required this.user});

  void logout(BuildContext context) async {
    await AuthService().signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appColor,
        title: Text("Pasien - ${user.name}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () => logout(context), icon: Icon(Icons.logout, color: Colors.white))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = RoomModel.fromMap(
                docs[index].id,
                docs[index].data() as Map<String, dynamic>,
              );

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left section (Room Info)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.name,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text("Status: "),
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(data.isAvailable),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    data.isAvailable ? 'tersedia' : 'sedang digunakan',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text("Lokasi: ${data.location}"),
                          ],
                        ),
                      ),

                      // Right section (Dosen + Status Dropdown)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Dosen: ${data.lecture}"),
                          Text("Kapasitas: ${data.capacity}"),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(bool status) {
    switch (status) {
      case true:
        return Colors.green;
      default:
        return Colors.red;
    }
  }

}
