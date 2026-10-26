
import 'conexao.dart';
import '../models/usuario.dart';

class EmailJaCadastradoException implements Exception {}

class BancoUsuario {
  static Future<int> cadastrar(Usuario usuario) async {
    await Conexao.abrirConexao();
    final usuarios = Conexao.usuarios;
    final email = usuario.email.trim();

    final emailExistente = usuarios.values.any(
      (map) => (map['email'] as String).toLowerCase() == email.toLowerCase(),
    );
    if (emailExistente) {
      throw EmailJaCadastradoException();
    }

    final id = _proximoId(usuarios.keys);
    await usuarios.put(id, {...usuario.toMap(), 'id': id, 'email': email});
    return id;
  }

  static Future<Usuario?> autenticar(
    String email,
    String senha,
  ) async {
    await Conexao.abrirConexao();
    final emailNormalizado = email.trim().toLowerCase();

    for (final map in Conexao.usuarios.values) {
      if ((map['email'] as String).toLowerCase() == emailNormalizado &&
          map['senha'] == senha) {
        return Usuario.fromMap(Map<String, dynamic>.from(map));
      }
    }

    return null;
  }

  static int _proximoId(Iterable<dynamic> chaves) {
    return chaves.whereType<int>().fold(0, (maior, id) {
          return id > maior ? id : maior;
        }) +
        1;
  }
}
