import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'services/store.dart';
import 'theme.dart';
import 'screens/welcome.dart';
import 'screens/login.dart';
import 'screens/onboarding.dart';
import 'screens/dashboard.dart';
import 'screens/properties.dart';
import 'screens/tenant_details.dart';
import 'screens/record_payment.dart';
import 'screens/add_property.dart';
import 'screens/agreement.dart';
import 'screens/reports.dart';
import 'screens/profile.dart';
import 'screens/add_expense.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.init();
  final store = AppStore();
  await store.load();
  runApp(ChangeNotifierProvider.value(value: store, child: const KirayadarApp()));
}

class KirayadarApp extends StatelessWidget {
  const KirayadarApp({super.key});
  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return MaterialApp(
      title: 'Kiraya Manager',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      initialRoute: store.loggedIn ? '/home' : '/',
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const HomeShell(),
        '/tenant': (_) => const TenantDetailsScreen(),
        '/record-payment': (_) => const RecordPaymentScreen(),
        '/add-property': (_) => const AddPropertyScreen(),
        '/agreement': (_) => const AgreementScreen(),
        '/add-expense': (_) => const AddExpenseScreen(),
      },
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;
  final pages = const [DashboardScreen(), PropertiesScreen(), ReportsScreen(), ProfileScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border2))),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => setState(() => index = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.apartment), label: 'Properties'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      ),
    );
  }
}
