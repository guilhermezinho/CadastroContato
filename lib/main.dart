import 'package:flutter/material.dart';

import 'database/conexao.dart';
import 'view/home.dart';
import 'view/login_view.dart';
import 'services/sessao_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Conexao.abrirConexao();

  final usuarioId = await SessaoService.obterUsuarioId();

  runApp(MeuAplicativo(sessaoAtiva: usuarioId != null));
}

class MeuAplicativo extends StatelessWidget {
  final bool sessaoAtiva;

  const MeuAplicativo({super.key, required this.sessaoAtiva});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Pessoas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme: const InputDecorationTheme(filled: true),
      ),
      home: sessaoAtiva ? const HomeScreen() : const LoginScreen(),
    );
  }
}
