import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import 'pdf_viewer_screen.dart';

class DocumentVaultScreen extends StatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  State<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends State<DocumentVaultScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _documents = [];

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      try {
        final docs = await _apiService.getUploadedDocuments(user.registrationId);
        setState(() {
          _documents = docs;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text('Secure Document Vault', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
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
            _buildVaultHeader(),
            const SizedBox(height: 32),
            Text(
              'ISSUED & VERIFIED DOCUMENTS',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF004B23).withOpacity(0.5),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF004B23)))
                : _buildDocumentList(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildVaultHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF004B23),
        borderRadius: BorderRadius.circular(30),
        image: const DecorationImage(
          image: NetworkImage('https://www.transparenttextures.com/patterns/cubes.png'), // Subtle texture
          opacity: 0.1,
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: const Color(0xFF004B23).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.security_rounded, color: Color(0xFFFFD700), size: 48),
          ),
          const SizedBox(height: 20),
          Text(
            'Digital Vault',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Your verified DRCC documents are securely stored here for official use.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentList(BuildContext context) {
    if (_documents.isEmpty) {
      return Center(
        child: Text('No documents found.', style: GoogleFonts.outfit(color: Colors.black54)),
      );
    }

    return Column(
      children: _documents.map((doc) => _buildDocumentCard(context, doc)).toList(),
    );
  }

  IconData _getIconForType(String title) {
    if (title.contains('Aadhaar')) return Icons.badge_rounded;
    if (title.contains('PAN')) return Icons.credit_card_rounded;
    if (title.contains('Admission')) return Icons.business_rounded;
    if (title.contains('Sanction')) return Icons.verified_user_rounded;
    if (title.contains('Agreement')) return Icons.gavel_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color _getColorForType(String title) {
    if (title.contains('Aadhaar')) return const Color(0xFF1976D2);
    if (title.contains('PAN')) return const Color(0xFFF57C00);
    if (title.contains('Admission')) return const Color(0xFF004B23);
    if (title.contains('Sanction')) return const Color(0xFF8E24AA);
    if (title.contains('Agreement')) return const Color(0xFFE53935);
    return Colors.black54;
  }

  Widget _buildDocumentCard(BuildContext context, Map<String, dynamic> doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (doc['isRealDoc'] == true) {
               final auth = Provider.of<AuthProvider>(context, listen: false);
               String? path;
               dynamic bytes;
               
               if (doc['docType'] == 'sanction') {
                 path = auth.sanctionLetterPath;
                 bytes = auth.sanctionLetterBytes;
               } else if (doc['docType'] == 'agreement') {
                 path = auth.agreementLetterPath;
                 bytes = auth.agreementLetterBytes;
               }

               if (path != null || bytes != null) {
                 Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => PdfViewerScreen(
                        title: doc['title'],
                        pdfPath: path,
                        pdfBytes: bytes,
                      ),
                    ),
                  );
                  return;
               }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Mock: Downloading ${doc['title']}...', style: GoogleFonts.outfit()),
                backgroundColor: const Color(0xFF004B23),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getColorForType(doc['title'] ?? '').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_getIconForType(doc['title'] ?? ''), color: _getColorForType(doc['title'] ?? ''), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['title'] ?? 'Document',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16, color: const Color(0xFF0D1D14)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                         doc['id'] ?? '',
                        style: GoogleFonts.outfit(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                         doc['date'] ?? '',
                        style: GoogleFonts.outfit(color: Colors.black38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAF9),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: const Icon(Icons.download_rounded, color: Color(0xFF004B23), size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
