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


    scaffoldBackgroundColor: fundo,


    colorScheme: ColorScheme.fromSeed(

      seedColor: principal,

    ),



    appBarTheme: const AppBarTheme(


      backgroundColor: principal,


      elevation: 0,


      centerTitle: true,


      titleTextStyle: TextStyle(

        color: Colors.white,

        fontSize:20,

        fontWeight:FontWeight.bold,

      ),


    ),



    elevatedButtonTheme:
    ElevatedButtonThemeData(


      style: ElevatedButton.styleFrom(


        backgroundColor: principal,


        foregroundColor: Colors.white,


        shape: RoundedRectangleBorder(

          borderRadius:
          BorderRadius.all(

            Radius.circular(14),

          ),

        ),


      ),


    ),



    cardTheme: CardThemeData(


      color: Colors.white,


      elevation: 2,


      shape: RoundedRectangleBorder(

        borderRadius:
        BorderRadius.circular(18),

      ),


    ),


  );


}