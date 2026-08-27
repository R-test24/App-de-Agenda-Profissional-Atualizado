import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'clientes_screen.dart';
import 'novo_agendamento_screen.dart';
import 'agenda_screen.dart';
import 'relatorios_screen.dart';
import 'ativacao_screen.dart';

import '../repositories/agendamento_repository.dart';
import '../services/licenca_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AgendamentoRepository repository =
      AgendamentoRepository();

  List<Map<String, dynamic>> agendamentosHoje = [];

  int totalHoje = 0;
  double faturamentoHoje = 0;
  int totalClientes = 0;

  String proximoHorario = "Nenhum";

  String plano = "Carregando...";
  String vencimento = "Carregando...";
  String diasRestantes = "";

  bool licencaVitalicia = false;

  @override
  void initState() {
    super.initState();

    carregarDados();
    carregarLicenca();
  }

  // ============================================================
  // SAIR DA AGENDA
  // ============================================================

  Future<void> sair() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const AtivacaoScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao sair: $e"),
        ),
      );
    }
  }

  // ============================================================
  // LICENÇA
  // ============================================================

  Future<void> carregarLicenca() async {
    final licencaService = LicencaService();

    final dados = await licencaService.obterDadosLocais();

    if (!mounted) return;

    final planoLocal =
        dados['plano']?.toString();

    final dataExpiracao =
        dados['dataExpiracao'] as DateTime?;

    final dias =
        dados['diasRestantes'] as int?;

    setState(() {
      plano = planoLocal == null ||
              planoLocal.isEmpty
          ? "Não informado"
          : planoLocal;

      licencaVitalicia =
          dados['vitalicia'] == true;

      if (licencaVitalicia) {
        vencimento = "Sem vencimento";
        diasRestantes = "";
      } else if (dataExpiracao != null) {
        vencimento =
            "${dataExpiracao.day.toString().padLeft(2, '0')}/"
            "${dataExpiracao.month.toString().padLeft(2, '0')}/"
            "${dataExpiracao.year}";

        diasRestantes =
            dias == null
                ? ""
                : "$dias dias restantes";
      } else {
        vencimento = "Não informado";
        diasRestantes = "";
      }
    });
  }

  // ============================================================
  // CARREGAR DADOS
  // ============================================================

  Future<void> carregarDados() async {
    final lista =
        await repository.listarAgendamentosComCliente();

    final clientes =
        await repository.listarClientes();

    final hoje = DateTime.now();

    final dataHoje =
        "${hoje.day.toString().padLeft(2, '0')}/"
        "${hoje.month.toString().padLeft(2, '0')}/"
        "${hoje.year}";

    final filtrados = lista.where((item) {
      return item['data'] == dataHoje;
    }).toList();

    double total = 0;

    for (final item in filtrados) {
      total +=
          (item['valor'] ?? 0).toDouble();
    }

    String proximo = "Nenhum";

    if (filtrados.isNotEmpty) {
      filtrados.sort((a, b) {
        return a['horario']
            .compareTo(b['horario']);
      });

      proximo =
          filtrados.first['horario'];
    }

    if (!mounted) return;

    setState(() {
      agendamentosHoje = filtrados;

      totalHoje = filtrados.length;

      faturamentoHoje = total;

      totalClientes = clientes.length;

      proximoHorario = proximo;
    });
  }

  // ============================================================
  // TELA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F4F6),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF374151),

        elevation: 0,

        title: const Text(
          "Gestão de Agenda",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: "Sair",

            icon: const Icon(
              Icons.logout,
              color: Colors.white,
              size: 27,
            ),

            onPressed: () async {
              final confirmar =
                  await showDialog<bool>(
                context: context,

                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text(
                      "Sair da agenda",
                    ),

                    content: const Text(
                      "Deseja realmente sair da agenda?",
                    ),

                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            false,
                          );
                        },

                        child: const Text(
                          "Cancelar",
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(
                            dialogContext,
                            true,
                          );
                        },

                        icon: const Icon(
                          Icons.logout,
                        ),

                        label: const Text(
                          "Sair",
                        ),
                      ),
                    ],
                  );
                },
              );

              if (confirmar == true) {
                await sair();
              }
            },
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            const Text(
              "Olá, profissional 👋",

              style: TextStyle(
                fontSize: 26,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Organize seus compromissos e acompanhe seus resultados.",

              style: TextStyle(
                fontSize: 15,
                color:
                    Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 25),

            // ==================================================
            // INDICADORES
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: CardIndicador(
                    titulo:
                        "Atendimentos",

                    valor:
                        "$totalHoje",

                    icone:
                        Icons.event_available,
                  ),
                ),

                const SizedBox(
                  width: 15,
                ),

                Expanded(
                  child: CardIndicador(
                    titulo:
                        "Faturamento",

                    valor:
                        "R\$ ${faturamentoHoje.toStringAsFixed(2)}",

                    icone:
                        Icons.attach_money,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: CardIndicador(
                    titulo:
                        "Clientes",

                    valor:
                        "$totalClientes",

                    icone:
                        Icons.people_outline,
                  ),
                ),

                const SizedBox(
                  width: 15,
                ),

                Expanded(
                  child: CardIndicador(
                    titulo:
                        "Próximo",

                    valor:
                        proximoHorario,

                    icone:
                        Icons.access_time,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ==================================================
            // COMPROMISSOS
            // ==================================================

            const Text(
              "Compromissos de hoje",

              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 15),

            ListaAgendamentos(
              agendamentos:
                  agendamentosHoje,
            ),

            const SizedBox(height: 30),

            // ==================================================
            // MENU
            // ==================================================

            BotaoMenu(
              texto: "Agenda",

              icone:
                  Icons.calendar_month,

              onTap: () async {
                await Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const AgendaScreen(),
                  ),
                );

                carregarDados();
              },
            ),

            BotaoMenu(
              texto:
                  "Novo Agendamento",

              icone:
                  Icons.add_circle_outline,

              onTap: () async {
                await Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const NovoAgendamentoScreen(),
                  ),
                );

                carregarDados();
              },
            ),

            BotaoMenu(
              texto: "Clientes",

              icone:
                  Icons.people_outline,

              onTap: () async {
                await Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const ClientesScreen(),
                  ),
                );

                carregarDados();
              },
            ),

            BotaoMenu(
              texto: "Relatórios",

              icone:
                  Icons.bar_chart,

              onTap: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                        const RelatoriosScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CARD INDICADOR
// ============================================================

class CardIndicador extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;

  const CardIndicador({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.05,
            ),

            blurRadius: 10,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icone,

            size: 30,

            color:
                const Color(0xFF374151),
          ),

          const SizedBox(
            height: 15,
          ),

          Text(
            valor,

            style:
                const TextStyle(
              fontSize: 22,
              fontWeight:
                  FontWeight.bold,
              color:
                  Color(0xFF111827),
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            titulo,

            style:
                const TextStyle(
              color:
                  Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LISTA DE AGENDAMENTOS
// ============================================================

class ListaAgendamentos
    extends StatelessWidget {
  final List<Map<String, dynamic>>
      agendamentos;

  const ListaAgendamentos({
    super.key,
    required this.agendamentos,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    if (agendamentos.isEmpty) {
      return Container(
        padding:
            const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(16),
        ),

        child: const Row(
          children: [
            Icon(
              Icons.event_busy,
              color: Colors.grey,
            ),

            SizedBox(width: 15),

            Text(
              "Nenhum compromisso hoje",
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          agendamentos.map((item) {
        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.calendar_month,

              color:
                  Color(0xFF374151),
            ),

            title: Text(
              "${item['horario']} - ${item['clienteNome']}",

              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            subtitle: Text(
              item['servico'] ?? "",
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================
// BOTÃO MENU
// ============================================================

class BotaoMenu
    extends StatelessWidget {
  final String texto;
  final IconData icone;
  final VoidCallback onTap;

  const BotaoMenu({
    super.key,
    required this.texto,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,

      height: 55,

      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      child: ElevatedButton.icon(
        onPressed: onTap,

        icon: Icon(
          icone,
          color: Colors.white,
        ),

        label: Text(
          texto,

          style:
              const TextStyle(
            fontSize: 16,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF374151),

          foregroundColor:
              Colors.white,

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
        ),
      ),
    );
  }
}