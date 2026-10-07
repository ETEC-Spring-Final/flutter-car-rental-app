import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  late GoRouter router;
  late GlobalKey<NavigatorState> navigatorKey;

  Widget shell(int index) {
    return Scaffold(
      body: Text('shell-$index'),
      bottomNavigationBar: Text('tab-$index'),
    );
  }

  GoRouter buildRouter(String initialLocation) {
    navigatorKey = GlobalKey<NavigatorState>();
    return GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: initialLocation,
      routes: [
        GoRoute(path: '/', builder: (context, state) => shell(0)),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            final index = state.extra is int ? state.extra as int : 0;
            return shell(index);
          },
        ),
      ],
    );
  }

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  void pushManualRoute() {
    navigatorKey.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('manual')),
      ),
    );
  }

  testWidgets('plain go to same location keeps manually pushed routes on top', (
    tester,
  ) async {
    router = buildRouter('/home');
    await pumpApp(tester);

    pushManualRoute();
    await tester.pumpAndSettle();
    expect(find.text('manual'), findsOneWidget);

    router.go('/home', extra: 2);
    await tester.pumpAndSettle();

    expect(find.text('manual'), findsOneWidget);
    expect(find.text('shell-2', skipOffstage: false), findsOneWidget);
  });

  testWidgets(
    'popUntil first + go clears manual routes when location was /home',
    (tester) async {
      router = buildRouter('/home');
      await pumpApp(tester);

      pushManualRoute();
      await tester.pumpAndSettle();

      navigatorKey.currentState!.popUntil((route) => route.isFirst);
      router.go('/home', extra: 2);
      await tester.pumpAndSettle();

      expect(find.text('manual'), findsNothing);
      expect(find.text('shell-2'), findsOneWidget);
      expect(find.text('tab-2'), findsOneWidget);
    },
  );

  testWidgets('popUntil first + go clears manual routes when location was /', (
    tester,
  ) async {
    router = buildRouter('/');
    await pumpApp(tester);

    pushManualRoute();
    await tester.pumpAndSettle();

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
    router.go('/home', extra: 2);
    await tester.pumpAndSettle();

    expect(find.text('manual'), findsNothing);
    expect(find.text('shell-2'), findsOneWidget);
    expect(find.text('tab-2'), findsOneWidget);
  });
}
