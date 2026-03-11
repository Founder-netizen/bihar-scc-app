import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrackStatusScreen extends StatelessWidget {
  const TrackStatusScreen({super.key});

  final List<Map<String, dynamic>> statusSteps = const [
    {
      'title': 'Submitted',
      'description': 'Application successfully submitted online.',
      'icon': Icons.description_rounded,
      'isCompleted': true,
      'date': 'Oct 12, 2023',
    },
    {
      'title': 'Institute Verified',
      'description': 'Verification completed by the educational institute.',
      'icon': Icons.domain_verification_rounded,
      'isCompleted': true,
      'date': 'Oct 25, 2023',
    },
    {
      'title': 'DRCC Verification',
      'description': 'Document verification at District Registration & Counseling Center.',
      'icon': Icons.location_city_rounded,
      'isCompleted': true,
      'date': 'Nov 05, 2023',
    },
    {
      'title': 'Sanctioned',
      'description': 'Loan amount approved by BSFC.',
      'icon': Icons.fact_check_rounded,
      'isCompleted': false,
      'date': 'Pending',
    },
    {
      'title': 'Disbursed',
      'description': 'Amount transferred to the respective accounts.',
      'icon': Icons.account_balance_rounded,
      'isCompleted': false,
      'date': 'Pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text('Track Status', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF004B23),
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildCurrentStatusHeader(),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildTimelineStep(
                    step: statusSteps[index],
                    isFirst: index == 0,
                    isLast: index == statusSteps.length - 1,
                  );
                },
                childCount: statusSteps.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatusHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF004B23),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 48),
          ),
          const SizedBox(height: 16),
          Text(
            'Pending at DRCC',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your application is currently undergoing document verification at the District Center.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required Map<String, dynamic> step,
    required bool isFirst,
    required bool isLast,
  }) {
    final bool isCompleted = step['isCompleted'];
    
    // Determine if this is the currently "active" pending step
    // (i.e. the first step that is NOT completed)
    final int currentStepIndex = statusSteps.indexWhere((s) => s['isCompleted'] == false);
    final bool isActive = statusSteps.indexOf(step) == currentStepIndex;

    final Color statusColor = isCompleted ? const Color(0xFF2E7D32) : (isActive ? const Color(0xFFEF6C00) : Colors.grey.shade400);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line
                Container(
                  width: 2,
                  height: 20,
                  color: isFirst ? Colors.transparent : (isCompleted || isActive ? const Color(0xFF2E7D32) : Colors.grey.shade300),
                ),
                // Indicator Node
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? statusColor : Colors.white,
                    border: Border.all(color: statusColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : (isActive ? Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle))) : null),
                ),
                // Bottom line
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : (isCompleted && !isActive ? const Color(0xFF2E7D32) : Colors.grey.shade300),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content Column
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isActive ? statusColor.withOpacity(0.5) : Colors.black.withOpacity(0.04), width: isActive ? 2 : 1),
                boxShadow: [
                   if (isActive) BoxShadow(color: statusColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(step['icon'], size: 20, color: statusColor),
                          const SizedBox(width: 8),
                          Text(
                            step['title'],
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isCompleted || isActive ? const Color(0xFF0D1D14) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        step['date'],
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCompleted ? Colors.black54 : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    step['description'],
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      height: 1.4,
                      color: isCompleted || isActive ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
