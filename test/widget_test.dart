import 'package:flextime_app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App should render without crashing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: FlexTimeApp()));

    // Verify app renders
    expect(find.text('FlexTime'), findsOneWidget);
    expect(find.text('Welcome to FlexTime'), findsOneWidget);
  });
}
