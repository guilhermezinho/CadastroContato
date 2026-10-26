
import 'package:shared_preferences/shared_preferences.dart';

class SessaoService {
  static const _chaveId = 'usuario_id';
  static const _chaveNome = 'usuario_nome';

  static Future<void> salvarSessao(
    int usuarioId,
    String nome,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_chaveId, usuarioId);
    await prefs.setString(_chaveNome, nome);
  }

  static Future<int?> obterUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_chaveId);
  }

  static Future<String?> obterNome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveNome);
  }

  static Future<void> encerrarSessao() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_chaveId);
    await prefs.remove(_chaveNome);
  }
}
