import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../api/multi_api_factory.dart';
import '../models/dosen.dart';
import '../widgets/hacker_loading_indicator.dart';
import '../widgets/console_text.dart';
import '../widgets/terminal_window.dart';
import '../utils/constants.dart';
import '../utils/screen_utils.dart';

/// Screen untuk menampilkan detail dosen
class DosenDetailScreen extends StatefulWidget {
  final String dosenId;
  final String dosenName;

  const DosenDetailScreen({
    Key? key,
    required this.dosenId,
    required this.dosenName,
  }) : super(key: key);

  @override
  _DosenDetailScreenState createState() => _DosenDetailScreenState();
}

class _DosenDetailScreenState extends State<DosenDetailScreen>
    with SingleTickerProviderStateMixin {
  late Future<DosenDetail> _dosenFuture;
  bool _isLoading = true;
  List<String> _consoleMessages = [];
  final Random _random = Random();
  Timer? _loadTimer;
  late AnimationController _animationController;

  // Tab yang aktif
  int _activeTabIndex = 0;

  // Tambahkan instance MultiApiFactory
  late MultiApiFactory _multiApiFactory;

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

    // Mulai sequence loading
    _simulateLoading();
  }

  void _simulateLoading() {
    setState(() {
      _consoleMessages = [];
      _isLoading = true;
    });

    _addConsoleMessageWithDelay("AKSES DATABASE AMAN...", 300);
    _addConsoleMessageWithDelay("MENCARI DATA DOSEN: ${widget.dosenName}", 800);
    _addConsoleMessageWithDelay("DEKRIPSI RIWAYAT AKADEMIK...", 1400);
    _addConsoleMessageWithDelay("SCRAPING DATA INSTITUSI...", 2000);
    _addConsoleMessageWithDelay("EKSTRAKSI RIWAYAT MENGAJAR...", 2600);
    _addConsoleMessageWithDelay("AKSES KARYA ILMIAH...", 3200);
    _addConsoleMessageWithDelay("KOMPILASI PROFIL DOSEN...", 3800);

    // Fetch data setelah simulasi
    _loadTimer = Timer(const Duration(milliseconds: 4200), () {
      _fetchDosenDetail();
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

  void _fetchDosenDetail() {
    // Gunakan MultiApiFactory untuk mengambil detail lengkap dosen
    _dosenFuture =
        _multiApiFactory.getDosenDetailFromAllSources(widget.dosenId);

    _dosenFuture.then((_) {
      setState(() {
        _isLoading = false;
      });
      _addConsoleMessageWithDelay("EKSTRAKSI DATA SELESAI", 300);
      _addConsoleMessageWithDelay("AKSES DIBERIKAN", 600);
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      _addConsoleMessageWithDelay("ERROR: EKSTRAKSI DATA GAGAL", 300);
      _addConsoleMessageWithDelay("AKSES DITOLAK", 600);
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
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
    // Pastikan ScreenUtils diinisialisasi
    if (ScreenUtils.screenWidth == 0) {
      ScreenUtils.init(context);
    }

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
              "PROFIL DOSEN",
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
      ),
      body: SafeArea(
        child: Container(
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
                      'SUBJEK: ${widget.dosenName}',
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
                child: _isLoading
                    ? TerminalWindow(
                        title: "DEKRIPSI DATA",
                        child: Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _consoleMessages.length,
                                itemBuilder: (context, index) {
                                  bool isSuccess =
                                      index == _consoleMessages.length - 1 &&
                                          _consoleMessages[index]
                                              .contains("SELESAI");
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
                    : FutureBuilder<DosenDetail>(
                        future: _dosenFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: HackerLoadingIndicator());
                          } else if (snapshot.hasError) {
                            return _buildErrorView();
                          } else if (!snapshot.hasData) {
                            return const Center(
                              child: Text(
                                'Data Dosen tidak tersedia',
                                style: TextStyle(
                                  color: HackerColors.error,
                                  fontFamily: 'Courier',
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }

                          final dosen = snapshot.data!;
                          return _buildDosenDetailView(dosen);
                        },
                      ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
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
              const Text(
                'Gagal memuat data dosen',
                style: TextStyle(
                  color: HackerColors.error,
                  fontSize: 16,
                  fontFamily: 'Courier',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _simulateLoading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HackerColors.surface,
                  foregroundColor: HackerColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  side: const BorderSide(color: HackerColors.primary),
                ),
                child: const Text("COBA LAGI", style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
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
                    fontFamily: 'Courier'),
              ),
            ],
          ),
          const Text(
            'BY: TAMAENGS',
            style: TextStyle(
                color: HackerColors.text,
                fontSize: 10,
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDosenDetailView(DosenDetail dosen) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profile Card
          _buildProfileCard(dosen),
          const SizedBox(height: 16),

          // Tab Navigation
          _buildTabNavigation(),
          const SizedBox(height: 16),

          // Tab Content
          _buildTabContent(dosen),
        ],
      ),
    );
  }

  Widget _buildProfileCard(DosenDetail dosen) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HackerColors.surface,
        border: Border.all(color: HackerColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: HackerColors.primary.withOpacity(0.1),
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
                  color: HackerColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: HackerColors.primary, width: 2),
                ),
                child: Icon(
                  Icons.person,
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
                      dosen.namaDosen,
                      style: const TextStyle(
                        color: HackerColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (dosen.nidn.isNotEmpty)
                      Text(
                        'NIDN: ${dosen.nidn}',
                        style: const TextStyle(
                          color: HackerColors.accent,
                          fontSize: 14,
                          fontFamily: 'Courier',
                        ),
                      ),
                    if (dosen.jabatanAkademik.isNotEmpty)
                      Text(
                        dosen.jabatanAkademik,
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
              _buildStatusChip('Status', dosen.statusAktivitas),
              _buildStatusChip('Ikatan Kerja', dosen.statusIkatanKerja),
              if (dosen.pendidikanTertinggi.isNotEmpty)
                _buildStatusChip('Pendidikan', dosen.pendidikanTertinggi),
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
        color: HackerColors.primary.withOpacity(0.1),
        border: Border.all(color: HackerColors.primary.withOpacity(0.3)),
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
      'INSTITUSI',
      'RIWAYAT',
      'PORTFOLIO',
    ];

    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: HackerColors.surface,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: HackerColors.primary.withOpacity(0.3)),
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

  Widget _buildTabContent(DosenDetail dosen) {
    switch (_activeTabIndex) {
      case 0:
        return _buildProfilTab(dosen);
      case 1:
        return _buildInstitusiTab(dosen);
      case 2:
        return _buildRiwayatTab(dosen);
      case 3:
        return _buildPortfolioTab(dosen);
      default:
        return _buildProfilTab(dosen);
    }
  }

  Widget _buildProfilTab(DosenDetail dosen) {
    return Column(
      children: [
        _buildInfoCard('INFORMASI PERSONAL', [
          _buildInfoRow('Nama Lengkap', dosen.namaDosen),
          _buildInfoRow('NIDN', dosen.nidn),
          _buildInfoRow('NIDK', dosen.nidk),
          _buildInfoRow('Gelar Depan', dosen.gelarDepan),
          _buildInfoRow('Gelar Belakang', dosen.gelarBelakang),
          _buildInfoRow('Jenis Kelamin', dosen.jenisKelamin),
          _buildInfoRow('Tempat Lahir', dosen.tempatLahir),
          _buildInfoRow('Tanggal Lahir', dosen.tanggalLahir),
          _buildInfoRow('Agama', dosen.agama),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('STATUS KEPEGAWAIAN', [
          _buildInfoRow('Status Ikatan Kerja', dosen.statusIkatanKerja),
          _buildInfoRow('Status Aktivitas', dosen.statusAktivitas),
          _buildInfoRow('Jabatan Akademik', dosen.jabatanAkademik),
          _buildInfoRow('Tanggal SK', dosen.tanggalSk),
          _buildInfoRow('TMT Jabatan', dosen.tmtJabatan),
          _buildInfoRow('Nomor SK', dosen.nomorSk),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('SERTIFIKASI', [
          _buildInfoRow('Status Sertifikasi', dosen.statusSertifikasi),
          _buildInfoRow('Tahun Sertifikasi', dosen.tahunSertifikasi),
          _buildInfoRow('Nomor Sertifikat', dosen.nomorSertifikat),
          _buildInfoRow('Bidang Sertifikasi', dosen.bidangSertifikasi),
        ]),
      ],
    );
  }

  Widget _buildInstitusiTab(DosenDetail dosen) {
    return Column(
      children: [
        _buildInfoCard('PERGURUAN TINGGI', [
          _buildInfoRow('Nama PT', dosen.namaPt),
          _buildInfoRow('Program Studi', dosen.namaProdi),
          _buildInfoRow('Home PT', dosen.homePt),
          _buildInfoRow('Home Prodi', dosen.homeProdi),
          _buildInfoRow('Status Homebase', dosen.statusHomebase),
          _buildInfoRow('Rasio Homebase', dosen.rasioHomebase),
        ]),
        const SizedBox(height: 16),
        _buildInfoCard('PENDIDIKAN TERTINGGI', [
          _buildInfoRow('Jenjang', dosen.pendidikanTertinggi),
          _buildInfoRow('Bidang Ilmu', dosen.bidangIlmu),
          _buildInfoRow('Institusi', dosen.institusiPendidikan),
          _buildInfoRow('Tahun Lulus', dosen.tahunLulusTertinggi),
        ]),
      ],
    );
  }

  Widget _buildRiwayatTab(DosenDetail dosen) {
    return Column(
      children: [
        if (dosen.riwayatStudi.isNotEmpty) ...[
          _buildListCard(
              'RIWAYAT PENDIDIKAN',
              dosen.riwayatStudi
                  .map((studi) => _buildRiwayatStudiItem(studi))
                  .toList()),
          const SizedBox(height: 16),
        ],
        if (dosen.riwayatMengajar.isNotEmpty) ...[
          _buildListCard(
              'RIWAYAT MENGAJAR',
              dosen.riwayatMengajar
                  .map((mengajar) => _buildRiwayatMengajarItem(mengajar))
                  .toList()),
          const SizedBox(height: 16),
        ],
        if (dosen.riwayatJabatan.isNotEmpty) ...[
          _buildListCard(
              'RIWAYAT JABATAN',
              dosen.riwayatJabatan
                  .map((jabatan) => _buildRiwayatJabatanItem(jabatan))
                  .toList()),
          const SizedBox(height: 16),
        ],
        if (dosen.riwayatPenugasan.isNotEmpty) ...[
          _buildListCard(
              'RIWAYAT PENUGASAN',
              dosen.riwayatPenugasan
                  .map((penugasan) => _buildRiwayatPenugasanItem(penugasan))
                  .toList()),
        ],
        if (dosen.riwayatStudi.isEmpty &&
            dosen.riwayatMengajar.isEmpty &&
            dosen.riwayatJabatan.isEmpty &&
            dosen.riwayatPenugasan.isEmpty)
          _buildEmptyState('Belum ada data riwayat'),
      ],
    );
  }

  Widget _buildPortfolioTab(DosenDetail dosen) {
    return Column(
      children: [
        if (dosen.penelitian.isNotEmpty) ...[
          _buildListCard(
              'PENELITIAN',
              dosen.penelitian
                  .map((item) => _buildPortfolioItem(item))
                  .toList()),
          const SizedBox(height: 16),
        ],
        if (dosen.pengabdian.isNotEmpty) ...[
          _buildListCard(
              'PENGABDIAN MASYARAKAT',
              dosen.pengabdian
                  .map((item) => _buildPortfolioItem(item))
                  .toList()),
          const SizedBox(height: 16),
        ],
        if (dosen.karya.isNotEmpty) ...[
          _buildListCard('KARYA ILMIAH',
              dosen.karya.map((item) => _buildPortfolioItem(item)).toList()),
          const SizedBox(height: 16),
        ],
        if (dosen.paten.isNotEmpty) ...[
          _buildListCard('PATEN',
              dosen.paten.map((item) => _buildPortfolioItem(item)).toList()),
        ],
        if (dosen.penelitian.isEmpty &&
            dosen.pengabdian.isEmpty &&
            dosen.karya.isEmpty &&
            dosen.paten.isEmpty)
          _buildEmptyState('Belum ada data portfolio'),
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
        border: Border.all(color: HackerColors.primary.withOpacity(0.3)),
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
        border: Border.all(color: HackerColors.primary.withOpacity(0.3)),
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

  Widget _buildRiwayatStudiItem(DosenRiwayatStudi studi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HackerColors.background,
        border: Border.all(color: HackerColors.accent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${studi.jenjang} - ${studi.gelar}',
            style: const TextStyle(
              color: HackerColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            studi.perguruan,
            style: const TextStyle(
              color: HackerColors.text,
              fontSize: 13,
              fontFamily: 'Courier',
            ),
          ),
          if (studi.bidangStudi.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Bidang: ${studi.bidangStudi}',
              style: const TextStyle(
                color: HackerColors.accent,
                fontSize: 12,
                fontFamily: 'Courier',
              ),
            ),
          ],
          if (studi.tahunLulus.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Lulus: ${studi.tahunLulus}',
              style: const TextStyle(
                color: HackerColors.highlight,
                fontSize: 12,
                fontFamily: 'Courier',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRiwayatMengajarItem(DosenRiwayatMengajar mengajar) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HackerColors.background,
        border: Border.all(color: HackerColors.accent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            mengajar.namaMatkul,
            style: const TextStyle(
              color: HackerColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kode: ${mengajar.kodeMatkul}',
            style: const TextStyle(
              color: HackerColors.accent,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Text(
            'Kelas: ${mengajar.namaKelas}',
            style: const TextStyle(
              color: HackerColors.text,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Text(
            'Semester: ${mengajar.namaSemester}',
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

  Widget _buildRiwayatJabatanItem(DosenJabatanFungsional jabatan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HackerColors.background,
        border: Border.all(color: HackerColors.accent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            jabatan.jabatan,
            style: const TextStyle(
              color: HackerColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 4),
          if (jabatan.tanggalSk.isNotEmpty)
            Text(
              'Tanggal SK: ${jabatan.tanggalSk}',
              style: const TextStyle(
                color: HackerColors.text,
                fontSize: 12,
                fontFamily: 'Courier',
              ),
            ),
          if (jabatan.nomorSk.isNotEmpty)
            Text(
              'Nomor SK: ${jabatan.nomorSk}',
              style: const TextStyle(
                color: HackerColors.accent,
                fontSize: 12,
                fontFamily: 'Courier',
              ),
            ),
          if (jabatan.tmtJabatan.isNotEmpty)
            Text(
              'TMT: ${jabatan.tmtJabatan}',
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

  Widget _buildRiwayatPenugasanItem(DosenPenugasan penugasan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HackerColors.background,
        border: Border.all(color: HackerColors.accent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            penugasan.namaPt,
            style: const TextStyle(
              color: HackerColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Prodi: ${penugasan.namaProdi}',
            style: const TextStyle(
              color: HackerColors.text,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Text(
            'Status: ${penugasan.statusPenugasan}',
            style: const TextStyle(
              color: HackerColors.accent,
              fontSize: 12,
              fontFamily: 'Courier',
            ),
          ),
          Text(
            'Periode: ${penugasan.tahunMulai}${penugasan.tahunSelesai.isNotEmpty ? ' - ${penugasan.tahunSelesai}' : ' - Sekarang'}',
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

  Widget _buildPortfolioItem(DosenPortofolio portfolio) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HackerColors.background,
        border: Border.all(color: HackerColors.accent.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            portfolio.judulKegiatan,
            style: const TextStyle(
              color: HackerColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Courier',
            ),
          ),
          const SizedBox(height: 4),
          if (portfolio.jenisKegiatan.isNotEmpty)
            Text(
              'Jenis: ${portfolio.jenisKegiatan}',
              style: const TextStyle(
                color: HackerColors.accent,
                fontSize: 12,
                fontFamily: 'Courier',
              ),
            ),
          if (portfolio.tahunKegiatan.isNotEmpty)
            Text(
              'Tahun: ${portfolio.tahunKegiatan}',
              style: const TextStyle(
                color: HackerColors.highlight,
                fontSize: 12,
                fontFamily: 'Courier',
              ),
            ),
          if (portfolio.detailKegiatan.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              portfolio.detailKegiatan,
              style: const TextStyle(
                color: HackerColors.text,
                fontSize: 12,
                fontFamily: 'Courier',
              ),
            ),
          ],
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
        border: Border.all(color: HackerColors.primary.withOpacity(0.3)),
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
}
