import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class RepaymentScreen extends StatefulWidget {
  const RepaymentScreen({super.key});

  @override
  State<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends State<RepaymentScreen> {
  final ApiService _api = ApiService();
  bool _isLoading = true;

  // New Calculator State
  double _sanctionedAmount = 0.0;
  int _repaymentYears = 5; // Default 5 years
  double _interestRate = 1.0; // 1% or 0%
  
  // Calculated values
  double _totalOutstanding = 0.0;
  double _monthlyEmi = 0.0;
  int _totalMonths = 0;

  @override
  void initState() {
    super.initState();
    _fetchRepaymentData();
  }

  Future<void> _fetchRepaymentData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      // Simulate fetching sanctioned amount (since it's not directly in summary)
      // In a real app, this might come from the profile or a specific loan details API.
      // For now, we take it from the user profile if available, else fallback.
      final amountStr = auth.user?.sanctionAmount.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0';
      _sanctionedAmount = double.tryParse(amountStr) ?? 400000.0; // Defaulting to 4L if not parsed

      setState(() {
        _isLoading = false;
        _calculateEMI();
      });
    } catch (e) {
      debugPrint('Repayment fetch error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _calculateEMI() {
    // Max repayment is 84 months (7 years)
    _totalMonths = _repaymentYears * 12;
    if (_totalMonths > 84) _totalMonths = 84;

    // Simple Interest Calculation
    // Total Amount = Principal + (Principal * Rate * Time / 100)
    // Here Time is in years.
    double simpleInterest = (_sanctionedAmount * _interestRate * _repaymentYears) / 100;
    _totalOutstanding = _sanctionedAmount + simpleInterest;
    
    // EMI Calculation (Total Outstanding / Total Months)
    if (_totalMonths > 0) {
      _monthlyEmi = _totalOutstanding / _totalMonths;
    } else {
      _monthlyEmi = 0;
    }
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text('Repayment Status', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF004B23),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF004B23)))
          : RefreshIndicator(
              onRefresh: _fetchRepaymentData,
              color: const Color(0xFF004B23),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      _buildSummaryHeader(),
                      const SizedBox(height: 32),
                      _buildCalculatorSection(),
                      const SizedBox(height: 32),
                      Text(
                      'ESTIMATED EMI SCHEDULE',
                      style: GoogleFonts.outfit(
                        fontSize: 11, 
                        fontWeight: FontWeight.w800, 
                        color: const Color(0xFF004B23).withOpacity(0.5),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCalculatedEmiCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryHeader() {
    final user = Provider.of<AuthProvider>(context).user!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF004B23), Color(0xFF0D3D22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: const Color(0xFF004B23).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL OUTSTANDING',
                style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('ESTIMATED', style: GoogleFonts.outfit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${_formatCurrency(_totalOutstanding)}',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderStat('LOAN A/C', user.loanNumber ?? 'NA'),
              _buildHeaderStat('STATUS', 'STAY (REPAYMENT)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildCalculatorSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_rounded, color: Color(0xFF004B23)),
              const SizedBox(width: 8),
              Text('EMI Calculator', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0D1D14))),
            ],
          ),
          const SizedBox(height: 24),
          
          // Repayment Years Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Repayment Tenure', style: GoogleFonts.outfit(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600)),
              Text(
                '$_repaymentYears Years (${_repaymentYears * 12 > 84 ? 84 : _repaymentYears * 12} Months)', 
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF004B23))
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF004B23),
              inactiveTrackColor: const Color(0xFFE8F5E9),
              thumbColor: const Color(0xFF004B23),
              overlayColor: const Color(0xFF004B23).withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: _repaymentYears.toDouble(),
              min: 1,
              max: 7, // Max 7 years (84 months)
              divisions: 6,
              onChanged: (value) {
                setState(() {
                  _repaymentYears = value.toInt();
                  _calculateEMI();
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Interest Rate Toggle
          Text('Applicable Interest Rate (Recent Govt Guidelines)', style: GoogleFonts.outfit(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInterestToggle(1.0, '1% (Standard)'),
              const SizedBox(width: 12),
              _buildInterestToggle(0.0, '0% (Revised Scheme)'),
            ],
          ),

          const SizedBox(height: 16),
          Container(
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: const Color(0xFFFFF3E0),
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: const Color(0xFFFFCC80))
             ),
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFEF6C00)),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                     'Repayment starts 1 year after course completion. Max tenure is 84 months.',
                     style: GoogleFonts.outfit(color: const Color(0xFFE65100), fontSize: 11, height: 1.4),
                   ),
                 ),
               ],
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestToggle(double rate, String label) {
    bool isSelected = _interestRate == rate;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _interestRate = rate;
            _calculateEMI();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF004B23) : Colors.transparent,
            border: Border.all(color: isSelected ? const Color(0xFF004B23) : Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculatedEmiCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MONTHLY EMI (ESTIMATED)', style: GoogleFonts.outfit(color: Colors.black38, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 4),
                  Text(
                    '₹ ${_formatCurrency(_monthlyEmi)}',
                     style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 24, color: const Color(0xFF0D1D14)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('READY', style: GoogleFonts.outfit(color: const Color(0xFF2E7D32), fontSize: 9, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 1, color: Color(0xFFF0F4F2)),
          ),
          _buildDetailRow(Icons.calendar_month_rounded, 'Repayment Interval', 'Monthly'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.timer_outlined, 'Max Tenure', '$_totalMonths Months'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.analytics_outlined, 'Interest Rate', '${_interestRate == 0 ? '0% Rate' : '1% Simple Interest'}'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.account_balance_wallet_rounded, 'Principal', '₹ ${_formatCurrency(_sanctionedAmount)}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black26),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.outfit(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13, color: const Color(0xFF0D1D14))),
      ],
    );
  }
}
