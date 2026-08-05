import 'package:flutter/material.dart';


class AppTheme {


  static const Color fundo =
      Color(0xFFF3F4F6);


  static const Color principal =
      Color(0xFF374151);


  static const Color texto =
      Color(0xFF111827);


  static const Color textoSecundario =
      Color(0xFF6B7280);



  static ThemeData tema = ThemeData(


    useMaterial3: true,


    scaffoldBackgroundColor: fundo,



    appBarTheme: const AppBarTheme(


      backgroundColor: principal,


      elevation: 0,


      titleTextStyle: TextStyle(

        color: Colors.white,

        fontSize: 20,

        fontWeight: FontWeight.bold,

      ),


    ),




    cardTheme: CardThemeData(


      color: Colors.white,


      elevation: 2,


      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.all(

          Radius.circular(18),

        ),

      ),


    ),





    elevatedButtonTheme:
    ElevatedButtonThemeData(


      style: ElevatedButton.styleFrom(


        backgroundColor: principal,


        foregroundColor: Colors.white,


        minimumSize:
        const Size(double.infinity,55),



        shape:
        RoundedRectangleBorder(


          borderRadius:
          BorderRadius.circular(14),


        ),


      ),


    ),


  );


}