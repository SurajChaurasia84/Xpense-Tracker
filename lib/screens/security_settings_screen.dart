import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/security_service.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final security = Provider.of<SecurityService>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Security', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Security',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Protect your financial data with biometric authentication.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black45),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('App Lock', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black87)),
                subtitle: Text('Require Fingerprint, Face ID or PIN to open the app.', style: GoogleFonts.inter(fontSize: 12, color: Colors.black45)),
                value: security.isLockEnabledValue,
                activeColor: const Color(0xFF2E7D32),
                onChanged: (value) async {
                  if (value) {
                    // Show confirmation dialog before enabling
                    bool? confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: Text('Enable App Lock?', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                        content: Text(
                          'When enabled, you will need to authenticate using your device Fingerprint or PIN every time you open Xpense Tracker.',
                          style: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey)),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Enable', style: GoogleFonts.inter()),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    bool available = await security.isBiometricAvailable();
                    if (!available) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Biometric authentication not available on this device')),
                        );
                      }
                      return;
                    }
                  }
                  await security.setLockEnabled(value);
                },
              ),
            ),
            const SizedBox(height: 24),
            _buildSecurityTip(
              Icons.shield_outlined,
              'Your biometric data never leaves your device and is not accessible by Xpense Tracker.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTip(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black38, height: 1.5),
          ),
        ),
      ],
    );
  }
}
