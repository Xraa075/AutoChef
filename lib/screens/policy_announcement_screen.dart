import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:autochef/routes.dart';

class PolicyAnnouncementScreen extends StatelessWidget {
  const PolicyAnnouncementScreen({super.key});

  Future<void> _handleAcknowledge(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenPolicyAnnouncement', true);

    await prefs.setBool('hasLoggedAsUser', false);
    await prefs.remove('userToken');
    await prefs.remove('userData');
    await prefs.remove('userId');
    await prefs.remove('userEmail');
    await prefs.remove('userName');

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFFFBC72A).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.announcement_outlined,
                          color: Color(0xFFF46A06),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pemberitahuan Pembaruan\nKebijakan Layanan – AutoChef',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kepada, Pengguna AutoChef',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Dalam rangka meningkatkan kualitas layanan dan keamanan data pengguna, kami telah melakukan pembaruan terhadap kebijakan layanan AutoChef.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text.rich(
                            TextSpan(
                              text:
                                  'Sehubungan dengan hal tersebut, seluruh pengguna diwajibkan untuk melakukan ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade700,
                                height: 1.6,
                              ),
                              children: [
                                TextSpan(
                                  text: 'registrasi ulang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFF46A06),
                                    fontWeight: FontWeight.w600,
                                    height: 1.6,
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      ' guna melanjutkan penggunaan aplikasi secara optimal.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade700,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Kami menghargai kerja sama dan pengertian Anda.\nTerima kasih telah menjadi bagian dari AutoChef.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade700,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Salam hangat,\nTim AutoChef',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleAcknowledge(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF46A06),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Saya Mengerti',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
