import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class PdfViewerScreen extends StatelessWidget {
  final String title;
  
  // We accept either a file path (for mobile) or memory bytes (for web)
  final String? pdfPath;
  final Uint8List? pdfBytes;

  const PdfViewerScreen({
    super.key,
    required this.title,
    this.pdfPath,
    this.pdfBytes,
  }) : assert(pdfPath != null || pdfBytes != null, 'Either pdfPath or pdfBytes must be provided.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF004B23),
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildPdfViewer(),
    );
  }

  Widget _buildPdfViewer() {
    if (kIsWeb) {
      // On Web, we must use memory bytes as we can't easily read from a local File object like mobile
      if (pdfBytes != null) {
        return SfPdfViewer.memory(pdfBytes!);
      } else {
        return const Center(child: Text('Error: No PDF data available for Web.'));
      }
    } else {
      // On Mobile/Desktop, we can use the downloaded file path
      if (pdfPath != null) {
        return SfPdfViewer.file(File(pdfPath!));
      } else if (pdfBytes != null) {
         // Fallback if only bytes were provided
         return SfPdfViewer.memory(pdfBytes!);
      } else {
        return const Center(child: Text('Error: No PDF file found.'));
      }
    }
  }
}
