import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pump a widget with MaterialApp wrapper
Future<void> pumpAppWidget(
  WidgetTester tester,
  Widget widget, {
  List<BlocProvider>? providers,
  ThemeData? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: providers != null
          ? MultiBlocProvider(
              providers: providers,
              child: widget,
            )
          : widget,
    ),
  );
}

/// Wait for all animations and microtasks
Future<void> pumpAndSettleApp(WidgetTester tester) async {
  await tester.pumpAndSettle();
}

/// Find text and tap
Future<void> tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

/// Find widget by key and tap
Future<void> tapKey(WidgetTester tester, Key key) async {
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

/// Find icon and tap
Future<void> tapIcon(WidgetTester tester, IconData icon) async {
  await tester.tap(find.byIcon(icon));
  await tester.pumpAndSettle();
}

/// Enter text in field by key
Future<void> enterTextByKey(
  WidgetTester tester,
  Key key,
  String text,
) async {
  await tester.enterText(find.byKey(key), text);
  await tester.pumpAndSettle();
}

/// Enter text in field by finder
Future<void> enterText(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Scroll until visible and tap
Future<void> scrollAndTap(
  WidgetTester tester,
  Finder finder, {
  Finder? scrollable,
}) async {
  await tester.scrollUntilVisible(
    finder,
    100.0,
    scrollable: scrollable ?? find.byType(Scrollable).first,
  );
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Verify text exists
void expectTextExists(String text) {
  expect(find.text(text), findsOneWidget);
}

/// Verify widget type exists
void expectWidgetExists<T>() {
  expect(find.byType(T), findsOneWidget);
}

/// Verify text does not exist
void expectTextNotExists(String text) {
  expect(find.text(text), findsNothing);
}

/// Verify loading indicator is shown
void expectLoading() {
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
}

/// Verify no loading indicator
void expectNotLoading() {
  expect(find.byType(CircularProgressIndicator), findsNothing);
}

/// Wait for a specific duration
Future<void> wait(WidgetTester tester, Duration duration) async {
  await tester.pump(duration);
  await tester.pumpAndSettle();
}

/// Drag to refresh (pull to refresh gesture)
Future<void> dragToRefresh(WidgetTester tester) async {
  await tester.drag(
    find.byType(RefreshIndicator),
    const Offset(0, 300),
  );
  await tester.pumpAndSettle();
}
