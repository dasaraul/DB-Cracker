import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../api/multi_api_factory.dart';
import '../models/dosen.dart';
import '../widgets/ctos_container.dart';
import '../widgets/ctos_layout.dart';
import '../utils/constants.dart';

/// Screen untuk melakukan pencarian dosen dengan tema ctOS yang elegan
class DosenSearchScreenNew extends StatefulWidget {
  const DosenSearchScreenNew({Key? key}) : super(key: key);

  @override
  _DosenSearchScreenNewState createState() => _DosenSearchScreenNewState();
}

class _DosenSearchScreenNewState extends State<DosenSearchScreenNew>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final MultiApiFactory _apiFactory = MultiApiFactory();
  final Random _random = Random();

  List<Dosen> _searchResults = [];
  List<Dosen> _filteredResults = [];
  List<String> _ptList = [];
  String? _selectedPt;
  String? _errorMessage;
  bool _isLoading = false;

  late AnimationController _animationController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animationController.repeat();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _glowController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchDosen() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _searchResults.clear();
      _filteredResults.clear();
      _ptList.clear();
      _selectedPt = null;
    });

    try {
      final results = await _apiFactory.searchAllDosen(query);

      setState(() {
        _searchResults = results;
        _filteredResults = results;
        _ptList = results.map((d) => d.namaPt).toSet().toList()..sort();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _filterResults(String? pt) {
    setState(() {
      _selectedPt = pt;
      if (pt == null) {
        _filteredResults = _searchResults;
      } else {
        _filteredResults = _searchResults.where((d) => d.namaPt == pt).toList();
      }
    });
  }

  void _clearFilter() {
    _filterResults(null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CtOSColors.background,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchSection(),
            if (_searchResults.isNotEmpty && _ptList.isNotEmpty)
              _buildFilterSection(),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildMainContent(),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 12.0,
                height: 12.0,
                margin: const EdgeInsets.only(right: 12.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _animationController.value > 0.5
                      ? CtOSColors.primary
                      : CtOSColors.error,
                  boxShadow: [
                    BoxShadow(
                      color: (_animationController.value > 0.5
                              ? CtOSColors.primary
                              : CtOSColors.error)
                          .withValues(alpha: 0.6),
                      blurRadius: 8.0,
                      spreadRadius: 2.0,
                    ),
                  ],
                ),
              );
            },
          ),
          const CtOSText(
            "ctOS DATABASE SCANNER",
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: CtOSColors.primary,
          ),
        ],
      ),
      backgroundColor: CtOSColors.surface,
      elevation: 0,
      actions: [
        if (_searchResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: CtOSColors.background,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: CtOSColors.primary),
                  boxShadow: [
                    BoxShadow(
                      color: CtOSColors.primary.withValues(alpha: 0.3),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
                child: CtOSText(
                  '${_filteredResults.length}/${_searchResults.length}',
                  fontSize: 12.0,
                  color: CtOSColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return CtOSContainer(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(16.0),
      backgroundColor: CtOSColors.surfaceVariant,
      showBorder: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CtOSStatusIndicator(
            isActive: _isLoading,
            label: _isLoading ? "SCANNING" : "READY",
          ),
          const SizedBox(width: 24.0),
          const CtOSText(
            'ctOS FACULTY DATABASE ACCESS',
            fontSize: 14.0,
            color: CtOSColors.textAccent,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return CtOSContainer(
      child: CtOSSearchBar(
        controller: _searchController,
        hintText: "masukkan nama dosen...",
        onSearch: _searchDosen,
        isLoading: _isLoading,
      ),
    );
  }

  Widget _buildFilterSection() {
    return CtOSContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CtOSHeader(
            title: "FILTER PERGURUAN TINGGI",
            showDivider: false,
          ),
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: CtOSColors.background,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: CtOSColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedPt,
                hint: const CtOSText(
                  "PILIH PERGURUAN TINGGI",
                  fontSize: 12.0,
                  color: CtOSColors.textSecondary,
                ),
                dropdownColor: CtOSColors.surface,
                style: const TextStyle(
                  color: CtOSColors.primary,
                  fontFamily: 'Courier',
                  fontSize: 12.0,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: CtOSColors.textSecondary,
                ),
                onChanged: _filterResults,
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: CtOSText(
                      "SEMUA PERGURUAN TINGGI",
                      fontSize: 12.0,
                      color: CtOSColors.textPrimary,
                    ),
                  ),
                  ..._ptList.map<DropdownMenuItem<String>>((String pt) {
                    return DropdownMenuItem<String>(
                      value: pt,
                      child: CtOSText(
                        pt,
                        fontSize: 12.0,
                        color: CtOSColors.primary,
                        maxLines: 1,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage != null) {
      return _buildErrorState();
    } else if (_searchResults.isEmpty) {
      return _buildEmptyState();
    } else if (_filteredResults.isEmpty && _selectedPt != null) {
      return _buildNoFilterResultsState();
    } else {
      return _buildResultsList();
    }
  }

  Widget _buildLoadingState() {
    return CtOSContainer(
      showGlow: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: CtOSColors.primary.withValues(
                      alpha: 0.3 + 0.7 * _glowController.value,
                    ),
                    width: 2.0,
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(CtOSColors.primary),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24.0),
          const CtOSText(
            "SCANNING DATABASE...",
            fontSize: 16.0,
            color: CtOSColors.primary,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8.0),
          const CtOSText(
            "Mengakses server PDDIKTI",
            fontSize: 12.0,
            color: CtOSColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return CtOSContainer(
      borderColor: CtOSColors.error,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: CtOSColors.error,
            size: 64.0,
          ),
          const SizedBox(height: 16.0),
          CtOSText(
            _errorMessage!,
            fontSize: 14.0,
            color: CtOSColors.error,
            textAlign: TextAlign.center,
            maxLines: 3,
          ),
          const SizedBox(height: 24.0),
          CtOSButton(
            text: "COBA LAGI",
            onPressed: _searchDosen,
            icon: Icons.refresh,
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return CtOSContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            color: CtOSColors.textSecondary.withValues(alpha: 0.5),
            size: 80.0,
          ),
          const SizedBox(height: 24.0),
          const CtOSText(
            "MASUKKAN NAMA DOSEN",
            fontSize: 18.0,
            color: CtOSColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 8.0),
          const CtOSText(
            "Sistem siap untuk memulai pencarian",
            fontSize: 12.0,
            color: CtOSColors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoFilterResultsState() {
    return CtOSContainer(
      borderColor: CtOSColors.warning,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.filter_alt_off,
            color: CtOSColors.warning,
            size: 64.0,
          ),
          const SizedBox(height: 16.0),
          const CtOSText(
            "TIDAK ADA HASIL UNTUK FILTER INI",
            fontSize: 16.0,
            color: CtOSColors.warning,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          CtOSButton(
            text: "HAPUS FILTER",
            onPressed: _clearFilter,
            icon: Icons.clear,
            isPrimary: false,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return CtOSContainer(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CtOSHeader(
            title: "HASIL PENCARIAN",
            subtitle: _selectedPt != null
                ? 'Filter: $_selectedPt (${_filteredResults.length})'
                : 'Ditemukan ${_searchResults.length} dosen',
            trailing: _selectedPt != null
                ? IconButton(
                    icon: const Icon(Icons.clear, color: CtOSColors.warning),
                    onPressed: _clearFilter,
                  )
                : null,
          ),
          Expanded(
            child: _filteredResults.isEmpty
                ? const Center(
                    child: CtOSText(
                      "Tidak ada data dosen",
                      fontSize: 14.0,
                      color: CtOSColors.textSecondary,
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredResults.length,
                    itemBuilder: (context, index) => _buildDosenCard(index),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDosenCard(int index) {
    final dosen = _filteredResults[index];
    final isEven = index % 2 == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: CtOSListItem(
        title: dosen.nama,
        subtitle: 'NIDN: ${dosen.nidn}\n${dosen.namaProdi}',
        trailing: dosen.namaPt,
        leadingIcon: Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: CtOSColors.background,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(
              color: isEven ? CtOSColors.primary : CtOSColors.secondary,
            ),
          ),
          child: Center(
            child: CtOSText(
              dosen.nama.isNotEmpty ? dosen.nama[0].toUpperCase() : 'D',
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: isEven ? CtOSColors.primary : CtOSColors.secondary,
            ),
          ),
        ),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/dosen/detail/${dosen.id}',
            arguments: {'dosenName': dosen.nama},
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return CtOSContainer(
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(12.0),
      backgroundColor: CtOSColors.surface,
      showBorder: false,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _random.nextBool()
                          ? CtOSColors.primary
                          : CtOSColors.secondary,
                    ),
                  );
                },
              ),
              const SizedBox(width: 8.0),
              CtOSText(
                DateTime.now().toString().substring(0, 19),
                fontSize: 10.0,
                color: CtOSColors.textSecondary,
              ),
            ],
          ),
          const CtOSText(
            'BY: TAMAENGS',
            fontSize: 10.0,
            color: CtOSColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}
