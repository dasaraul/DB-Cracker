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

class _DosenDetailScreenState extends State<DosenDetailScreen> with SingleTickerProviderStateMixin {
  late Future<DosenDetail?> _dosenFuture;
  bool _isLoading = true;
  List<String> _consoleMessages = [];
  final Random _random = Random();
  Timer? _loadTimer;
  late AnimationController _animationController;
  
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
    _addConsoleMessageWithDelay("MENCARI SUBJEK: ${widget.dosenName}", 800);
    _addConsoleMessageWithDelay("DEKRIPSI RIWAYAT AKADEMIK...", 1400);
    _addConsoleMessageWithDelay("MELEWATI ENKRIPSI...", 2000);
    _addConsoleMessageWithDelay("EKSTRAKSI CATATAN INSTANSI...", 2600);
    _addConsoleMessageWithDelay("MEMBUAT PROFIL DOSEN...", 3200);
    
    // Fetch data setelah simulasi
    _loadTimer = Timer(const Duration(milliseconds: 4000), () {
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
    // Gunakan MultiApiFactory untuk mencari data dosen
    _dosenFuture = _multiApiFactory.getDosenDetailFromAllSources(widget.dosenId);
    
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
    
    // Adaptasi berdasarkan ukuran layar
    final bool isMobile = ScreenUtils.isMobileScreen();
    
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
                              bool isSuccess = index == _consoleMessages.length - 1 && 
                                            _consoleMessages[index].contains("SELESAI");
                              bool isError = index == _consoleMessages.length - 1 && 
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
                : FutureBuilder<DosenDetail?>(
                    future: _dosenFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                                    'Error: ${snapshot.error}',
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
                                    onPressed: _simulateLoading,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: HackerColors.surface,
                                      foregroundColor: HackerColors.primary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16, 
                                        vertical: 8
                                      ),
                                      side: const BorderSide(color: HackerColors.primary),
                                    ),
                                    child: const Text(
                                      "COBA LAGI",
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

  Widget _buildDosenDetailView(DosenDetail dosen) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;
    
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: isMobile
                // Layout mobile: data pribadi di atas, data institusi di bawah
                ? Column(
                    children: [
                      Expanded(
                        child: _buildDataTerminal(
                          title: "DATA PRIBADI",
                          icon: Icons.person,
                          content: [
                            _buildDataRow("NAMA", dosen.namaDosen),
                            _buildDataRow("ID SDM", dosen.idSdm),
                            _buildDataRow("JENIS KELAMIN", dosen.jenisKelamin),
                            _buildDataRow("PENDIDIKAN", dosen.pendidikanTertinggi),
                            _buildDataRow("JABATAN", dosen.jabatanAkademik),
                            _buildDataRow("STATUS", dosen.statusAktivitas),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _buildDataTerminal(
                          title: "DATA INSTITUSI",
                          icon: Icons.school,
                          content: [
                            _buildDataRow("INSTITUSI", dosen.namaPt),
                            _buildDataRow("PROGRAM STUDI", dosen.namaProdi),
                            _buildDataRow("STATUS KERJA", dosen.statusIkatanKerja),
                          ],
                        ),
                      ),
                    ],
                  )
                // Layout tablet/desktop: data pribadi di kiri, data institusi di kanan
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildDataTerminal(
                          title: "DATA PRIBADI",
                          icon: Icons.person,
                          content: [
                            _buildDataRow("NAMA", dosen.namaDosen),
                            _buildDataRow("ID SDM", dosen.idSdm),
                            _buildDataRow("JENIS KELAMIN", dosen.jenisKelamin),
                            _buildDataRow("PENDIDIKAN", dosen.pendidikanTertinggi),
                            _buildDataRow("JABATAN", dosen.jabatanAkademik),
                            _buildDataRow("STATUS", dosen.statusAktivitas),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: _buildDataTerminal(
                          title: "DATA INSTITUSI",
                          icon: Icons.school,
                          content: [
                            _buildDataRow("INSTITUSI", dosen.namaPt),
                            _buildDataRow("PROGRAM STUDI", dosen.namaProdi),
                            _buildDataRow("STATUS KERJA", dosen.statusIkatanKerja),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 12),
          _buildSecurityTerminal(dosen),
        ],
      ),
    );
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
  
  Widget _buildSecurityTerminal(DosenDetail dosen) {
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
              "ANALISIS PROFIL",
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
                  _generateRandomSecurityInfo(dosen, index),
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

  String _generateRandomSecurityInfo(DosenDetail dosen, int index) {
    final hexCode = _getRandomHexValue(16);
    
    switch (index) {
      case 0:
        return "LEVEL AKSES: ${_random.nextInt(3) + 3} | IP: 192.168.${_random.nextInt(255)}.${_random.nextInt(255)} | PORT: ${_random.nextInt(9000) + 1000}";
      case 1:
        return "INTEGRITAS DATA: ${_random.nextInt(30) + 70}% | ENKRIPSI: AES-256 | HASH: SHA3-${_random.nextInt(2) == 0 ? "256" : "512"}";
      case 2:
        return "SISTEM: PROF-DB-SEC | NODE: ${_getRandomHexValue(4)}-${_getRandomHexValue(4)} | SESI: $hexCode";
      case 3:
        return "UPDATE TERAKHIR: ${DateTime.now().toString().substring(0, 16)} | ID RECORD: ${dosen.idSdm.substring(0, min(10, dosen.idSdm.length))}...";
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
  
  // Helper function to limit string length
  int min(int a, int b) {
    return (a < b) ? a : b;
  }
}