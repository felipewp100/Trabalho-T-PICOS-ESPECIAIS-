// ==========================================
// 01. CLASSES & OBJETOS
// ==========================================

// --- Exercício 1: Classe Livro [cite: 3] ---
class Livro {
  String titulo; 
  String autor; 
  int paginas; 
  bool lido = false; 
  Livro(this.titulo, this.autor, this.paginas);

  // Método para mudar o estado de leitura 
  void marcarComoLido() {
    lido = true;
    print("O livro '$titulo' foi marcado como lido!"); 

  // Representação legível do objeto 
  @override
  String toString() {
    return "Livro: $titulo | Autor: $autor | Páginas: $paginas | Lido: ${lido ? 'Sim' : 'Não'}";
  }
}

// --- Exercício 2: Classe ContaBancaria com encapsulamento
  double _saldo = 0; // Atributo privado 

  // Getter para consultar o saldo 
  double get saldo => _saldo;

  void depositar(double valor) {
    _saldo += valor; 
    print("Depósito de R\$ $valor realizado.");
  }

  void sacar(double valor) {
    // Verifica saldo suficiente antes de realizar a operação 
    if (valor <= _saldo) {
      _saldo -= valor;
      print("Saque de R\$ $valor realizado.");
    } else {
      print("Erro: Saldo insuficiente para sacar R\$ $valor."); // 
  }
}

// ==========================================
// 02. ATRIBUTOS & CONSTRUTORES
// ==========================================

// --- Exercício 3: Construtor nomeado fromJson 
class Usuario {
  String nome; 
  String email; 
  bool ativo; 

  // Construtor padrão 
  Usuario(this.nome, this.email, this.ativo);

  // Construtor nomeado para Mapas 
  Usuario.fromJson(Map<String, dynamic> json)
      : nome = json['nome'],
        email = json['email'],
        ativo = json['ativo'];

  // Construtor factory para convidados 
  factory Usuario.convidado() {
    return Usuario("Convidado", "sem@email.com", false); // 
}

// --- Exercício 4: Atributos com getter e setter  ---
class Termostato {
  double _temperatura = 20.0; // Atributo privado 
  double get temperatura => _temperatura; // 

  set temperatura(double valor) {
    // Validação entre 16.0 e 30.0 
    if (valor >= 16.0 && valor <= 30.0) {
      _temperatura = valor;
    } else {
      print("Aviso: Temperatura $valor fora do intervalo (16-30)."); // 
    }
  }
}

// ==========================================
// 03. MÉTODOS
// ==========================================

// --- Exercício 5: Classe Carrinho [cite: 28] ---
class Carrinho {
  final List<String> _itens = []; // Lista privada [cite: 29]
  double _total = 0;  [cite: 30]

  void adicionarItem(String nome, double preco) {
    _itens.add(nome);  
    _total += preco;  
  }

  void removerItem(String nome, double preco) {
    if (_itens.contains(nome)) {
      _itens.remove(nome); 
      _total -= preco; 
    }
  }

  bool estaVazio() => _itens.isEmpty; 

  void exibirResumo() {
    print("Carrinho: $_itens | Total: R\$ $_total"); 
  }
}

// --- Exercício 6: Método com retorno de lista 
class Turma {
  List<String> alunos; 

  Turma(this.alunos);

  // Retorna nomes com nota >= 7 
  List<String> aprovados(List<double> notas) {
    List<String> resultado = [];
    for (int i = 0; i < alunos.length; i++) {
      if (notas[i] >= 7.0) resultado.add(alunos[i]);
    }
    return resultado;
  }

  double mediaGeral(List<double> notas) {
    return notas.reduce((a, b) => a + b) / notas.length; 
  }
}

// ==========================================
// 04. HERANÇA & POLIMORFISMO
// ==========================================

// --- Exercício 7: Hierarquia Funcionário 
  String nome;
  double salario;

  Funcionario(this.nome, this.salario);

  void exibirInfo() => print("Func: $nome | Salário: $salario"); 
}

class Gerente extends Funcionario {
  String departamento;
  Gerente(String nome, double sal, this.departamento) : super(nome, sal); 

  void aprovarFerias(String func) => print("Gerente $nome aprovou férias de $func."); 

  @override
  void exibirInfo() {
    super.exibirInfo();
    print("Depto: $departamento"); 
}

class Desenvolvedor extends Funcionario {
  String linguagem;
  Desenvolvedor(String nome, double sal, this.linguagem) : super(nome, sal); 
  void fazerDeploy() => print("$nome fez deploy em $linguagem."); 
  @override
  void exibirInfo() {
    super.exibirInfo();
    print("Linguagem: $linguagem"); 
  }
}

// --- Exercício 8: Polimorfismo com formas 
abstract class Forma {
  double calcularArea(); 
}

class Retangulo extends Forma {
  double largura, altura; 
  Retangulo(this.largura, this.altura);
  @override
  double calcularArea() => largura * altura;
}

class Circulo extends Forma {
  double raio; 
  Circulo(this.raio);
  @override
  double calcularArea() => 3.14159 * raio * raio;
}

class Triangulo extends Forma {
  double base, altura; 
  Triangulo(this.base, this.altura);
  @override
  double calcularArea() => (base * altura) / 2;
}

// ==========================================
// 05. ABSTRACT & INTERFACES
// ==========================================

// --- Exercício 9: Classe abstrata Veiculo 
abstract class Veiculo {
  String modelo; 
  Veiculo(this.modelo);
  void mover(); 
  void exibirModelo() => print("Veículo: $modelo"); 
}

class Carro extends Veiculo {
  Carro(String mod) : super(mod);
  @override
  void mover() => print("$modelo está rodando na estrada."); 
}

class Barco extends Veiculo {
  Barco(String mod) : super(mod);
  @override
  void mover() => print("$modelo está navegando no mar."); 
}
class Aviao extends Veiculo {
  Aviao(String mod) : super(mod);
  @override
  void mover() => print("$modelo está voando nos céus."); 
}

// --- Exercício 10: Interfaces com implements 
abstract class Exportavel {
  void exportarCsv(); 
  void exportarPdf(); 
}

abstract class Imprimivel {
  void imprimir(); 
}

class Relatorio implements Exportavel, Imprimivel {
  String titulo; 
  Relatorio(this.titulo);

  @override
  void exportarCsv() => print("CSV de '$titulo' exportado."); 
  void exportarPdf() => print("PDF de '$titulo' exportado."); 
  @override
  void imprimir() => print("Relatório '$titulo' impresso."); 
}

// ==========================================
// 06. MIXIN
// ==========================================

// --- Exercício 11: Mixin Registravel [cite: 87] ---
mixin Registravel {
  final List<String> _logs = []; 

  void registrar(String msg) {
    _logs.add("[LOG] $msg"); 
    print("[LOG] $msg");
  }

  void exibirLogs() => _logs.forEach(print);
}

class ServicoDeEmail with Registravel {
  void enviar(String dest, String assunto) => registrar("Para $dest: $assunto"); 
  void cancelar(String id) => registrar("Cancelado ID: $id"); 
}

// --- Exercício 12: Combinando Mixin com Herança 
mixin Nadavel {
  void nadar(String nome) => print("$nome está nadando!"); 
}

mixin Corredora {
  void correr(String nome) => print("$nome está correndo!"); 
}

class Atleta {
  String nome; 
  Atleta(this.nome);
  void treinar() => print("$nome está treinando."); 
}

class Triatleta extends Atleta with Nadavel, Corredora { 
  Triatleta(String nome) : super(nome);
}

class Nadador extends Atleta with Nadavel { 
  Nadador(String nome) : super(nome);
}

// ==========================================
// FUNÇÃO PRINCIPAL (MAIN)
// ==========================================

void main() {
  print("--- Ex 1 ---");
  var l1 = Livro("Poo com Dart", "Felipe", 100);
  var l2 = Livro("Flutter 101", "Ana", 150);
  l1.marcarComoLido(); 
  print(l1); 
  print(l2); 

  print("\n--- Ex 2 ---");
  var conta = ContaBancaria();
  conta.depositar(100); 
  conta.sacar(50); 
  conta.sacar(200); 
  print("Saldo: ${conta.saldo}"); 

  print("\n--- Ex 3 ---");
  var u1 = Usuario("Felipe", "f@mail.com", true);
  var u2 = Usuario.fromJson({"nome": "Bia", "email": "b@mail.com", "ativo": true});
  var u3 = Usuario.convidado();
  print("${u1.nome}, ${u2.nome}, ${u3.nome}");

  print("\n--- Ex 4 ---");
  var termo = Termostato();
  termo.temperatura = 22; 
  termo.temperatura = 35; 

  print("\n--- Ex 5 ---");
  var car = Carrinho();
  car.adicionarItem("Teclado", 100); 
  car.adicionarItem("Mouse", 50); 
  car.adicionarItem("Cabo", 20); 
  car.removerItem("Cabo", 20); 
  car.exibirResumo(); 

  print("\n--- Ex 6 ---");
  var turma = Turma(["Felipe", "Ana", "João", "Maria"]);
  var notas = [8.0, 6.0, 9.0, 5.0];
  print("Aprovados: ${turma.aprovados(notas)}"); 
  print("Média: ${turma.mediaGeral(notas)}"); 

  print("\n--- Ex 7 ---");
  var ger = Gerente("Felipe", 5000, "TI");
  var dev = Desenvolvedor("Beto", 4000, "Dart");
  ger.exibirInfo(); 
  ger.aprovarFerias("Beto"); 
  dev.exibirInfo(); 
  dev.fazerDeploy(); 

  print("\n--- Ex 8 ---");
  List<Forma> formas = [Retangulo(10, 5), Circulo(2), Triangulo(10, 5)];
  for (var f in formas) print("Área: ${f.calcularArea()}"); 

  print("\n--- Ex 9 ---");
  List<Veiculo> veiculos = [Carro("Civic"), Barco("Titanic"), Aviao("747")];
  veiculos.forEach((v) => v.mover()); 

  print("\n--- Ex 10 ---");
  var rel = Relatorio("Vendas");
  rel.imprimir(); 
  rel.exportarPdf();

  print("\n--- Ex 11 ---");
  var mail = ServicoDeEmail();
  mail.enviar("felipe@mail.com", "Teste"); 
  mail.cancelar("123"); 
  mail.exibirLogs(); 

  print("\n--- Ex 12 ---");
  var tri = Triatleta("Felipe");
  var nad = Nadador("Ana");
  tri.treinar(); 
  tri.correr(tri.nome); 
  tri.nadar(tri.nome); 
    nad.nadar(nad.nome); 
    
}