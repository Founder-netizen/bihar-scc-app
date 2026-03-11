import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../providers/auth_provider.dart';
import 'academic_tracker_screen.dart';
import 'document_vault_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
       appBar: AppBar(
        title: Text('Account Profile', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF004B23),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Premium Profile Header
            _buildProfileHeader(user),
            const SizedBox(height: 48),
            
            _buildSectionCard('PERSONAL DETAILS', [
              _buildInfoRow(Icons.phone_iphone_rounded, 'Mobile Contact', user.mobile),
              _buildInfoRow(Icons.alternate_email_rounded, 'Registered Email', user.email),
              _buildInfoRow(Icons.fingerprint_rounded, 'Identity / Reg ID', user.registrationId),
            ]),
            const SizedBox(height: 20),
            
             _buildSectionCard('ACADEMIC FOOTPRINT', [
              _buildInfoRow(Icons.castle_rounded, 'Learning Institute', user.institute),
              _buildInfoRow(Icons.auto_stories_rounded, 'Enrolled Course', user.course),
              _buildInfoRow(Icons.account_balance_rounded, 'Loan Account', user.loanNumber ?? 'NA'),
            ]),
            const SizedBox(height: 20),
            _buildAcademicTrackerButton(context),
            const SizedBox(height: 16),
            _buildDocumentVaultButton(context),
            const SizedBox(height: 40),
            _buildPreferencesSection(),
            const SizedBox(height: 40),
            _buildApiSettingsSection(context),
            const SizedBox(height: 40),
            _buildSyncSection(context),
            const SizedBox(height: 40),
            _buildCredits(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700), width: 2),
            ),
            child: CircleAvatar(
              radius: 54,
              backgroundColor: const Color(0xFF004B23),
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w800, color: const Color(0xFFFFD700)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user.name.toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0D1D14)),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF004B23).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'VERIFIED STUDENT',
              style: GoogleFonts.outfit(color: const Color(0xFF004B23), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1D14),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.sync_rounded, color: Color(0xFFFFD700), size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data Synchronization',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                Text(
                  'Refresh account details from portal',
                  style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile records updated successfully.')),
              );
            },
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicTrackerButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AcademicTrackerScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academic Tracker',
                        style: GoogleFonts.outfit(color: const Color(0xFF0D1D14), fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View CGPA & upload marksheets',
                        style: GoogleFonts.outfit(color: const Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF2E7D32), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentVaultButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFECB3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const DocumentVaultScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF57F17), // Dark Yellow/Orange
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.security_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secure Document Vault',
                        style: GoogleFonts.outfit(color: const Color(0xFF0D1D14), fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Access verified DRCC documents',
                        style: GoogleFonts.outfit(color: const Color(0xFFF57F17), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFF57F17), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSectionCard('APP PREFERENCES', [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
               Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.notifications_active_rounded, size: 20, color: Color(0xFF004B23)),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Notifications',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF0D1D14)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Alerts for EMIs & pending docs',
                    style: GoogleFonts.outfit(color: Colors.black45, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: true, 
            onChanged: (val) {}, 
            activeColor: const Color(0xFF004B23),
            activeTrackColor: const Color(0xFF004B23).withOpacity(0.3),
          ),
        ],
      ),
    ]);
  }

  Widget _buildApiSettingsSection(BuildContext context) {
    return _buildSectionCard('AI ASSISTANT SETTINGS', [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
               Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.vpn_key_rounded, size: 20, color: Color(0xFF004B23)),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Groq API Key',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF0D1D14)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Required for intelligent chat',
                    style: GoogleFonts.outfit(color: Colors.black45, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () {
              _showApiKeyDialog(context);
            },
            icon: const Icon(Icons.edit_rounded, color: Color(0xFF004B23)),
          ),
        ],
      ),
    ]);
  }

  void _showApiKeyDialog(BuildContext context) async {
    final storage = const FlutterSecureStorage();
    final currentKey = await storage.read(key: 'groq_api_key') ?? '';
    final controller = TextEditingController(text: currentKey);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Groq API Key', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter your gsk_... key',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF004B23), width: 2),
              ),
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () async {
                await storage.write(key: 'groq_api_key', value: controller.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API Key saved successfully!')),
                  );
                }
              },
              child: Text('SAVE', style: GoogleFonts.outfit(color: const Color(0xFF004B23), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 10, 
              fontWeight: FontWeight.w800, 
              color: const Color(0xFF004B23).withOpacity(0.4),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF004B23)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.outfit(color: Colors.black26, fontSize: 10, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14, color: const Color(0xFF0D1D14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredits() {
    return Column(
      children: [
        Text(
          'Bihar Student Credit Card Scheme',
          style: GoogleFonts.outfit(color: Colors.black12, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          'Version 2.0.0 (Premium Build)',
          style: GoogleFonts.outfit(color: Colors.black12, fontSize: 9),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Sign Out?', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to end your current session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Safely call logout after dialog dismisses
              Future.microtask(() {
                if (context.mounted) {
                  Provider.of<AuthProvider>(context, listen: false).logout();
                }
              });
            },
            child: Text('LOGOUT', style: GoogleFonts.outfit(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
