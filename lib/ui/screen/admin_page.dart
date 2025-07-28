import 'package:flutter/material.dart';
import 'package:ruangku/service/auth_service.dart';
import 'package:ruangku/ui/theme/colors.dart';
import '../../models/room_model.dart';
import '../../models/user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

import 'package:flutter/material.dart';
import 'package:ruangku/service/auth_service.dart';
import 'package:ruangku/ui/theme/colors.dart';
import '../../models/room_model.dart';
import '../../models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'dart:developer' as developer; // Optional: for logging

class AdminPage extends StatefulWidget {
  final UserModel userModel;
  const AdminPage({super.key, required this.userModel});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<String> lecturers = [];

  @override
  void initState() {
    super.initState();
    fetchLecturers();
  }

  Future<void> fetchLecturers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'dosen')
          .get();
      setState(() {
        lecturers = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      developer.log('Error fetching lecturers: $e'); // Optional logging
      // Consider showing an error message to the user
    }
  }

  // --- FIXED: Corrected typo 'isAvalaible' to 'isAvailable'
  void updateStatusAndLecture(String id, String newStatus, String newLecture) {
    FirebaseFirestore.instance.collection('rooms').doc(id).update({
      'isAvailable': newStatus == 'tersedia', // Corrected field name
      'lecture': newLecture,
    }).catchError((error) {
      developer.log('Error updating room: $error'); // Optional logging
      // Consider showing an error message to the user
    });
  }

  void logout(BuildContext context) async {
    try {
      await AuthService().signOut();
      if (context.mounted) { // Check if context is still valid
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginPage()));
      }
    } catch (e) {
      developer.log('Error during logout: $e'); // Optional logging
      // Consider showing an error message to the user
    }
  }

  Color _getStatusColor(bool isAvailable) {
    return isAvailable ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appColor,
        title: Text("Admin - ${widget.userModel.name}",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              onPressed: () => logout(context),
              icon: Icon(Icons.logout),
              color: Colors.white)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label "Daftar Ruang Kelas"
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 8, top: 8),
              child: Text(
                "Daftar Ruang Kelas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // StreamBuilder untuk List Room
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  developer.log('Firestore error: ${snapshot.error}'); // Optional logging
                  return Center(child: Text("Error loading rooms"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No rooms found"));
                }
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
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left side: Room info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data.name,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold, fontSize: 16)),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text("Status: "),
                                      SizedBox(width: 8),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(data.isAvailable), // --- FIXED: Typo
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          data.isAvailable // --- FIXED: Typo
                                              ? 'tersedia'
                                              : 'sedang digunakan',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text("Lokasi: ${data.location}"),
                                  Text("Kapasitas: ${data.capacity}"),
                                ],
                              ),
                            ),
                            // Right side: Dropdowns
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    value:  (data.lecture.isNotEmpty && lecturers.contains(data.lecture))
                                        ? data.lecture
                                        : null,
                                    hint: Text("Pilih Dosen"),
                                    items: lecturers.map((dosen) {
                                      return DropdownMenuItem(
                                        value: dosen,
                                        child: Text(dosen),
                                      );
                                    }).toList(),
                                    onChanged: (selectedDosen) {
                                      if (selectedDosen != null) {
                                        updateStatusAndLecture(
                                          data.uid,
                                          data.isAvailable // --- FIXED: Typo
                                              ? 'tersedia'
                                              : 'sedang digunakan',
                                          data.isAvailable ? '' : selectedDosen,
                                        );
                                      }
                                    },
                                    validator: (value) {
                                      // Optional: Add validation if needed
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(height: 12),
                                SizedBox(
                                  width: 150,
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    // --- IMPROVEMENT: Ensure value matches items
                                    value: data.isAvailable // --- FIXED: Typo
                                        ? 'tersedia'
                                        : 'sedang digunakan',
                                    items: ['tersedia', 'sedang digunakan']
                                        .map((status) {
                                      return DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      );
                                    }).toList(),
                                    onChanged: (newStatus) {
                                      if (newStatus != null) {
                                        updateStatusAndLecture(
                                            data.uid, newStatus,
                                            data.isAvailable ? '' : data.lecture);
                                      }
                                    },
                                    validator: (value) {
                                      // Optional: Add validation if needed
                                      return null;
                                    },
                                  ),
                                ),
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
            // Label "Daftar Pengguna"
            Padding(
              padding: const EdgeInsets.only(left: 15, bottom: 8, top: 16),
              child: Text(
                "Daftar Pengguna",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // StreamBuilder untuk Users
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  developer.log('Firestore error: ${snapshot.error}'); // Optional logging
                  return Center(child: Text("Error loading users"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No users found"));
                }
                final users = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData = users[index].data() as Map<String, dynamic>;
                    final userId = users[index].id;
                    return ListTile(
                      title: Text(userData['name'] ?? 'No Name'),
                      subtitle: Text(userData['email'] ?? 'No Email'),
                      // Optional: Display role if needed
                      // trailing: Text(userData['role'] ?? 'No Role'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditUserDialog(context, userId, userData);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Optional: Add confirmation dialog before deleting
                              try {
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(userId)
                                    .delete();
                              } catch (e) {
                                developer.log('Error deleting user: $e'); // Optional logging
                                // Consider showing an error message to the user
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'addRoom',
            onPressed: () => _showAddRoomDialog(context),
            label: Text("Add Room", style: TextStyle(color: Colors.white)),
            icon: Icon(Icons.meeting_room, color: Colors.white),
            backgroundColor: appColor,
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'addUser',
            onPressed: () => _showAddUserDialog(context),
            label: Text("Add User", style: TextStyle(color: Colors.white)),
            icon: Icon(Icons.person_add, color: Colors.white),
            backgroundColor: appColor,
          ),
        ],
      ),
    );
  }

  void _showAddRoomDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();
    final locationController = TextEditingController(); // For location input
    String? selectedLecture; // For lecturer selection

    // Fetch lecturers again to ensure list is up-to-date
    List<String> lecturerNames = [];
    try {
      final lecturersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'dosen')
          .get();
      lecturerNames = lecturersSnapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();
    } catch (e) {
      developer.log('Error fetching lecturers for dialog: $e'); // Optional logging
      // Consider showing an error message or disabling lecturer selection
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // Use StatefulBuilder to update dropdown
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Room"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: "Room Name"),
                    ),
                    TextField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Room Capacity"),
                    ),
                    TextField(
                      controller: locationController,
                      // Removed keyboardType for location as it might be text
                      decoration: InputDecoration(labelText: "Room Location"),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedLecture,
                      hint: Text("Select Lecturer (Optional)"),
                      items: lecturerNames.map((name) {
                        return DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() { // Update dialog state
                          selectedLecture = value;
                        });
                      },
                      decoration: InputDecoration(labelText: "Select Lecturer"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Basic validation
                    if (nameController.text.isEmpty ||
                        capacityController.text.isEmpty ||
                        locationController.text.isEmpty) {
                      // Show snackbar or dialog indicating required fields
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill all fields")));
                      return;
                    }
                    int? capacity = int.tryParse(capacityController.text);
                    if (capacity == null || capacity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please enter a valid capacity")));
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance.collection('rooms').add({
                        'name': nameController.text.trim(),
                        'capacity': capacity,
                        'lecture': selectedLecture?.trim() ?? '', // Handle null/empty lecturer
                        'location': locationController.text.trim(), // --- FIXED: Use location input
                        'isAvailable': true, // --- IMPROVEMENT: Default status
                      });
                      Navigator.pop(context); // Close dialog on success
                      // Optional: Show success message
                    } catch (e) {
                      developer.log('Error adding room: $e'); // Optional logging
                      // Show error message to user
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error adding room")));
                      }
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          }
      ),
    ).then((_) {
      // Clear controllers when dialog is closed
      nameController.dispose();
      capacityController.dispose();
      locationController.dispose();
    });
  }

  void _showAddUserDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true), // Hide password input
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Basic validation
              if (nameController.text.isEmpty ||
                  emailController.text.isEmpty ||
                  passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields")));
                return;
              }
              // --- CRITICAL SECURITY FIX: Do NOT store passwords in plain text in Firestore.
              // You should use Firebase Authentication to create the user account first.
              // Then, store only non-sensitive user data (like name, role) in Firestore.
              // The password should be handled by Firebase Auth.
              // Example flow (requires AuthService implementation):
              /*
              try {
                // 1. Create user with email and password using FirebaseAuth
                UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: emailController.text.trim(),
                  password: passwordController.text.trim(),
                );

                // 2. If successful, store additional user data in Firestore
                if (userCredential.user != null) {
                  await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'role': 'dosen', // Or get role from input
                    // DO NOT store 'password' here
                  });
                  Navigator.pop(context); // Close dialog
                  // Show success message
                }
              } on FirebaseAuthException catch (e) {
                 String message = 'Error adding user';
                 if (e.code == 'email-already-in-use') {
                   message = 'Email already in use';
                 } else if (e.code == 'invalid-email') {
                   message = 'Invalid email format';
                 } else if (e.code == 'weak-password') {
                   message = 'Password is too weak';
                 }
                 // Show error message to user
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
              } catch (e) {
                 developer.log('Unexpected error adding user: $e');
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error adding user")));
              }
              */

              // --- TEMPORARY WORKAROUND (NOT RECOMMENDED FOR PRODUCTION):
              // If you must store data directly (e.g., for testing or specific backend logic),
              // at least do not store the plain password. Indicate that auth is handled elsewhere
              // or use a placeholder. This is insecure and should be replaced.
              // TODO: Implement proper Firebase Authentication integration.

              try {
                // Example: Store user data without password (assuming auth is handled separately)
                await FirebaseFirestore.instance.collection('users').add({
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  // 'password': passwordController.text.trim(), // DO NOT DO THIS
                  'role': 'dosen', // Consider making this selectable
                });
                Navigator.pop(context); // Close dialog on success
                // Optional: Show success message
              } catch (e) {
                developer.log('Error adding user to Firestore: $e'); // Optional logging
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error adding user")));
                }
              }
            },
            child: Text("Add"),
          ),
        ],
      ),
    ).then((_) {
      // Clear controllers when dialog is closed
      nameController.dispose();
      emailController.dispose();
      passwordController.dispose();
    });
  }


  void _showEditUserDialog(BuildContext context, String id, Map<String, dynamic> data) {
    final nameController = TextEditingController(text: data['name']);
    final emailController = TextEditingController(text: data['email']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Pengguna"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              // Basic validation
              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all fields")));
                return;
              }
              try {
                await FirebaseFirestore.instance.collection('users').doc(id).update({
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                });
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog on success
                }
                // Optional: Show success message
              } catch (e) {
                developer.log('Error editing user: $e'); // Optional logging
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error updating user")));
                }
              }
            },
            child: Text("Simpan"),
          ),
        ],
      ),
    ).then((_) {
      // Clear controllers when dialog is closed
      nameController.dispose();
      emailController.dispose();
    });
  }
}