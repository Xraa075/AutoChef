import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/models/user.dart';
import 'package:autochef/services/api_profile.dart';

class EditProfileScreen extends StatefulWidget {
  final User currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _isLoading = false;

  // State changes
  bool _nameChanged = false;
  bool _avatarChanged = false;
  
  // Visibility State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Avatar Data
  final List<String> _avatars = [
    'lib/assets/images/avatar1.png',
    'lib/assets/images/avatar2.png',
    'lib/assets/images/avatar3.png',
    'lib/assets/images/avatar4.png',
    'lib/assets/images/avatar5.png',
    'lib/assets/images/avatar6.png',
    'lib/assets/images/avatar7.png',
  ];
  String _selectedAvatar = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.username);
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _selectedAvatar = widget.currentUser.userImage;

    _nameController.addListener(_handleNameChange);
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleNameChange);
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleNameChange() {
    final newName = _nameController.text.trim();
    setState(() {
      _nameChanged = (newName != widget.currentUser.username && newName.isNotEmpty);
    });
  }

  Future<void> _updateAvatar(String avatar) async {
    if (_selectedAvatar != avatar) {
      setState(() {
        _selectedAvatar = avatar;
        _avatarChanged = true;
      });
    }
  }

  // LOGIC UTAMA: Disesuaikan karena belum ada API Password
  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus(); // Tutup keyboard

    // 1. Cek apakah form valid
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Cek apakah user mencoba mengisi password
    if (_passwordController.text.isNotEmpty || _confirmPasswordController.text.isNotEmpty) {
      // Tampilkan pesan bahwa fitur belum tersedia
      _showNotification(
        icon: Icons.construction, 
        title: 'Dalam Pengembangan', 
        message: 'Mohon maaf, fitur ubah password belum tersedia saat ini.', 
        isError: false,
        showWarning: true
      );
      
      // Jika TIDAK ada perubahan nama/avatar, stop di sini.
      if (!_nameChanged && !_avatarChanged) return;
    }

    // 3. Cek apakah ada perubahan data diri (Nama/Avatar)
    if (!_nameChanged && !_avatarChanged) {
      // Jika password kosong DAN nama/avatar tidak berubah
      if (_passwordController.text.isEmpty) {
        _showNotification(
          icon: Icons.info_outline,
          title: 'Info',
          message: 'Tidak ada perubahan data diri yang disimpan.',
          isError: false,
          showWarning: true,
        );
      }
      return;
    }

    // 4. Proses Update Nama & Avatar (API Profile)
    setState(() => _isLoading = true);

    try {
      // Kita kirim email lama karena updateProfile butuh parameter email,
      // tapi di UI tidak ada field email.
      final result = await ApiProfile.updateProfile(
        name: _nameController.text.trim(),
        email: widget.currentUser.email, 
        avatar: _selectedAvatar,
      );

      if (result['success']) {
        _showNotification(
          icon: Icons.check_circle_outline,
          title: 'Berhasil',
          message: 'Profil berhasil diperbarui.',
          isError: false,
        );
        
        // Delay sedikit lalu kembali
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context, true);

      } else {
        _showNotification(
          icon: Icons.error_outline,
          title: 'Gagal',
          message: result['message'] ?? 'Gagal memperbarui profil.',
          isError: true,
        );
      }
    } catch (e) {
      _showNotification(
        icon: Icons.error_outline,
        title: 'Error',
        message: 'Terjadi kesalahan: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI dibangun semirip mungkin dengan screenshot
    return Scaffold(
      backgroundColor: const Color(0xFFFBC72A), // Latar Kuning
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 50),
                
                // --- HEADER SECTION (Tombol Back & Avatar) ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Tombol Back
                      Align(
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white, // Background putih di tombol back agar terlihat
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back, color: Colors.black),
                          ),
                        ),
                      ),
                      
                      // Avatar Profile
                      GestureDetector(
                        onTap: _showAvatarSelectionDialog,
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4), // Border putih tipis
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: AssetImage(_selectedAvatar),
                                backgroundColor: Colors.grey.shade200,
                              ),
                            ),
                            // Icon Edit (Pensil Hitam)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- FORM SECTION (Putih Melengkung) ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Field Nama
                                  _buildLabel("Nama Kamu"),
                                  _buildTextField(
                                    controller: _nameController,
                                    hint: "Nama Kamu",
                                    validator: (val) => val!.isEmpty ? "Nama tidak boleh kosong" : null,
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  // Field Password (UI Only untuk sekarang)
                                  _buildLabel("Password"),
                                  _buildTextField(
                                    controller: _passwordController,
                                    hint: "Password",
                                    isPassword: true,
                                    obscureText: _obscurePassword,
                                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),

                                  const SizedBox(height: 20),

                                  // Field Konfirmasi Password
                                  _buildLabel("Konfirmasi Password"),
                                  _buildTextField(
                                    controller: _confirmPasswordController,
                                    hint: "Konfirmasi Password",
                                    isPassword: true,
                                    obscureText: _obscureConfirmPassword,
                                    onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    validator: (val) {
                                      if (val!.isNotEmpty && val != _passwordController.text) {
                                        return "Password tidak cocok";
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Tombol Simpan
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFBC72A), // Warna Kuning sesuai desain
                                foregroundColor: Colors.black, // Teks hitam
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: _isLoading 
                                ? const CircularProgressIndicator(color: Colors.black)
                                : const Text(
                                    "Simpan",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Loading Overlay
            if (_isLoading)
              Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator(color: Color(0xFFF46A06))),
              ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.grey), // Border abu-abu saat diam
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.black, width: 1.5), // Border hitam saat fokus
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }

  // Dialog Pilih Avatar
  void _showAvatarSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFBC72A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Text('Pilih Avatar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16),
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  final avatar = _avatars[index];
                  final isSelected = _selectedAvatar == avatar;
                  return InkWell(
                    onTap: () { _updateAvatar(avatar); Navigator.pop(context); },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey.shade300, 
                          width: isSelected ? 3 : 2
                        ),
                      ),
                      child: CircleAvatar(backgroundImage: AssetImage(avatar), backgroundColor: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Notifikasi Snackbar
  void _showNotification({
    required IconData icon, required String title, required String message, required bool isError, bool showWarning = false,
  }) {
    if (!mounted) return;
    Color bgColor = isError ? Colors.red.shade700 : (showWarning ? Colors.orange.shade800 : Colors.green.shade700);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(icon, color: Colors.white), 
          const SizedBox(width: 10), 
          Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), 
            Text(message)
          ]))
        ]),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}