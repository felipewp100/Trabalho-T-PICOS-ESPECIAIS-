# API REST com Dart + SQLite — Guia Passo a Passo

## Sobre este projeto

Neste guia você vai construir do zero uma **API REST completa** usando Dart puro com persistência em SQLite. A API gerencia **Tarefas** (CRUD) e inclui middleware de logging e CORS.

**Stack utilizada:**

- **Dart SDK** — linguagem de programação
- **shelf** — servidor HTTP leve (similar ao Express.js do Node)
- **shelf_router** — sistema de rotas
- **sqlite3** — banco de dados SQLite nativo

---

## Pré-requisitos

1. **Dart SDK** instalado (versão 3.0+)  
   - Verifique com: `dart --version`
   - Download: [https://dart.dev/get-dart](https://dart.dev/get-dart)

2. **Postman** ou **Insomnia** instalado para testar a API  
   - Postman: [https://www.postman.com/downloads](https://www.postman.com/downloads)
   - Insomnia: [https://insomnia.rest/download](https://insomnia.rest/download)
   - Ou use a extensão **Thunder Client** no VS Code

---

## 1. Criando o projeto

Abra o terminal e execute:

```bash
dart create -t console api_tarefas
cd api_tarefas
```

Agora edite o `pubspec.yaml` para adicionar as dependências:

```yaml
name: api_tarefas
description: API REST CRUD de Tarefas com Dart + SQLite
version: 1.0.0

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  shelf: ^1.4.0
  shelf_router: ^1.1.0
  sqlite3: ^2.1.0
```

Instale as dependências:

```bash
dart pub get
```

---

## 2. Estrutura de pastas

Organize o projeto assim:

```
api_tarefas/
├── bin/
│   └── server.dart          ← Ponto de entrada
├── lib/
│   ├── database.dart        ← Conexão SQLite
│   ├── middleware.dart       ← Logger e CORS
│   ├── router.dart           ← Rotas CRUD
│   └── models/
│       └── tarefa.dart       ← Modelo de dados
├── pubspec.yaml
└── tarefas.db                ← Banco (criado automaticamente)
```

---

## 3. Criando o Modelo (Tarefa)

Crie o arquivo `lib/models/tarefa.dart`:

```dart
class Tarefa {
  final int? id;
  final String titulo;
  final String descricao;
  final bool concluida;

  Tarefa({
    this.id,
    required this.titulo,
    required this.descricao,
    this.concluida = false,
  });

  /// Cria uma Tarefa a partir de um Map (banco de dados)
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      concluida: (map['concluida'] as int) == 1,
    );
  }

  /// Converte para Map (salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida ? 1 : 0,
    };
  }

  /// Converte para JSON (resposta da API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'concluida': concluida,
    };
  }
}
```

**O que está acontecendo aqui?**

- `fromMap` — converte um registro do banco (onde `concluida` é 0 ou 1) para um objeto Dart
- `toMap` — converte para salvar no banco
- `toJson` — converte para devolver na API (onde `concluida` é `true`/`false`)

---

## 4. Configurando o Banco de Dados (SQLite)

Crie o arquivo `lib/database.dart`:

```dart
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

  /// Filtra tarefas pelo status
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
      'SELECT * FROM tarefas WHERE id = ?', [id],
    );
    if (result.isEmpty) return null;
    return Tarefa.fromMap(result.first);
  }

  /// Insere uma nova tarefa
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
    if (getById(id) == null) return null;
    _db.execute(
      'UPDATE tarefas SET titulo = ?, descricao = ?, concluida = ? WHERE id = ?',
      [tarefa.titulo, tarefa.descricao, tarefa.concluida ? 1 : 0, id],
    );
    return getById(id);
  }

  /// Deleta uma tarefa
  bool delete(int id) {
    if (getById(id) == null) return false;
    _db.execute('DELETE FROM tarefas WHERE id = ?', [id]);
    return true;
  }
}
```

**Pontos importantes:**

- O SQLite guarda booleanos como inteiros (0 = false, 1 = true)
- `lastInsertRowId` retorna o ID auto-gerado
- Usamos `?` nos queries para evitar SQL Injection

---

## 5. Criando os Middlewares

Crie o arquivo `lib/middleware.dart`:

```dart
import 'package:shelf/shelf.dart';

/// Middleware de Logging
Middleware logMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final stopwatch = Stopwatch()..start();
      final response = await innerHandler(request);
      stopwatch.stop();

      print(
        '${request.method.padRight(6)} '
        '${request.requestedUri.path} '
        '→ ${response.statusCode} '
        '(${stopwatch.elapsedMilliseconds}ms)',
      );

      return response;
    };
  };
}

/// Middleware de CORS
Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      };

      // Responde preflight (OPTIONS) imediatamente
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }

      final response = await innerHandler(request);
      return response.change(headers: corsHeaders);
    };
  };
}
```

**O que cada middleware faz:**

- **logMiddleware** — registra no console cada request com método, URL, status code e tempo de resposta
- **corsMiddleware** — adiciona headers CORS em toda resposta, permitindo que frontends em outros domínios consumam a API. Também responde requisições `OPTIONS` (preflight) automaticamente.

---

## 6. Definindo as Rotas (Router)

Crie o arquivo `lib/router.dart`:

```dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'database.dart';
import 'models/tarefa.dart';

Router tarefaRouter(DatabaseHelper db) {
  final router = Router();

  // GET /tarefas — Listar todas (com filtro opcional)
  router.get('/tarefas', (Request request) {
    final concluidaParam = request.requestedUri.queryParameters['concluida'];

    List<Tarefa> tarefas;
    if (concluidaParam != null) {
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

  // GET /tarefas/<id> — Buscar por ID
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

  // POST /tarefas — Criar nova tarefa
  router.post('/tarefas', (Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (data['titulo'] == null || data['descricao'] == null) {
        return Response(400,
          body: jsonEncode({
            'erro': 'Campos "titulo" e "descricao" são obrigatórios'
          }),
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

  // PUT /tarefas/<id> — Atualizar tarefa
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
          body: jsonEncode({
            'erro': 'Campos "titulo" e "descricao" são obrigatórios'
          }),
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

  // DELETE /tarefas/<id> — Deletar tarefa
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
```

---

## 7. Ponto de Entrada (Server)

Crie o arquivo `bin/server.dart`:

```dart
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import '../lib/router.dart';
import '../lib/middleware.dart';
import '../lib/database.dart';

void main() async {
  // Inicializa o banco de dados
  final db = DatabaseHelper();
  db.initialize();
  print('✅ Banco de dados SQLite inicializado');

  // Pipeline: Middlewares → Router
  final handler = Pipeline()
      .addMiddleware(logMiddleware())
      .addMiddleware(corsMiddleware())
      .addHandler(tarefaRouter(db));

  // Inicia o servidor na porta 8080
  final server = await io.serve(handler, 'localhost', 8080);
  print('🚀 Servidor rodando em http://${server.address.host}:${server.port}');
}
```

---

## 8. Rodando o projeto

```bash
dart run bin/server.dart
```

Saída esperada:

```
✅ Banco de dados SQLite inicializado
🚀 Servidor rodando em http://localhost:8080
```

---

## 9. Testando com Postman / Insomnia

### Criar uma tarefa (POST)

- **Método:** POST
- **URL:** `http://localhost:8080/tarefas`
- **Header:** `Content-Type: application/json`
- **Body (JSON):**

```json
{
  "titulo": "Estudar APIs REST",
  "descricao": "Aprender os conceitos de REST com Dart"
}
```

**Resposta esperada (201 Created):**

```json
{
  "id": 1,
  "titulo": "Estudar APIs REST",
  "descricao": "Aprender os conceitos de REST com Dart",
  "concluida": false
}
```

### Listar todas (GET)

- **URL:** `http://localhost:8080/tarefas`

### Filtrar por status (GET com Query Param)

- **URL:** `http://localhost:8080/tarefas?concluida=false`

### Buscar por ID (GET)

- **URL:** `http://localhost:8080/tarefas/1`

### Atualizar (PUT)

- **Método:** PUT
- **URL:** `http://localhost:8080/tarefas/1`
- **Body:**

```json
{
  "titulo": "Estudar APIs REST",
  "descricao": "Conceitos aprendidos com sucesso!",
  "concluida": true
}
```

### Deletar (DELETE)

- **Método:** DELETE
- **URL:** `http://localhost:8080/tarefas/1`

**Resposta:**

```json
{
  "mensagem": "Tarefa 1 deletada com sucesso"
}
```

---

## 10. Testando com curl (Terminal)

```bash
# Criar tarefa
curl -X POST http://localhost:8080/tarefas \
  -H "Content-Type: application/json" \
  -d '{"titulo": "Primeira tarefa", "descricao": "Criada via curl"}'

# Listar todas
curl http://localhost:8080/tarefas

# Filtrar concluídas
curl "http://localhost:8080/tarefas?concluida=true"

# Buscar por ID
curl http://localhost:8080/tarefas/1

# Atualizar
curl -X PUT http://localhost:8080/tarefas/1 \
  -H "Content-Type: application/json" \
  -d '{"titulo": "Tarefa atualizada", "descricao": "Agora com PUT", "concluida": true}'

# Deletar
curl -X DELETE http://localhost:8080/tarefas/1
```

---

## Resumo dos Endpoints

| Método | Rota | Descrição | Status |
|--------|------|-----------|--------|
| GET | `/tarefas` | Listar todas as tarefas | 200 |
| GET | `/tarefas?concluida=true` | Filtrar por status | 200 |
| GET | `/tarefas/<id>` | Buscar por ID | 200 / 404 |
| POST | `/tarefas` | Criar nova tarefa | 201 / 400 |
| PUT | `/tarefas/<id>` | Atualizar tarefa | 200 / 404 |
| DELETE | `/tarefas/<id>` | Deletar tarefa | 200 / 404 |

---

## Desafios para os alunos

1. **Paginação** — Adicione query params `?page=1&limit=10` no GET
2. **Busca por título** — Implemente `?titulo=estudar` com `LIKE` no SQL
3. **Ordenação** — Adicione `?orderBy=titulo&order=asc`
4. **Validação** — Não permita título vazio ou com menos de 3 caracteres
5. **Autenticação** — Crie um middleware que verifica um token no header `Authorization`
6. **Swagger** — Pesquise como gerar documentação OpenAPI para a API

---

## Referências

- [Documentação do Shelf](https://pub.dev/packages/shelf)
- [Shelf Router](https://pub.dev/packages/shelf_router)
- [SQLite3 para Dart](https://pub.dev/packages/sqlite3)
- [Postman Learning Center](https://learning.postman.com)
- [OpenAPI / Swagger](https://swagger.io/specification/)
