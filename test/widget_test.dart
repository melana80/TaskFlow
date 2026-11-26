import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/app/taskflow_app.dart';
import 'package:task_flow/features/tasks/data/local_task_repository.dart';
import 'package:task_flow/features/tasks/presentation/task_detail_screen.dart';
import 'package:task_flow/features/tasks/presentation/tasks_view_model.dart';

Widget createTestApp() {
  return ChangeNotifierProvider(
    create: (_) => TasksViewModel(LocalTaskRepository())..loadTasks(),
    child: const TaskFlowApp(),
  );
}

void main() {
  test('el repositorio local contiene tareas con ids únicos', () async {
    final tasks = await LocalTaskRepository().getTasks();
    final ids = tasks.map((task) => task.id).toSet();

    expect(tasks, hasLength(3));
    expect(ids, hasLength(3));
    expect(tasks.every((task) => task.userId == 1), isTrue);
  });

  testWidgets('muestra la lista de tareas del repositorio', (tester) async {
    tester.view.physicalSize = const Size(400, 350);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    appRouter.go('/');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Mis tareas'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);

    for (final title in [
      'Leer documentación',
      'Diseñar pantalla',
      'Preparar evidencia',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        200,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text(title), findsOneWidget);
    }

    expect(find.text('Prioridad: Alta'), findsOneWidget);
  });

  testWidgets('abre el detalle de la tarea seleccionada', (tester) async {
    appRouter.go('/');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Diseñar pantalla'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle de tarea'), findsOneWidget);
    expect(find.text('Diseñar pantalla'), findsOneWidget);
    expect(find.text('Dibujar la lista de tareas'), findsOneWidget);
    expect(find.text('Prioridad: Media'), findsOneWidget);
    expect(find.text('Estado: pendiente'), findsOneWidget);
    expect(find.text('Usuario: 1'), findsOneWidget);

    final detailContext = tester.element(find.byType(TaskDetailScreen));
    expect(GoRouterState.of(detailContext).uri.path, '/task/2');
  });

  testWidgets('alternar el estado actualiza el detalle y la lista', (
    tester,
  ) async {
    appRouter.go('/');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Leer documentación'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Marcar como completada'));
    await tester.pumpAndSettle();
    expect(find.text('Estado: completada'), findsOneWidget);
    expect(find.text('Marcar como pendiente'), findsOneWidget);

    appRouter.go('/');
    await tester.pumpAndSettle();

    final taskCard = find.ancestor(
      of: find.text('Leer documentación'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(of: taskCard, matching: find.byIcon(Icons.check_circle)),
      findsOneWidget,
    );
  });

  testWidgets('muestra un mensaje para ids desconocidos o inválidos', (
    tester,
  ) async {
    appRouter.go('/task/999');
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('No se encontró esta tarea.'), findsOneWidget);

    appRouter.go('/task/no-es-un-id');
    await tester.pumpAndSettle();

    expect(find.text('No se encontró esta tarea.'), findsOneWidget);
  });
}
