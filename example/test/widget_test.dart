import 'package:flutter_test/flutter_test.dart';
import 'package:preview_hub_example/main.dart';

void main() {
  testWidgets('the example app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Preview Hub Example'), findsOneWidget);
  });
}
