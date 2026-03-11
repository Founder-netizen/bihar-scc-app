import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class AcademicTrackerScreen extends StatefulWidget {
  const AcademicTrackerScreen({super.key});

  @override
  State<AcademicTrackerScreen> createState() => _AcademicTrackerScreenState();
}

class _AcademicTrackerScreenState extends State<AcademicTrackerScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _semesterController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _semesterController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text('Academic Progress', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF004B23),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),
            const SizedBox(height: 32),
            Text(
              'SEMESTER PERFORMANCE',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF004B23).withOpacity(0.5),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            _buildSemesterList(),
            const SizedBox(height: 40),
            _buildUploadSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CURRENT CGPA',
                    style: GoogleFonts.outfit(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '8.42',
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Top 15% of Class', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: 8.42 / 10.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                    ),
                  ),
                  const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 32),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterList() {
    final List<Map<String, dynamic>> semesters = [
      {'sem': 'Semester 4', 'gpa': 'Pending', 'status': 'ongoing', 'credits': 24},
      {'sem': 'Semester 3', 'gpa': '8.6', 'status': 'completed', 'credits': 22},
      {'sem': 'Semester 2', 'gpa': '8.2', 'status': 'completed', 'credits': 20},
      {'sem': 'Semester 1', 'gpa': '8.4', 'status': 'completed', 'credits': 20},
    ];

    return Column(
      children: semesters.map((sem) => _buildSemesterCard(sem)).toList(),
    );
  }

  Widget _buildSemesterCard(Map<String, dynamic> sem) {
    bool isCompleted = sem['status'] == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.03)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                  color: isCompleted ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sem['sem'],
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF0D1D14)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${sem['credits']} Credits',
                    style: GoogleFonts.outfit(color: Colors.black45, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'SGPA',
                style: GoogleFonts.outfit(color: Colors.black38, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                sem['gpa'],
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: isCompleted ? const Color(0xFF0D1D14) : Colors.black38,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFECB3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFFFFB300).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: const Icon(Icons.upload_file_rounded, color: Color(0xFFFFB300), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Request Next Disbursement',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0D1D14)),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your latest marksheet and specify your results to request the next semester funds.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _semesterController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Semester No.',
                    labelStyle: GoogleFonts.outfit(color: Colors.black45, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _cgpaController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'SGPA/CGPA',
                    labelStyle: GoogleFonts.outfit(color: Colors.black45, fontSize: 13),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedFileName != null ? const Color(0xFF004B23) : Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _selectedFileName != null ? Icons.check_circle_rounded : Icons.attach_file_rounded,
                    color: _selectedFileName != null ? const Color(0xFF004B23) : Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _selectedFileName ?? 'Select Marksheet (PDF/JPG)',
                    style: GoogleFonts.outfit(
                      color: _selectedFileName != null ? const Color(0xFF004B23) : Colors.black54,
                      fontWeight: _selectedFileName != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004B23),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Submit Application', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _submitApplication() async {
    if (_semesterController.text.trim().isEmpty || _cgpaController.text.trim().isEmpty || _selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and attach a marksheet.', style: GoogleFonts.outfit()), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final int? semester = int.tryParse(_semesterController.text.trim());
    if (semester == null) {
      setState(() { _isSubmitting = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid Semester number.', style: GoogleFonts.outfit()), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      try {
        final result = await _apiService.applyForSubsequentDisbursement(
          user.registrationId,
          semester,
          _cgpaController.text.trim(),
          _selectedFilePath ?? 'memory_path/\$_selectedFileName', // Fallback for web if path is null
        );

        if (mounted) {
          setState(() {
            _isSubmitting = false;
            _semesterController.clear();
            _cgpaController.clear();
            _selectedFilePath = null;
            _selectedFileName = null;
          });
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Icon(Icons.check_circle_rounded, color: Color(0xFF004B23), size: 48),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Application Submitted', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(result['message'] ?? 'Successfully applied.', textAlign: TextAlign.center, style: GoogleFonts.outfit(color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text('Ref: \${result["applicationId"]}', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black38)),
                ],
              ),
              actions: [
                 TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('OK', style: GoogleFonts.outfit(color: const Color(0xFF004B23), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() { _isSubmitting = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submission failed. Please try again.', style: GoogleFonts.outfit()), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }
}
