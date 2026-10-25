# Gerenciador de Pessoas

Aplicativo Flutter para cadastro e gerenciamento local de contatos. O acesso é
feito por contas locais; cada usuário visualiza e altera somente os próprios
contatos.

## Funcionalidades

- Cadastro de usuário e login por e-mail e senha.
- Sessão temporária armazenada com `shared_preferences`.
- Cadastro, listagem e edição de pessoas em armazenamento local com Hive.
- Exclusão com gesto de deslizar, confirmação e retorno visual.
- Separação de acesso ao banco em `lib/database/`.
- Navegação pelo menu lateral (Drawer), com acesso aos contatos, cadastro e saída.

As caixas Hive `usuarios` e `pessoas` são inicializadas no primeiro início do
aplicativo. Cada contato mantém o identificador do usuário proprietário.
Os dados que já existiam no banco SQLite de versões anteriores não são
importados automaticamente para o Hive.

## Executar

Requisitos: Flutter SDK instalado e um emulador ou dispositivo Android/iOS.

Na pasta `meu_app`, execute:

```sh
flutter pub get
flutter run
```

Para executar os testes e a análise estática:

```sh
flutter test
flutter analyze
```

## Roteiro de demonstração

1. Abra **Cadastrar novo usuário**, informe nome, e-mail e senha e conclua.
2. Faça login com as credenciais cadastradas.
3. Toque em **+**, cadastre uma pessoa e salve.
4. Toque no contato, altere os dados e salve.
5. Deslize o contato, confirme a exclusão e confira a mensagem de retorno.
6. Opcionalmente, encerre a sessão e faça login com outra conta para confirmar
   que a lista de contatos é privada.
