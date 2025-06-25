class Mahasiswa {
  final String id;
  final String nama;
  final String nim;
  final String namaPt;
  final String singkatanPt;
  final String namaProdi;

  Mahasiswa({
    required this.id,
    required this.nama,
    required this.nim,
    required this.namaPt,
    required this.singkatanPt,
    required this.namaProdi,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    try {
      return Mahasiswa(
        id: _ensureString(json['id']),
        nama: _ensureString(json['nama']),
        nim: _ensureString(json['nim']),
        namaPt: _ensureString(json['nama_pt']),
        singkatanPt: _ensureString(json['singkatan_pt']),
        namaProdi: _ensureString(json['nama_prodi']),
      );
    } catch (e) {
      print('Error parsing Mahasiswa: $e');
      print('JSON data: $json');
      throw Exception('Failed to parse Mahasiswa data: $e');
    }
  }

  // Helper method to ensure all values are strings
  static String _ensureString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

class MahasiswaDetail {
  // Profil Mahasiswa Dasar
  final String id;
  final String nama;
  final String nim;
  final String jenisKelamin;
  final String statusSaatIni;
  final String semesterSaatIni;
  final String tempatLahir;
  final String tanggalLahir;
  final String agama;
  final String alamat;

  // Perguruan Tinggi dan Program Studi
  final String namaPt;
  final String kodePt;
  final String idPt;
  final String prodi;
  final String kodeProdi;
  final String idSms;
  final String jenjang;
  final String akreditasiProdi;

  // Riwayat Studi
  final String jenisDaftar;
  final String jalurMasuk;
  final String tahunMasuk;
  final String tahunLulus;
  final String semesterAktifTerakhir;
  final String statusAkhir;

  // Data Kelulusan dan Ijazah
  final String tanggalLulus;
  final String nomorIjazah;
  final String ipk;
  final String totalSks;
  final String predikatKelulusan;
  final String judulSkripsi;

  // Riwayat detail
  final List<MahasiswaRiwayatSemester> riwayatSemester;
  final List<MahasiswaNilai> riwayatNilai;
  final List<MahasiswaKelas> riwayatKelas;

  MahasiswaDetail({
    required this.id,
    required this.nama,
    required this.nim,
    required this.jenisKelamin,
    required this.statusSaatIni,
    this.semesterSaatIni = '',
    this.tempatLahir = '',
    this.tanggalLahir = '',
    this.agama = '',
    this.alamat = '',
    required this.namaPt,
    this.kodePt = '',
    this.idPt = '',
    required this.prodi,
    this.kodeProdi = '',
    this.idSms = '',
    this.jenjang = '',
    this.akreditasiProdi = '',
    this.jenisDaftar = '',
    this.jalurMasuk = '',
    this.tahunMasuk = '',
    this.tahunLulus = '',
    this.semesterAktifTerakhir = '',
    this.statusAkhir = '',
    this.tanggalLulus = '',
    this.nomorIjazah = '',
    this.ipk = '',
    this.totalSks = '',
    this.predikatKelulusan = '',
    this.judulSkripsi = '',
    this.riwayatSemester = const [],
    this.riwayatNilai = const [],
    this.riwayatKelas = const [],
  });

  factory MahasiswaDetail.fromJson(Map<String, dynamic> json) {
    try {
      // Print keys for debugging
      print('Keys in MahasiswaDetail.fromJson: ${json.keys.toList()}');

      // More flexible field handling
      // Use alternative field names if primary ones don't exist
      return MahasiswaDetail(
        id: _ensureString(
            json['id'] ?? json['id_mahasiswa'] ?? json['mahasiswa_id'] ?? ''),
        namaPt: _ensureString(json['nama_pt'] ??
            json['pt_nama'] ??
            json['perguruan_tinggi'] ??
            ''),
        kodePt: _ensureString(json['kode_pt'] ?? json['pt_kode'] ?? ''),
        kodeProdi:
            _ensureString(json['kode_prodi'] ?? json['prodi_kode'] ?? ''),
        prodi: _ensureString(
            json['prodi'] ?? json['nama_prodi'] ?? json['program_studi'] ?? ''),
        nama: _ensureString(json['nama'] ?? json['nama_mahasiswa'] ?? ''),
        nim: _ensureString(json['nim'] ??
            json['nomor_induk'] ??
            json['nomor_mahasiswa'] ??
            ''),
        jenisDaftar: _ensureString(
            json['jenis_daftar'] ?? json['jalur_daftar'] ?? 'Reguler'),
        idPt: _ensureString(json['id_pt'] ?? json['pt_id'] ?? ''),
        idSms: _ensureString(json['id_sms'] ?? json['sms_id'] ?? ''),
        jenisKelamin:
            _ensureString(json['jenis_kelamin'] ?? json['gender'] ?? ''),
        jenjang:
            _ensureString(json['jenjang'] ?? json['jenjang_pendidikan'] ?? ''),
        statusSaatIni: _ensureString(json['status_saat_ini'] ??
            json['status'] ??
            json['status_mahasiswa'] ??
            'Aktif'),
        tahunMasuk:
            _ensureString(json['tahun_masuk'] ?? json['angkatan'] ?? ''),
      );
    } catch (e) {
      print('Error parsing MahasiswaDetail: $e');
      print('JSON data: $json');

      // Create a minimal valid object instead of throwing an exception
      return MahasiswaDetail(
        id: _ensureString(json['id'] ?? ''),
        namaPt: _ensureString(json['nama_pt'] ?? ''),
        kodePt: _ensureString(json['kode_pt'] ?? ''),
        kodeProdi: _ensureString(json['kode_prodi'] ?? ''),
        prodi: _ensureString(json['prodi'] ?? ''),
        nama: _ensureString(json['nama'] ?? 'Data Tidak Tersedia'),
        nim: _ensureString(json['nim'] ?? 'N/A'),
        jenisDaftar: 'Reguler',
        idPt: _ensureString(json['id_pt'] ?? ''),
        idSms: _ensureString(json['id_sms'] ?? ''),
        jenisKelamin: _ensureString(json['jenis_kelamin'] ?? 'N/A'),
        jenjang: _ensureString(json['jenjang'] ?? 'N/A'),
        statusSaatIni: 'N/A',
        tahunMasuk: _ensureString(json['tahun_masuk'] ?? 'N/A'),
      );
    }
  }

  // Helper method to ensure all values are strings
  static String _ensureString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

class MahasiswaRiwayatSemester {
  final String idSms;
  final String namaSemester;
  final String statusSemester;
  final String ips;
  final String ipk;
  final String sksTotal;
  final String sksDiambil;
  final String sksLulus;

  MahasiswaRiwayatSemester({
    required this.idSms,
    required this.namaSemester,
    required this.statusSemester,
    this.ips = '',
    this.ipk = '',
    this.sksTotal = '',
    this.sksDiambil = '',
    this.sksLulus = '',
  });

  factory MahasiswaRiwayatSemester.fromJson(Map<String, dynamic> json) {
    try {
      return MahasiswaRiwayatSemester(
        idSms: _ensureString(json['id_sms']),
        namaSemester: _ensureString(json['nama_semester']),
        statusSemester: _ensureString(json['status_semester']),
        ips: _ensureString(json['ips']),
        ipk: _ensureString(json['ipk']),
        sksTotal: _ensureString(json['sks_total']),
        sksDiambil: _ensureString(json['sks_diambil']),
        sksLulus: _ensureString(json['sks_lulus']),
      );
    } catch (e) {
      print('Error parsing MahasiswaRiwayatSemester: $e');
      return MahasiswaRiwayatSemester(
        idSms: '',
        namaSemester: 'Error: $e',
        statusSemester: '',
      );
    }
  }

  static String _ensureString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

class MahasiswaNilai {
  final String idSms;
  final String kodeMatkul;
  final String namaMatkul;
  final String sks;
  final String nilaiHuruf;
  final String nilaiAngka;
  final String namaSemester;

  MahasiswaNilai({
    required this.idSms,
    required this.kodeMatkul,
    required this.namaMatkul,
    required this.sks,
    required this.nilaiHuruf,
    required this.nilaiAngka,
    required this.namaSemester,
  });

  factory MahasiswaNilai.fromJson(Map<String, dynamic> json) {
    try {
      return MahasiswaNilai(
        idSms: _ensureString(json['id_sms']),
        kodeMatkul: _ensureString(json['kode_matkul']),
        namaMatkul: _ensureString(json['nama_matkul']),
        sks: _ensureString(json['sks']),
        nilaiHuruf: _ensureString(json['nilai_huruf']),
        nilaiAngka: _ensureString(json['nilai_angka']),
        namaSemester: _ensureString(json['nama_semester']),
      );
    } catch (e) {
      print('Error parsing MahasiswaNilai: $e');
      return MahasiswaNilai(
        idSms: '',
        kodeMatkul: '',
        namaMatkul: 'Error: $e',
        sks: '',
        nilaiHuruf: '',
        nilaiAngka: '',
        namaSemester: '',
      );
    }
  }

  static String _ensureString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

class MahasiswaKelas {
  final String idSms;
  final String kodeMatkul;
  final String namaMatkul;
  final String namaKelas;
  final String namaDosen;
  final String namaSemester;

  MahasiswaKelas({
    required this.idSms,
    required this.kodeMatkul,
    required this.namaMatkul,
    required this.namaKelas,
    required this.namaDosen,
    required this.namaSemester,
  });

  factory MahasiswaKelas.fromJson(Map<String, dynamic> json) {
    try {
      return MahasiswaKelas(
        idSms: _ensureString(json['id_sms']),
        kodeMatkul: _ensureString(json['kode_matkul']),
        namaMatkul: _ensureString(json['nama_matkul']),
        namaKelas: _ensureString(json['nama_kelas']),
        namaDosen: _ensureString(json['nama_dosen']),
        namaSemester: _ensureString(json['nama_semester']),
      );
    } catch (e) {
      print('Error parsing MahasiswaKelas: $e');
      return MahasiswaKelas(
        idSms: '',
        kodeMatkul: '',
        namaMatkul: 'Error: $e',
        namaKelas: '',
        namaDosen: '',
        namaSemester: '',
      );
    }
  }

  static String _ensureString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}
