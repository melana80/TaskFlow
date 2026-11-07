import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:task_flow/main.dart';

void main() {
  testWidgets('muestra y permite desplazar las cinco tareas', (tester) async {
    tester.view.physicalSize = const Size(400, 350);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TaskFlowApp());

    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);

    for (final task in demoTasks) {
      await tester.scrollUntilVisible(
        find.text(task.title),
        200,
        scrollable: find.byType(Scrollable),
      );

      expect(find.text(task.title), findsOneWidget);
      expect(
        find.text('${task.priority} · ${task.description}'),
        findsOneWidget,
      );
      final taskCard = find.ancestor(
        of: find.text(task.title),
        matching: find.byType(TaskCard),
      );
      expect(
        find.descendant(
          of: taskCard,
          matching: find.byIcon(
            task.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
          ),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('abre el detalle de la tarea seleccionada', (tester) async {
    await tester.pumpWidget(const TaskFlowApp());

    await tester.tap(find.text('Implementar la lista desplazable'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle de tarea'), findsOneWidget);
    expect(find.text('Implementar la lista desplazable'), findsOneWidget);
    expect(
      find.text('Renderizar las tareas con ListView.builder'),
      findsOneWidget,
    );
    expect(find.text('Prioridad: Alta'), findsOneWidget);
    expect(find.text('Estado: completada'), findsOneWidget);

    await tester.tap(find.text('Volver al listado'));
    await tester.pumpAndSettle();

    expect(find.text('Mis tareas'), findsOneWidget);
  });

  testWidgets('usa un id único por tarea y permite volver por ambos medios', (
    tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());
    final visitedPaths = <String>{};

    for (final task in demoTasks) {
      await tester.scrollUntilVisible(
        find.text(task.title),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text(task.title));
      await tester.pumpAndSettle();

      final detailContext = tester.element(find.byType(TaskDetailScreen));
      final path = GoRouterState.of(detailContext).uri.path;
      expect(path, '/task/${task.id}');
      expect(visitedPaths.add(path), isTrue);
      expect(find.text(task.description), findsOneWidget);

      if (task.id.isOdd) {
        await tester.tap(find.text('Volver al listado'));
      } else {
        await tester.binding.handlePopRoute();
      }
      await tester.pumpAndSettle();

      expect(
        GoRouterState.of(tester.element(find.byType(TaskListScreen))).uri.path,
        '/',
      );

      expect(find.text('Mis tareas'), findsOneWidget);
    }

    expect(visitedPaths, hasLength(demoTasks.length));
  });

  testWidgets('las acciones mantienen el contador y su estado válido', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    expect(find.text('Tareas pendientes: 3'), findsOneWidget);
    expect(find.text('Completadas hoy: 0 de 5'), findsOneWidget);
    expect(find.text('Aún tienes tareas por organizar.'), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
      isNotNull,
    );
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNotNull,
    );

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Agregar tarea'));
      await tester.pump();
    }
    expect(find.text('Tareas pendientes: 5'), findsOneWidget);
    expect(find.text('Completadas hoy: 0 de 5'), findsOneWidget);

    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text('Completar una tarea'));
      await tester.pump();
    }

    expect(find.text('Tareas pendientes: 0'), findsOneWidget);
    expect(find.text('Completadas hoy: 5 de 5'), findsOneWidget);
    expect(
      find.text('¡Excelente! No tienes tareas pendientes.'),
      findsOneWidget,
    );
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );

    await tester.tap(find.text('Agregar tarea'));
    await tester.pump();

    expect(find.text('Tareas pendientes: 1'), findsOneWidget);
    expect(find.text('Completadas hoy: 5 de 5'), findsOneWidget);
    expect(find.text('Aún tienes tareas por organizar.'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNotNull,
    );

    await tester.tap(find.text('Completar una tarea'));
    await tester.pump();

    expect(find.text('Tareas pendientes: 0'), findsOneWidget);
    expect(find.text('Completadas hoy: 5 de 5'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
  });
}
