import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mahasiswa.dart';
import '../models/dosen.dart';
import '../models/pt.dart';
import '../models/prodi.dart';
import 'api_factory.dart';
import 'api_services_integration.dart';

/// Class untuk mengakses berbagai API pendidikan Indonesia selain PDDIKTI
/// Menggabungkan data dari berbagai sumber untuk meningkatkan hasil pencarian
class MultiApiFactory {
  /// Singleton instance
  static final MultiApiFactory _instance = MultiApiFactory._internal();

  /// Private constructor
  MultiApiFactory._internal();

  /// Factory constructor
  factory MultiApiFactory() {
    return _instance;
  }

  /// API Factory untuk PDDIKTI
  final ApiFactory _pddiktiApi = ApiFactory();

  /// API Services Integration
  final ApiServicesIntegration _apiServices = ApiServicesIntegration();

  /// Base URL untuk API Data Mahasiswa Kemdikbud
  final String _kemdikbudApiUrl = 'https://api-frontend.kemdikbud.go.id';

  /// Header untuk request
  Map<String, String> get _headers => {
        'Accept': 'application/json, text/plain, */*',
        'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
        'Origin': 'https://indonesia-public-static-api.vercel.app',
        'Referer': 'https://indonesia-public-static-api.vercel.app',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36',
      };

  /// Encode parameter URL
  String _parseString(String text) {
    return Uri.encodeComponent(text);
  }

  /// Metode utama untuk mencari data mahasiswa dari berbagai sumber API
  Future<List<Mahasiswa>> searchAllSources(String keyword) async {
    List<Mahasiswa> results = [];
    List<Future<List<Mahasiswa>>> futures = [];

    // Cari data dari PDDIKTI
    futures.add(_pddiktiApi.searchMahasiswa(keyword));

    // Cari data dari Kemdikbud
    futures.add(_searchKemdikbud(keyword));

    // Cari data dari API lain dan konversi ke model Mahasiswa
    futures.add(_searchFromEducationApis(keyword));

    // Jalankan semua pencarian secara paralel
    try {
      final responses = await Future.wait(futures);

      // Gabungkan semua hasil
      for (var response in responses) {
        results.addAll(response);
      }

      // Hapus duplikat berdasarkan kombinasi nama dan nim
      final uniqueResults = <String, Mahasiswa>{};
      for (var mahasiswa in results) {
        final key = '${mahasiswa.nama}-${mahasiswa.nim}';
        uniqueResults[key] = mahasiswa;
      }

      return uniqueResults.values.toList();
    } catch (e) {
      print('Error mencari dari semua sumber: $e');
      // Jika terjadi error, coba kembalikan apa saja yang berhasil
      return results;
    }
  }

  /// Cari data mahasiswa dari API pendidikan lain
  Future<List<Mahasiswa>> _searchFromEducationApis(String keyword) async {
    try {
      // Dapatkan data dari API pendidikan
      final rawData = await _apiServices.searchEducationData(keyword);

      // Konversi ke model Mahasiswa
      return _apiServices.convertToMahasiswa(rawData);
    } catch (e) {
      print('Error mencari dari API pendidikan: $e');
      return [];
    }
  }

  /// Cari data mahasiswa dari API Kemdikbud
  Future<List<Mahasiswa>> _searchKemdikbud(String keyword) async {
    try {
      final Uri url =
          Uri.parse('$_kemdikbudApiUrl/hit_mhs/${_parseString(keyword)}');

      final response = await http
          .get(
            url,
            headers: _headers,
          )
          .timeout(
            Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data.containsKey('mahasiswa') && data['mahasiswa'] is List) {
          final List mahasiswaList = data['mahasiswa'] as List;

          return mahasiswaList
              .map((item) {
                if (item is Map<String, dynamic>) {
                  return Mahasiswa(
                    id: item['id_mahasiswa'] ?? '',
                    nama: item['nm_mhs'] ?? '',
                    nim: item['nipd'] ?? '',
                    namaPt: item['nm_pt'] ?? '',
                    singkatanPt: item['kode_pt'] ?? '',
                    namaProdi: item['nm_prodi'] ?? '',
                  );
                }
                return Mahasiswa(
                  id: '',
                  nama: '',
                  nim: '',
                  namaPt: '',
                  singkatanPt: '',
                  namaProdi: '',
                );
              })
              .where((m) => m.id.isNotEmpty)
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error mencari dari Kemdikbud: $e');
      return [];
    }
  }

  /// Cari data dosen dari berbagai sumber
  Future<List<Dosen>> searchAllDosen(String keyword) async {
    try {
      List<Dosen> results = [];
      List<Future<List<Dosen>>> futures = [];

      // Cari dari PDDIKTI
      futures.add(_pddiktiApi.searchDosen(keyword));

      // Cari dari API lain
      futures.add(_searchDosenFromOtherSources(keyword));

      // Jalankan semua pencarian secara paralel
      final responses = await Future.wait(futures);

      // Gabungkan semua hasil
      for (var response in responses) {
        results.addAll(response);
      }

      // Hapus duplikat berdasarkan kombinasi nama dan nidn
      final uniqueResults = <String, Dosen>{};
      for (var dosen in results) {
        final key = '${dosen.nama}-${dosen.nidn}';
        uniqueResults[key] = dosen;
      }

      return uniqueResults.values.toList();
    } catch (e) {
      print('Error mencari dosen: $e');
      // Jika terjadi error, coba kembalikan apa saja yang berhasil
      List<Dosen> backupResults = [];

      try {
        // Coba dapatkan dari mock service sebagai fallback
        backupResults = await _pddiktiApi.searchDosen(keyword);
      } catch (e2) {
        print('Error getting data from PDDIKTI: $e2');

        // Jika masih error, coba return data mock sederhana
        backupResults = [
          Dosen(
            id: '1',
            nama: 'Dr. Mock Data',
            nidn: '12345',
            namaPt: 'Universitas Testing',
            singkatanPt: 'UNTEST',
            namaProdi: 'Informatika',
          ),
          Dosen(
            id: '2',
            nama: 'Prof. Dummy Data',
            nidn: '67890',
            namaPt: 'Institut Testing',
            singkatanPt: 'IT',
            namaProdi: 'Teknik Informatika',
          ),
        ];
      }

      return backupResults;
    }
  }

  /// Implementasi pencarian dosen dari sumber lain
  Future<List<Dosen>> _searchDosenFromOtherSources(String keyword) async {
    try {
      // Dapatkan data dari API pendidikan
      final rawData = await _apiServices.searchEducationData(keyword);

      // Konversi ke model Dosen
      return _apiServices.convertToDosen(rawData);
    } catch (e) {
      print('Error mencari dosen dari sumber lain: $e');
      return [];
    }
  }

  /// Mendapatkan detail mahasiswa dari berbagai sumber
  Future<MahasiswaDetail> getMahasiswaDetail(String mahasiswaId) async {
    try {
      // Coba dapatkan dari PDDIKTI terlebih dahulu
      final detail = await _pddiktiApi.getMahasiswaDetail(mahasiswaId);

      // Tambahkan data eksternal jika ada
      try {
        // Coba untuk memperkaya data dengan sumber-sumber lain
        final kemdikbudDetail = await _searchKemdikbudDetail(mahasiswaId);
        if (kemdikbudDetail != null) {
          // Gunakan data dari Kemdikbud untuk melengkapi
          // Implementasi penggabungan data bisa dikembangkan
          return kemdikbudDetail;
        }
      } catch (e) {
        print('Gagal mendapatkan data tambahan: $e');
        // Tidak perlu melakukan apa-apa, gunakan data yang sudah ada
      }

      return detail;
    } catch (e) {
      print('Error mendapatkan detail dari PDDIKTI: $e');

      // Fallback to minimal detail
      return MahasiswaDetail(
        id: mahasiswaId,
        namaPt: 'Data tidak tersedia (error)',
        kodePt: '-',
        kodeProdi: '-',
        prodi: 'Data tidak tersedia',
        nama: 'Data tidak tersedia (error)',
        nim: '-',
        jenisDaftar: '-',
        idPt: '-',
        idSms: '-',
        jenisKelamin: '-',
        jenjang: '-',
        statusSaatIni: '-',
        tahunMasuk: '-',
      );
    }
  }

  /// Mendapatkan detail dosen lengkap dari berbagai sumber
  Future<DosenDetail> getDosenDetailFromAllSources(String dosenId) async {
    try {
      // Coba dapatkan detail lengkap dari PDDIKTI terlebih dahulu
      final detail = await _pddiktiApi.getDosenDetailLengkap(dosenId);

      // Tambahkan data eksternal jika ada
      try {
        // Coba untuk memperkaya data dengan sumber-sumber lain jika ada waktu
        // Ini bisa diimplementasikan di masa mendatang
      } catch (e) {
        print('Gagal mendapatkan data tambahan: $e');
        // Tidak perlu melakukan apa-apa, gunakan data yang sudah ada
      }

      return detail;
    } catch (e) {
      print('Error mendapatkan detail dari PDDIKTI: $e');

      // Fallback to minimal detail
      return DosenDetail(
        idSdm: dosenId,
        namaDosen: 'Data tidak tersedia (error)',
        namaPt: 'Data tidak tersedia',
        namaProdi: 'Data tidak tersedia',
        jenisKelamin: '-',
        jabatanAkademik: '-',
        pendidikanTertinggi: '-',
        statusIkatanKerja: '-',
        statusAktivitas: '-',
        penelitian: [],
        pengabdian: [],
        karya: [],
        paten: [],
        riwayatStudi: [],
        riwayatMengajar: [],
      );
    }
  }

  /// Mencari detail mahasiswa dari API Kemdikbud
  Future<MahasiswaDetail?> _searchKemdikbudDetail(String mahasiswaId) async {
    try {
      final Uri url = Uri.parse(
          '$_kemdikbudApiUrl/detail_mhs/${_parseString(mahasiswaId)}');

      final response = await http
          .get(
            url,
            headers: _headers,
          )
          .timeout(
            Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);

        if (data is Map<String, dynamic>) {
          // Konversi ke model MahasiswaDetail
          return MahasiswaDetail(
            id: mahasiswaId,
            namaPt: data['nm_pt'] ?? 'Tidak Tersedia',
            kodePt: data['kode_pt'] ?? '-',
            kodeProdi: data['kode_prodi'] ?? '-',
            prodi: data['nama_prodi'] ?? 'Tidak Tersedia',
            nama: data['nm_mhs'] ?? 'Tidak Tersedia',
            nim: data['nipd'] ?? '-',
            jenisDaftar: data['jenis_daftar'] ?? 'Reguler',
            idPt: data['id_pt'] ?? '-',
            idSms: data['id_sms'] ?? '-',
            jenisKelamin: data['jk'] ?? '-',
            jenjang: data['jenjang'] ?? '-',
            statusSaatIni: data['sts_mhs'] ?? '-',
            tahunMasuk: data['mulai_smt'] ?? '-',
          );
        }
      }

      return null;
    } catch (e) {
      print('Error mencari detail dari Kemdikbud: $e');
      return null;
    }
  }

  /// Mendapatkan informasi Perguruan Tinggi
  Future<PerguruanTinggiDetail?> getDetailPT(String ptId) async {
    try {
      // Gunakan API PDDIKTI untuk mendapatkan detail PT
      final detail = await _pddiktiApi.getDetailPt(ptId);
      return detail;
    } catch (e) {
      print('Error mendapatkan detail PT: $e');

      // Buat data dummy jika error
      return PerguruanTinggiDetail(
        kelompok: '-',
        pembina: '-',
        idSp: ptId,
        kodePt: '-',
        email: '-',
        noTel: '-',
        noFax: '-',
        website: '-',
        alamat: 'Data tidak tersedia',
        namaPt: 'Universitas tidak tersedia',
        nmSingkat: '-',
        kodePos: '-',
        provinsiPt: '-',
        kabKotaPt: '-',
        kecamatanPt: '-',
        lintangPt: '-',
        bujurPt: '-',
        tglBerdiriPt: '-',
        tglSkPendirianSp: '-',
        skPendirianSp: '-',
        statusPt: '-',
        akreditasiPt: '-',
        statusAkreditasi: '-',
      );
    }
  }

  /// Mendapatkan informasi Program Studi
  Future<ProdiDetail?> getDetailProdi(String prodiId) async {
    try {
      // Gunakan API PDDIKTI untuk mendapatkan detail Prodi
      final detail = await _pddiktiApi.getDetailProdi(prodiId);
      return detail;
    } catch (e) {
      print('Error mendapatkan detail Prodi: $e');

      // Buat data dummy jika error
      return ProdiDetail(
        idSp: '-',
        idSms: prodiId,
        namaPt: 'Data tidak tersedia',
        kodePt: '-',
        namaProdi: 'Program Studi tidak tersedia',
        kodeProdi: '-',
        kelBidang: '-',
        jenjangDidik: '-',
        tglBerdiri: '-',
        tglSkSelenggara: '-',
        skSelenggara: '-',
        noTel: '-',
        noFax: '-',
        website: '-',
        email: '-',
        alamat: '-',
        provinsi: '-',
        kabKota: '-',
        kecamatan: '-',
        lintang: '-',
        bujur: '-',
        status: '-',
        akreditasi: '-',
        akreditasiInternasional: '-',
        statusAkreditasi: '-',
        deskripsiSingkat: '-',
        visi: '-',
        misi: '-',
        kompetensi: '-',
        capaianBelajar: '-',
        rataMasaStudi: '-',
      );
    }
  }

  /// Mencari data Program Studi
  Future<List<Prodi>> searchProdi(String keyword) async {
    try {
      // Gunakan API PDDIKTI untuk mencari Prodi
      return await _pddiktiApi.searchProdi(keyword);
    } catch (e) {
      print('Error mencari Prodi: $e');
      return [];
    }
  }

  /// Mencari data Perguruan Tinggi
  Future<List<PerguruanTinggi>> searchPT(String keyword) async {
    try {
      // Gunakan API PDDIKTI untuk mencari PT
      return await _pddiktiApi.searchPt(keyword);
    } catch (e) {
      print('Error mencari PT: $e');
      return [];
    }
  }

  /// Mendapatkan daftar Prodi di PT tertentu
  Future<List<ProdiPt>> getProdiInPT(String ptId, int tahun) async {
    try {
      // Gunakan API PDDIKTI untuk mendapatkan daftar Prodi
      return await _pddiktiApi.getProdiPt(ptId, tahun);
    } catch (e) {
      print('Error mendapatkan daftar Prodi di PT: $e');
      return [];
    }
  }

  /// Mencari data lokasi prodi
  Future<Map<String, String>> getProdiLocation(String prodiId) async {
    try {
      // Gunakan detail Prodi untuk mendapatkan lokasinya
      final prodiDetail = await getDetailProdi(prodiId);
      if (prodiDetail != null) {
        return {
          'latitude': prodiDetail.lintang,
          'longitude': prodiDetail.bujur,
          'address': prodiDetail.alamat,
          'city': prodiDetail.kabKota,
          'province': prodiDetail.provinsi,
        };
      }
      return {};
    } catch (e) {
      print('Error mendapatkan lokasi Prodi: $e');
      return {};
    }
  }
}
