import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/vinyl_model.dart';
import '../../services/vinyl_service.dart';

class VinylFormPage extends StatefulWidget {
  final Vinyl? vinyl;
  const VinylFormPage({super.key, this.vinyl});

  @override
  State<VinylFormPage> createState() => _VinylFormPageState();
}

class _VinylFormPageState extends State<VinylFormPage> {
  final _formKey = GlobalKey<FormState>();

  final titleC = TextEditingController();
  final artistC = TextEditingController();
  final yearC = TextEditingController();
  final priceC = TextEditingController();
  final stockC = TextEditingController();
  final descriptionC = TextEditingController();

  // Genre dropdown
  String? selectedGenre;
  final List<String> genreOptions = [
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

  Uint8List? coverBytes;
  String? coverName;

  Uint8List? audioBytes;
  String? audioName;

  bool _isSaving = false;
  
  // Untuk tracking perubahan saat edit
  String? _originalTitle;
  String? _originalArtist;
  String? _originalYear;
  String? _originalPrice;
  String? _originalStock;
  String? _originalGenre;
  String? _originalDescription;

  @override
  void initState() {
    super.initState();
    if (widget.vinyl != null) {
      _originalTitle = widget.vinyl!.title;
      _originalArtist = widget.vinyl!.artist;
      _originalYear = widget.vinyl!.year?.toString() ?? '';
      _originalPrice = widget.vinyl!.price.toString();
      _originalStock = widget.vinyl!.stock.toString();
      _originalGenre = widget.vinyl!.genre ?? '';
      _originalDescription = widget.vinyl!.description ?? '';
      
      titleC.text = widget.vinyl!.title;
      artistC.text = widget.vinyl!.artist;
      
      if (widget.vinyl!.year != null) {
        yearC.text = widget.vinyl!.year.toString();
      }
      
      priceC.text = widget.vinyl!.price.toString();
      stockC.text = widget.vinyl!.stock.toString();
      selectedGenre = widget.vinyl!.genre;
      descriptionC.text = widget.vinyl!.description ?? '';
      
      if (widget.vinyl!.coverUrl != null && widget.vinyl!.coverUrl!.isNotEmpty) {
        coverName = _getFileNameFromUrl(widget.vinyl!.coverUrl!);
      }
      if (widget.vinyl!.audioUrl != null && widget.vinyl!.audioUrl!.isNotEmpty) {
        audioName = _getFileNameFromUrl(widget.vinyl!.audioUrl!);
      }
    }
    
    // Add listeners untuk detect perubahan
    titleC.addListener(_onFieldChanged);
    artistC.addListener(_onFieldChanged);
    yearC.addListener(_onFieldChanged);
    priceC.addListener(_onFieldChanged);
    stockC.addListener(_onFieldChanged);
    descriptionC.addListener(_onFieldChanged);
  }
  
  void _onFieldChanged() {
    setState(() {}); // Rebuild untuk update button state
  }
  
  // Check apakah ada perubahan atau field terisi (untuk mode tambah)
  bool get _hasChanges {
    if (widget.vinyl == null) {
      // Mode tambah: selalu aktif agar user bisa klik dan lihat validasi
      return true;
    }
    
    // Mode edit: cek apakah ada perubahan dari nilai original
    return titleC.text != _originalTitle ||
           artistC.text != _originalArtist ||
           yearC.text != _originalYear ||
           priceC.text != _originalPrice ||
           stockC.text != _originalStock ||
           selectedGenre != _originalGenre ||
           descriptionC.text != _originalDescription ||
           coverBytes != null ||
           audioBytes != null;
  }
  
  String _getFileNameFromUrl(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    return segments.isNotEmpty ? segments.last : 'File terlampir';
  }

  @override
  void dispose() {
    titleC.removeListener(_onFieldChanged);
    artistC.removeListener(_onFieldChanged);
    yearC.removeListener(_onFieldChanged);
    priceC.removeListener(_onFieldChanged);
    stockC.removeListener(_onFieldChanged);
    descriptionC.removeListener(_onFieldChanged);
    
    titleC.dispose();
    artistC.dispose();
    yearC.dispose();
    priceC.dispose();
    stockC.dispose();
    descriptionC.dispose();
    super.dispose();
  }

  void pickImage() async {
    final picker = ImagePicker();
    final res = await picker.pickImage(source: ImageSource.gallery);
    if (res != null) {
      final bytes = await res.readAsBytes();
      setState(() {
        coverBytes = bytes;
        coverName = res.name;
      });
    }
  }

  void pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true,
    );
    if (result != null) {
      setState(() {
        audioBytes = result.files.first.bytes;
        audioName = result.files.first.name;
      });
    }
  }

  void pickYear() async {
    final now = DateTime.now();
    
    DateTime initialDate;
    if (yearC.text.isNotEmpty) {
      final parsedYear = int.tryParse(yearC.text);
      if (parsedYear != null && parsedYear >= 1900 && parsedYear <= now.year + 1) {
        initialDate = DateTime(parsedYear);
      } else {
        initialDate = DateTime(now.year);
      }
    } else {
      initialDate = DateTime(now.year);
    }
    
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.amber[600]!,
              onPrimary: Colors.white,
              surface: const Color(0xFF2d2d2d),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF2d2d2d),
          ),
          child: child!,
        );
      },
    );
    if (selected != null) {
      setState(() {
        yearC.text = selected.year.toString();
      });
    }
  }

  void save() async {
    // Validasi form dulu sebelum parsing
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("⚠️ Mohon lengkapi semua field yang wajib diisi"),
          backgroundColor: Colors.orange[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Parse dengan safe checking
    final year = int.tryParse(yearC.text);
    final price = double.tryParse(priceC.text);
    final stock = int.tryParse(stockC.text);

    // Double check jika parsing gagal (seharusnya tidak terjadi karena sudah divalidasi)
    if (year == null || price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("❌ Ada kesalahan pada format data"),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final ok = await VinylService.saveVinyl(
      id: widget.vinyl?.id,
      title: titleC.text.trim(),
      artist: artistC.text.trim(),
      year: year,
      price: price,
      stock: stock,
      genre: selectedGenre,
      description: descriptionC.text.trim().isNotEmpty ? descriptionC.text.trim() : null,
      coverBytes: coverBytes,
      coverName: coverName,
      audioBytes: audioBytes,
      audioName: audioName,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.vinyl == null ? "✅ Vinyl berhasil ditambahkan!" : "✅ Vinyl berhasil diupdate!"),
          backgroundColor: const Color(0xFF1a1a1a),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("❌ Gagal menyimpan vinyl"),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        inputFormatters: inputFormatters,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.amber[600]),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[700]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.amber[600]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[900]!.withOpacity(0.5),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: DropdownButtonFormField<String>(
        value: selectedGenre,
        style: const TextStyle(color: Colors.white),
        dropdownColor: const Color(0xFF2d2d2d),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: "Genre *",
          labelStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.music_note, color: Colors.amber[600]),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[700]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[700]!, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.amber[600]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[900]!.withOpacity(0.5),
        ),
        items: genreOptions.map((genre) {
          return DropdownMenuItem<String>(
            value: genre,
            child: Text(genre),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedGenre = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Genre wajib dipilih";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildFilePickerButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required String? fileName,
    required Color color,
    bool existingFile = false,
  }) {
    final hasFile = fileName != null || existingFile;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: hasFile ? Colors.amber[600]! : Colors.grey[700]!,
                width: 2,
              ),
              gradient: hasFile
                  ? LinearGradient(
                      colors: [
                        Colors.grey[850]!,
                        Colors.grey[900]!,
                      ],
                    )
                  : null,
              color: !hasFile ? Colors.grey[900]!.withOpacity(0.3) : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fileName ?? (existingFile ? "File sudah terupload" : "Belum dipilih"),
                              style: TextStyle(
                                color: hasFile ? Colors.amber[300] : Colors.grey[500],
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        hasFile ? Icons.check_circle : Icons.upload_file,
                        color: hasFile ? Colors.green[400] : Colors.grey[600],
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.vinyl != null;
    final canSave = !_isSaving && _hasChanges;

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
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900]!.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[800]!,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.amber[600]),
                        onPressed: () => Navigator.pop(context),
                      ),
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
                            child: Text(
                              isEdit ? "EDIT VINYL" : "TAMBAH VINYL",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          Text(
                            isEdit ? "Update informasi vinyl" : "Tambahkan vinyl baru",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.album, color: Colors.amber[600], size: 28),
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Basic Information Section
                      _buildSectionHeader("📀 Informasi Dasar"),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: titleC,
                        label: "Judul Vinyl *",
                        hint: "Contoh: Abbey Road",
                        icon: Icons.album,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Judul vinyl wajib diisi";
                          }
                          if (v.trim().length < 2) {
                            return "Judul minimal 2 karakter";
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: artistC,
                        label: "Artis *",
                        hint: "Contoh: The Beatles",
                        icon: Icons.person,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Artis wajib diisi";
                          }
                          if (v.trim().length < 2) {
                            return "Nama artis minimal 2 karakter";
                          }
                          return null;
                        },
                      ),

                      _buildTextField(
                        controller: yearC,
                        label: "Tahun Rilis *",
                        hint: "Klik untuk pilih tahun",
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: pickYear,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Tahun rilis wajib diisi";
                          }
                          final year = int.tryParse(v);
                          if (year == null) {
                            return "Tahun tidak valid";
                          }
                          if (year < 1900 || year > DateTime.now().year + 1) {
                            return "Tahun harus antara 1900 - ${DateTime.now().year + 1}";
                          }
                          return null;
                        },
                      ),

                      _buildDropdownField(),

                      const SizedBox(height: 24),

                      // Price & Stock Section
                      _buildSectionHeader("💰 Harga & Stok"),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: priceC,
                              label: "Harga (Rp) *",
                              hint: "100000",
                              icon: Icons.payments,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return "Harga wajib diisi";
                                }
                                final price = double.tryParse(v);
                                if (price == null) {
                                  return "Harga tidak valid";
                                }
                                if (price <= 0) {
                                  return "Harga harus lebih dari 0";
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: stockC,
                              label: "Stok *",
                              hint: "10",
                              icon: Icons.inventory_2,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return "Stok wajib diisi";
                                }
                                final stock = int.tryParse(v);
                                if (stock == null) {
                                  return "Stok tidak valid";
                                }
                                if (stock < 0) {
                                  return "Stok tidak boleh negatif";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description Section
                      _buildSectionHeader("📝 Deskripsi"),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: descriptionC,
                        label: "Deskripsi (opsional)",
                        hint: "Ceritakan tentang vinyl ini...",
                        icon: Icons.description,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 24),

                      // Media Files Section
                      _buildSectionHeader("📁 File Media"),
                      const SizedBox(height: 16),

                      _buildFilePickerButton(
                        label: "Cover Vinyl",
                        icon: Icons.image,
                        onPressed: pickImage,
                        fileName: coverName,
                        color: Colors.blue[400]!,
                        existingFile: widget.vinyl?.coverUrl != null && widget.vinyl!.coverUrl!.isNotEmpty,
                      ),

                      _buildFilePickerButton(
                        label: "Audio Preview (MP3)",
                        icon: Icons.audiotrack,
                        onPressed: pickAudio,
                        fileName: audioName,
                        color: Colors.purple[400]!,
                        existingFile: widget.vinyl?.audioUrl != null && widget.vinyl!.audioUrl!.isNotEmpty,
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: canSave
                              ? LinearGradient(
                                  colors: [Colors.amber[700]!, Colors.amber[500]!],
                                )
                              : null,
                          color: !canSave ? Colors.grey[800] : null,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: canSave
                              ? [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          onPressed: canSave ? save : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.save,
                                      size: 24,
                                      color: canSave ? Colors.white : Colors.grey[600],
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isEdit ? "UPDATE VINYL" : "SIMPAN VINYL",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                        color: canSave ? Colors.white : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      if (isEdit && !_hasChanges && !_isSaving)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            "ℹ️ Tidak ada perubahan yang terdeteksi",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber[600]!, Colors.amber[300]!],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[300],
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}