import 'package:flutter/material.dart';

import '../database/banco_pessoa.dart';
import '../models/pessoa.dart';
import '../services/sessao_service.dart';
import 'form_pessoa.dart';
import 'login_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _usuarioId;
  String _nomeUsuario = '';
  List<Pessoa> _pessoas = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final id = await SessaoService.obterUsuarioId();
    final nome = await SessaoService.obterNome();

    if (!mounted) return;

    if (id == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
      return;
    }

    setState(() {
      _usuarioId = id;
      _nomeUsuario = nome ?? 'Usuário';
    });

    await _carregarPessoas();
  }

  Future<void> _carregarPessoas() async {
    final id = _usuarioId;
    if (id == null) return;

    try {
      final pessoas = await BancoPessoa.listarPessoas(id);

      if (!mounted) return;

      setState(() {
        _pessoas = pessoas;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() => _carregando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar os contatos.')),
      );
    }
  }

  Future<void> _abrirFormulario({Pessoa? pessoa}) async {
    final id = _usuarioId;
    if (id == null) return;

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormPessoaScreen(usuarioId: id, pessoa: pessoa),
      ),
    );

    if (resultado == true) {
      await _carregarPessoas();
    }
  }

  Future<bool> _confirmarExclusao(Pessoa pessoa) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir pessoa?'),
        content: Text('Deseja excluir ${pessoa.nome} permanentemente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return false;

    final usuarioId = _usuarioId;
    final pessoaId = pessoa.id;
    if (usuarioId == null || pessoaId == null) return false;

    try {
      final quantidade = await BancoPessoa.excluirPessoa(pessoaId, usuarioId);
      if (!mounted) return false;

      if (quantidade == 0) {
        await _carregarPessoas();
        if (!mounted) return false;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A pessoa não foi encontrada.')),
        );
        return false;
      }

      return true;
    } catch (_) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir a pessoa.')),
      );
      return false;
    }
  }

  Future<void> _sair() async {
    await SessaoService.encerrarSessao();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus contatos'),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      child: Text(
                        _nomeUsuario.isEmpty
                            ? '?'
                            : _nomeUsuario[0].toUpperCase(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _nomeUsuario,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Text('Gerenciador de Pessoas'),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.contacts),
                title: const Text('Meus contatos'),
                selected: true,
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1),
                title: const Text('Adicionar pessoa'),
                onTap: () {
                  Navigator.pop(context);
                  _abrirFormulario();
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () {
                  Navigator.pop(context);
                  _sair();
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(
              'Olá, $_nomeUsuario!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Seus contatos cadastrados'),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _pessoas.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhuma pessoa cadastrada.\n'
                      'Toque em + para adicionar.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _carregarPessoas,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: _pessoas.length,
                      itemBuilder: (context, index) {
                        final pessoa = _pessoas[index];

                        return Dismissible(
                          key: ValueKey(pessoa.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmarExclusao(pessoa),
                          onDismissed: (_) {
                            setState(() {
                              _pessoas.removeWhere((p) => p.id == pessoa.id);
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${pessoa.nome} foi excluído.'),
                              ),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(
                                  pessoa.nome.isEmpty
                                      ? '?'
                                      : pessoa.nome[0].toUpperCase(),
                                ),
                              ),
                              title: Text(pessoa.nome),
                              subtitle: Text(
                                '${pessoa.email}\n'
                                'Idade: ${pessoa.idade} | '
                                'Telefone: ${pessoa.telefone}',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.edit),
                              onTap: () => _abrirFormulario(pessoa: pessoa),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(),
        tooltip: 'Adicionar pessoa',
        child: const Icon(Icons.add),
      ),
    );
  }
}
