import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../models/vinyl_model.dart';
import '../../services/vinyl_service.dart';
import 'vinyl_form_page.dart';

class VinylListPage extends StatefulWidget {
  const VinylListPage({super.key});

  @override
  State<VinylListPage> createState() => _VinylListPageState();
}

class _VinylListPageState extends State<VinylListPage> {
  bool loading = true;
  List<Vinyl> data = [];
  List<Vinyl> filteredData = [];
  
  // Search & Filter
  final searchController = TextEditingController();
  String selectedGenreFilter = 'Semua';
  String sortBy = 'Judul A-Z';
  
  final List<String> genreFilterOptions = [
    'Semua',
    'Rock',
    'Jazz',
    'Hip Hop',
    'Classical',
    'Pop',
    'Electronic',
    'R&B',
    'Blues',
    'Country',
    'Reggae',
    'Metal',
    'Folk',
    'Punk',
    'Soul',
    'Funk',
  ];
  
  final List<String> sortOptions = [
    'Judul A-Z',
    'Judul Z-A',
    'Harga Terendah',
    'Harga Tertinggi',
    'Stok Terbanyak',
    'Stok Tersedikit',
    'Tahun Terbaru',
    'Tahun Terlama',
  ];

  @override
  void initState() {
    super.initState();
    load();
    searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    searchController.removeListener(_applyFilters);
    searchController.dispose();
    super.dispose();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      data = await VinylService.getAll();
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to load vinyl records: $e"),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      data = [];
      filteredData = [];
    }
    setState(() => loading = false);
  }

  void _applyFilters() {
    setState(() {
      filteredData = data.where((vinyl) {
        // Filter by search query
        final searchQuery = searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            vinyl.title.toLowerCase().contains(searchQuery) ||
            vinyl.artist.toLowerCase().contains(searchQuery);
        
        // Filter by genre
        final matchesGenre = selectedGenreFilter == 'Semua' ||
            vinyl.genre == selectedGenreFilter;
        
        return matchesSearch && matchesGenre;
      }).toList();
      
      // Apply sorting
      _applySorting();
    });
  }

  void _applySorting() {
    switch (sortBy) {
      case 'Judul A-Z':
        filteredData.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'Judul Z-A':
        filteredData.sort((a, b) => b.title.compareTo(a.title));
        break;
      case 'Harga Terendah':
        filteredData.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'Harga Tertinggi':
        filteredData.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Stok Terbanyak':
        filteredData.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case 'Stok Tersedikit':
        filteredData.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case 'Tahun Terbaru':
        filteredData.sort((a, b) => (b.year ?? 0).compareTo(a.year ?? 0));
        break;
      case 'Tahun Terlama':
        filteredData.sort((a, b) => (a.year ?? 0).compareTo(b.year ?? 0));
        break;
    }
  }

  void deleteItem(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber[600], size: 28),
            const SizedBox(width: 12),
            const Text(
              "Hapus Vinyl",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          "Apakah Anda yakin ingin menghapus vinyl ini?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[400],
            ),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (ok == true) {
      final success = await VinylService.deleteVinyl(id);
      if (success) {
        load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("🗑 Vinyl berhasil dihapus"),
              backgroundColor: const Color(0xFF1a1a1a),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2d2d2d),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: Colors.amber[600], size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Filter & Urutkan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey[400]),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              Divider(color: Colors.grey[800], height: 1),
              
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Genre Filter Section
                    Row(
                      children: [
                        Icon(Icons.category, color: Colors.amber[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Filter Genre",
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: genreFilterOptions.map((genre) {
                        final isSelected = selectedGenreFilter == genre;
                        return FilterChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedGenreFilter = genre;
                              _applyFilters();
                            });
                            Navigator.pop(context);
                          },
                          backgroundColor: Colors.grey[800],
                          selectedColor: Colors.amber[700],
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[400],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sort Options Section
                    Row(
                      children: [
                        Icon(Icons.sort, color: Colors.amber[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          "Urutkan Berdasarkan",
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    ...sortOptions.map((option) {
                      final isSelected = sortBy == option;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected 
                              ? Colors.amber[700]!.withOpacity(0.2) 
                              : Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.amber[700]! : Colors.grey[800]!,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text(
                            option,
                            style: TextStyle(
                              color: isSelected ? Colors.amber[300] : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(Icons.check_circle, color: Colors.amber[600], size: 20)
                              : Icon(Icons.circle_outlined, color: Colors.grey[700], size: 20),
                          onTap: () {
                            setState(() {
                              sortBy = option;
                              _applyFilters();
                            });
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 80), // Extra padding at bottom
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Base URL helper sesuai platform
  String getBaseUrl() {
    if (kIsWeb) return "http://localhost:3000";
    if (Platform.isAndroid) return "http://10.0.2.2:3000";
    return "http://localhost:3000"; // iOS / macOS
  }

  /// Cover image URL helper
  String getCoverUrl(String? coverFileName) {
    if (coverFileName == null || coverFileName.isEmpty) return "";
    final cleanPath = coverFileName.startsWith('/') ? coverFileName.substring(1) : coverFileName;
    return "${getBaseUrl()}/$cleanPath";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a1a1a),
              const Color(0xFF2d2d2d),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber[700]!.withOpacity(0.2),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber[700],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.album, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [Colors.amber[600]!, Colors.amber[200]!],
                                ).createShader(bounds),
                                child: const Text(
                                  "VINYL ADMIN",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              Text(
                                "${filteredData.length} dari ${data.length} Vinyl",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Filter Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900]!.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (selectedGenreFilter != 'Semua' || sortBy != 'Judul A-Z')
                                  ? Colors.amber[600]!
                                  : Colors.grey[800]!,
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color: (selectedGenreFilter != 'Semua' || sortBy != 'Judul A-Z')
                                  ? Colors.amber[600]
                                  : Colors.grey[400],
                            ),
                            onPressed: _showFilterDialog,
                            tooltip: "Filter & Sort",
                          ),
                        ),
                      ],
                    ),
                    
                    // Search Bar
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900]!.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.grey[800]!,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Cari judul atau artis...",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: Icon(Icons.search, color: Colors.amber[600]),
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                                  onPressed: () {
                                    searchController.clear();
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    
                    // Active Filters Chips
                    if (selectedGenreFilter != 'Semua' || sortBy != 'Judul A-Z')
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            if (selectedGenreFilter != 'Semua')
                              Chip(
                                label: Text(
                                  "Genre: $selectedGenreFilter",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.amber[700],
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    selectedGenreFilter = 'Semua';
                                    _applyFilters();
                                  });
                                },
                              ),
                            if (sortBy != 'Judul A-Z')
                              Chip(
                                label: Text(
                                  sortBy,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.amber[700],
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    sortBy = 'Judul A-Z';
                                    _applyFilters();
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: loading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Loading vinyl records...",
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : filteredData.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  searchController.text.isNotEmpty || selectedGenreFilter != 'Semua'
                                      ? Icons.search_off
                                      : Icons.album_outlined,
                                  size: 80,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  searchController.text.isNotEmpty || selectedGenreFilter != 'Semua'
                                      ? "Tidak ada hasil"
                                      : "Belum ada vinyl",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  searchController.text.isNotEmpty || selectedGenreFilter != 'Semua'
                                      ? "Coba kata kunci atau filter lain"
                                      : "Tekan tombol + untuk menambah",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: load,
                            color: Colors.amber[600],
                            backgroundColor: const Color(0xFF2d2d2d),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredData.length,
                              itemBuilder: (_, i) {
                                final v = filteredData[i];
                                final coverUrl = getCoverUrl(v.coverUrl);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey[900]!,
                                        const Color(0xFF2d2d2d),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[800]!,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(12),
                                      leading: Container(
                                        width: 70,
                                        height: 70,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.grey[800]!,
                                              Colors.black,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.amber.withOpacity(0.2),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: coverUrl.isNotEmpty
                                              ? Image.network(
                                                  coverUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.album,
                                                      size: 35,
                                                      color: Colors.amber[600],
                                                    );
                                                  },
                                                )
                                              : Icon(
                                                  Icons.album,
                                                  size: 35,
                                                  color: Colors.amber[600],
                                                ),
                                        ),
                                      ),
                                      title: Text(
                                        v.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(Icons.person, size: 14, color: Colors.grey[500]),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  "${v.artist} • ${v.year}",
                                                  style: TextStyle(
                                                    color: Colors.grey[400],
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (v.genre != null && v.genre!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.music_note, size: 14, color: Colors.grey[500]),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    v.genre!,
                                                    style: TextStyle(
                                                      color: Colors.amber[300],
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber[700],
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  "Rp ${v.price.toStringAsFixed(0)}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: v.stock > 0
                                                      ? Colors.green[700]
                                                      : Colors.red[700],
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      v.stock > 0
                                                          ? Icons.inventory_2
                                                          : Icons.remove_shopping_cart,
                                                      size: 12,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "Stock: ${v.stock}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      isThreeLine: true,
                                      trailing: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[850],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Colors.amber[600], size: 20),
                                              onPressed: () async {
                                                await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => VinylFormPage(vinyl: v),
                                                  ),
                                                );
                                                load();
                                              },
                                              tooltip: "Edit",
                                            ),
                                            Container(
                                              width: 1,
                                              height: 30,
                                              color: Colors.grey[800],
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Colors.red[400], size: 20),
                                              onPressed: () => deleteItem(v.id!),
                                              tooltip: "Delete",
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber[700]!, Colors.amber[500]!],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VinylFormPage()),
            );
            load();
          },
        ),
      ),
    );
  }
}