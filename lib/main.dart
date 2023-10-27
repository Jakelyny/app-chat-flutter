import 'package:appchat/screens/chat_screen.dart';
import 'package:appchat/screens/mapa.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
   );
   final CollectionReference _contatos =
   FirebaseFirestore.instance.collection('contatos');

  // _contatos.add({"nome" : "Maria", "fone" : "555555"});
  // print("incluindo dados de contato");
   ////contatos/ECbzi4R508MWVre2E47A

   //_contatos.doc("YdQbACTkWKXQw8vzs3MC").update({"fone" :"88888888"});
  // _contatos.doc("ECbzi4R508MWVre2E47A").delete();

   QuerySnapshot snapshot = await _contatos.get();

   snapshot.docs.forEach((element) {
     print(element.data().toString());
   });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {



  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: MapSample(),
    );
  }
}
