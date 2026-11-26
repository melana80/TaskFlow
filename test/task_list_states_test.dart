import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:task_flow/app/taskflow_app.dart';
import 'package:task_flow/features/tasks/data/task_api_task_mapper.dart';
import 'package:task_flow/features/tasks/data/task_repository.dart';
import 'package:task_flow/features/tasks/domain/task.dart';
import 'package:task_flow/features/tasks/presentation/task_detail_screen.dart';
import 'package:task_flow/features/tasks/presentation/tasks_view_model.dart';

typedef TaskLoader = Future<List<Task>> Function();

class ScriptedTaskRepository implements TaskRepository {
  ScriptedTaskRepository(this._loaders);

  final List<TaskLoader> _loaders;
  int calls = 0;

  @override
  Future<List<Task>> getTasks() => _loaders[calls++]();

  @override
  void save(Task task) {}
}

const _tasks = [
  Task(
    id: 1,
    title: 'Leer documentación',
    description: 'Revisar el material de Flutter',
    priority: 'Alta',
    isCompleted: false,
    userId: 1,
  ),
  Task(
    id: 2,
    title: 'Diseñar pantalla',
    description: 'Dibujar la lista de tareas',
    priority: 'Media',
    isCompleted: false,
    userId: 1,
  ),
  Task(
    id: 3,
    title: 'Preparar evidencia',
    description: 'Tomar capturas del avance',
    priority: 'Baja',
    isCompleted: true,
    userId: 1,
  ),
];

Widget _createApp(ScriptedTaskRepository repository) {
  return ChangeNotifierProvider(
    create: (_) => TasksViewModel(repository)..loadTasks(),
    child: const TaskFlowApp(),
  );
}

void _setTestViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('muestra el indicador hasta recibir la respuesta', (
    tester,
  ) async {
    final response = Completer<List<Task>>();
    final repository = ScriptedTaskRepository([() => response.future]);

    appRouter.go('/');
    await tester.pumpWidget(_createApp(repository));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    response.complete(_tasks);
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Leer documentación'), findsOneWidget);
  });

  testWidgets('el detalle conserva el título y el id de la tarea remota', (
    tester,
  ) async {
    final remoteTask = TaskApiTaskMapper.fromJson({
      'id': 2,
      'title': 'quis ut nam facilis et officia qui',
      'completed': false,
      'userId': 1,
    });
    final repository = ScriptedTaskRepository([
      () async => [remoteTask],
    ]);

    appRouter.go('/');
    await tester.pumpWidget(_createApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.text(remoteTask.title));
    await tester.pumpAndSettle();

    expect(find.text(remoteTask.title), findsOneWidget);
    final detailContext = tester.element(find.byType(TaskDetailScreen));
    expect(GoRouterState.of(detailContext).uri.path, '/task/2');
  });

  testWidgets('muestra la lista y captura el estado de éxito', (tester) async {
    _setTestViewport(tester);
    final repository = ScriptedTaskRepository([() async => _tasks]);

    appRouter.go('/');
    await tester.pumpWidget(_createApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Leer documentación'), findsOneWidget);
    expect(find.text('Diseñar pantalla'), findsOneWidget);
    expect(find.text('Preparar evidencia'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../evidence/taskflow-list-async.png'),
    );
  });

  testWidgets('muestra vacío y captura el estado sin tareas', (tester) async {
    _setTestViewport(tester);
    final repository = ScriptedTaskRepository([() async => <Task>[]]);

    appRouter.go('/');
    await tester.pumpWidget(_createApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('Todavía no hay tareas para mostrar.'), findsOneWidget);
    expect(find.text('Actualizar'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../evidence/taskflow-empty-async.png'),
    );
  });

  testWidgets('Reintentar recupera la lista sin reiniciar la app', (
    tester,
  ) async {
    _setTestViewport(tester);
    final repository = ScriptedTaskRepository([
      () async => throw StateError('Error de red simulado'),
      () async => _tasks,
    ]);

    appRouter.go('/');
    await tester.pumpWidget(_createApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('No se pudieron cargar las tareas.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(repository.calls, 1);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../evidence/taskflow-error-async.png'),
    );

    final app = find.byType(TaskFlowApp);
    expect(app, findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(find.text('Leer documentación'), findsOneWidget);
    expect(find.text('No se pudieron cargar las tareas.'), findsNothing);
    expect(repository.calls, 2);
    expect(app, findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../evidence/taskflow-list-async.png'),
    );
  });
}
