import '../services/sqlite_service.dart';

abstract class BaseLocalDataSource<E> {
  final SqliteService db;
  final String tableName;

  BaseLocalDataSource({required this.db, required this.tableName});

  Future<List<E>> getAll();
  Future<E> getDetail(int id);

  Future<int> insert(E data);

  Future<int> update(E data);

  Future<int> delete(int id);
}
