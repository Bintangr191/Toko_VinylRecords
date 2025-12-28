import 'package:flutter/material.dart';
import '../../models/reservation_model.dart';
import '../../services/catalog_service.dart';

class ReservationAdminPage extends StatefulWidget {
  const ReservationAdminPage({super.key});

  @override
  State<ReservationAdminPage> createState() => _ReservationAdminPageState();
}

class _ReservationAdminPageState extends State<ReservationAdminPage> {
  late Future<List<Reservation>> future;
  List<Reservation> allReservations = [];
  
  final searchController = TextEditingController();
  String selectedStatusFilter = 'Semua';
  
  final List<String> statusFilterOptions = [
    'Semua',
    'active',
    'collected',
    'expired',
  ];

  @override
  void initState() {
    super.initState();
    future = CatalogService.getAllReservations();
    searchController.addListener(() {
      setState(() {}); // Simple setState untuk rebuild
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> refresh() async {
    setState(() {
      future = CatalogService.getAllReservations();
    });
  }

  List<Reservation> _getFilteredReservations() {
    return allReservations.where((reservation) {
      // Filter by search query (username)
      final searchQuery = searchController.text.toLowerCase();
      final matchesSearch = searchQuery.isEmpty ||
          (reservation.userName?.toLowerCase().contains(searchQuery) ?? false);
      
      // Filter by status
      final matchesStatus = selectedStatusFilter == 'Semua' ||
          reservation.status == selectedStatusFilter;
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  String formatPrice(double? price) {
    if (price == null) return "-";
    return "Rp ${price.toStringAsFixed(0)}";
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'collected':
        return 'Diambil';
      case 'expired':
        return 'Kadaluarsa';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.orange;
      case 'collected':
        return Colors.green;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.schedule;
      case 'collected':
        return Icons.check_circle;
      case 'expired':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [Colors.amber[600]!, Colors.amber[200]!],
                                ).createShader(bounds),
                                child: const Text(
                                  "RESERVASI",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              Text(
                                "Kelola reservasi vinyl",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.bookmark, color: Colors.amber[600], size: 28),
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
                          hintText: "Cari berdasarkan username...",
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
                    
                    // Status Filter Chips
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: statusFilterOptions.map((status) {
                          final isSelected = selectedStatusFilter == status;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                status == 'Semua' ? status : getStatusLabel(status),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  selectedStatusFilter = status;
                                });
                              },
                              backgroundColor: Colors.grey[800],
                              selectedColor: Colors.amber[700],
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[400],
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: FutureBuilder<List<Reservation>>(
                  future: future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Memuat reservasi...",
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 60, color: Colors.red[400]),
                            const SizedBox(height: 16),
                            Text(
                              "Gagal memuat data",
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${snapshot.error}",
                              style: TextStyle(color: Colors.grey[500], fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    allReservations = snapshot.data ?? [];
                    final filteredReservations = _getFilteredReservations();

                    if (filteredReservations.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              searchController.text.isNotEmpty || selectedStatusFilter != 'Semua'
                                  ? Icons.search_off
                                  : Icons.bookmark_border,
                              size: 80,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchController.text.isNotEmpty || selectedStatusFilter != 'Semua'
                                  ? "Tidak ada hasil"
                                  : "Belum ada reservasi",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              searchController.text.isNotEmpty || selectedStatusFilter != 'Semua'
                                  ? "Coba kata kunci atau filter lain"
                                  : "Reservasi akan muncul di sini",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: refresh,
                      color: Colors.amber[600],
                      backgroundColor: const Color(0xFF2d2d2d),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredReservations.length,
                        itemBuilder: (context, index) {
                          final r = filteredReservations[index];
                          final statusColor = getStatusColor(r.status);
                          final statusIcon = getStatusIcon(r.status);

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
                                color: statusColor.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with Status Badge
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          r.vinyl?.title ?? "Vinyl tidak tersedia",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: statusColor,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              statusIcon,
                                              color: statusColor,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              getStatusLabel(r.status),
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // Vinyl Info
                                  Row(
                                    children: [
                                      Icon(Icons.person, size: 16, color: Colors.grey[500]),
                                      const SizedBox(width: 6),
                                      Text(
                                        r.vinyl?.artist ?? '-',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 6),
                                  
                                  Row(
                                    children: [
                                      Icon(Icons.payments, size: 16, color: Colors.grey[500]),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber[700],
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          formatPrice(r.vinyl?.price),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(height: 12),
                                  
                                  Divider(color: Colors.grey[800], height: 1),
                                  
                                  const SizedBox(height: 12),
                                  
                                  // User Info
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.amber[700]!.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.account_circle,
                                          color: Colors.amber[600],
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Direservasi oleh:",
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 11,
                                              ),
                                            ),
                                            Text(
                                              r.userName ?? 'Tidak diketahui',
                                              style: TextStyle(
                                                color: Colors.amber[300],
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Action Buttons
                                  if (r.status == "active") ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.green[700]!, Colors.green[500]!],
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton.icon(
                                              onPressed: () async {
                                                await CatalogService.updateReservationStatus(
                                                    r.id, "collected");
                                                refresh();
                                              },
                                              icon: const Icon(Icons.check_circle, size: 20),
                                              label: const Text(
                                                "Sudah Diambil",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                padding: const EdgeInsets.symmetric(vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () async {
                                              await CatalogService.updateReservationStatus(
                                                  r.id, "expired");
                                              refresh();
                                            },
                                            icon: const Icon(Icons.cancel, size: 20),
                                            label: const Text(
                                              "Expired",
                                              style: TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red[400],
                                              side: BorderSide(color: Colors.red[400]!, width: 2),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}