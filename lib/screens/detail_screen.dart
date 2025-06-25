import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../api/multi_api_factory.dart';
import '../api/api_services_integration.dart';
import '../models/mahasiswa.dart';
import '../widgets/hacker_loading_indicator.dart';
import '../widgets/console_text.dart';
import '../widgets/terminal_window.dart';
import '../utils/constants.dart';

class DetailScreen extends StatefulWidget {
  final String mahasiswaId;
  final String subjectName;

  const DetailScreen({
    Key? key,
    required this.mahasiswaId,
    required this.subjectName,
  }) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late Future<MahasiswaDetail> _mahasiswaFuture;
  bool _isDecrypting = true;
  List<String> _consoleMessages = [];
  final Random _random = Random();
  Timer? _decryptTimer;
  late AnimationController _animationController;

  // Tab yang aktif
  int _activeTabIndex = 0;

  // Tambahkan instance MultiApiFactory
  late MultiApiFactory _multiApiFactory;

  // Flag untuk menampilkan informasi eksternal
  bool _showExternalInfo = false;
  Map<String, dynamic> _externalData = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animationController.repeat(reverse: true);

    // Inisialisasi MultiApiFactory
    _multiApiFactory = MultiApiFactory();

    // Mulai sequence dekripsi
    _simulateDecryption();

    // Coba dapatkan data tambahan
    _fetchExternalData();
  }

  void _simulateDecryption() {
    setState(() {
      _consoleMessages = [];
      _isDecrypting = true;
    });

    _addConsoleMessageWithDelay("AKSES DATABASE AMAN...", 300);
    _addConsoleMessageWithDelay("MENCARI SUBJEK: ${widget.subjectName}", 800);
    _addConsoleMessageWithDelay("DEKRIPSI DATA PRIBADI...", 1400);
    _addConsoleMessageWithDelay("MELEWATI ENKRIPSI...", 2000);
    _addConsoleMessageWithDelay("EKSTRAKSI CATATAN INSTITUSI...", 2600);
    _addConsoleMessageWithDelay("MEMBERSIHKAN DATA...", 3200);
    _addConsoleMessageWithDelay(
        "KORELASI DATA DENGAN DATABASE EKSTERNAL...", 3800); // Pesan baru

    // Fetch data setelah simulasi
    _decryptTimer = Timer(const Duration(milliseconds: 4000), () {
      _fetchMahasiswaDetail();
    });
  }

  void _addConsoleMessageWithDelay(String message, int delay) {
    Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        setState(() {
          _consoleMessages.add(message);
        });
      }
    });
  }

  void _fetchMahasiswaDetail() {
    // Gunakan MultiApiFactory
    _mahasiswaFuture = _multiApiFactory.getMahasiswaDetail(widget.mahasiswaId);

    _mahasiswaFuture.then((_) {
      setState(() {
        _isDecrypting = false;
      });
      _addConsoleMessageWithDelay("EKSTRAKSI DATA SELESAI", 300);
      _addConsoleMessageWithDelay("AKSES DIBERIKAN", 600);
    }).catchError((error) {
      setState(() {
        _isDecrypting = false;
      });
      _addConsoleMessageWithDelay("ERROR: EKSTRAKSI DATA GAGAL", 300);
      _addConsoleMessageWithDelay("AKSES DITOLAK", 600);
    });
  }

  // Metode untuk mengambil data tambahan dari API eksternal
  Future<void> _fetchExternalData() async {
    try {
      // Delay untuk simulasi pencarian
      await Future.delayed(Duration(seconds: 2));

      // Coba cari di Wikipedia
      final apiServices = ApiServicesIntegration();
      final wikipediaData =
          await apiServices.searchWikipedia(widget.subjectName);

      if (wikipediaData.isNotEmpty) {
        setState(() {
          _externalData = wikipediaData;
          _showExternalInfo = true;
        });
      }
    } catch (e) {
      print('Error fetching external data: $e');
    }
  }

  @override
  void dispose() {
    _decryptTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  String _getRandomHexValue(int length) {
    const chars = '0123456789ABCDEF';
    return List.generate(
      length,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: HackerColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _animationController.value > 0.5
                        ? HackerColors.primary
                        : HackerColors.accent,
                  ),
                );
              },
            ),
            const Text(
              AppStrings.detailTitle,
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
                color: HackerColors.primary,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: HackerColors.surface,
        iconTheme: const IconThemeData(
          color: HackerColors.primary,
        ),
        actions: [
          // Toggle untuk menampilkan info eksternal
          IconButton(
            icon: Icon(
              _showExternalInfo ? Icons.visibility : Icons.visibility_off,
              color: HackerColors.primary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _showExternalInfo = !_showExternalInfo;
              });
            },
          ),
        ],
      ),
      body: Container(
        color: HackerColors.background,
        child: Column(
          children: [
            Container(
              color: HackerColors.surface.withOpacity(0.7),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _random.nextBool()
                          ? HackerColors.primary
                          : HackerColors.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RAHASIA - LEVEL AKSES 3 - SUBJEK: ${widget.subjectName}',
                    style: const TextStyle(
                      color: HackerColors.highlight,
                      fontFamily: 'Courier',
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isDecrypting
                  ? TerminalWindow(
                      title: "DEKRIPSI DATA",
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _consoleMessages.length,
                              itemBuilder: (context, index) {
                                bool isSuccess = index ==
                                        _consoleMessages.length - 1 &&
                                    _consoleMessages[index].contains("SELESAI");
                                bool isError = index ==
                                        _consoleMessages.length - 1 &&
                                    _consoleMessages[index].contains("ERROR");

                                return ConsoleText(
                                  text: _consoleMessages[index],
                                  isSuccess: isSuccess,
                                  isError: isError,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : FutureBuilder<MahasiswaDetail>(
                      future: _mahasiswaFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(child: HackerLoadingIndicator());
                        } else if (snapshot.hasError) {
                          return TerminalWindow(
                            title: "ERROR",
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: HackerColors.error,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '${AppStrings.errorLoadingData} ${snapshot.error}',
                                      style: const TextStyle(
                                        color: HackerColors.error,
                                        fontSize: 16,
                                        fontFamily: 'Courier',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: _simulateDecryption,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: HackerColors.surface,
                                        foregroundColor: HackerColors.primary,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        side: const BorderSide(
                                            color: HackerColors.primary),
                                      ),
                                      child: const Text(
                                        AppStrings.retry,
                                        style: TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(
                            child: Text(
                              AppStrings.noDataAvailable,
                              style: TextStyle(
                                color: HackerColors.error,
                                fontFamily: 'Courier',
                                fontSize: 16,
                              ),
                            ),
                          );
                        }

                        final mahasiswa = snapshot.data!;
                        return _buildHackerDetailView(mahasiswa);
                      },
                    ),
            ),
            Container(
              color: HackerColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _random.nextBool()
                              ? HackerColors.primary
                              : HackerColors.accent,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'KUNCI: ${_getRandomHexValue(8)}-${_getRandomHexValue(4)}-${_getRandomHexValue(4)}',
                        style: const TextStyle(
                          color: HackerColors.text,
                          fontSize: 10,
                          fontFamily: 'Courier',
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                  const Text(
                    'BY: TAMAENGS',
                    style: TextStyle(
                      color: HackerColors.text,
                      fontSize: 10,
                      fontFamily: 'Courier',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHackerDetailView(MahasiswaDetail mahasiswa) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profile Card
          _buildProfileCard(mahasiswa),
          const SizedBox(height: 16),

          // Tab Navigation
          _buildTabNavigation(),
          const SizedBox(height: 16),

          // Tab Content
          _buildTabContent(mahasiswa),
        ],
      ),
    );
  }

  Widget _buildProfileCard(MahasiswaDetail mahasiswa) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HackerColors.surface,
        border: Border.all(color: HackerColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: HackerColors.primary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar dan Nama
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: HackerColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: HackerColors.primary, width: 2),
                ),
                child: Icon(
                  Icons.school,
                  size: 40,
                  color: HackerColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mahasiswa.nama,
                      style: const TextStyle(
                        color: HackerColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (mahasiswa.nim.isNotEmpty)
                      Text(
                        'NIM: ${mahasiswa.nim}',
                        style: const TextStyle(
                          color: HackerColors.accent,
                          fontSize: 14,
                          fontFamily: 'Courier',
                        ),
                      ),
                    if (mahasiswa.statusSaatIni.isNotEmpty)
                      Text(
                        mahasiswa.statusSaatIni,
                        style: const TextStyle(
                          color: HackerColors.highlight,
                          fontSize: 14,
                          fontFamily: 'Courier',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Status Indicators
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip('Status', mahasiswa.statusSaatIni),
              _buildStatusChip('Jenjang', mahasiswa.jenjang),
              if (mahasiswa.tahunMasuk.isNotEmpty)
                _buildStatusChip('Tahun Masuk', mahasiswa.tahunMasuk),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HackerColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: HackerColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: HackerColors.primary,
          fontSize: 12,
          fontFamily: 'Courier',
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    final tabs = [
      'PROFIL',
      'AKADEMIK',
      'TRANSKRIP',
      'KELULUSAN',
    ];

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: HackerColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isActive = _activeTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTabIndex = index),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isActive ? HackerColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isActive
                          ? HackerColors.background
                          : HackerColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(MahasiswaDetail mahasiswa) {
    switch (_activeTabIndex) {
      case 0:
        return _buildProfilTab(mahasiswa);
      case 1:
        return _buildAkademikTab(mahasiswa);
      case 2:
        return _buildTranskripTab(mahasiswa);
      case 3:
        return _buildKelulusanTab(mahasiswa);
      default:
        return _buildProfilTab(mahasiswa);
    }
  }

  Widget _buildProfilTab(MahasiswaDetail mahasiswa) {
    return Column(
      children: [
        _buildInfoCard('INFORMASI PERSONAL', [
          _buildInfoRow('Nama Lengkap', mahasiswa.nama),
          _buildInfoRow('NIM', mahasiswa.nim),
          _buildInfoRow('Jenis Kelamin', mahasiswa.jenisKelamin),
          _buildInfoRow('Tempat Lahir', mahasiswa.tempatLahir),
          _buildInfoRow('Tanggal Lahir', mahasiswa.tanggalLahir),
          _buildInfoRow('Agama', mahasiswa.agama),
          _buildInfoRow('Alamat', mahasiswa.alamat),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('STATUS AKADEMIK', [
          _buildInfoRow('Status Saat Ini', mahasiswa.statusSaatIni),
          _buildInfoRow('Tahun Masuk', mahasiswa.tahunMasuk),
          _buildInfoRow('Jenis Daftar', mahasiswa.jenisDaftar),
          _buildInfoRow('Semester Saat Ini', mahasiswa.semesterSaatIni),
          _buildInfoRow(
              'Semester Aktif Terakhir', mahasiswa.semesterAktifTerakhir),
          _buildInfoRow('Status Akhir', mahasiswa.statusAkhir),
        ]),
      ],
    );
  }

  Widget _buildAkademikTab(MahasiswaDetail mahasiswa) {
    return Column(
      children: [
        _buildInfoCard('PERGURUAN TINGGI', [
          _buildInfoRow('Nama PT', mahasiswa.namaPt),
          _buildInfoRow('Kode PT', mahasiswa.kodePt),
          _buildInfoRow('ID PT', mahasiswa.idPt),
          _buildInfoRow('Program Studi', mahasiswa.prodi),
          _buildInfoRow('Kode Prodi', mahasiswa.kodeProdi),
          _buildInfoRow('ID SMS', mahasiswa.idSms),
          _buildInfoRow('Jenjang', mahasiswa.jenjang),
          _buildInfoRow('Akreditasi Prodi', mahasiswa.akreditasiProdi),
        ]),
        const SizedBox(height: 16),
        if (mahasiswa.riwayatKelas.isNotEmpty) ...[
          _buildListCard(
              'RIWAYAT KELAS',
              mahasiswa.riwayatKelas
                  .map((kelas) => _buildRiwayatKelasItem(kelas))
                  .toList()),
          const SizedBox(height: 16),
        ],
        if (mahasiswa.riwayatKelas.isEmpty)
          _buildEmptyState('Belum ada data riwayat kelas'),
      ],
    );
  }

  Widget _buildTranskripTab(MahasiswaDetail mahasiswa) {
    return Column(
      children: [
        if (mahasiswa.riwayatNilai.isNotEmpty) ...[
          _buildListCard(
              'TRANSKRIP NILAI',
              mahasiswa.riwayatNilai
                  .map((nilai) => _buildTranskripItem(nilai))
                  .toList()),
          const SizedBox(height: 16),
        ],
        if (mahasiswa.riwayatSemester.isNotEmpty) ...[
          _buildListCard(
              'IP PER SEMESTER',
              mahasiswa.riwayatSemester
                  .map((ip) => _buildIpSemesterItem(ip))
                  .toList()),
        ],
        if (mahasiswa.riwayatNilai.isEmpty && mahasiswa.riwayatSemester.isEmpty)
          _buildEmptyState('Belum ada data transkrip'),
      ],
    );
  }

  Widget _buildKelulusanTab(MahasiswaDetail mahasiswa) {
    return Column(
      children: [
        _buildInfoCard('DATA KELULUSAN', [
          _buildInfoRow('Tanggal Lulus', mahasiswa.tanggalLulus),
          _buildInfoRow('Tahun Lulus', mahasiswa.tahunLulus),
          _buildInfoRow('Nomor Ijazah', mahasiswa.nomorIjazah),
          _buildInfoRow('IPK', mahasiswa.ipk),
          _buildInfoRow('Total SKS', mahasiswa.totalSks),
          _buildInfoRow('Predikat Kelulusan', mahasiswa.predikatKelulusan),
          _buildInfoRow('Judul Skripsi', mahasiswa.judulSkripsi),
        ]),
        const SizedBox(height: 16),
        if (mahasiswa.tanggalLulus.isEmpty)
          _buildEmptyState('Belum ada data kelulusan'),
      ],
    );
  }

  // Helper Methods
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HackerColors.surface,
        border: Border.all(color: HackerColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: HackerColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HackerColors.surface,
        border: Border.all(color: HackerColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: HackerColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: HackerColors.accent,
                fontSize: 14,
                fontFamily: 'Courier',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: HackerColors.text,
                fontSize: 14,
                fontFamily: 'Courier',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatKelasItem(MahasiswaKelas kelas) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HackerColors.background,
        border: Border.all(color: HackerColors.accent.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kelas.namaMatkul,
            style: const TextStyle(
              color: HackerColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kode: ${kelas.kodeMatkul}',
            style: const TextStyle(
              color: HackerColors.accent,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Text(
            'Dosen: ${kelas.namaDosen}',
            style: const TextStyle(
              color: HackerColors.text,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Text(
            'Kelas: ${kelas.namaKelas}',
            style: const TextStyle(
              color: HackerColors.highlight,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Text(
            'Semester: ${kelas.namaSemester}',
            style: const TextStyle(
              color: HackerColors.highlight,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranskripItem(MahasiswaNilai nilai) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HackerColors.background,
        border: Border.all(color: HackerColors.accent.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  nilai.namaMatkul,
                  style: const TextStyle(
                    color: HackerColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      _getNilaiColor(nilai.nilaiHuruf).withValues(alpha: 0.2),
                  border: Border.all(color: _getNilaiColor(nilai.nilaiHuruf)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  nilai.nilaiHuruf,
                  style: TextStyle(
                    color: _getNilaiColor(nilai.nilaiHuruf),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Kode: ${nilai.kodeMatkul}',
            style: const TextStyle(
              color: HackerColors.accent,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Row(
            children: [
              Text(
                'SKS: ${nilai.sks}',
                style: const TextStyle(
                  color: HackerColors.text,
                  fontSize: 12,
                  fontFamily: 'Courier',
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Nilai: ${nilai.nilaiAngka}',
                style: const TextStyle(
                  color: HackerColors.highlight,
                  fontSize: 12,
                  fontFamily: 'Courier',
                ),
              ),
            ],
          ),
          Text(
            'Semester: ${nilai.namaSemester}',
            style: const TextStyle(
              color: HackerColors.highlight,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIpSemesterItem(MahasiswaRiwayatSemester semester) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HackerColors.background,
        border: Border.all(color: HackerColors.accent.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            semester.namaSemester,
            style: const TextStyle(
              color: HackerColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('IPS', semester.ips),
              ),
              Expanded(
                child: _buildStatItem('IPK', semester.ipk),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('SKS Diambil', semester.sksDiambil),
              ),
              Expanded(
                child: _buildStatItem('SKS Lulus', semester.sksLulus),
              ),
            ],
          ),
          Text(
            'Status: ${semester.statusSemester}',
            style: const TextStyle(
              color: HackerColors.highlight,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSertifikatItem(dynamic sertifikat) {
    // Placeholder untuk sertifikat - sesuaikan dengan struktur data yang ada
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HackerColors.background,
        border: Border.all(color: HackerColors.accent.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sertifikat.toString(),
            style: const TextStyle(
              color: HackerColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: HackerColors.surface,
        border: Border.all(color: HackerColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: HackerColors.accent,
              fontSize: 10,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value.isEmpty ? '-' : value,
            style: const TextStyle(
              color: HackerColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: HackerColors.surface,
        border: Border.all(color: HackerColors.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            color: HackerColors.accent,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              color: HackerColors.accent,
              fontSize: 14,
              fontFamily: 'Courier',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getNilaiColor(String nilaiHuruf) {
    switch (nilaiHuruf.toUpperCase()) {
      case 'A':
        return HackerColors.primary;
      case 'B':
        return HackerColors.highlight;
      case 'C':
        return HackerColors.accent;
      case 'D':
        return HackerColors.error;
      case 'E':
      case 'F':
        return HackerColors.error;
      default:
        return HackerColors.text;
    }
  }

  Widget _buildDataTerminal({
    required String title,
    required IconData icon,
    required List<Widget> content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: HackerColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: HackerColors.primary,
                    fontFamily: 'Courier',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(
            color: HackerColors.accent,
            height: 24,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: content,
            ),
          ),
        ],
      ),
    );
  }

  // Terminal untuk menampilkan data eksternal seperti Wikipedia
  Widget _buildExternalDataTerminal() {
    // Mengekstrak informasi dari Wikipedia
    final String title = _externalData['title'] ?? 'DATA EKSTERNAL';
    final String extract =
        _externalData['extract'] ?? 'Tidak ada data yang tersedia.';
    final String source = _externalData['source'] ?? 'SUMBER TIDAK DIKETAHUI';

    return Container(
      height: 150, // Tetapkan tinggi yang jelas
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent, width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.language,
                color: HackerColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "DATA EKSTERNAL: $title",
                  style: const TextStyle(
                    color: HackerColors.primary,
                    fontFamily: 'Courier',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(
            color: HackerColors.accent,
            height: 24,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Text(
                  extract,
                  style: const TextStyle(
                    color: HackerColors.text,
                    fontFamily: 'Courier',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "SUMBER: $source",
                  style: const TextStyle(
                    color: HackerColors.accent,
                    fontFamily: 'Courier',
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTerminal(MahasiswaDetail mahasiswa) {
    // Adaptasi berdasarkan ukuran layar
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;
    final double terminalHeight = isMobile ? 100 : 120;

    return Container(
      height: terminalHeight,
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: HackerColors.accent),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: HackerColors.background,
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              "ANALISIS KEAMANAN",
              style: TextStyle(
                color: HackerColors.warning,
                fontFamily: 'Courier',
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Text(
                  _generateRandomSecurityInfo(mahasiswa, index),
                  style: TextStyle(
                    color: _getSecurityColor(index),
                    fontFamily: 'Courier',
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _generateRandomSecurityInfo(MahasiswaDetail mahasiswa, int index) {
    final hexCode = _getRandomHexValue(16);

    switch (index) {
      case 0:
        return "LEVEL AKSES: ${_random.nextInt(3) + 2} | IP: 192.168.${_random.nextInt(255)}.${_random.nextInt(255)} | PORT: ${_random.nextInt(9000) + 1000}";
      case 1:
        return "INTEGRITAS DATA: ${_random.nextInt(30) + 70}% | ENKRIPSI: AES-256 | HASH: SHA3-${_random.nextInt(2) == 0 ? "256" : "512"}";
      case 2:
        return "SISTEM: MULTI-DB-SEC | NODE: ${_getRandomHexValue(4)}-${_getRandomHexValue(4)} | SESI: $hexCode"; // Updated
      case 3:
        int length = min(10, mahasiswa.id.length);
        String idPrefix =
            length > 0 ? mahasiswa.id.substring(0, length) : "UNKNOWN";
        return "UPDATE TERAKHIR: ${DateTime.now().toString().substring(0, 16)} | ID RECORD: $idPrefix...";
      case 4:
        return "STATUS: ${_random.nextBool() ? "AMAN" : "MONITOR"} | CHECKSUM: ${_getRandomHexValue(8)} | AUTH: ${_getRandomHexValue(6)}";
      default:
        return "";
    }
  }

  Color _getSecurityColor(int index) {
    switch (index) {
      case 0:
        return HackerColors.primary;
      case 1:
        return HackerColors.accent;
      case 2:
        return HackerColors.text;
      case 3:
        return HackerColors.warning;
      case 4:
        return HackerColors.primary;
      default:
        return HackerColors.text;
    }
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: HackerColors.text.withOpacity(0.7),
              fontFamily: 'Courier',
              fontSize: 10,
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            decoration: BoxDecoration(
              color: HackerColors.background,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: HackerColors.accent.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              value.isNotEmpty ? value : "-DISENSOR-",
              style: const TextStyle(
                color: HackerColors.primary,
                fontFamily: 'Courier',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
