
import 'package:flutter/material.dart';

import '../database/banco_pessoa.dart';
import '../models/pessoa.dart';

class FormPessoaScreen extends StatefulWidget {
  final int usuarioId;
  final Pessoa? pessoa;

  const FormPessoaScreen({
    super.key,
    required this.usuarioId,
    this.pessoa,
  });

  @override
  State<FormPessoaScreen> createState() =>
      _FormPessoaScreenState();
}

class _FormPessoaScreenState extends State<FormPessoaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _email;
  late final TextEditingController _idade;
  late final TextEditingController _telefone;

  bool _salvando = false;

  bool get _editando => widget.pessoa != null;

  @override
  void initState() {
    super.initState();

    final pessoa = widget.pessoa;

    _nome = TextEditingController(text: pessoa?.nome ?? '');
    _email = TextEditingController(text: pessoa?.email ?? '');
    _idade = TextEditingController(
      text: pessoa == null ? '' : pessoa.idade.toString(),
    );
    _telefone = TextEditingController(
      text: pessoa?.telefone ?? '',
    );
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _idade.dispose();
    _telefone.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      final pessoa = Pessoa(
        id: widget.pessoa?.id,
        usuarioId: widget.usuarioId,
        nome: _nome.text.trim(),
        email: _email.text.trim(),
        idade: int.parse(_idade.text.trim()),
        telefone: _telefone.text.trim(),
      );

      if (_editando) {
        await BancoPessoa.atualizarPessoa(pessoa);
      } else {
        await BancoPessoa.inserirPessoa(pessoa);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando
                ? 'Pessoa atualizada com sucesso!'
                : 'Pessoa cadastrada com sucesso!',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar a pessoa.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editando ? 'Editar pessoa' : 'Nova pessoa',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Informe o nome.'
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (v) {
                  if (v == null ||
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(v.trim())) {
                    return 'Informe um e-mail válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _idade,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Idade',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                validator: (v) {
                  final idade = int.tryParse(v ?? '');
                  if (idade == null || idade < 0 || idade > 120) {
                    return 'Informe uma idade entre 0 e 120.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: '(67) 99999-9999',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) {
                  final digitos =
                      (v ?? '').replaceAll(RegExp(r'\D'), '');
                  if (digitos.length < 10 ||
                      digitos.length > 13) {
                    return 'Informe um telefone válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _salvando
                        ? 'Salvando...'
                        : 'Salvar pessoa',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
