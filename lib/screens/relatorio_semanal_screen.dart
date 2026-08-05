import 'package:flutter/material.dart';

import '../repositories/agendamento_repository.dart';



class RelatorioSemanalScreen extends StatefulWidget {


  const RelatorioSemanalScreen({super.key});


  @override
  State<RelatorioSemanalScreen> createState() =>
      _RelatorioSemanalScreenState();

}



class _RelatorioSemanalScreenState
    extends State<RelatorioSemanalScreen>{


final AgendamentoRepository repository =
    AgendamentoRepository();



int quantidade = 0;

double faturamento = 0;



@override
void initState(){

super.initState();

carregar();

}



Future<void> carregar() async {


final hoje = DateTime.now();


// encontra segunda-feira
final inicio =
    hoje.subtract(
      Duration(
        days: hoje.weekday - 1,
      ),
    );


// domingo
final fim =
    inicio.add(
      const Duration(days:6),
    );



final qtd =
 await repository.totalAtendimentosSemana(
    inicio,
    fim,
 );



final valor =
 await repository.faturamentoSemana(
    inicio,
    fim,
 );



setState((){

quantidade = qtd;

faturamento = valor;

});


}




Widget card(
String titulo,
String valor,
IconData icone
){

return Card(

elevation:4,

child: ListTile(

leading: Icon(

icone,

color: Colors.pinkAccent,

size:40,

),


title: Text(

titulo,

style: const TextStyle(

fontWeight: FontWeight.bold,

),

),


subtitle: Text(

valor,

style: const TextStyle(

fontSize:18,

),

),


),

);

}




@override
Widget build(BuildContext context){


return Scaffold(


appBar: AppBar(

title: const Text(
"Relatório Semanal",
),

backgroundColor:
Colors.pinkAccent,

),



body: Padding(

padding:
const EdgeInsets.all(20),



child: Column(

children:[



card(

"Atendimentos da semana",

"$quantidade unhas feitas",

Icons.calendar_month,

),



const SizedBox(height:20),



card(

"Faturamento semanal",

"R\$ ${faturamento.toStringAsFixed(2)}",

Icons.attach_money,

),



],

),

),


);


}


}