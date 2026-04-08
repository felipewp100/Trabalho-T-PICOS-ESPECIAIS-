import 'package:apidart/database.dart';
import 'package:apidart/middleware.dart';
import 'package:apidart/router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  // Inicializa o banco de dados SQLite
  final db = DatabaseHelper();
  db.initialize();
  print('✅ Banco de dados SQLite inicializado');

  // Cria o pipeline: Middleware → Router
  final handler = Pipeline()
      .addMiddleware(logMiddleware())
      .addMiddleware(corsMiddleware())
      .addHandler(tarefaRouter(db));

  // Inicia o servidor
  final server = await io.serve(handler, 'localhost', 8080);
  print('🚀 Servidor rodando em http://${server.address.host}:${server.port}');
  print('📋 Endpoints disponíveis:');
  print('   GET    /tarefas         → Listar todas');
  print('   GET    /tarefas/<id>    → Buscar por ID');
  print('   POST   /tarefas         → Criar nova');
  print('   PUT    /tarefas/<id>    → Atualizar');
  print('   DELETE /tarefas/<id>    → Deletar');
  print('   GET    /tarefas?concluida=true → Filtrar por status');
}
