import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import 'package:workmanager/workmanager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/notification_service.dart';
import 'services/api_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    const storage = FlutterSecureStorage();
    final api = ApiService();
    
    final userId = await storage.read(key: 'userId');
    if (userId == null) return true;

    try {
      final summary = await api.getAccountSummary(userId);
      final recordList = summary['recordList'] as List?;
      if (recordList != null && recordList.isNotEmpty) {
        final currentStatus = recordList[0]['PAID_FLAG']?.toString() ?? 'Pending';
        final lastStatus = await storage.read(key: 'lastKnownStatus');

        if (lastStatus != null && lastStatus != currentStatus) {
          await NotificationService.init();
          await NotificationService.showStatusNotification(
            oldStatus: lastStatus,
            newStatus: currentStatus,
          );
        }
        await storage.write(key: 'lastKnownStatus', value: currentStatus);
      }
    } catch (e) {
      debugPrint('Background sync error: $e');
    }
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!kIsWeb) {
    await NotificationService.init();
    
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    
    Workmanager().registerPeriodicTask(
      "1",
      "statusUpdateTask",
      frequency: const Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bihar Student Credit Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004B23)),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isLoggedIn ? const DashboardScreen() : const LoginScreen();
        },
      ),
    );
  }
}
