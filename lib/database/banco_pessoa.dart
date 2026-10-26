
import 'conexao.dart';
import '../models/pessoa.dart';

class BancoPessoa {
  static Future<int> inserirPessoa(Pessoa pessoa) async {
    await Conexao.abrirConexao();
    final pessoas = Conexao.pessoas;
    final id = _proximoId(pessoas.keys);
    await pessoas.put(id, {...pessoa.toMap(), 'id': id});
    return id;
  }

  static Future<List<Pessoa>> listarPessoas(
    int usuarioId,
  ) async {
    await Conexao.abrirConexao();
    final pessoas = Conexao.pessoas.values
        .where((map) => map['usuario_id'] == usuarioId)
        .map((map) => Pessoa.fromMap(Map<String, dynamic>.from(map)))
        .toList()
      ..sort(
        (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
      );

    return pessoas;
  }

  static Future<int> atualizarPessoa(Pessoa pessoa) async {
    if (pessoa.id == null) {
      throw ArgumentError('A pessoa não possui ID.');
    }

    await Conexao.abrirConexao();
    final pessoas = Conexao.pessoas;
    final existente = pessoas.get(pessoa.id);
    if (existente == null || existente['usuario_id'] != pessoa.usuarioId) {
      return 0;
    }

    await pessoas.put(pessoa.id, pessoa.toMap());
    return 1;
  }

  static Future<int> excluirPessoa(
    int pessoaId,
    int usuarioId,
  ) async {
    await Conexao.abrirConexao();
    final pessoas = Conexao.pessoas;
    final existente = pessoas.get(pessoaId);
    if (existente == null || existente['usuario_id'] != usuarioId) {
      return 0;
    }

    await pessoas.delete(pessoaId);
    return 1;
  }

  static int _proximoId(Iterable<dynamic> chaves) {
    return chaves.whereType<int>().fold(0, (maior, id) {
          return id > maior ? id : maior;
        }) +
        1;
  }
}
