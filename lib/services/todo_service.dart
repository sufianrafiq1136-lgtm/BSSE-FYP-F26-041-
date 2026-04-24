import '../models/todo_item_model.dart';
import 'firestore_service.dart';

class TodoService {
  static final TodoService _instance = TodoService._internal();

  factory TodoService() {
    return _instance;
  }

  TodoService._internal();

  final FirestoreService _firestoreService = FirestoreService();

  String _getTodoPath({required String userId, required String farmId}) {
    return 'users/$userId/farms/$farmId/todos';
  }

  Future<String> addTodo({
    required String userId,
    required String farmId,
    required TodoItemModel todo,
  }) async {
    final todoWithMetadata = todo.copyWith(
      userId: userId,
      farmId: farmId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return _firestoreService.create(
      _getTodoPath(userId: userId, farmId: farmId),
      todoWithMetadata.toMap(),
    );
  }

  Future<void> updateTodo({
    required String userId,
    required String farmId,
    required String todoId,
    required TodoItemModel todo,
  }) async {
    await _firestoreService.update(
      _getTodoPath(userId: userId, farmId: farmId),
      todoId,
      todo.copyWith(updatedAt: DateTime.now()).toMap(),
    );
  }

  Future<void> setTodoCompleted({
    required String userId,
    required String farmId,
    required TodoItemModel todo,
    required bool isCompleted,
  }) async {
    await updateTodo(
      userId: userId,
      farmId: farmId,
      todoId: todo.id,
      todo: todo.copyWith(isCompleted: isCompleted, updatedAt: DateTime.now()),
    );
  }

  Future<void> deleteTodo({
    required String userId,
    required String farmId,
    required String todoId,
  }) async {
    await _firestoreService.delete(
      _getTodoPath(userId: userId, farmId: farmId),
      todoId,
    );
  }

  Stream<List<TodoItemModel>> streamTodos({
    required String userId,
    required String farmId,
  }) {
    return _firestoreService
        .streamAll(_getTodoPath(userId: userId, farmId: farmId))
        .map((docs) {
          final todos = docs
              .map(
                (doc) => TodoItemModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
          todos.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
          return todos;
        });
  }

  Stream<List<TodoItemModel>> streamTodosForDate({
    required String userId,
    required String farmId,
    required DateTime date,
  }) {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    return streamTodos(userId: userId, farmId: farmId).map(
      (todos) => todos.where((todo) {
        if (todo.repeatDaily) {
          return true;
        }
        return !todo.scheduledAt.isBefore(dayStart) &&
            todo.scheduledAt.isBefore(dayEnd);
      }).toList(),
    );
  }
}
