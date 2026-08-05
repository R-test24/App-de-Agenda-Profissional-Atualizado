import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../repositories/agendamento_repository.dart';


class EditarAgendamentoScreen extends StatefulWidget {

  final Map<String, dynamic> agendamento;


  const EditarAgendamentoScreen({
    super.key,
    required this.agendamento,
  });



  @override
  State<EditarAgendamentoScreen> createState() =>
      _EditarAgendamentoScreenState();

}



class _EditarAgendamentoScreenState
    extends State<EditarAgendamentoScreen> {


  final AgendamentoRepository repository =
      AgendamentoRepository();



  late TextEditingController dataController;
  late TextEditingController horarioController;
  late TextEditingController servicoController;
  late TextEditingController valorController;
  late TextEditingController observacaoController;



  @override
  void initState() {

    super.initState();


    dataController = TextEditingController(
      text: widget.agendamento['data'],
    );


    horarioController = TextEditingController(
      text: widget.agendamento['horario'],
    );


    servicoController = TextEditingController(
      text: widget.agendamento['servico'],
    );


    valorController = TextEditingController(
      text: widget.agendamento['valor'].toString(),
    );


    observacaoController = TextEditingController(
      text: widget.agendamento['observacao'] ?? "",
    );

  }





  Future<void> salvarAlteracao() async {


    final agendamento = Agendamento(

      id: widget.agendamento['id'],

      clienteId:
          widget.agendamento['clienteId'],

      data:
          dataController.text,

      horario:
          horarioController.text,

      servico:
          servicoController.text,

      valor:
          double.tryParse(
            valorController.text,
          ) ?? 0,


      observacao:
          observacaoController.text,

    );



    await repository.atualizarAgendamento(
      agendamento,
    );



    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content:
            Text("Agendamento atualizado!"),

      ),

    );



    Navigator.pop(context);


  }





  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title:
            const Text("Editar Agendamento"),

        backgroundColor:
            Colors.pinkAccent,

      ),



      body: Padding(

        padding:
            const EdgeInsets.all(20),



        child: Column(

          children: [


            TextField(

              controller:
                  dataController,

              decoration:
                  const InputDecoration(

                labelText:
                    "Data",

                border:
                    OutlineInputBorder(),

              ),

            ),



            const SizedBox(height:15),



            TextField(

              controller:
                  horarioController,

              decoration:
                  const InputDecoration(

                labelText:
                    "Horário",

                border:
                    OutlineInputBorder(),

              ),

            ),



            const SizedBox(height:15),



            TextField(

              controller:
                  servicoController,

              decoration:
                  const InputDecoration(

                labelText:
                    "Serviço",

                border:
                    OutlineInputBorder(),

              ),

            ),



            const SizedBox(height:15),



            TextField(

              controller:
                  valorController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  const InputDecoration(

                labelText:
                    "Valor",

                border:
                    OutlineInputBorder(),

              ),

            ),



            const SizedBox(height:15),



            TextField(

              controller:
                  observacaoController,

              maxLines:
                  3,

              decoration:
                  const InputDecoration(

                labelText:
                    "Observação",

                border:
                    OutlineInputBorder(),

              ),

            ),



            const SizedBox(height:25),



            SizedBox(

              width:
                  double.infinity,


              child:
                  ElevatedButton(

                onPressed:
                    salvarAlteracao,


                child:
                    const Text(
                      "Salvar Alteração",
                    ),

              ),

            ),


          ],


        ),


      ),


    );


  }

}