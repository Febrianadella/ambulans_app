import 'package:flutter_test/flutter_test.dart';
import 'package:ambulans_app/main.dart';

void main() {
  testWidgets('AmbulanceBookingApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AmbulanceBookingApp());
    expect(find.text('Ambulance System'), findsOneWidget);
  });
}
