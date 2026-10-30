import 'package:flutter_test/flutter_test.dart';

import 'package:task_flow/main.dart';

void main() {
  testWidgets('muestra el curso, el usuario y las tareas pendientes', (
    tester,
  ) async {
    await tester.pumpWidget(const TaskFlowApp());

    expect(find.text('TaskFlow'), findsOneWidget);
    expect(find.text('Melani Molina Ponce'), findsOneWidget);
    expect(find.text('Desarrollo de Aplicaciones Móviles'), findsOneWidget);
    expect(find.text('Tareas pendientes'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
  });
}
