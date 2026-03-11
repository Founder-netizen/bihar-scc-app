import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'chatbot_screen.dart';
import 'drcc_locator_screen.dart';

class ServiceRequestScreen extends StatefulWidget {
  const ServiceRequestScreen({super.key});

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text('Support Center', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF004B23),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionCard(
              'SCC AI Assistant',
              'Get instant, automated answers regarding loan policies, disbursement rules, and basic account queries.',
              Icons.smart_toy_rounded,
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotScreen()));
              },
              isPrimary: true,
            ),
            const SizedBox(height: 16),
             _buildActionCard(
              'Resolution Desk',
              'Request data correction or submit a complex query to the BSEFCL team for your specific loan account.',
              Icons.contact_support_rounded,
              () {
                _showOfficialWebsiteNotice();
              },
              isPrimary: false,
            ),
            const SizedBox(height: 16),
            _buildDrccLocatorCard(context),
            const SizedBox(height: 48),
            Text(
              'ACTIVE REQUESTS',
              style: GoogleFonts.outfit(
                fontSize: 11, 
                fontWeight: FontWeight.w800, 
                color: const Color(0xFF004B23).withOpacity(0.5),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            _buildEmptyRequests(),
            const SizedBox(height: 40),
            _buildContactInfo(),
          ],
        ),
      ),
    );
  }

  void _showOfficialWebsiteNotice() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 32),
            const Icon(Icons.language_rounded, size: 48, color: Color(0xFF004B23)),
            const SizedBox(height: 24),
            Text(
              'Official Portal Required',
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'For security and document verification, new service requests must be initiated through the official MNSSBY web portal.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.black54, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004B23),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('UNDERSTOOD', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap, {bool isPrimary = true}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPrimary 
            ? const [Color(0xFF004B23), Color(0xFF0D3D22)]
            : [Colors.white, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: isPrimary ? null : Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          if (isPrimary) BoxShadow(color: const Color(0xFF004B23).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
          else BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(icon, size: 120, color: isPrimary ? Colors.white.withOpacity(0.05) : const Color(0xFF004B23).withOpacity(0.03)),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPrimary ? Colors.white.withOpacity(0.1) : const Color(0xFF004B23).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: isPrimary ? const Color(0xFFFFD700) : const Color(0xFF004B23), size: 28),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: GoogleFonts.outfit(color: isPrimary ? Colors.white : const Color(0xFF0D1D14), fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(color: isPrimary ? Colors.white70 : Colors.black54, fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPrimary ? const Color(0xFFFFD700) : const Color(0xFFF0F4F2),
                      foregroundColor: isPrimary ? const Color(0xFF0D1D14) : const Color(0xFF004B23),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      isPrimary ? 'START CHAT' : 'CONNECT WITH SUPPORT',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrccLocatorCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DrccLocatorScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF6C00),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find My DRCC',
                        style: GoogleFonts.outfit(color: const Color(0xFF0D1D14), fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get directions to district center',
                        style: GoogleFonts.outfit(color: const Color(0xFFEF6C00), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFEF6C00), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyRequests() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          Icon(Icons.assignment_turned_in_rounded, size: 56, color: Colors.black.withOpacity(0.05)),
          const SizedBox(height: 24),
          Text(
            'System Healthy',
            style: GoogleFonts.outfit(fontSize: 18, color: const Color(0xFF0D1D14), fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t raised any support\ntokens yet.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.black38, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF004B23).withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildContactRow(Icons.alternate_email_rounded, 'support.bsefcl@bihar.gov.in'),
          const SizedBox(height: 16),
          _buildContactRow(Icons.phone_in_talk_rounded, '1800 3456 444 (Toll Free)'),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF004B23)),
        const SizedBox(width: 16),
        Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF0D1D14))),
      ],
    );
  }
}
