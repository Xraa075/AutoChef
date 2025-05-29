import 'package:flutter/material.dart';
import 'package:autochef/models/user.dart'; // Assuming User model exists
import 'package:autochef/services/api_profile.dart'; // Assuming ApiProfile service exists

class EditProfileScreen extends StatefulWidget {
  final User currentUser;

  const EditProfileScreen({super.key, required this.currentUser});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  bool _isLoading = false;
  bool _nameChanged = false;
  bool _emailChanged = false;
  bool _avatarChanged = false;
  bool _passwordFieldsNotEmpty = false;

  // List of available avatars
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
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentUser.username);
    _emailController = TextEditingController(text: widget.currentUser.email);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _selectedAvatar = widget.currentUser.userImage;

    _nameController.addListener(_handleNameChange);
    _emailController.addListener(_handleEmailChange);
    _currentPasswordController.addListener(_handlePasswordFieldsChange);
    _newPasswordController.addListener(_handlePasswordFieldsChange);
  }

  void _handleNameChange() {
    final newName = _nameController.text.trim();
    if (newName != widget.currentUser.username && newName.isNotEmpty) {
      if (!_nameChanged) setState(() => _nameChanged = true);
    } else {
      if (_nameChanged) setState(() => _nameChanged = false);
    }
    // Update header text immediately
    setState(() {});
  }

  void _handleEmailChange() {
    final newEmail = _emailController.text.trim();
    if (newEmail != widget.currentUser.email &&
        newEmail.contains('@') &&
        newEmail.contains('.')) {
      if (!_emailChanged) setState(() => _emailChanged = true);
    } else {
      if (_emailChanged) setState(() => _emailChanged = false);
    }
    // Update header text immediately
    setState(() {});
  }

  void _handlePasswordFieldsChange() {
    final bool currentlyNotEmpty =
        _currentPasswordController.text.isNotEmpty ||
            _newPasswordController.text.isNotEmpty;
    if (_passwordFieldsNotEmpty != currentlyNotEmpty) {
      setState(() {
        _passwordFieldsNotEmpty = currentlyNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_handleNameChange);
    _emailController.removeListener(_handleEmailChange);
    _currentPasswordController.removeListener(_handlePasswordFieldsChange);
    _newPasswordController.removeListener(_handlePasswordFieldsChange);

    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfileAndOrPassword() async {
    final bool profileDataHasChanged =
        _nameChanged || _emailChanged || _avatarChanged;
    final bool passwordFieldsAreFilled =
        _currentPasswordController.text.isNotEmpty ||
            _newPasswordController.text.isNotEmpty;

    if (!profileDataHasChanged && !passwordFieldsAreFilled) {
      _showNotification(
        icon: Icons.info_outline,
        title: 'Informasi',
        message: 'Tidak ada perubahan untuk disimpan.',
        isError: false,
        showWarning: true,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      bool anySuccess = false;
      String successDetails = "";
      List<String> errorMessages = [];

      // 1. Update Profile (if changes exist)
      if (profileDataHasChanged) {
        final result = await ApiProfile.updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          avatar: _selectedAvatar,
        );

        if (result['success']) {
          anySuccess = true;
          successDetails += "Profil berhasil diperbarui. ";

          setState(() {
            _nameChanged = false;
            _emailChanged = false;
            _avatarChanged = false;
          });
        } 
      }

      // 2. Change Password (if fields are filled)
      if (passwordFieldsAreFilled) {
        if (_currentPasswordController.text.isEmpty ||
            _newPasswordController.text.isEmpty) {
          errorMessages.add(
            'Semua field password harus diisi untuk mengubah password.',
          );
        } else {
          final passResult = await ApiProfile.changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );

          if (passResult['success']) {
            anySuccess = true;
            successDetails += "Password berhasil diubah. ";
            _currentPasswordController.clear();
            _newPasswordController.clear();
            setState(() {
              _passwordFieldsNotEmpty = false; // Reset flag after clearing
            });
          } else {
            errorMessages.add(
              passResult['message'] ?? 'Gagal mengubah password.',
            );
          }
        }
      }

      // 3. Consolidate notifications and navigation
      if (anySuccess && errorMessages.isEmpty) {
        _showNotification(
          icon: Icons.check_circle_outline,
          title: 'Berhasil',
          message: successDetails.trim().isEmpty
              ? 'Perubahan berhasil disimpan.'
              : successDetails.trim(),
          isError: false,
        );
        await Future.delayed(
          const Duration(seconds: 2),
        ); 
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else if (errorMessages.isNotEmpty) {
        _showNotification(
          icon: Icons.error_outline,
          title: 'Gagal',
          message: errorMessages.join('\n'),
          isError: true,
        );
      }
    } catch (e) {
      _showNotification(
        icon: Icons.error_outline,
        title: 'Error',
        message: 'Terjadi kesalahan tidak terduga: ${e.toString()}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  void _showNotification({
    required IconData icon,
    required String title,
    required String message,
    required bool isError,
    bool showWarning = false,
  }) {
    if (mounted) {
      setState(() {
        if (isError) {
        } else if (!showWarning) {
          // Don't overwrite success message if it's just a warning
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: isError
              ? Colors.red.shade800
              : (showWarning
                  ? Colors.amber.shade800
                  : Colors.green.shade800),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasOverallChanges = _nameChanged ||
        _emailChanged ||
        _avatarChanged ||
        _passwordFieldsNotEmpty;

    return Scaffold(
      backgroundColor: Color(0xFFFBC72A),
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: const Color(0xFFFBC72A),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (hasOverallChanges) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('Perubahan Belum Disimpan'),
                  content: const Text(
                    'Anda memiliki perubahan yang belum disimpan. Yakin ingin keluar?',
                  ),
                  actions: [
                    TextButton(
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text(
                        'Ya, Keluar',
                        style: TextStyle(color: Color(0xFFF46A06)),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // tutup dialog
                        Navigator.pop(context); // kembali ke halaman sebelumnya
                      },
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        actions: [], // Removed the save button from here
      ),
      body: _isLoading
          ? Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        color: const Color(0xFFF46A06),
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        strokeWidth: 6,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Menyimpan perubahan...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(28),
                          topRight: Radius.circular(28),
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileSection(),
                            const SizedBox(height: 16),
                            _buildPasswordSection(),
                            const SizedBox(height: 30), // Spacing before the button
                            if (hasOverallChanges)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0), // Optional: add some bottom padding if needed
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading
                                      ? null
                                      : _updateProfileAndOrPassword,
                                  label: const Text('Simpan Perubahan'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF46A06),
                                    foregroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
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
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Color(0xFFFBC72A), // Ensure header background is consistent
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage(_selectedAvatar),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _showAvatarSelectionDialog,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF46A06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                if (_avatarChanged) // Indicator for avatar change
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Icon(Icons.check, color: Colors.white, size: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _nameController.text, // Dynamically update from controller
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              _emailController.text, // Dynamically update from controller
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 230, 230, 230), // Softer border
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Color(0xFFF46A06), size: 22),
                const SizedBox(width: 10),
                const Text(
                  'Informasi Profil',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const Spacer(),
                if (_nameChanged ||
                    _emailChanged) // Show "Diubah" if name or email changed
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF46A06).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFF46A06).withOpacity(0.3),
                      ),
                    ),
                    child: const Text(
                      'Diubah',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF46A06),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        hintText: 'Masukkan nama lengkap',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFF46A06),
                          ),
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        hintText: 'Masukkan email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFF46A06),
                          ),
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Email tidak valid';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 10),
            margin: const EdgeInsets.only(bottom: 10), // Add margin for spacing
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock, color: Color(0xFFF46A06), size: 22),
                SizedBox(width: 10),
                Text(
                  'Ubah Password (Opsional)', // Make it clear it's optional
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
          _buildPasswordTextField(
            controller: _currentPasswordController,
            labelText: 'Password Saat Ini',
            hintText: 'Masukkan password saat ini',
          ),
          const SizedBox(height: 12), // Consistent spacing
          _buildPasswordTextField(
            controller: _newPasswordController,
            labelText: 'Password Baru',
            hintText: 'Masukkan password baru',
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFF46A06)),
            ),
          ),
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  void _showAvatarSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFBC72A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.face, color: Colors.black),
                  const SizedBox(width: 10),
                  const Text(
                    'Pilih Avatar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // If content might overflow
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  final avatar = _avatars[index];
                  final bool isSelected = _selectedAvatar == avatar;
                  return InkWell(
                    onTap: () {
                      _updateAvatar(avatar);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFFF46A06),
                                width: 3,
                              )
                            : Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFF46A06,
                                  ).withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: CircleAvatar(
                        backgroundImage: AssetImage(avatar),
                        backgroundColor: Colors.white,
                      ),
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
}