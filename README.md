# 🎯 DB-Cracker: ctOS Faculty Database Scanner

<div align="center">

![ctOS Logo](https://img.shields.io/badge/ctOS-DATABASE%20SCANNER-00ff41?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTEyIDJMMTMuMDkgOC4yNkwyMCA5TDEzLjA5IDE1Ljc0TDEyIDIyTDEwLjkxIDE1Ljc0TDQgOUwxMC45MSA4LjI2TDEyIDJaIiBmaWxsPSIjMDBmZjQxIi8+Cjwvc3ZnPgo=)

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://developer.android.com)

**🔥 Advanced Faculty & Student Database Intelligence System 🔥**

*Inspired by Watch Dogs ctOS - Elegant, Futuristic, Powerful*

</div>

---

## 🚀 **Tentang Proyek**

**DB-Cracker** adalah aplikasi mobile canggih yang dirancang untuk mengakses dan menganalisis database akademik Indonesia dengan antarmuka yang terinspirasi dari sistem ctOS dalam game Watch Dogs. Aplikasi ini menyediakan akses comprehensive ke data dosen dan mahasiswa dari berbagai sumber API pendidikan Indonesia.

### 🎨 **Design Philosophy**
- **ctOS Aesthetic**: Dark theme dengan aksen cyan/hijau neon
- **Futuristic UI**: Typography monospace, animasi glow, efek hacker
- **Responsive Layout**: Mengikuti prinsip design Gojek untuk mobile-first experience
- **Data Visualization**: Presentasi data yang elegan dan mudah dibaca

---

## ✨ **Fitur Utama**

### 🔍 **Database Scanner**
- **Multi-Source Search**: Pencarian dari berbagai API pendidikan Indonesia
- **Real-time Results**: Hasil pencarian langsung dengan animasi loading
- **Smart Filtering**: Filter berdasarkan perguruan tinggi, program studi
- **Comprehensive Data**: Akses ke semua data yang tersedia dari PDDikti API

### 👨‍🏫 **Profil Dosen Lengkap**
- ✅ **Informasi Personal**: Nama, NIDN/NIDK, gelar, jenis kelamin, tempat/tanggal lahir
- ✅ **Status Kepegawaian**: Ikatan kerja, status aktivitas, jabatan akademik
- ✅ **Riwayat Pendidikan**: S1/S2/S3, perguruan tinggi asal, tahun lulus
- ✅ **Jabatan Fungsional**: Asisten Ahli, Lektor, Lektor Kepala, Guru Besar
- ✅ **Sertifikasi Dosen**: Status, tahun, nomor sertifikat
- ✅ **Riwayat Mengajar**: Mata kuliah, semester, perguruan tinggi
- ✅ **Portfolio Akademik**: Penelitian, pengabdian, karya ilmiah, paten
- ✅ **Homebase & Penugasan**: Status homebase, riwayat penugasan

### 🎓 **Profil Mahasiswa Lengkap**
- ✅ **Informasi Personal**: Nama, NIM, jenis kelamin, tempat/tanggal lahir, alamat
- ✅ **Status Akademik**: Aktif, cuti, lulus, DO, semester saat ini
- ✅ **Perguruan Tinggi**: Nama PT, program studi, akreditasi
- ✅ **Riwayat Studi**: Tahun masuk, jalur masuk, semester aktif terakhir
- ✅ **Transkrip Nilai**: Mata kuliah, nilai huruf & angka, SKS, IP per semester
- ✅ **Riwayat Kelas**: Mata kuliah, nama dosen pengajar, kelas/kelompok
- ✅ **Data Kelulusan**: Tanggal lulus, nomor ijazah, IPK, predikat, judul skripsi

### 🏛️ **Database Perguruan Tinggi**
- **Informasi PT**: Nama, status, akreditasi, alamat
- **Program Studi**: Daftar prodi, akreditasi, jenjang
- **Statistik**: Jumlah dosen, mahasiswa, lulusan

---

## 🛠️ **Teknologi & Arsitektur**

### **Frontend**
- **Flutter 3.x**: Cross-platform mobile development
- **Dart**: Programming language
- **Material Design 3**: Modern UI components
- **Custom Widgets**: ctOS-themed components

### **Backend Integration**
- **PDDikti API**: Sumber data utama Kementerian Pendidikan
- **Multi-API Factory**: Integrasi berbagai sumber data
- **HTTP Client**: Networking dengan error handling
- **JSON Parsing**: Robust data processing

### **Architecture Pattern**
- **Clean Architecture**: Separation of concerns
- **Repository Pattern**: Data abstraction layer
- **Factory Pattern**: API service management
- **Singleton Pattern**: State management

---

## 🚀 **Instalasi & Setup**

### **Prerequisites**
```bash
Flutter SDK >= 3.0.0
Dart SDK >= 3.0.0
Android Studio / VS Code
Android Device / Emulator
```

### **Clone Repository**
```bash
git clone https://github.com/el-pablos/DB-Cracker.git
cd DB-Cracker
```

### **Install Dependencies**
```bash
flutter pub get
```

### **Run Application**
```bash
# Debug mode
flutter run

# Release mode
flutter run --release

# Specific device
flutter run -d <device-id>
```

---

## 🎯 **Penggunaan**

### **1. Pencarian Dosen**
1. Buka aplikasi dan pilih "Cari Dosen"
2. Masukkan nama dosen yang ingin dicari
3. Gunakan filter perguruan tinggi jika diperlukan
4. Tap pada hasil untuk melihat detail lengkap

### **2. Pencarian Mahasiswa**
1. Pilih "Cari Mahasiswa" dari menu utama
2. Masukkan nama atau NIM mahasiswa
3. Filter berdasarkan perguruan tinggi atau program studi
4. Akses profil lengkap dengan riwayat akademik

### **3. Database Perguruan Tinggi**
1. Pilih "Database PT" untuk menjelajahi perguruan tinggi
2. Cari berdasarkan nama atau lokasi
3. Lihat detail lengkap termasuk program studi

---

## 🔧 **Konfigurasi**

### **API Configuration**
```dart
// lib/utils/constants.dart
class ApiConstants {
  static const String pddiktiBaseUrl = 'https://api-pddikti.kemdiktisaintek.go.id';
  static const int requestTimeout = 30; // seconds
  static const bool enableMockData = false; // for testing
}
```

### **Theme Customization**
```dart
// lib/utils/constants.dart
class CtOSColors {
  static const Color primary = Color(0xFF00FF41);
  static const Color secondary = Color(0xFF00D4FF);
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1A1A1A);
}
```

---

## 🤝 **Contributing**

Kontribusi sangat diterima! Silakan ikuti langkah berikut:

1. **Fork** repository ini
2. **Create** feature branch (`git checkout -b feature/AmazingFeature`)
3. **Commit** perubahan (`git commit -m 'Add: AmazingFeature'`)
4. **Push** ke branch (`git push origin feature/AmazingFeature`)
5. **Open** Pull Request

### **Commit Convention**
```
add: menambahkan fitur baru
fix: memperbaiki bug
update: memperbarui fitur yang ada
remove: menghapus fitur/file
docs: perubahan dokumentasi
style: perubahan styling/UI
refactor: refactoring code
test: menambahkan/memperbaiki test
```

---

## 📄 **License**

Distributed under the MIT License. See `LICENSE` for more information.

---

## 👨‍💻 **Author**

<div align="center">

**Pablos**
*Full-Stack Developer & Mobile App Specialist*

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/el-pablos)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/pablos)
[![Email](https://img.shields.io/badge/Email-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:yeteprem.end23juni@gmail.com)

*"Building the future, one line of code at a time"*

</div>

---

## 🙏 **Acknowledgments**

- **Kementerian Pendidikan Indonesia** - Untuk API PDDikti
- **Flutter Team** - Framework yang luar biasa
- **Watch Dogs Series** - Inspirasi design ctOS
- **Gojek Design Team** - Referensi responsive layout
- **Open Source Community** - Dukungan dan kontribusi

---

<div align="center">

**⭐ Jika proyek ini membantu, jangan lupa berikan star! ⭐**

*Made with ❤️ by Pablos*

</div>