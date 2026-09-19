import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_todo/main.dart';

void main() {
  testWidgets('app shows onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Todo Planner'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
