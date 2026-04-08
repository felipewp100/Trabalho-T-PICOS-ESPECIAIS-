class Produto {
  int id;
  String nome;
  double preco;

  Produto({required this.id, required this.nome, required this.preco});

  @override
  String toString() => 'ID: $id | Nome: $nome | Preço: R\$${preco.toStringAsFixed(2)}';
}

class ProdutoRepository {
  final List<Produto> _produtos = [];

  // CREATE
  void adicionar(Produto p) {
    _produtos.add(p);
    print('✅ Produto "${p.nome}" adicionado com sucesso!');
  }

  // READ
  void listarTodos() {
    if (_produtos.isEmpty) {
      print('⚠️ Nenhun produto cadastrado.');
      return;
    }
    print('\n--- Lista de Produtos ---');
    _produtos.forEach((p) => print(p));
  }

  // UPDATE
  void atualizar(int id, String novoNome, double novoPreco) {
    try {
      var p = _produtos.firstWhere((prod) => prod.id == id);
      p.nome = novoNome;
      p.preco = novoPreco;
      print('🔄 Produto ID $id atualizado!');
    } catch (e) {
      print('❌ Erro: Produto com ID $id não encontrado.');
    }
  }

  // DELETE
  void excluir(int id) {
    _produtos.removeWhere((p) => p.id == id);
    print('🗑️ Produto ID $id removido (se existia).');
  }
}
void main() {
  var repo = ProdutoRepository();

  // 1. Create
  repo.adicionar(Produto(id: 1, nome: 'Teclado Mecânico', preco: 250.00));
  repo.adicionar(Produto(id: 2, nome: 'Mouse Gamer', preco: 120.00));

  // 2. Read
  repo.listarTodos();

  // 3. Update
  repo.atualizar(1, 'Teclado RGB', 280.00);

  // 4. Delete
  repo.excluir(2);

  // Verificando resultado final
  repo.listarTodos();
}