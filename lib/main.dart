import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ruangku/ui/screen/admin_page.dart';
import 'package:ruangku/ui/screen/login_page.dart';
import 'package:ruangku/ui/screen/patient_page.dart';
import 'package:ruangku/ui/theme/colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monitoring Ruang Kelas',
      theme: ThemeData(
        primaryColor: appColor,
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'DMSans',
      ),
      home: LoginPage(),
    );
  }
}

// class HomeMenu extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Sistem Monitoring Kamar"), backgroundColor: Color(0xFF4CAF50)),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PatientPage())),
//               child: Text("Cek Status Kamar"),
//               style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4CAF50)),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPage())),
//               child: Text("Masuk sebagai Admin"),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }