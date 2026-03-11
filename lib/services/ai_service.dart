import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AiService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  final _storage = const FlutterSecureStorage();
  
  http.Client get _client {
    return http.Client();
  }

  final String _systemPrompt = '''You are a highly knowledgeable and professional AI Assistant exclusively dedicated to the Bihar Student Credit Card (MNSSBY) scheme and the District Registration and Counseling Center (DRCC). Your purpose is to provide accurate, helpful, and concise information to students regarding their educational loans.

Key Information to use in your answers:
1. Eligibility: Applicant must be a resident of Bihar, under 25 years old (for UG), and have completed 12th standard.
2. Loan Amount: Maximum loan sanctioned is up to ₹4 Lakhs.
3. Interest Rates: Standard interest rate is 4% simple interest. It is 1% for Girls, Transgenders, and Divyang (differently-abled). Note: State government may occasionally announce 0% under special circumstances or specific compliance, so advise checking official latest notices.
4. Repayment: Starts 1 year after course completion or 6 months after getting a job, whichever is earlier. Maximum repayment tenure is typically 84 months (7 years). Calculate total outstanding as Sanctioned Amount + Simple Interest.
5. Subsequent Disbursements: Require submission of previous semester mark sheets and a "Continuing Certificate" from the institute.
6. Changing College/Course: Requires an NOC from the old institute, a revised admission letter, and applying in person at the DRCC. Loan amount cannot be increased beyond the original sanction.
7. Tone: Be polite, supportive, clear, and official. Format your answers clearly, using bullet points or short paragraphs. Never make up rules not mentioned here. If unsure, advise the student to visit their nearest DRCC or log a service request on the portal.''';

  Future<String> getAiResponse(String userMessage) async {
    final apiKey = await _storage.read(key: 'groq_api_key');
    
    if (apiKey == null || apiKey.trim().isEmpty) {
      return 'Please set your Groq API Key in the Profile tab first to enable AI features.';
    }

    final client = _client;

    try {
      final response = await client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer \$apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama3-70b-8192', 
          'messages': [
            {'role': 'system', 'content': _systemPrompt},
            {'role': 'user', 'content': userMessage},
          ],
          'temperature': 0.3,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        return 'Server Error \${response.statusCode}: Failed to fetch response.';
      }
    } catch (e) {
      return 'Connection Error: Unable to reach the AI servers at this time.';
    } finally {
      client.close();
    }
  }
}
