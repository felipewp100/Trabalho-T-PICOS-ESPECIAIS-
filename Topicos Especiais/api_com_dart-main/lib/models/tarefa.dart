// lib/models/tarefa.dart
// Modelo de dados para a entidade Tarefa

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

  /// Cria uma Tarefa a partir de um Map (vindo do JSON ou do banco)
  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      concluida: (map['concluida'] as int) == 1,
    );
  }

  /// Converte a Tarefa para Map (para salvar no banco ou retornar como JSON)
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
