// lib/middleware.dart
// Middleware personalizado para logging e CORS

import 'package:shelf/shelf.dart';

/// Middleware de logging — registra método, URL e tempo de resposta
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

/// Middleware de CORS — permite que frontends em outros domínios consumam a API
Middleware corsMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      // Headers CORS que serão adicionados em toda resposta
      final corsHeaders = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      };

      // Responde requisições preflight (OPTIONS) imediatamente
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }

      // Para outros métodos, processa normalmente e adiciona headers CORS
      final response = await innerHandler(request);
      return response.change(headers: corsHeaders);
    };
  };
}
