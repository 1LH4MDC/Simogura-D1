import 'package:flutter_test/flutter_test.dart';
import 'package:simogura/main.dart';

void main() {
  testWidgets('Smoke test - app launches without error', (WidgetTester tester) async {
    await tester.pumpWidget(const SimoguraApp());
    await tester.pumpAndSettle();

    // Cek halaman Login muncul
    expect(find.text('Login'), findsOneWidget);
  });
}