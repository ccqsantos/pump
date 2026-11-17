import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'models/treino.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/treino_form_screen.dart';
import 'screens/treino_detalhe_screen.dart';
import 'services/auth_refresh_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const PumpApp());
}

class PumpApp extends StatefulWidget {
  const PumpApp({super.key});

  @override
  State<PumpApp> createState() => _PumpAppState();
}

class _PumpAppState extends State<PumpApp> {
  late final GoRouter _router;
  late final AuthRefreshNotifier _authRefreshNotifier;

  @override
  void initState() {
    super.initState();

    _authRefreshNotifier = AuthRefreshNotifier();

    _router = GoRouter(
      initialLocation: '/login',

      refreshListenable: _authRefreshNotifier,

      redirect: (context, state) {
        final logado = FirebaseAuth.instance.currentUser != null;

        final indoParaLogin =
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/register';

        if (!logado && !indoParaLogin) {
          return '/login';
        }

        if (logado && indoParaLogin) {
          return '/home';
        }

        return null;
      },

      routes: [
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/perfil', builder: (_, _) => const PerfilScreen()),
        GoRoute(
          path: '/treino-form',
          builder: (context, state) {
            final treino = state.extra as Treino?;
            return TreinoFormScreen(treino: treino);
          },
        ),
        GoRoute(
          path: '/treino-detalhe',
          builder: (context, state) {
            final treino = state.extra as Treino;
            return TreinoDetalheScreen(treino: treino);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _authRefreshNotifier.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'Pump', routerConfig: _router);
  }
}
