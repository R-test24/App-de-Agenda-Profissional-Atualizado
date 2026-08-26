import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/ativacao_screen.dart';
import 'services/licenca_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const AgendaNailsApp(),
  );
}

class AgendaNailsApp extends StatelessWidget {
  const AgendaNailsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestão de Agenda',
      theme: AppTheme.tema,
      home: const InicializacaoScreen(),
    );
  }
}

class InicializacaoScreen extends StatefulWidget {
  const InicializacaoScreen({super.key});

  @override
  State<InicializacaoScreen> createState() =>
      _InicializacaoScreenState();
}

class _InicializacaoScreenState
    extends State<InicializacaoScreen> {
  @override
  void initState() {
    super.initState();

    _verificarLicenca();
  }

  Future<void> _verificarLicenca() async {
    final licencaService =
        LicencaService();

    final resultado =
        await licencaService
            .verificarSeNecessario();

    if (!mounted) return;

    final precisaAtivar =
        resultado['precisaAtivar'] == true;

    final valida =
        resultado['valida'] == true;

    if (valida && !precisaAtivar) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AtivacaoScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}