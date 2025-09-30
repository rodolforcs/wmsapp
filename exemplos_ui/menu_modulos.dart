import 'package:flutter/material.dart';

// 1. Ponto de entrada da aplicação.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exemplo de Módulo WMS',
      theme: ThemeData(
        // Tema visual moderno, com cores que remetem a um ambiente industrial/tecnológico.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness
              .dark, // Um tema escuro é ótimo para ambientes de armazém.
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      // A tela inicial do nosso exemplo é a tela do módulo de Estoque.
      home: const EstoqueModuleScreen(),
    );
  }
}

// 2. A tela principal do Módulo de Estoque.
//    Ela é um StatefulWidget porque precisa gerenciar o estado da aba selecionada.
class EstoqueModuleScreen extends StatefulWidget {
  const EstoqueModuleScreen({super.key});

  @override
  State<EstoqueModuleScreen> createState() => _EstoqueModuleScreenState();
}

class _EstoqueModuleScreenState extends State<EstoqueModuleScreen> {
  // Variável que controla qual aba está atualmente selecionada. Começa na primeira (índice 0).
  int _selectedIndex = 0;

  // Lista das telas (widgets) que serão exibidas. A ordem DEVE corresponder à ordem das abas.
  static const List<Widget> _widgetOptions = <Widget>[
    // Tela para a opção 1: Recebimento
    ModuleOptionScreen(
      title: 'Recebimento de Materiais',
      icon: Icons.inventory_2,
      color: Colors.green,
      description:
          'Esta tela conteria a lógica para registrar a entrada de novos materiais, ler notas fiscais, etc.',
    ),
    // Tela para a opção 2: Endereçamento
    ModuleOptionScreen(
      title: 'Endereçamento de Estoque',
      icon: Icons.forklift, // Ícone de empilhadeira, temático para WMS.
      color: Colors.orange,
      description:
          'Aqui o operador seria guiado para guardar os paletes recebidos nos endereços corretos do armazém.',
    ),
    // Tela para a opção 3: Separação
    ModuleOptionScreen(
      title: 'Separação de Requisições',
      icon: Icons.checklist,
      color: Colors.cyan,
      description:
          'Nesta tela, o sistema mostraria uma lista de itens a serem coletados (picking) para atender a um pedido ou ordem de produção.',
    ),
  ];

  // Função chamada quando o usuário toca em uma das abas.
  void _onItemTapped(int index) {
    // setState notifica o Flutter que o estado mudou, fazendo com que a tela se reconstrua
    // com a nova aba selecionada.
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // O título do AppBar muda dinamicamente com base na aba selecionada.
        title: Text(_widgetOptions[_selectedIndex].key.toString()),
      ),
      // O corpo da tela é a tela da lista `_widgetOptions` correspondente ao índice selecionado.
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      // 3. A Barra de Navegação Inferior (BottomNavigationBar).
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          // Definição de cada botão/aba na barra.
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Receber',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forklift),
            label: 'Endereçar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Separar',
          ),
        ],
        currentIndex: _selectedIndex, // Informa qual aba está ativa.
        selectedItemColor:
            Colors.amber[800], // Cor do ícone e texto da aba ativa.
        onTap: _onItemTapped, // Função a ser chamada quando uma aba é tocada.
      ),
    );
  }
}

// 4. Widget genérico para representar o conteúdo de cada tela do módulo.
//    No seu app real, cada opção teria seu próprio widget complexo.
class ModuleOptionScreen extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  // Usamos uma Key para que o AppBar possa ler o título.
  const ModuleOptionScreen({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  }) : super(key: const ValueKey('')); // Truque para o AppBar ler o título

  @override
  Key? get key => ValueKey<String>(title);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(
            icon,
            size: 80,
            color: color,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
