import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/models/user.dart';
import 'package:autochef/services/api_profile.dart';
import 'dart:io'; // Untuk File
import 'package:image_picker/image_picker.dart'; // Import Image Picker

class EditProfileScreen extends StatefulWidget {
  final User currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controller
  late TextEditingController _nameController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _isLoading = false;

  // State changes
  bool _nameChanged = false;
  bool _avatarChanged = false;
  
  // Visibility State
  bool _obscureCurrentPassword = true;
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
    _nameController = TextEditingController(text: widget.currentUser.name);
    _currentPasswordController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _selectedAvatar = widget.currentUser.userImage;

    _nameController.addListener(_handleNameChange);
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleNameChange);
    _nameController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleNameChange() {
    final newName = _nameController.text.trim();
    setState(() {
      _nameChanged = (newName != widget.currentUser.name && newName.isNotEmpty);
    });
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      return AssetImage(path);
    }
  }

  Future<void> _updateAvatar(String avatar) async {
    if (_selectedAvatar != avatar) {
      setState(() {
        _selectedAvatar = avatar;
        _avatarChanged = true;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Navigator.pop(context); 

      setState(() => _isLoading = true);
      
      try {
        File file = File(image.path);
        final result = await ApiProfile.uploadProfilePhoto(file);

        if (result['success'] == true) {
          String? newPhotoUrl = result['data']['profile_photo_url']; 
          
          if (newPhotoUrl != null) {
            setState(() {
              _selectedAvatar = newPhotoUrl;
              _avatarChanged = true;
            });
          }
        } else {
          _showNotification(
            icon: Icons.error_outline,
            title: 'Gagal Upload',
            message: result['message'] ?? 'Gagal mengupload foto.',
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
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }
    bool isPasswordFilled = _passwordController.text.isNotEmpty;
    if (isPasswordFilled && _currentPasswordController.text.isEmpty) {
        _showNotification(
          icon: Icons.warning_amber_rounded,
          title: 'Perhatian',
          message: 'Harap isi Password Saat Ini untuk mengubah password.',
          isError: true,
        );
        return;
    }

    if (!_nameChanged && !_avatarChanged && !isPasswordFilled) {
      _showNotification(
        icon: Icons.info_outline,
        title: 'Info',
        message: 'Tidak ada perubahan data diri yang disimpan.',
        isError: false,
        showWarning: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;
      if (_nameChanged || isPasswordFilled) {
        result = await ApiProfile.updateProfile(
          name: _nameController.text.trim(),
          email: widget.currentUser.email,
          avatar: _selectedAvatar,
          password: isPasswordFilled ? _passwordController.text : null,
          passwordConfirmation: isPasswordFilled ? _confirmPasswordController.text : null,
          currentPassword: isPasswordFilled ? _currentPasswordController.text : null,
        );
      } 
      else if (_avatarChanged) {
        result = await ApiProfile.updateAvatar(_selectedAvatar);
      } else {
        result = {'success': false, 'message': 'Tidak ada perubahan.'};
      }

      if (result['success']) {
        _showNotification(
          icon: Icons.check_circle_outline,
          title: 'Berhasil',
          message: 'Profil berhasil diperbarui.',
          isError: false,
        );

        _currentPasswordController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

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
    return Scaffold(
      backgroundColor: const Color(0xFFFBC72A), 
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 50),
                
                // --- HEADER SECTION ---
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
                              color: Colors.white,
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
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              // PERBAIKAN: Menggunakan _getImageProvider agar support Network & Asset
                              child: CircleAvatar(
                                radius: 50,
                                backgroundImage: _getImageProvider(_selectedAvatar),
                                backgroundColor: Colors.grey.shade200,
                              ),
                            ),
                            // Icon Edit
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

                // --- FORM SECTION ---
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

                                  _buildLabel("Password Saat Ini"),
                                  _buildTextField(
                                    controller: _currentPasswordController,
                                    hint: "Password Saat Ini",
                                    isPassword: true,
                                    obscureText: _obscureCurrentPassword,
                                    onToggleVisibility: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  
                                  _buildLabel("Password Baru"),
                                  _buildTextField(
                                    controller: _passwordController,
                                    hint: "Password Baru",
                                    isPassword: true,
                                    obscureText: _obscurePassword,
                                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),

                                  const SizedBox(height: 20),

                                  _buildLabel("Konfirmasi Password Baru"),
                                  _buildTextField(
                                    controller: _confirmPasswordController,
                                    hint: "Konfirmasi Password Baru",
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

                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFBC72A),
                                foregroundColor: Colors.black,
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

  // ... (Widget _buildLabel dan _buildTextField sama seperti sebelumnya, tidak diubah) ...
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)));
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, bool isPassword = false, bool obscureText = false, VoidCallback? onToggleVisibility, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller, obscureText: isPassword ? obscureText : false, validator: validator, autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint, hintStyle: const TextStyle(color: Colors.grey), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.grey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.black, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.red)),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey), onPressed: onToggleVisibility) : null,
      ),
    );
  }

  // --- UPDATE: Dialog Pilih Avatar dengan Tombol Tambah ---
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
                // +1 item count untuk tombol "Tambah Foto"
                itemCount: _avatars.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16),
                itemBuilder: (context, index) {
                  
                  // Item ke-0 adalah Tombol Tambah Foto
                  if (index == 0) {
                     return InkWell(
                      onTap: _pickAndUploadImage, // Panggil fungsi upload
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.grey.shade400, width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.add_a_photo, color: Colors.black54, size: 30),
                        ),
                      ),
                    );
                  }

                  final avatar = _avatars[index - 1];
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

  void _showNotification({required IconData icon, required String title, required String message, required bool isError, bool showWarning = false}) {
    if (!mounted) return;
    Color bgColor = isError ? Colors.red.shade700 : (showWarning ? Colors.orange.shade800 : Colors.green.shade700);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(children: [Icon(icon, color: Colors.white), const SizedBox(width: 10), Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(message)]))]), backgroundColor: bgColor, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.all(10)));
  }
}