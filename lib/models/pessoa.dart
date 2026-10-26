
class Pessoa {
  final int? id;
  final int usuarioId;
  final String nome;
  final String email;
  final int idade;
  final String telefone;

  Pessoa({
    this.id,
    required this.usuarioId,
    required this.nome,
    required this.email,
    required this.idade,
    required this.telefone,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'usuario_id': usuarioId,
      'nome': nome,
      'email': email,
      'idade': idade,
      'telefone': telefone,
    };
  }

  factory Pessoa.fromMap(Map<String, dynamic> map) {
    return Pessoa(
      id: map['id'] as int,
      usuarioId: map['usuario_id'] as int,
      nome: map['nome'] as String,
      email: map['email'] as String,
      idade: map['idade'] as int,
      telefone: map['telefone'] as String,
    );
  }
}
