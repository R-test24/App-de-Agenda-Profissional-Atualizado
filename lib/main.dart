import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_theme.dart';



void main() {

  WidgetsFlutterBinding.ensureInitialized();


  runApp(

    const AgendaNailsApp(),

  );

}




class AgendaNailsApp extends StatelessWidget {


  const AgendaNailsApp({super.key});



  @override
  Widget build(BuildContext context) {


    return MaterialApp(


      debugShowCheckedModeBanner: false,


      title: "Gestão de Agenda",



      theme: AppTheme.tema,


      home: const HomeScreen(),


    );


  }


}