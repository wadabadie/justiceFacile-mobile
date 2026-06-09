import 'package:flutter_test/flutter_test.dart';
import 'package:justice_facile_client/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const JusticeFacileApp());
    await tester.pump();
  });
}
