// lib/database.dart
// Gerenciamento do banco de dados SQLite

import 'package:sqlite3/sqlite3.dart';
import 'models/tarefa.dart';

class DatabaseHelper {
  late Database _db;

  /// Abre o banco e cria a tabela se não existir
  void initialize() {
    _db = sqlite3.open('tarefas.db');
    _db.execute('''
      CREATE TABLE IF NOT EXISTS tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        descricao TEXT NOT NULL,
        concluida INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  /// Retorna todas as tarefas
  List<Tarefa> getAll() {
    final result = _db.select('SELECT * FROM tarefas ORDER BY id DESC');
    return result.map((row) => Tarefa.fromMap(row)).toList();
  }

  /// Retorna tarefas filtradas pelo status de conclusão
  List<Tarefa> getByStatus(bool concluida) {
    final result = _db.select(
      'SELECT * FROM tarefas WHERE concluida = ? ORDER BY id DESC',
      [concluida ? 1 : 0],
    );
    return result.map((row) => Tarefa.fromMap(row)).toList();
  }

  /// Busca uma tarefa pelo ID
  Tarefa? getById(int id) {
    final result = _db.select(
      'SELECT * FROM tarefas WHERE id = ?',
      [id],
    );
    if (result.isEmpty) return null;
    return Tarefa.fromMap(result.first);
  }

  /// Insere uma nova tarefa e retorna ela com o ID gerado
  Tarefa insert(Tarefa tarefa) {
    _db.execute(
      'INSERT INTO tarefas (titulo, descricao, concluida) VALUES (?, ?, ?)',
      [tarefa.titulo, tarefa.descricao, tarefa.concluida ? 1 : 0],
    );
    final id = _db.lastInsertRowId;
    return getById(id)!;
  }

  /// Atualiza uma tarefa existente
  Tarefa? update(int id, Tarefa tarefa) {
    final existing = getById(id);
    if (existing == null) return null;

    _db.execute(
      'UPDATE tarefas SET titulo = ?, descricao = ?, concluida = ? WHERE id = ?',
      [tarefa.titulo, tarefa.descricao, tarefa.concluida ? 1 : 0, id],
    );
    return getById(id);
  }

  /// Deleta uma tarefa pelo ID. Retorna true se deletou.
  bool delete(int id) {
    final existing = getById(id);
    if (existing == null) return false;

    _db.execute('DELETE FROM tarefas WHERE id = ?', [id]);
    return true;
  }

  /// Fecha a conexão com o banco
  void close() {
    _db.dispose();
  }
}
