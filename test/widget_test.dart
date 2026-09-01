import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_mart/widgets/aura_skeletons.dart';
import 'package:aura_mart/widgets/aura_animations.dart';

void main() {
  testWidgets('AuraSkeleton renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductSkeleton(),
        ),
      ),
    );

    expect(find.byType(ProductSkeleton), findsOneWidget);
    expect(find.byType(AuraSkeleton), findsNWidgets(3));
  });

  testWidgets('FadeInAnimation renders child widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FadeInAnimation(
            child: Text('Aura Mart Test'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Aura Mart Test'), findsOneWidget);
  });
}
