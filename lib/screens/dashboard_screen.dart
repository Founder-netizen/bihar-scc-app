import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../models/student_models.dart';
import 'profile_screen.dart';
import 'repayment_screen.dart';
import 'service_request_screen.dart';
import 'notification_screen.dart';
import 'pdf_viewer_screen.dart';
import 'document_vault_screen.dart';
import 'academic_tracker_screen.dart';
import 'chatbot_screen.dart';
import 'track_status_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final ApiService _api = ApiService();
  List<DisbursementRecord> _records = [];
  bool _isLoading = true;



  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);
    try {
      final response = await _api.getDisbursementDetails(auth.user!.registrationId);
      if (response['recordList'] != null) {
        setState(() {
          _records = (response['recordList'] as List)
              .map((e) => DisbursementRecord.fromJson(e))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Fetch data error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      DashboardHome(records: _records, isLoading: _isLoading, onRefresh: _fetchData),
      const RepaymentScreen(),
      const ServiceRequestScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(0xFF004B23),
              unselectedItemColor: Colors.grey.withOpacity(0.5),
              selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 11),
              unselectedLabelStyle: GoogleFonts.outfit(fontSize: 11),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Repayment'),
                BottomNavigationBarItem(icon: Icon(Icons.support_agent_rounded), label: 'Services'),
                BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  final List<DisbursementRecord> records;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const DashboardHome({
    super.key, 
    this.records = const [], 
    this.isLoading = false,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF004B23),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF004B23),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(context, user),
              stretchModes: const [StretchMode.zoomBackground],
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationScreen())),
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(user),
                  const SizedBox(height: 24),
                  _buildCurrentStatusCard(context),
                  const SizedBox(height: 20),
                  _buildBankDetailsCard(context),
                  const SizedBox(height: 24),
                  _buildQuickActions3D(context),
                  const SizedBox(height: 24),
                  _buildNextDisbursementEstimator(),
                  const SizedBox(height: 32),
                  _buildSectionHeader('DISBURSEMENT TRACKER', context),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                  else if (records.isEmpty)
                    _buildEmptyState()
                  else
                    ...records.map((r) => _buildDisbursementCard(r)).toList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StudentProfile user) {
    final userAuth = Provider.of<AuthProvider>(context, listen: false);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF004B23), Color(0xFF0D3D22)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Icon(Icons.account_balance, size: 200, color: Colors.white.withOpacity(0.03)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3), width: 2),
                        ),
                        child: const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white12,
                          child: Icon(Icons.person, color: Color(0xFFFFD700)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: GoogleFonts.outfit(color: Colors.white54, fontSize: 13, letterSpacing: 0.5),
                          ),
                          Text(
                            user.name,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderInfoTile('REGISTRATION ID', user.registrationId),
                      _buildHeaderInfoTile('COURSE', user.course),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeaderActionButton(
                          context, 
                          Icons.verified_user_rounded, 
                          'Sanction\nLetter',
                          'Sanction Letter',
                          userAuth.sanctionLetterPath,
                          userAuth.sanctionLetterBytes,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildHeaderActionButton(
                          context, 
                          Icons.gavel_rounded, 
                          'Agreement\nLetter',
                          'Agreement Letter',
                          userAuth.agreementLetterPath,
                          userAuth.agreementLetterBytes,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildHeaderActionButton(
    BuildContext context, 
    IconData icon, 
    String label, 
    String docTitle, 
    String? docPath, 
    dynamic docBytes,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (docPath != null || docBytes != null) {
            Navigator.push(
              context, 
              MaterialPageRoute(
                builder: (context) => PdfViewerScreen(
                  title: docTitle,
                  pdfPath: docPath,
                  pdfBytes: docBytes,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$docTitle is not available yet.', style: GoogleFonts.outfit()),
                backgroundColor: const Color(0xFFEF6C00),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFFFD700), size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, height: 1.2),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(StudentProfile user) {
    return Row(
      children: [
        _buildStatsCard('SANCTIONED', '₹${user.sanctionAmount}', const Color(0xFF004B23), Icons.verified_rounded),
        const SizedBox(width: 16),
        _buildStatsCard('DISBURSED', '₹${user.totalDisbursed}', const Color(0xFFC9A200), Icons.payments_rounded),
      ],
    );
  }

  Widget _buildStatsCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: GoogleFonts.outfit(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0D1D14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF004B23).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF004B23).withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => TrackStatusScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF6C00).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_city_rounded, color: Color(0xFFEF6C00), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Status',
                        style: GoogleFonts.outfit(color: Colors.black45, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pending at DRCC',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0D1D14)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004B23),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Track', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBankDetailsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_balance_rounded, color: Color(0xFF1976D2), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disbursement Account',
                  style: GoogleFonts.outfit(color: Colors.black45, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  'STATE BANK OF INDIA',
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0D1D14)),
                ),
                const SizedBox(height: 2),
                Text(
                  'A/C: XXXXXXXX4589',
                  style: GoogleFonts.outfit(color: const Color(0xFF1976D2), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextDisbursementEstimator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1D14), Color(0xFF1A3828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0D1D14).withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month_rounded, color: Color(0xFFFFD700), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'NEXT DISBURSEMENT',
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('ESTIMATED', style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '₹ 1,20,000',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Expected around 15th July 2024 for Semester 5.',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.65, // Example progress, e.g., 65% of elapsed time to next date
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Prev: Jan 2024', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10)),
              Text('Next: Jul 2024', style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions3D(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Text(
              'QUICK ACTIONS',
              style: GoogleFonts.outfit(
                fontSize: 12, 
                fontWeight: FontWeight.w800, 
                color: const Color(0xFF004B23).withOpacity(0.6),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _build3DActionCard(
              context,
              'Document\nVault',
              'assets/images/3d_icons/3d_document_vault_1773248373479.png',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentVaultScreen())),
            ),
            const SizedBox(width: 12),
            _build3DActionCard(
              context,
              'AI Chatbot',
              'assets/images/3d_icons/3d_robot_assistant_1773248388169.png',
               () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotScreen())),
            ),
            const SizedBox(width: 12),
            _build3DActionCard(
              context,
              'Academic\nTracker',
               'assets/images/3d_icons/3d_graduation_cap_1773248405072.png',
               () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AcademicTrackerScreen())),
            ),
             const SizedBox(width: 12),
             _build3DActionCard(
              context,
              'Manage\nLoans',
               'assets/images/3d_icons/3d_wallet_coins_1773248423677.png',
               () {
                  // Navigate to Repayment area or show message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Manage Loans coming soon.', style: GoogleFonts.outfit()), backgroundColor: const Color(0xFFEF6C00)),
                  );
               },
            ),
          ],
        ),
      ],
    );
  }

  Widget _build3DActionCard(BuildContext context, String label, String assetPath, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.04)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  width: 48,
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline), // Fallback
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF0D1D14),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12, 
            fontWeight: FontWeight.w800, 
            color: const Color(0xFF004B23).withOpacity(0.6),
            letterSpacing: 2,
          ),
        ),
        TextButton(
          onPressed: () {},
           child: Text('View All', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF004B23))),
        ),
      ],
    );
  }

  Widget _buildDisbursementCard(DisbursementRecord record) {
    bool isSuccess = record.status == 'Success';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSuccess ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isSuccess ? Icons.check_circle_rounded : Icons.pending_rounded,
                color: isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹ ${record.amount}',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'UTR: ${record.utrNo}',
                    style: GoogleFonts.outfit(color: Colors.black45, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.date,
                  style: GoogleFonts.outfit(color: Colors.black38, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSuccess ? const Color(0xFF2E7D32).withOpacity(0.1) : const Color(0xFFEF6C00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    record.status.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: isSuccess ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 48, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No transactions yet.',
            style: GoogleFonts.outfit(color: Colors.black38, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
