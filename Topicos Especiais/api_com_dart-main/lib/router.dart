// lib/router.dart
// Definição das rotas CRUD da API

import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'database.dart';
import 'models/tarefa.dart';

/// Cria e retorna o router com todas as rotas da API
Router tarefaRouter(DatabaseHelper db) {
  final router = Router();

  // ────────────────────────────────────────
  // GET /tarefas — Listar todas as tarefas
  // Suporta query param: ?concluida=true|false
  // ────────────────────────────────────────
  router.get('/tarefas', (Request request) {
    final concluidaParam = request.requestedUri.queryParameters['concluida'];

    List<Tarefa> tarefas;
    if (concluidaParam != null) {
      // Filtra pelo query param
      final concluida = concluidaParam.toLowerCase() == 'true';
      tarefas = db.getByStatus(concluida);
    } else {
      tarefas = db.getAll();
    }

    return Response.ok(
      jsonEncode(tarefas.map((t) => t.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // ────────────────────────────────────────
  // GET /tarefas/<id> — Buscar tarefa por ID
  // ────────────────────────────────────────
  router.get('/tarefas/<id>', (Request request, String id) {
    final tarefaId = int.tryParse(id);
    if (tarefaId == null) {
      return Response(400,
        body: jsonEncode({'erro': 'ID inválido'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final tarefa = db.getById(tarefaId);
    if (tarefa == null) {
      return Response(404,
        body: jsonEncode({'erro': 'Tarefa não encontrada'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode(tarefa.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // ────────────────────────────────────────
  // POST /tarefas — Criar nova tarefa
  // Body esperado: { "titulo": "...", "descricao": "..." }
  // ────────────────────────────────────────
  router.post('/tarefas', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // Validação dos campos obrigatórios
      if (data['titulo'] == null || data['descricao'] == null) {
        return Response(400,
          body: jsonEncode({'erro': 'Campos "titulo" e "descricao" são obrigatórios'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final novaTarefa = Tarefa(
        titulo: data['titulo'] as String,
        descricao: data['descricao'] as String,
        concluida: data['concluida'] == true,
      );

      final criada = db.insert(novaTarefa);

      return Response(201,
        body: jsonEncode(criada.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(400,
        body: jsonEncode({'erro': 'JSON inválido: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // ────────────────────────────────────────
  // PUT /tarefas/<id> — Atualizar tarefa
  // Body esperado: { "titulo": "...", "descricao": "...", "concluida": true }
  // ────────────────────────────────────────
  router.put('/tarefas/<id>', (Request request, String id) async {
    final tarefaId = int.tryParse(id);
    if (tarefaId == null) {
      return Response(400,
        body: jsonEncode({'erro': 'ID inválido'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (data['titulo'] == null || data['descricao'] == null) {
        return Response(400,
          body: jsonEncode({'erro': 'Campos "titulo" e "descricao" são obrigatórios'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final tarefaAtualizada = Tarefa(
        titulo: data['titulo'] as String,
        descricao: data['descricao'] as String,
        concluida: data['concluida'] == true,
      );

      final resultado = db.update(tarefaId, tarefaAtualizada);
      if (resultado == null) {
        return Response(404,
          body: jsonEncode({'erro': 'Tarefa não encontrada'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        jsonEncode(resultado.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response(400,
        body: jsonEncode({'erro': 'JSON inválido: $e'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // ────────────────────────────────────────
  // DELETE /tarefas/<id> — Deletar tarefa
  // ────────────────────────────────────────
  router.delete('/tarefas/<id>', (Request request, String id) {
    final tarefaId = int.tryParse(id);
    if (tarefaId == null) {
      return Response(400,
        body: jsonEncode({'erro': 'ID inválido'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    final deletou = db.delete(tarefaId);
    if (!deletou) {
      return Response(404,
        body: jsonEncode({'erro': 'Tarefa não encontrada'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({'mensagem': 'Tarefa $tarefaId deletada com sucesso'}),
      headers: {'Content-Type': 'application/json'},
    );
  });

  return router;
}
