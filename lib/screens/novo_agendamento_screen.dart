import 'package:flutter/material.dart';

import '../models/agendamento.dart';
import '../models/cliente.dart';
import '../repositories/agendamento_repository.dart';
import '../repositories/cliente_repository.dart';



class NovoAgendamentoScreen extends StatefulWidget {


  const NovoAgendamentoScreen({super.key});



  @override
  State<NovoAgendamentoScreen> createState() =>
      _NovoAgendamentoScreenState();


}






class _NovoAgendamentoScreenState
    extends State<NovoAgendamentoScreen> {



  final ClienteRepository clienteRepository =
      ClienteRepository();



  final AgendamentoRepository agendamentoRepository =
      AgendamentoRepository();




  List<Cliente> clientes = [];

  Cliente? clienteSelecionada;


  String? horarioSelecionado;





  final List<String> horarios = [


    "07:00",
    "07:15",
    "07:30",
    "08:00",
    "08:15",
    "08:30",
    "09:00",
    "09:15",
    "09:30",
    "10:00",
    "10:15",
    "10:30",
    "11:00",
    "11:15",
    "11:30",
    "13:00",
    "13:15",
    "13:30",
    "14:00",
    "14:15",
    "14:30",
    "15:00",
    "15:15",
    "15:30",
    "16:00",
    "16:15",
    "16:30",
    "17:00",
    "17:15",
    "17:30",
    "18:00",
    "18:15",
    "18:30",
    "19:00",
    "19:15",
    "19:30",
    "20:00",
    "20:15",
    "20:30",
    "21:00",
    "21:15",
    "21:30",
    "22:00",
    "22:15",
    "22:30",
    "23:00",

  ];





  final dataController =
      TextEditingController();


  final servicoController =
      TextEditingController();


  final valorController =
      TextEditingController();


  final observacaoController =
      TextEditingController();







  @override
  void initState(){


    super.initState();


    carregarClientes();


    preencherDataAtual();


  }







  void preencherDataAtual(){


    final hoje =
    DateTime.now();



    dataController.text =

        "${hoje.day.toString().padLeft(2,'0')}/"
        "${hoje.month.toString().padLeft(2,'0')}/"
        "${hoje.year}";


  }







  Future<void> carregarClientes() async {



    final lista =
    await clienteRepository.listarClientes();



    if(!mounted) return;



    setState((){


      clientes = lista;


    });



  }







  Future<void> selecionarData() async {



    final DateTime? dataEscolhida =
    await showDatePicker(



      context: context,


      initialDate:
      DateTime.now(),


      firstDate:
      DateTime(2025),


      lastDate:
      DateTime(2035),


    );




    if(dataEscolhida != null){



      setState((){


        dataController.text =

            "${dataEscolhida.day.toString().padLeft(2,'0')}/"
            "${dataEscolhida.month.toString().padLeft(2,'0')}/"
            "${dataEscolhida.year}";


      });


    }


  }

  Future<void> salvar() async {


    if(clienteSelecionada == null){

      mensagem(
          "Selecione um cliente"
      );

      return;

    }




    if(horarioSelecionado == null){


      mensagem(
          "Selecione o horário"
      );


      return;


    }





    if(servicoController.text.isEmpty){


      mensagem(
          "Informe o serviço"
      );


      return;


    }





    if(valorController.text.isEmpty){


      mensagem(
          "Informe o valor"
      );


      return;


    }






    final agendamento = Agendamento(



      clienteId:
      clienteSelecionada!.id!,



      data:
      dataController.text,



      horario:
      horarioSelecionado!,



      servico:
      servicoController.text,



      valor:
      double.tryParse(

        valorController.text
            .replaceAll(",", "."),

      ) ?? 0,



      observacao:
      observacaoController.text,


    );






    await agendamentoRepository
        .salvarAgendamento(
        agendamento
    );







    if(!mounted) return;





    ScaffoldMessenger.of(context)
        .showSnackBar(



      const SnackBar(


        content:
        Text(

            "Agendamento salvo com sucesso!"

        ),


      ),


    );




    Navigator.pop(context);



  }








  void mensagem(String texto){



    ScaffoldMessenger.of(context)
        .showSnackBar(



      SnackBar(


        content:
        Text(texto),


      ),


    );


  }









  InputDecoration campo(String texto, IconData icone){


    return InputDecoration(


      labelText: texto,


      prefixIcon:
      Icon(icone),



      filled:
      true,



      fillColor:
      Colors.white,



      border:
      OutlineInputBorder(



        borderRadius:
        BorderRadius.circular(15),



      ),



    );


  }








  @override
  Widget build(BuildContext context){



    return Scaffold(



      appBar: AppBar(


        title:
        const Text(

            "Novo Agendamento"

        ),


      ),







      body:
      SingleChildScrollView(



        padding:
        const EdgeInsets.all(20),



        child:
        Column(



          children: [






            DropdownButtonFormField<Cliente>(



              decoration:
              campo(

                  "Cliente",

                  Icons.person

              ),




              value:
              clienteSelecionada,




              items:
              clientes.map((cliente){



                return DropdownMenuItem(


                  value:
                  cliente,


                  child:
                  Text(

                      cliente.nome

                  ),


                );



              }).toList(),




              onChanged:(cliente){



                setState((){


                  clienteSelecionada =
                      cliente;



                });



              },


            ),







            const SizedBox(height:15),







            TextField(



              controller:
              dataController,



              readOnly:
              true,



              onTap:
              selecionarData,



              decoration:
              campo(

                  "Data",

                  Icons.calendar_month

              ),



            ),








            const SizedBox(height:15),






            DropdownButtonFormField<String>(



              decoration:
              campo(

                  "Horário",

                  Icons.access_time

              ),




              value:
              horarioSelecionado,




              items:
              horarios.map((hora){



                return DropdownMenuItem(


                  value:
                  hora,


                  child:
                  Text(hora),


                );


              }).toList(),




              onChanged:(hora){



                setState((){


                  horarioSelecionado =
                      hora;



                });



              },


            ),







            const SizedBox(height:15),







            TextField(


              controller:
              servicoController,



              decoration:
              campo(

                  "Serviço",

                  Icons.work_outline

              ),



            ),







            const SizedBox(height:15),







            TextField(



              controller:
              valorController,



              keyboardType:
              TextInputType.number,



              decoration:
              campo(

                  "Valor",

                  Icons.attach_money

              ),



            ),







            const SizedBox(height:15),







            TextField(



              controller:
              observacaoController,



              maxLines:
              3,



              decoration:
              campo(

                  "Observação",

                  Icons.notes

              ),



            ),








            const SizedBox(height:25),







            SizedBox(



              width:
              double.infinity,



              height:
              55,



              child:
              ElevatedButton.icon(



                onPressed:
                salvar,



                icon:
                const Icon(

                    Icons.save

                ),



                label:
                const Text(

                    "Salvar Agendamento"

                ),



              ),



            )





          ],



        ),



      ),



    );


  }


}