import '../domain/task.dart';

typedef _SpanishTaskContent = ({
  String title,
  String description,
  String priority,
});

class TaskApiTaskMapper {
  static const Map<int, _SpanishTaskContent> _spanishContent = {
    1: (
      title: 'Terminar el avance de TaskFlow',
      description: 'Integrar el modelo y verificar la lista de tareas.',
      priority: 'Alta',
    ),
    2: (
      title: 'Repasar conceptos de Flutter',
      description: 'Revisar widgets, navegación y estado antes de clase.',
      priority: 'Media',
    ),
    3: (
      title: 'Entregar el reporte del semestre',
      description: 'Corregir las conclusiones y subir el documento final.',
      priority: 'Alta',
    ),
    4: (
      title: 'Organizar pendientes de la semana',
      description: 'Ordenar actividades académicas por fecha y prioridad.',
      priority: 'Baja',
    ),
    5: (
      title: 'Preparar exposición del proyecto',
      description: 'Practicar la demostración y revisar las diapositivas.',
      priority: 'Media',
    ),
    6: (
      title: 'Revisar la documentación del curso',
      description: 'Consultar las referencias indicadas para la asignatura.',
      priority: 'Baja',
    ),
    7: (
      title: 'Completar los ejercicios de práctica',
      description: 'Resolver los ejercicios y comprobar cada resultado.',
      priority: 'Alta',
    ),
    8: (
      title: 'Preparar los materiales de clase',
      description: 'Reunir apuntes y recursos para la próxima sesión.',
      priority: 'Media',
    ),
    9: (
      title: 'Avanzar el trabajo en equipo',
      description: 'Compartir los avances y coordinar las tareas pendientes.',
      priority: 'Alta',
    ),
    10: (
      title: 'Estudiar para la evaluación',
      description: 'Repasar los temas y completar una guía de estudio.',
      priority: 'Alta',
    ),
    11: (
      title: 'Actualizar los apuntes',
      description: 'Ordenar y completar las notas de las últimas clases.',
      priority: 'Baja',
    ),
    12: (
      title: 'Revisar el borrador del informe',
      description: 'Verificar la redacción, las referencias y el formato.',
      priority: 'Media',
    ),
    13: (
      title: 'Entregar la actividad pendiente',
      description: 'Comprobar los requisitos y enviar la actividad a tiempo.',
      priority: 'Alta',
    ),
    14: (
      title: 'Organizar los archivos del proyecto',
      description:
          'Clasificar documentos y respaldar los archivos importantes.',
      priority: 'Baja',
    ),
    15: (
      title: 'Practicar la presentación oral',
      description: 'Ensayar la exposición y ajustar su duración.',
      priority: 'Media',
    ),
    16: (
      title: 'Consultar dudas con el equipo',
      description: 'Resolver preguntas y acordar los siguientes pasos.',
      priority: 'Baja',
    ),
    17: (
      title: 'Verificar los requisitos del proyecto',
      description: 'Comparar el avance con las instrucciones de entrega.',
      priority: 'Alta',
    ),
    18: (
      title: 'Preparar el resumen de lectura',
      description: 'Identificar las ideas principales del material asignado.',
      priority: 'Media',
    ),
    19: (
      title: 'Revisar las fechas de entrega',
      description: 'Actualizar el calendario con las próximas evaluaciones.',
      priority: 'Baja',
    ),
    20: (
      title: 'Finalizar las tareas del curso',
      description: 'Revisar y cerrar las actividades académicas pendientes.',
      priority: 'Media',
    ),
  };

  static Task fromJson(Map<String, dynamic> json) {
    final remoteTask = Task.fromJson(json);
    final spanishContent = _spanishContent[remoteTask.id];
    if (spanishContent == null) return remoteTask;

    return Task(
      id: remoteTask.id,
      title: spanishContent.title,
      description: spanishContent.description,
      priority: spanishContent.priority,
      isCompleted: remoteTask.isCompleted,
      userId: remoteTask.userId,
    );
  }
}
