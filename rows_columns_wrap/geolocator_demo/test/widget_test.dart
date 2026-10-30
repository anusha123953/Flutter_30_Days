import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_demo/main.dart' as app;

void main() {
  testWidgets('Geolocator app launches', (tester) async {
    await tester.pumpWidget(const app.MyApp());

    expect(find.text('Geolocator Demo'), findsOneWidget);
  });
}