import 'package:hive_flutter/hive_flutter.dart';

class Conexao {
  static const _usuariosBox = 'usuarios';
  static const _pessoasBox = 'pessoas';
  static Future<void>? _inicializacao;

  static Future<void> abrirConexao() {
    return _inicializacao ??= _inicializar();
  }

  static Future<void> _inicializar() async {
    await Hive.initFlutter();

    if (!Hive.isBoxOpen(_usuariosBox)) {
      await Hive.openBox<Map>(_usuariosBox);
    }
    if (!Hive.isBoxOpen(_pessoasBox)) {
      await Hive.openBox<Map>(_pessoasBox);
    }
  }

  static Box<Map> get usuarios => Hive.box<Map>(_usuariosBox);
  static Box<Map> get pessoas => Hive.box<Map>(_pessoasBox);
}
