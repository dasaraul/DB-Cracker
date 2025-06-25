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
                  : FutureBuilder<DosenDetail>(
                      future: _dosenFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: HackerLoadingIndicator());
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  color: _random.nextBool() ? HackerColors.primary : HackerColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'KUNCI: ${_getRandomHexValue(8)}-${_getRandomHexValue(4)}-${_getRandomHexValue(4)}',
                style: const TextStyle(color: HackerColors.text, fontSize: 10, fontFamily: 'Courier'),
              ),
            ],
          ),
          const Text(
            'BY: TAMAENGS',
            style: TextStyle(color: HackerColors.text, fontSize: 10, fontFamily: 'Courier', fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDosenDetailView(DosenDetail dosen) {
    return Center(
      child: Text(
        'Detail Dosen: ${dosen.namaDosen}',
        style: const TextStyle(color: HackerColors.text, fontFamily: 'Courier', fontSize: 16),
      ),
    );
  }
}
