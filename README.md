# TaskFlow

TaskFlow es una aplicación Flutter para organizar tareas académicas por
prioridad y consultar su avance.

## Usuario objetivo

Melani, estudiante universitaria que necesita reunir sus pendientes de clase y
proyecto en una lista, priorizarlos y revisar el detalle de cada actividad.
La lista se carga desde JSONPlaceholder; la API no entrega descripción ni
prioridad y sus títulos son texto de ejemplo en inglés. Para los 20 identificadores
de `userId: 1`, la aplicación agrega títulos, descripciones y prioridades en
español; conserva del servicio remoto el identificador, el usuario y el estado.

## Historias de usuario

1. **Consultar pendientes:** Como estudiante, quiero ver mis tareas para saber
   qué actividades tengo que completar. **Criterio:** la lista presenta las
   cinco tareas con título, prioridad y descripción.
2. **Revisar una tarea:** Como estudiante, quiero abrir una tarea para conocer
   sus datos completos. **Criterio:** al tocar una tarjeta se muestra el título,
   la descripción, la prioridad, el estado y el usuario de esa tarea.
3. **Crear una tarea:** Como estudiante, quiero registrar un pendiente nuevo.
   **Criterio:** el formulario futuro no permite guardar si el título está vacío
   y agrega a la lista una tarea válida.
4. **Actualizar una tarea:** Como estudiante, quiero corregir los datos de una
   actividad. **Criterio:** al guardar cambios, el título y la prioridad nuevos
   se reflejan en la lista y el detalle.
5. **Eliminar una tarea:** Como estudiante, quiero quitar actividades que ya no
   necesito. **Criterio:** después de confirmar la eliminación, la tarea ya no
   aparece en la lista y su ruta muestra que no fue encontrada.

## Requisitos

### Funcionales

- Mostrar las tareas del usuario identificado por `userId`.
- Permitir navegar de la lista al detalle usando el `id` de la tarea.
- Mostrar un mensaje comprensible cuando el `id` solicitado no existe.
- En el formulario futuro, exigir un título, permitir descripción y prioridad,
  y guardar el estado inicial como pendiente.
- Permitir editar y eliminar tareas en una iteración futura.

### No funcionales

- Usar textos en español y controles accesibles y comprensibles.
- Mantener los identificadores de tarea únicos y no mostrar datos de otro
  usuario.
- Mantener la navegación estable ante un identificador mal formado o
  inexistente.

## Modelo de datos

`Task` contiene los siguientes campos:

| Campo | Tipo JSON | Requisito |
|---|---|---|
| `id` | entero | Identificador único de la tarea |
| `title` | cadena | Título; obligatorio al crear |
| `description` | cadena | Descripción de la actividad |
| `priority` | cadena | `Alta`, `Media` o `Baja` |
| `isCompleted` | booleano | Estado de finalización |
| `userId` | entero | Identificador del usuario propietario |

Ejemplo de representación JSON:

```json
{
  "id": 1,
  "title": "Terminar el avance de TaskFlow",
  "description": "Integrar el modelo y verificar la lista de tareas",
  "priority": "Alta",
  "isCompleted": false,
  "userId": 1
}
```

## Pantallas

1. **Lista:** muestra las tareas del usuario con título, prioridad, descripción
   y estado; cada tarjeta abre su detalle.
2. **Detalle:** muestra los campos de una tarea y ofrece volver a la lista.
3. **Formulario (futuro):** permitirá crear o editar título, descripción y
   prioridad; el identificador, el usuario y el estado inicial se asignarán al
   guardar.

## Contrato JSON de API previsto

Las rutas siguientes describen el contrato necesario para una API futura; no
hay un servidor conectado todavía. Las respuestas de tarea usan el objeto JSON
anterior. La lista responde con un arreglo de esos objetos.

| Método y ruta | Uso | Cuerpo de solicitud | Respuesta esperada |
|---|---|---|---|
| `GET /api/users/{userId}/tasks` | Listar tareas del usuario | Sin cuerpo | `200 OK`, arreglo de tareas |
| `GET /api/tasks/{id}` | Consultar detalle | Sin cuerpo | `200 OK`, tarea; `404 Not Found` si no existe |
| `POST /api/users/{userId}/tasks` | Crear tarea | `title`, `description`, `priority` | `201 Created`, tarea con `id`, `isCompleted: false` y `userId` |
| `PATCH /api/tasks/{id}` | Actualizar campos | Uno o más de `title`, `description`, `priority`, `isCompleted` | `200 OK`, tarea actualizada; `404 Not Found` si no existe |
| `DELETE /api/tasks/{id}` | Eliminar tarea | Sin cuerpo | `204 No Content`; `404 Not Found` si no existe |

Al crear y actualizar, `priority` debe ser `Alta`, `Media` o `Baja`; el servidor
debe asociar las operaciones al usuario autenticado y no confiar en un `userId`
arbitrario enviado por el cliente.

## Evidencia

Las capturas de la lista y el detalle se guardan en:

- `evidence/taskflow-list.png`
- `evidence/taskflow-detail.png`

Los estados de carga terminada, vacío y error se capturan con pruebas de
widgets en:

- `evidence/taskflow-list-async.png`
- `evidence/taskflow-empty-async.png`
- `evidence/taskflow-error-async.png`

La aplicación de producción conserva el repositorio remoto. Para reproducir
los estados sin depender de la disponibilidad del servicio, la prueba
`test/task_list_states_test.dart` usa un repositorio controlado:

- **Carga:** mantiene pendiente la respuesta de prueba y comprueba el indicador
  sin añadir demoras artificiales al código de producción.
- **Lista:** el repositorio de prueba devuelve tres tareas.
- **Detalle:** selecciona una tarea con datos remotos y verifica que el título
  y la ruta conservan su id.
- **Vacío:** devuelve una lista vacía.
- **Error:** falla la primera carga con una excepción simulada. La prueba toma
  la captura del mensaje y pulsa **Reintentar**; la segunda llamada devuelve
  las tareas. Comprueba que la lista aparece y que la misma aplicación sigue
  montada, sin reiniciarla.

Para regenerar las capturas, ejecuta
`flutter test --update-goldens test/task_list_states_test.dart`. Para comprobar
el comportamiento sin reemplazar capturas, ejecuta
`flutter test test/task_list_states_test.dart`.

## Ejecutar y validar

```bash
flutter pub get
flutter run
flutter analyze
flutter test
```
