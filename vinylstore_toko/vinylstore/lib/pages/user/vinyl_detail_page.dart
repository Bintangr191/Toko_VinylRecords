import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../models/vinyl_model.dart';
import '../../services/catalog_service.dart';
import '../../utils/api_config.dart';

class VinylDetailPage extends StatefulWidget {
  final String vinylId;
  const VinylDetailPage({super.key, required this.vinylId});

  @override
  State<VinylDetailPage> createState() => _VinylDetailPageState();
}

class _VinylDetailPageState extends State<VinylDetailPage> with SingleTickerProviderStateMixin {
  Vinyl? vinyl;
  final player = AudioPlayer();
  bool playing = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  String? reservationStatus;
  bool loadingReservation = false;

  bool wishlisted = false;
  bool loadingWishlist = false;

  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    load();
    
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    player.durationStream.listen((d) {
      if (mounted) {
        setState(() => duration = d ?? Duration.zero);
      }
    });

    player.positionStream.listen((p) {
      if (mounted) {
        setState(() => position = p);
      }
    });

    player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          playing = state.playing;
        });
      }
    });
  }

  Future<void> load() async {
    try {
      vinyl = await CatalogService.getDetail(widget.vinylId);
      
      try {
        reservationStatus = await CatalogService.getReservationStatus(widget.vinylId);
      } catch (e) {
        print('Error loading reservation status: $e');
        reservationStatus = null;
      }
      
      try {
        wishlisted = await CatalogService.isWishlisted(widget.vinylId);
      } catch (e) {
        print('Error loading wishlist status: $e');
        wishlisted = false;
      }
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading vinyl detail: $e');
      if (mounted) {
        _showSnackBar("Error loading data: $e", Colors.red[700]!);
      }
    }
  }

  Future<void> keepVinyl() async {
    if (vinyl == null || loadingReservation) return;

    if (reservationStatus == "active" || reservationStatus == "collected") {
      return;
    }

    if (vinyl!.stock <= 0) {
      _showSnackBar("❌ Stok habis", Colors.red[700]!);
      return;
    }

    final confirmTitle = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = "";
        return AlertDialog(
          backgroundColor: const Color(0xFF2d2d2d),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.bookmark_add, color: Colors.amber[600], size: 28),
              const SizedBox(width: 12),
              const Text(
                "Konfirmasi Reserve",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Ketik judul vinyl untuk konfirmasi:",
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => input = v,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Judul Vinyl",
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  hintText: vinyl!.title,
                  hintStyle: TextStyle(color: Colors.grey[700]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[800]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.amber[600]!, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              style: TextButton.styleFrom(foregroundColor: Colors.grey[400]),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, input.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Konfirmasi"),
            ),
          ],
        );
      },
    );

    if (confirmTitle == null) return;

    setState(() => loadingReservation = true);

    try {
      final success = await CatalogService.keepVinyl(vinyl!.id, confirmTitle);

      if (success) {
        await load();
        _showSnackBar("✅ Vinyl berhasil di-reserve", Colors.green[700]!);
      } else {
        _showSnackBar("❌ Judul tidak sesuai", Colors.red[700]!);
      }
    } catch (e) {
      print('Error keeping vinyl: $e');
      _showSnackBar("❌ Error: $e", Colors.red[700]!);
    } finally {
      if (mounted) {
        setState(() => loadingReservation = false);
      }
    }
  }

  Future<void> toggleWishlist() async {
    if (loadingWishlist) return;

    setState(() => loadingWishlist = true);
    
    try {
      print('Toggling wishlist for vinyl: ${widget.vinylId}');
      final result = await CatalogService.toggleWishlist(widget.vinylId);
      print('Toggle result: $result');

      if (mounted) {
        setState(() {
          wishlisted = result;
          loadingWishlist = false;
        });

        _showSnackBar(
          wishlisted ? "❤️ Ditambahkan ke wishlist" : "💔 Dihapus dari wishlist",
          wishlisted ? Colors.pink[700]! : Colors.grey[700]!,
        );
      }
    } catch (e) {
      print('Error toggling wishlist: $e');
      if (mounted) {
        setState(() => loadingWishlist = false);
        _showSnackBar("❌ Error wishlist: ${e.toString()}", Colors.red[700]!);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    player.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  String get reservationLabel {
    switch (reservationStatus) {
      case "active":
        return "Reserved";
      case "collected":
        return "Collected";
      default:
        return "Reserve";
    }
  }

  bool get reservationDisabled =>
      reservationStatus == "active" || reservationStatus == "collected";

  IconData get reservationIcon {
    switch (reservationStatus) {
      case "active":
        return Icons.check_circle;
      case "collected":
        return Icons.lock;
      default:
        return Icons.bookmark_add;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (vinyl == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1a1a1a),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[600]!),
            strokeWidth: 3,
          ),
        ),
      );
    }

    final coverUrl = ApiConfig.resolveUrl(vinyl!.coverUrl);
    final audioUrl = ApiConfig.resolveUrl(vinyl!.audioUrl);
    final hasAudio = audioUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: loadingWishlist
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      wishlisted ? Icons.favorite : Icons.favorite_border,
                      color: wishlisted ? Colors.pink[400] : Colors.white,
                    ),
              onPressed: loadingWishlist ? null : toggleWishlist,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image with Blur Background
            Stack(
              children: [
                // Blurred background
                SizedBox(
                  height: 420,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) => Container(
                            color: Colors.grey[900],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  const Color(0xFF1a1a1a),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main album cover
                Container(
                  height: 420,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 80),
                  child: Hero(
                    tag: 'vinyl_${vinyl!.id}',
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          coverUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, _, __) => Container(
                            color: Colors.grey[900],
                            child: Icon(
                              Icons.album,
                              size: 100,
                              color: Colors.amber[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content Section
            Container(
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
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Artist
                  Text(
                    vinyl!.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "${vinyl!.artist} • ${vinyl!.year ?? "-"}",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Genre & Stock Row
                  Row(
                    children: [
                      if (vinyl!.genre != null && vinyl!.genre!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[700],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.music_note, size: 14, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                vinyl!.genre!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: vinyl!.stock > 0
                              ? Colors.green[700]
                              : Colors.red[700],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              vinyl!.stock > 0
                                  ? Icons.inventory_2
                                  : Icons.remove_shopping_cart,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              vinyl!.stock > 0 ? "Stok: ${vinyl!.stock}" : "Habis",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber[700]!, Colors.amber[600]!],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 2),
                        Text(
                          "Rp ${vinyl!.price.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  if (vinyl!.description != null && vinyl!.description!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, color: Colors.amber[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Deskripsi",
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900]!.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[800]!),
                          ),
                          child: Text(
                            vinyl!.description!,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Audio Player
                  if (hasAudio)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.grey[900]!,
                            Colors.grey[850]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[800]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.headphones, color: Colors.amber[600], size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Audio Preview",
                                style: TextStyle(
                                  color: Colors.grey[300],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Waveform with FIXED HEIGHT
                          SizedBox(
                            height: 24,
                            child: playing
                                ? AnimatedBuilder(
                                    animation: _waveController,
                                    builder: (context, child) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: List.generate(30, (index) {
                                          final height = 4.0 + 
                                              (20 * 
                                              (0.5 + 0.5 * 
                                              (index % 2 == 0 ? 
                                              (1 - _waveController.value) : 
                                              _waveController.value)));
                                          return Container(
                                            width: 3,
                                            height: height,
                                            margin: const EdgeInsets.symmetric(horizontal: 2),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                                colors: [
                                                  Colors.amber[700]!,
                                                  Colors.amber[400]!,
                                                ],
                                              ),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          );
                                        }),
                                      );
                                    },
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: List.generate(30, (index) {
                                      return Container(
                                        width: 3,
                                        height: 4,
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[700],
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      );
                                    }),
                                  ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Progress bar
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                              activeTrackColor: Colors.amber[600],
                              inactiveTrackColor: Colors.grey[800],
                              thumbColor: Colors.amber[600],
                              overlayColor: Colors.amber.withOpacity(0.2),
                            ),
                            child: Slider(
                              value: position.inSeconds.toDouble(),
                              max: duration.inSeconds.toDouble().clamp(1.0, double.infinity),
                              onChanged: (value) async {
                                final newPosition = Duration(seconds: value.toInt());
                                await player.seek(newPosition);
                              },
                            ),
                          ),
                          
                          // Time labels
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Play button
                          GestureDetector(
                            onTap: () async {
                              if (!playing) {
                                if (position == duration && duration != Duration.zero) {
                                  await player.seek(Duration.zero);
                                }
                                await player.setUrl(audioUrl);
                                player.play();
                              } else {
                                player.pause();
                              }
                            },
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.amber[700]!, Colors.amber[500]!],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                playing ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: reservationDisabled
                                  ? [Colors.grey[800]!, Colors.grey[700]!]
                                  : [Colors.grey[850]!, Colors.grey[800]!],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: reservationDisabled
                                  ? Colors.grey[700]!
                                  : Colors.amber[700]!,
                              width: 2,
                            ),
                          ),
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: loadingReservation
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    reservationIcon,
                                    color: reservationDisabled
                                        ? Colors.grey[500]
                                        : Colors.amber[400],
                                  ),
                            label: Text(
                              reservationLabel,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: reservationDisabled
                                    ? Colors.grey[500]
                                    : Colors.white,
                              ),
                            ),
                            onPressed: reservationDisabled ? null : keepVinyl,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}