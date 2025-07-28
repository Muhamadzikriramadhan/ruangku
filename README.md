# 🏫 RuangKu – Aplikasi Booking Ruang Kelas Kampus
/assets/images/icon_ruangku.png
**RuangKu** adalah aplikasi Flutter berbasis Firebase yang memungkinkan dosen melakukan pemesanan ruang kelas dan admin dapat mengelola data ruangan dan user dosen.

## 🧩 Fitur Utama

- 🔐 Login berbasis Firestore (tanpa Firebase Auth)
- 👤 Role-based access (Admin & Dosen)
- 📚 Admin:
    - CRUD data ruangan
    - CRUD user dosen
    - Assign dosen ke ruangan
- 🧾 Dosen:
    - Melihat ruang yang sudah di-assign
    - Request pemesanan ruang kelas

## 🛠 Teknologi

- Flutter
- Firebase Firestore
- State Management (Provider/Bloc)

## 📁 Struktur Proyek

```text
RuangKu/
├── lib/
│   ├── models/
│   ├── pages/
│   ├── services/
│   ├── providers/
│   └── main.dart
├── assets/
└── pubspec.yaml
