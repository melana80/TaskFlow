import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/features/tasks/data/task_api_task_mapper.dart';

void main() {
  test('localiza el contenido y conserva el estado remoto', () {
    final task = TaskApiTaskMapper.fromJson({
      'id': 1,
      'title': 'delectus aut autem',
      'completed': true,
      'userId': 1,
    });

    expect(task.id, 1);
    expect(task.title, 'Terminar el avance de TaskFlow');
    expect(
      task.description,
      'Integrar el modelo y verificar la lista de tareas.',
    );
    expect(task.priority, 'Alta');
    expect(task.isCompleted, isTrue);
    expect(task.userId, 1);
  });

  test('conserva los datos de tareas sin contenido localizado', () {
    final task = TaskApiTaskMapper.fromJson({
      'id': 21,
      'title': 'remote title',
      'completed': false,
      'userId': 1,
    });

    expect(task.title, 'remote title');
    expect(task.description, 'Sin descripción (API)');
    expect(task.priority, 'Sin prioridad (API)');
  });
}
