import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('EstudaiApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EstudaiApp());
    expect(find.byType(EstudaiApp), findsOneWidget);
  });
}
