import 'package:flutter/material.dart';
import 'package:appchat/screens/mapa.dart';
import 'package:appchat/screens/chat_screen.dart';

class MenuOptions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MenuOptionsState();
  }
}

class MenuOptionsState extends State<MenuOptions> {
  int paginaAtual = 0;
  PageController? pc;

  setPaginaAtual(pagina) {
    setState(() {
      paginaAtual = pagina;
    });
  }

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        children: [MapSample(), ChatScreen()], // Adicione as telas Mapa e Chat aqui
        onPageChanged: setPaginaAtual,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaAtual,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Mapa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chat",
          ),
        ],
        onTap: (pagina) {
          pc?.animateToPage(pagina,
              duration: Duration(milliseconds: 400), curve: Curves.ease);
        },
        backgroundColor: Colors.teal[900],
      ),
    );
  }
}
