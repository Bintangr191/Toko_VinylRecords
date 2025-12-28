import 'dart:ui';

import 'package:flutter/material.dart';
import '../../models/vinyl_model.dart';
import '../../services/catalog_service.dart';
import '../../utils/api_config.dart';
import 'vinyl_detail_page.dart';

enum SortType {
  none,
  priceLow,
  priceHigh,
  stockAvailable,
}

class HomeCatalogPage extends StatefulWidget {
  const HomeCatalogPage({super.key});

  @override
  State<HomeCatalogPage> createState() => _HomeCatalogPageState();
}

class _HomeCatalogPageState extends State<HomeCatalogPage> {
  bool loading = true;

  List<Vinyl> allData = [];
  List<Vinyl> filteredData = [];

  final TextEditingController searchController = TextEditingController();

  SortType sortType = SortType.none;
  String selectedGenre = "All";

  // Fixed genre list
  final List<String> genreOptions = [
    'All',
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
    'Default',
    'Harga Termurah',
    'Harga Termahal',
    'Stok Terbanyak',
  ];

  @override
  void initState() {
    super.initState();
    load();
    searchController.addListener(applyFilter);
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      allData = await CatalogService.getCatalog();
      filteredData = allData;
      applyFilter();
    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed to load catalog: $e"),
            backgroundColor: Colors.red[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
    setState(() => loading = false);
  }

  void applyFilter() {
    final q = searchController.text.toLowerCase();

    List<Vinyl> temp = allData.where((v) {
      final matchTitle = v.title.toLowerCase().contains(q) || 
                         v.artist.toLowerCase().contains(q);
      final matchGenre = selectedGenre == "All" || v.genre == selectedGenre;
      return matchTitle && matchGenre;
    }).toList();

    switch (sortType) {
      case SortType.priceLow:
        temp.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortType.priceHigh:
        temp.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortType.stockAvailable:
        temp.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case SortType.none:
        break;
    }

    setState(() {
      filteredData = temp;
    });
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
                      children: genreOptions.map((genre) {
                        final isSelected = selectedGenre == genre;
                        return FilterChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedGenre = genre;
                              applyFilter();
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
                    
                    _buildSortOption('Default', SortType.none),
                    _buildSortOption('Harga Termurah', SortType.priceLow),
                    _buildSortOption('Harga Termahal', SortType.priceHigh),
                    _buildSortOption('Stok Terbanyak', SortType.stockAvailable),
                    
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, SortType type) {
    final isSelected = sortType == type;
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
          label,
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
            sortType = type;
            applyFilter();
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.removeListener(applyFilter);
    searchController.dispose();
    super.dispose();
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
              // Custom Header
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
                          child: const Icon(Icons.store, color: Colors.white, size: 24),
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
                                  "VINYL STORE",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              Text(
                                "${filteredData.length} Vinyl Tersedia",
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
                              color: (selectedGenre != 'All' || sortType != SortType.none)
                                  ? Colors.amber[600]!
                                  : Colors.grey[800]!,
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color: (selectedGenre != 'All' || sortType != SortType.none)
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
                    if (selectedGenre != 'All' || sortType != SortType.none)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Wrap(
                          spacing: 8,
                          children: [
                            if (selectedGenre != 'All')
                              Chip(
                                label: Text(
                                  "Genre: $selectedGenre",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.amber[700],
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    selectedGenre = 'All';
                                    applyFilter();
                                  });
                                },
                              ),
                            if (sortType != SortType.none)
                              Chip(
                                label: Text(
                                  _getSortLabel(sortType),
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.amber[700],
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    sortType = SortType.none;
                                    applyFilter();
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
                              "Loading catalog...",
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
                                  Icons.search_off,
                                  size: 80,
                                  color: Colors.grey[700],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "Tidak ada vinyl ditemukan",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Coba kata kunci atau filter lain",
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
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: filteredData.length,
                              itemBuilder: (_, i) {
                                final v = filteredData[i];
                                final imageUrl = ApiConfig.fixImageUrl(v.coverUrl);

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => VinylDetailPage(vinylId: v.id),
                                      ),
                                    );
                                  },
                                  child: Container(
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Image with badge
                                          Expanded(
                                            flex: 3,
                                            child: Stack(
                                              children: [
                                                // Blurred background
                                                Positioned.fill(
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, _, _) => Container(
                                                      color: Colors.grey[900],
                                                    ),
                                                  ),
                                                ),
                                                // Blur overlay
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withOpacity(0.3),
                                                    ),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                                      child: Container(
                                                        color: Colors.black.withOpacity(0.2),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                // Main image centered
                                                Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8),
                                                    child: Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(
                                                          Icons.album,
                                                          size: 60,
                                                          color: Colors.amber[600],
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                
                                                // Genre Badge
                                                if (v.genre != null && v.genre!.isNotEmpty)
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.black87,
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(
                                                          color: Colors.amber[700]!,
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons.music_note,
                                                            size: 12,
                                                            color: Colors.amber[600],
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            v.genre!,
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                
                                                // Stock Badge
                                                Positioned(
                                                  top: 8,
                                                  right: 8,
                                                  child: Container(
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
                                                    child: Text(
                                                      v.stock > 0 ? "Stok: ${v.stock}" : "Habis",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          // Info
                                          Expanded(
                                            flex: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    v.title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    v.artist,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.grey[400],
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.amber[700],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      "Rp ${v.price.toStringAsFixed(0)}",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
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
    );
  }

  String _getSortLabel(SortType type) {
    switch (type) {
      case SortType.priceLow:
        return 'Harga Termurah';
      case SortType.priceHigh:
        return 'Harga Termahal';
      case SortType.stockAvailable:
        return 'Stok Terbanyak';
      case SortType.none:
        return 'Default';
    }
  }
}