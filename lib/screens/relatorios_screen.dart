import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../repositories/agendamento_repository.dart';
import '../services/licenca_service.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  final AgendamentoRepository repository = AgendamentoRepository();
  final LicencaService licencaService = LicencaService();

  List<Map<String, dynamic>> dadosGrafico = [];

  int atendimentosHoje = 0;
  double faturamentoHoje = 0;

  int atendimentosSemana = 0;
  double faturamentoSemana = 0;

  int atendimentosMes = 0;
  double faturamentoMes = 0;

  double faturamentoAnoAtual = 0;

  String periodoSemana = "";

  // 🔥 VARIÁVEIS DA LICENÇA
  String plano = "Carregando...";
  String vencimento = "Carregando...";
  String diasRestantes = "";
  bool licencaVitalicia = false;
  bool _carregandoLicenca = true;

  @override
  void initState() {
    super.initState();
    carregarRelatorios();
    carregarLicenca();
  }

  // ================================================
  // MÉTODOS DE FORMATAÇÃO
  // ================================================
  String formatarData(DateTime data) {
    return "${data.day.toString().padLeft(2, '0')}/"
        "${data.month.toString().padLeft(2, '0')}/"
        "${data.year}";
  }

  // ================================================
  // CARREGAR RELATÓRIOS
  // ================================================
  Future<void> carregarRelatorios() async {
    final agora = DateTime.now();

    final hoje = formatarData(agora);

    final mes =
        "${agora.month.toString().padLeft(2, '0')}/"
        "${agora.year}";

    final inicioSemana = agora.subtract(
      Duration(days: agora.weekday - 1),
    );

    final fimSemana = inicioSemana.add(
      const Duration(days: 6),
    );

    final qtdHoje = await repository.totalAtendimentosDia(hoje);
    final valorHoje = await repository.faturamentoDia(hoje);

    final qtdSemana = await repository.totalAtendimentosSemana(
      inicioSemana,
      fimSemana,
    );

    final valorSemana = await repository.faturamentoSemana(
      inicioSemana,
      fimSemana,
    );

    final qtdMes = await repository.totalAtendimentosMes(mes);
    final valorMes = await repository.faturamentoMes(mes);

    final grafico = await repository.faturamentoUltimosMeses();

    final ano = await repository.faturamentoAno(
      agora.year.toString(),
    );

    if (!mounted) return;

    setState(() {
      atendimentosHoje = qtdHoje;
      faturamentoHoje = valorHoje;

      atendimentosSemana = qtdSemana;
      faturamentoSemana = valorSemana;

      atendimentosMes = qtdMes;
      faturamentoMes = valorMes;

      dadosGrafico = grafico;

      faturamentoAnoAtual = ano;

      periodoSemana =
          "${formatarData(inicioSemana)} até "
          "${formatarData(fimSemana)}";
    });
  }

  // ================================================
  // CARREGAR LICENÇA
  // ================================================
  Future<void> carregarLicenca() async {
    setState(() {
      _carregandoLicenca = true;
    });

    try {
      // TENTA BUSCAR DO FIREBASE PRIMEIRO
      final email = await licencaService.obterEmail();

      if (email != null && email.trim().isNotEmpty) {
        // 🔥 BUSCA DIRETAMENTE DO FIREBASE
        final dados = await licencaService.buscarLicencaFirebase(email);

        print('📊 DADOS DO FIREBASE NA TELA: $dados');

        if (!mounted) return;

        final planoLocal = dados['plano']?.toString() ?? 'Não informado';
        final dataExpiracao = dados['dataExpiracao'] as DateTime?;
        final dias = dados['diasRestantes'] as int?;
        final isVitalicia = dados['vitalicia'] == true;

        setState(() {
          _carregandoLicenca = false;
          licencaVitalicia = isVitalicia;
          plano = planoLocal;

          if (licencaVitalicia) {
            vencimento = "Sem vencimento";
            diasRestantes = "";
          } else if (dataExpiracao != null) {
            vencimento =
                "${dataExpiracao.day.toString().padLeft(2, '0')}/"
                "${dataExpiracao.month.toString().padLeft(2, '0')}/"
                "${dataExpiracao.year}";
            diasRestantes = dias == null ? "" : "$dias dias restantes";
          } else {
            vencimento = "Não informado";
            diasRestantes = "";
          }
        });
        return;
      }

      // SE NÃO TIVER EMAIL, USA DADOS LOCAIS
      await _carregarDadosLocais();
    } catch (e) {
      print('❌ ERRO AO CARREGAR LICENÇA: $e');
      await _carregarDadosLocais();
    }
  }

  // 🔥 FALLBACK: CARREGA DOS DADOS LOCAIS
  Future<void> _carregarDadosLocais() async {
    final dados = await licencaService.obterDadosLocais();

    if (!mounted) return;

    final planoLocal = dados['plano']?.toString() ?? 'Não informado';
    final dataExpiracao = dados['dataExpiracao'] as DateTime?;
    final dias = dados['diasRestantes'] as int?;
    final isVitalicia = dados['vitalicia'] == true;

    setState(() {
      _carregandoLicenca = false;
      licencaVitalicia = isVitalicia;
      plano = planoLocal;

      if (licencaVitalicia) {
        vencimento = "Sem vencimento";
        diasRestantes = "";
      } else if (dataExpiracao != null) {
        vencimento =
            "${dataExpiracao.day.toString().padLeft(2, '0')}/"
            "${dataExpiracao.month.toString().padLeft(2, '0')}/"
            "${dataExpiracao.year}";
        diasRestantes = dias == null ? "" : "$dias dias restantes";
      } else {
        vencimento = "Não informado";
        diasRestantes = "";
      }
    });
  }

  // ================================================
  // GRÁFICO DE FATURAMENTO
  // ================================================
  Widget graficoFaturamento() {
    if (dadosGrafico.isEmpty) {
      return const SizedBox();
    }

    double maiorValor = dadosGrafico
        .map((e) => (e['total'] as num? ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Faturamento dos últimos meses",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  maxY: maiorValor * 1.3,
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 55,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "R\$${value.toInt()}",
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= dadosGrafico.length) {
                            return const SizedBox();
                          }
                          return Text(
                            dadosGrafico[index]['mes'].toString(),
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: List.generate(
                    dadosGrafico.length,
                    (index) {
                      final valor =
                          (dadosGrafico[index]['total'] as num? ?? 0).toDouble();

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: valor,
                            width: 22,
                            color: const Color(0xFF374151),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================
  // CARD DE RELATÓRIO
  // ================================================
  Widget cardRelatorio(
    String titulo,
    String descricao,
    int quantidade,
    double valor,
    IconData icone,
  ) {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icone,
                size: 35,
                color: const Color(0xFF374151),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(descricao),
                  const SizedBox(height: 8),
                  Text(
                    "$quantidade atendimentos realizados",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Faturamento: R\$ ${valor.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================
  // CARD MINHA LICENÇA
  // ================================================
  Widget cardMinhaLicenca() {
    if (_carregandoLicenca) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Color(0xFF374151),
                ),
                SizedBox(width: 10),
                Text(
                  "Minha Licença",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Center(
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: Color(0xFF374151),
              ),
              SizedBox(width: 10),
              Text(
                "Minha Licença",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Color(0xFF374151),
              ),
              const SizedBox(width: 10),
              const Text(
                "Plano:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  plano,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: licencaVitalicia ? Colors.blue : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
              SizedBox(width: 10),
              Text(
                "Status:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 5),
              Text(
                "Ativo",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: Color(0xFF374151),
              ),
              const SizedBox(width: 10),
              const Text(
                "Vencimento:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 5),
              Expanded(child: Text(vencimento)),
            ],
          ),
          if (diasRestantes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.hourglass_bottom,
                  color: Color(0xFF374151),
                ),
                const SizedBox(width: 10),
                Text(
                  diasRestantes,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ================================================
  // BUILD
  // ================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF374151),
        title: const Text(
          "Relatórios",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {
              carregarRelatorios();
              carregarLicenca();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await carregarRelatorios();
          await carregarLicenca();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            cardMinhaLicenca(),
            const SizedBox(height: 20),
            graficoFaturamento(),
            const SizedBox(height: 20),
            cardRelatorio(
              "Hoje",
              "Resumo dos atendimentos de hoje",
              atendimentosHoje,
              faturamentoHoje,
              Icons.today,
            ),
            const SizedBox(height: 20),
            cardRelatorio(
              "Esta semana",
              periodoSemana,
              atendimentosSemana,
              faturamentoSemana,
              Icons.calendar_view_week,
            ),
            const SizedBox(height: 20),
            cardRelatorio(
              "Este mês",
              "Resumo mensal",
              atendimentosMes,
              faturamentoMes,
              Icons.calendar_month,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bar_chart,
                    color: Color(0xFF374151),
                  ),
                ),
                title: const Text(
                  "Faturamento anual",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "R\$ ${faturamentoAnoAtual.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}