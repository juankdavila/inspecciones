import 'package:flutter_test/flutter_test.dart';

import 'package:inspecciones/main.dart';

void main() {
  testWidgets('La app arranca sin errores', (WidgetTester tester) async {
    await tester.pumpWidget(const MiApp());
    expect(find.text('Firebase conectado correctamente ✅'), findsOneWidget);
  });
}