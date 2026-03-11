import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path_provider/path_provider.dart';
import '../services/api_service.dart';
import '../models/student_models.dart';

class AuthProvider with ChangeNotifier {
  final _auth = LocalAuthentication();
  final _api = ApiService();
  final _storage = const FlutterSecureStorage();

  StudentProfile? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;

  StudentProfile? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Store bytes directly for Web usage, and paths for Mobile
  Uint8List? sanctionLetterBytes;
  Uint8List? agreementLetterBytes;
  String? sanctionLetterPath;
  String? agreementLetterPath;

  Future<bool> login(String username, String password, bool stayLoggedIn) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _api.validateUser(username, password);
      debugPrint('Login Result: $result');
      
      final status = result['status']?.toString();
      
      if (status == '1') {
        final userId = result['message']?.toString() ?? '';
        
        // Fetch detailed profile
        final profileData = await _api.getProfile(userId);
        debugPrint('Profile Data: $profileData');
        
        if (profileData['validationStatus'] == '1') {
          _user = StudentProfile.fromJson(profileData);
          
          // Fetch Account Summary for Loan Details
          try {
            final summaryData = await _api.getAccountSummary(userId);
            if (summaryData['recordList'] != null && (summaryData['recordList'] as List).isNotEmpty) {
              final firstRecord = summaryData['recordList'][0];
              _user = _user!.copyWith(
                loanNumber: firstRecord['Loan_Number']?.toString(),
                sanctionAmount: firstRecord['Sanction_Loan_Amount']?.toString(),
                totalDisbursed: firstRecord['Disbursed_Loan_Amount']?.toString(),
              );
              
              // Store initial status for background comparison
              final currentStatus = firstRecord['PAID_FLAG']?.toString() ?? 'Pending';
              await _storage.write(key: 'lastKnownStatus', value: currentStatus);
            }
          } catch (e) {
            debugPrint('Summary fetch failed: $e');
          }

          // Fetch Documents silently in the background
          _fetchAndStoreDocuments();

          _isLoggedIn = true;
          
          if (stayLoggedIn) {
            await _storage.write(key: 'userId', value: userId);
            await _storage.write(key: 'username', value: username);
            await _storage.write(key: 'password', value: password);
          }
          
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _errorMessage = 'Failed to load profile summary.';
        }
      } else {
        _errorMessage = 'Login Failed: ${result['message'] ?? 'Invalid User'}';
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _errorMessage = 'Connection Error: $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> checkBiometric() async {
    final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    
    if (canAuthenticate) {
      try {
        final didAuthenticate = await _auth.authenticate(
          localizedReason: 'Please authenticate to login to your Student Portal',
          options: const AuthenticationOptions(stickyAuth: true),
        );
        
        if (didAuthenticate) {
          final storedUser = await _storage.read(key: 'username');
          final storedPass = await _storage.read(key: 'password');
          
          if (storedUser != null && storedPass != null) {
            return await login(storedUser, storedPass, true);
          }
        }
      } catch (e) {
        debugPrint('Biometric error: $e');
      }
    }
    return false;
  }

  Future<void> _fetchAndStoreDocuments() async {
    if (_user == null || _user!.registrationId.isEmpty) return;
    try {
      // 1. Download bytes from API using real user Registration ID
      final regId = _user!.registrationId;
      sanctionLetterBytes = Uint8List.fromList(await _api.getSanctionLetterBytes(regId));
      agreementLetterBytes = Uint8List.fromList(await _api.getAgreementLetterBytes(regId));

      // 2. If not on web, try saving to local secure directory for offline/faster access
      if (!kIsWeb) {
        final dir = await getApplicationDocumentsDirectory();
        
        final sFile = File('${dir.path}/sanction_letter.pdf');
        await sFile.writeAsBytes(sanctionLetterBytes!);
        sanctionLetterPath = sFile.path;

        final aFile = File('${dir.path}/agreement_letter.pdf');
        await aFile.writeAsBytes(agreementLetterBytes!);
        agreementLetterPath = aFile.path;
      }
      debugPrint('Documents securely fetched and stored.');
    } catch (e) {
      debugPrint('Failed to fetch background documents: $e');
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
