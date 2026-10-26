import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meu_app/main.dart';

void main() {
  testWidgets('login offers registration for a new user', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MeuAplicativo(sessaoAtiva: false));

    expect(find.text('Gerenciador de Pessoas'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Cadastrar novo usuário'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
