import 'package:flutter/material.dart';
import 'package:autochef/models/user.dart';
import 'package:autochef/services/api_profile.dart';

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
  late TextEditingController _confirmPasswordController;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _showPasswordSection = false;
  bool _nameChanged = false;
  bool _emailChanged = false;

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
    _confirmPasswordController = TextEditingController();
    _selectedAvatar = widget.currentUser.userImage;

    // Tambahkan listener untuk mendeteksi perubahan
    _nameController.addListener(() {
      if (_nameController.text.trim() != widget.currentUser.username) {
        setState(() => _nameChanged = true);
      } else {
        setState(() => _nameChanged = false);
      }
    });

    _emailController.addListener(() {
      if (_emailController.text.trim() != widget.currentUser.email) {
        setState(() => _emailChanged = true);
      } else {
        setState(() => _emailChanged = false);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Update profile information
  Future<void> _updateProfile() async {
    // Jika tidak ada perubahan, langsung kembali
    if (!_nameChanged &&
        !_emailChanged &&
        _selectedAvatar == widget.currentUser.userImage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada perubahan pada profil'),
          backgroundColor: Colors.blueGrey,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Periksa token terlebih dahulu
    bool tokenValid = await ApiProfile.checkAndRefreshToken();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Update profile using API service
      final result = await ApiProfile.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        avatar: _selectedAvatar,
      );

      // Handle result
      if (result['success']) {
        _showNotification(
          icon: Icons.check_circle_outline,
          title: 'Berhasil',
          message: result['message'] ?? 'Profil berhasil diperbarui',
          isError: false,
        );

        // Wait 1 second before returning to profile screen
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
        }
      } else {
        String errorMsg = result['message'] ?? 'Gagal memperbarui profil';

        // Khusus untuk guest
        if (result['isGuest'] == true) {
          _showLoginDialog();
        } else if (result['isOffline'] == true) {
          _showNotification(
            icon: Icons.cloud_off,
            title: 'Disimpan Lokal',
            message:
                'Perubahan disimpan di perangkat, tapi tidak tersinkronisasi ke server',
            isError: false,
            showWarning: true,
          );
        } else {
          _showNotification(
            icon: Icons.error_outline,
            title: 'Gagal',
            message: errorMsg,
            isError: true,
          );
        }
      }
    } catch (e) {
      _showNotification(
        icon: Icons.error_outline,
        title: 'Error',
        message: 'Terjadi kesalahan tidak terduga',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Tambahkan metode untuk menampilkan dialog login
  void _showLoginDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.login, color: Color(0xFFF46A06)),
              SizedBox(width: 10),
              Text("Login Diperlukan"),
            ],
          ),
          content: Text(
            "Silahkan login terlebih dahulu untuk menyimpan perubahan profil Anda.",
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
              },
              child: Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF46A06),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                // Redirect ke halaman login
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: Text('Login Sekarang'),
            ),
          ],
        );
      },
    );
  }

  // Update password
  Future<void> _updatePassword() async {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showNotification(
        icon: Icons.info_outline,
        title: 'Validasi',
        message: 'Semua field password harus diisi',
        isError: true,
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showNotification(
        icon: Icons.info_outline,
        title: 'Validasi',
        message: 'Password baru dan konfirmasi password tidak cocok',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call API to change password
      final result = await ApiProfile.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (result['success']) {
        _showNotification(
          icon: Icons.lock_outline,
          title: 'Password Diubah',
          message: 'Password berhasil diperbarui',
          isError: false,
        );

        // Clear password fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
        // Hide the password section after successful update
        setState(() {
          _showPasswordSection = false;
        });
      } else {
        _showNotification(
          icon: Icons.error_outline,
          title: 'Gagal',
          message: result['message'] ?? 'Gagal mengubah password',
          isError: true,
        );
      }
    } catch (e) {
      _showNotification(
        icon: Icons.error_outline,
        title: 'Error',
        message: 'Terjadi kesalahan tidak terduga',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update avatar locally
  Future<void> _updateAvatar(String avatar) async {
    setState(() {
      _selectedAvatar = avatar;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  // Menampilkan notifikasi yang lebih menarik
  void _showNotification({
    required IconData icon,
    required String title,
    required String message,
    required bool isError,
    bool showWarning = false,
  }) {
    setState(() {
      if (isError) {
        _errorMessage = message;
        _successMessage = null;
      } else {
        _successMessage = message;
        _errorMessage = null;
      }
    });

    // Tampilkan snackbar yang lebih menarik
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
                  Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        backgroundColor:
            isError
                ? Colors.red.shade800
                : (showWarning ? Colors.amber.shade800 : Colors.green.shade800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasChanges =
        _nameChanged ||
        _emailChanged ||
        _selectedAvatar != widget.currentUser.userImage;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: const Color(0xFFFBC72A),
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Konfirmasi jika ada perubahan
            if (hasChanges) {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
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
                            Navigator.pop(
                              context,
                            ); // kembali ke halaman sebelumnya
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
        actions: [
          // Save button yang lebih mencolok dan hanya aktif ketika ada perubahan
          if (hasChanges)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _updateProfile,
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF46A06),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFF46A06)),
                    SizedBox(height: 16),
                    Text('Memproses...'),
                  ],
                ),
              )
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header dengan avatar
                      _buildHeader(),

                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Info Section
                            _buildProfileSection(),

                            const SizedBox(height: 16),

                            // Password Section
                            _buildPasswordSection(),

                            const SizedBox(height: 30),

                            // Tombol di bagian bawah
                            if (hasChanges)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _updateProfile,
                                  icon: const Icon(Icons.save),
                                  label: const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF46A06),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  // Header dengan avatar
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 30, top: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFBC72A).withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            // Avatar dengan badge indikator perubahan
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
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
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nama Pengguna di bawah avatar
            Text(
              _nameController.text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),

            // Email di bawah nama
            Text(
              _emailController.text,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  // Bagian profil
  Widget _buildProfileSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFFF46A06)),
                const SizedBox(width: 8),
                const Text(
                  'Informasi Profil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_nameChanged || _emailChanged)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Diubah',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama',
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon:
                    _nameChanged
                        ? Icon(Icons.check_circle, color: Colors.green.shade600)
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF46A06)),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon:
                    _emailChanged
                        ? Icon(Icons.check_circle, color: Colors.green.shade600)
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFF46A06)),
                ),
              ),
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
    );
  }

  // Bagian password
  Widget _buildPasswordSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _showPasswordSection = !_showPasswordSection;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Color(0xFFF46A06)),
                    const SizedBox(width: 8),
                    const Text(
                      'Ubah Password',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      _showPasswordSection
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            // Animasi tampilan password
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState:
                  _showPasswordSection
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
              firstChild: const SizedBox(height: 0),
              secondChild: Column(
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password Saat Ini',
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFF46A06)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFF46A06)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      prefixIcon: const Icon(Icons.check_circle_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFF46A06)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF46A06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _updatePassword,
                      child: const Text(
                        'Ubah Password',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog pemilihan avatar
  void _showAvatarSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
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
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                            border:
                                isSelected
                                    ? Border.all(
                                      color: const Color(0xFFF46A06),
                                      width: 3,
                                    )
                                    : Border.all(
                                      color: Colors.grey.shade300,
                                      width: 2,
                                    ),
                            boxShadow:
                                isSelected
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
