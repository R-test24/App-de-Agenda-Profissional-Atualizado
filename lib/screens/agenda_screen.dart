import 'package:flutter/material.dart';

import '../repositories/agendamento_repository.dart';
import 'editar_agendamento_screen.dart';



class AgendaScreen extends StatefulWidget {

  const AgendaScreen({super.key});


  @override
  State<AgendaScreen> createState() =>
      _AgendaScreenState();

}





class _AgendaScreenState extends State<AgendaScreen> {


  final AgendamentoRepository repository =
      AgendamentoRepository();



  List<Map<String,dynamic>> agendamentos = [];




  @override
  void initState(){

    super.initState();

    carregarAgendamentos();

  }





  Future<void> carregarAgendamentos() async {


    final lista =
        await repository.listarAgendamentosComCliente();



    if(!mounted) return;



    setState((){

      agendamentos = lista;

    });


  }







  Future<void> excluir(int id) async {


    await repository.excluirAgendamento(id);


    await carregarAgendamentos();



    if(!mounted) return;



    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content:
        Text("Agendamento excluído com sucesso!"),

      ),

    );


  }








  @override
  Widget build(BuildContext context){


    return Scaffold(



      appBar: AppBar(

        title:
        const Text("Agenda"),

      ),




      body: agendamentos.isEmpty



          ? const Center(

        child: Text(

          "Nenhum agendamento",

          style: TextStyle(

            fontSize: 18,

            color: Colors.grey,

          ),

        ),

      )



          :

      ListView.builder(



        padding:
        const EdgeInsets.all(15),



        itemCount:
        agendamentos.length,



        itemBuilder:
            (context,index){



          final agendamento =
          agendamentos[index];




          return Card(



            child: ListTile(



              contentPadding:
              const EdgeInsets.all(12),




              leading:
              const CircleAvatar(


                backgroundColor:
                Color(0xFFE5E7EB),



                child:

                Icon(

                  Icons.calendar_month,

                  color:
                  Color(0xFF374151),

                ),


              ),





              title: Text(


                "${agendamento['data']} | ${agendamento['horario']}",


                style:
                const TextStyle(

                  fontWeight:
                  FontWeight.bold,

                ),


              ),





              subtitle:
              Column(


                crossAxisAlignment:
                CrossAxisAlignment.start,


                children: [


                  const SizedBox(height:5),



                  Text(

                    "Cliente: ${agendamento['clienteNome']}",

                  ),



                  Text(

                    "Serviço: ${agendamento['servico']}",

                  ),



                  Text(

                    "Valor: R\$ ${agendamento['valor']}",

                  ),


                ],


              ),






              trailing:

              Row(


                mainAxisSize:
                MainAxisSize.min,



                children: [



                  IconButton(


                    icon:
                    const Icon(

                      Icons.edit,

                      color:
                      Colors.blue,

                    ),



                    onPressed: () async {



                      await Navigator.push(


                        context,


                        MaterialPageRoute(


                          builder: (_) =>

                              EditarAgendamentoScreen(

                                agendamento:
                                agendamento,

                              ),


                        ),


                      );


                      carregarAgendamentos();



                    },


                  ),





                  IconButton(


                    icon:
                    const Icon(

                      Icons.delete,

                      color:
                      Colors.red,

                    ),



                    onPressed: () async {



                      final confirmar =
                      await showDialog<bool>(


                        context:
                        context,



                        builder:
                            (context){



                          return AlertDialog(



                            title:
                            const Text(

                              "Excluir agendamento",

                            ),



                            content:
                            const Text(

                              "Deseja realmente excluir este agendamento?",

                            ),




                            actions: [



                              TextButton(


                                onPressed: (){

                                  Navigator.pop(

                                      context,

                                      false

                                  );

                                },


                                child:
                                const Text(

                                    "Cancelar"

                                ),


                              ),




                              ElevatedButton(


                                onPressed: (){


                                  Navigator.pop(

                                      context,

                                      true

                                  );


                                },


                                child:
                                const Text(

                                    "Excluir"

                                ),


                              ),



                            ],



                          );


                        },


                      );




                      if(confirmar == true){


                        await excluir(

                          agendamento['id'],

                        );


                      }



                    },


                  ),


                ],


              ),



            ),



          );



        },


      ),



    );


  }


}