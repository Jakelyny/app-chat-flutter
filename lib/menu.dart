import 'package:flutter/material.dart';
import 'screens/lista.dart';
import 'screens/chat_screen.dart';

class NavigationOptions extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _NavigationOptionsState();
  }
}

class _NavigationOptionsState extends State<NavigationOptions>{
  int paginaAtual = 0;
  PageController? pc;

  @override
  void initState() {
    super.initState();
    pc = PageController(initialPage: paginaAtual);
  }

  setPaginaAtual(pagina){
    setState(() {
      paginaAtual = pagina;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pc,
        children: [
          ChatScreen(),
          Lista(),
        ],
        onPageChanged: setPaginaAtual,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaAtual,
        items : const[
          BottomNavigationBarItem(icon: Icon(Icons.chat), label : "Chat"),
          BottomNavigationBarItem(icon: Icon(Icons.location_on),label : "Mapa")
        ],
        onTap: (pagina){
          pc?.animateToPage(pagina, duration: const Duration(milliseconds: 400),
              curve: Curves.ease);
        },
        backgroundColor: Colors.grey[200],
      ),
    );
  }

}