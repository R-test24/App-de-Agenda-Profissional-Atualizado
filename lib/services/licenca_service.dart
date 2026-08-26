import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LicencaService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static const String _chaveAtivada = 'licenca_ativada';
  static const String _chaveEmail = 'licenca_email';
  static const String _chavePlano = 'licenca_plano';
  static const String _chaveDataExpiracao =
      'licenca_data_expiracao';
  static const String _chaveVitalicia =
      'licenca_vitalicia';
  static const String _chaveUltimaVerificacao =
      'licenca_ultima_verificacao';

  static const Duration intervaloVerificacao =
      Duration(days: 7);

  // ================================================
  // 🔥 NOVO MÉTODO: BUSCA LICENÇA DIRETAMENTE DO FIREBASE
  // ================================================
  Future<Map<String, dynamic>> buscarLicencaFirebase(String email) async {
    try {
      final emailNormalizado = email.trim().toLowerCase();

      final resultado = await _firestore
          .collection('licencas')
          .where('email', isEqualTo: emailNormalizado)
          .limit(1)
          .get();

      if (resultado.docs.isEmpty) {
        return {
          'plano': 'Não encontrado',
          'vitalicia': false,
          'dataExpiracao': null,
          'diasRestantes': null,
          'valida': false,
        };
      }

      final dados = resultado.docs.first.data();
      
      print('📦 DADOS DO FIREBASE: $dados');

      final ativo = dados['ativo'] == true;
      
      if (!ativo) {
        return {
          'plano': 'Inativo',
          'vitalicia': false,
          'dataExpiracao': null,
          'diasRestantes': null,
          'valida': false,
        };
      }

      // 🔥 PEGA O PLANO
      String plano = dados['plano']?.toString() ?? '';
      final isVitalicia = dados['vitalicia'] == true;

      // 🔥 SE FOR VITALÍCIO E O PLANO ESTIVER VAZIO, DEFINE COMO "Vitalício"
      if (isVitalicia && plano.trim().isEmpty) {
        plano = 'Vitalício';
      }
      
      if (plano.trim().isEmpty) {
        plano = dados['tipo']?.toString() ?? '';
      }
      
      if (plano.trim().isEmpty) {
        plano = dados['plano_nome']?.toString() ?? '';
      }
      
      if (plano.trim().isEmpty) {
        plano = isVitalicia ? 'Vitalício' : 'Mensal';
      }

      print('📝 PLANO ENCONTRADO: $plano');
      print('💎 VITALÍCIA: $isVitalicia');

      DateTime? dataExpiracao;
      int? diasRestantes;

      if (!isVitalicia) {
        final dataExpiracaoFirebase = dados['dataExpiracao'];

        if (dataExpiracaoFirebase is Timestamp) {
          dataExpiracao = dataExpiracaoFirebase.toDate();

          final agora = DateTime.now();
          diasRestantes = dataExpiracao.difference(agora).inDays;
          
          if (diasRestantes < 0) {
            diasRestantes = 0;
          }
        }
      }

      // 🔥 SALVA OS DADOS LOCALMENTE
      await _salvarAtivacao(
        email: emailNormalizado,
        plano: plano,
        dataExpiracao: dataExpiracao,
        vitalicia: isVitalicia,
      );

      return {
        'plano': plano,
        'vitalicia': isVitalicia,
        'dataExpiracao': dataExpiracao,
        'diasRestantes': diasRestantes,
        'valida': true,
      };
    } catch (e) {
      print('❌ ERRO AO BUSCAR LICENÇA: $e');
      return {
        'plano': 'Erro',
        'vitalicia': false,
        'dataExpiracao': null,
        'diasRestantes': null,
        'valida': false,
      };
    }
  }

  // ================================================
  // MÉTODO ORIGINAL: VERIFICAR LICENÇA
  // ================================================
  Future<Map<String, dynamic>> verificarLicenca(
    String email,
  ) async {
    try {
      final emailNormalizado =
          email.trim().toLowerCase();

      final resultado = await _firestore
          .collection('licencas')
          .where(
            'email',
            isEqualTo: emailNormalizado,
          )
          .limit(1)
          .get();

      if (resultado.docs.isEmpty) {
        return {
          'valida': false,
          'mensagem':
              'Nenhuma licença encontrada para este e-mail.',
          'erroInternet': false,
        };
      }

      final dados = resultado.docs.first.data();
      
      // 🔥 DEBUG: Imprime os dados do Firebase
      print('📦 DADOS DO FIREBASE: $dados');

      final ativo = dados['ativo'] == true;

      if (!ativo) {
        return {
          'valida': false,
          'mensagem':
              'Esta licença está inativa.',
          'erroInternet': false,
        };
      }

      // 🔥 PEGA O PLANO DO FIREBASE
      String plano = dados['plano']?.toString() ?? '';
      
      // 🔥 VERIFICA SE É VITALÍCIO PELO CAMPO ESPECÍFICO
      final isVitalicia = dados['vitalicia'] == true;
      
      // 🔥 SE FOR VITALÍCIO E O PLANO ESTIVER VAZIO, DEFINE COMO "Vitalício"
      if (isVitalicia && plano.trim().isEmpty) {
        plano = 'Vitalício';
      }
      
      // 🔥 SE O PLANO AINDA ESTIVER VAZIO, USA O CAMPO "tipo" OU "plano_nome"
      if (plano.trim().isEmpty) {
        plano = dados['tipo']?.toString() ?? '';
      }
      
      if (plano.trim().isEmpty) {
        plano = dados['plano_nome']?.toString() ?? '';
      }

      // 🔥 ÚLTIMO RECURSO: SE AINDA ESTIVER VAZIO, DEFINE BASEADO NO VITALÍCIO
      if (plano.trim().isEmpty) {
        plano = isVitalicia ? 'Vitalício' : 'Mensal';
      }

      print('📝 PLANO FINAL: $plano');
      print('💎 VITALÍCIA: $isVitalicia');

      DateTime? expiracao;

      if (!isVitalicia) {
        final dataExpiracao =
            dados['dataExpiracao'];

        if (dataExpiracao is Timestamp) {
          expiracao = dataExpiracao.toDate();

          if (expiracao.isBefore(DateTime.now())) {
            return {
              'valida': false,
              'mensagem':
                  'Esta licença está expirada.',
              'erroInternet': false,
            };
          }
        }
      }

      await _salvarAtivacao(
        email: emailNormalizado,
        plano: plano,
        dataExpiracao: expiracao,
        vitalicia: isVitalicia,
      );

      return {
        'valida': true,
        'mensagem': isVitalicia
            ? 'Licença vitalícia válida.'
            : 'Licença válida.',
        'erroInternet': false,
      };
    } catch (e) {
      print('❌ ERRO AO VERIFICAR LICENÇA: $e');
      return {
        'valida': false,
        'mensagem':
            'Não foi possível conectar ao servidor.',
        'erroInternet': true,
      };
    }
  }

  // ================================================
  // SALVAR ATIVAÇÃO
  // ================================================
  Future<void> _salvarAtivacao({
    required String email,
    required String plano,
    required DateTime? dataExpiracao,
    required bool vitalicia,
  }) async {
    final prefs =
        await SharedPreferences.getInstance();

    // 🔥 GARANTE QUE O PLANO NÃO FIQUE VAZIO
    String planoFinal = plano.trim();
    if (planoFinal.isEmpty) {
      planoFinal = vitalicia ? 'Vitalício' : 'Mensal';
    }

    print('💾 SALVANDO - Plano: $planoFinal, Vitalícia: $vitalicia');

    await prefs.setBool(
      _chaveAtivada,
      true,
    );

    await prefs.setString(
      _chaveEmail,
      email,
    );

    await prefs.setString(
      _chavePlano,
      planoFinal,
    );

    await prefs.setBool(
      _chaveVitalicia,
      vitalicia,
    );

    if (dataExpiracao != null) {
      await prefs.setString(
        _chaveDataExpiracao,
        dataExpiracao.toIso8601String(),
      );
    } else {
      await prefs.remove(
        _chaveDataExpiracao,
      );
    }

    await prefs.setString(
      _chaveUltimaVerificacao,
      DateTime.now().toIso8601String(),
    );
  }

  // ================================================
  // OBTER DADOS LOCAIS
  // ================================================
  Future<Map<String, dynamic>>
      obterDadosLocais() async {
    final prefs =
        await SharedPreferences.getInstance();

    String? plano =
        prefs.getString(_chavePlano);
    
    final vitalicia =
        prefs.getBool(_chaveVitalicia) ?? false;

    print('📂 DADOS LOCAIS - Plano: "$plano", Vitalícia: $vitalicia');

    // 🔥 SE FOR VITALÍCIO E O PLANO ESTIVER VAZIO, DEFINE "Vitalício"
    if (vitalicia && (plano == null || plano.trim().isEmpty)) {
      plano = 'Vitalício';
      print('🔄 CORRIGINDO - Plano alterado para: "$plano"');
    }

    final dataString =
        prefs.getString(
      _chaveDataExpiracao,
    );

    DateTime? dataExpiracao;

    if (dataString != null) {
      dataExpiracao =
          DateTime.tryParse(dataString);
    }

    int? diasRestantes;

    if (!vitalicia &&
        dataExpiracao != null) {
      final agora = DateTime.now();

      diasRestantes =
          dataExpiracao
              .difference(agora)
              .inDays;

      if (diasRestantes < 0) {
        diasRestantes = 0;
      }
    }

    final resultado = {
      'plano': plano,
      'vitalicia': vitalicia,
      'dataExpiracao': dataExpiracao,
      'diasRestantes': diasRestantes,
    };

    print('📤 RETORNANDO: $resultado');
    return resultado;
  }

  // ================================================
  // MÉTODOS AUXILIARES
  // ================================================
  Future<bool> estaAtivado() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getBool(
          _chaveAtivada,
        ) ??
        false;
  }

  Future<String?> obterEmail() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(
      _chaveEmail,
    );
  }

  Future<bool> precisaVerificarNovamente() async {
    final prefs =
        await SharedPreferences.getInstance();

    final ultimaVerificacao =
        prefs.getString(
      _chaveUltimaVerificacao,
    );

    if (ultimaVerificacao == null) {
      return true;
    }

    final data =
        DateTime.tryParse(
      ultimaVerificacao,
    );

    if (data == null) {
      return true;
    }

    return DateTime.now()
            .difference(data) >=
        intervaloVerificacao;
  }

  Future<Map<String, dynamic>>
      verificarSeNecessario() async {
    final ativado =
        await estaAtivado();

    if (!ativado) {
      return {
        'precisaAtivar': true,
        'valida': false,
      };
    }

    final precisaVerificar =
        await precisaVerificarNovamente();

    if (!precisaVerificar) {
      return {
        'precisaAtivar': false,
        'valida': true,
        'verificacaoOnline': false,
      };
    }

    final email =
        await obterEmail();

    if (email == null ||
        email.trim().isEmpty) {
      return {
        'precisaAtivar': true,
        'valida': false,
      };
    }

    final resultado =
        await verificarLicenca(email);

    if (resultado['erroInternet'] == true) {
      return {
        'precisaAtivar': false,
        'valida': true,
        'verificacaoOnline': false,
        'modoOffline': true,
        'mensagem':
            'Sem conexão. Licença anterior mantida.',
      };
    }

    if (resultado['valida'] == true) {
      return {
        ...resultado,
        'precisaAtivar': false,
        'verificacaoOnline': true,
        'modoOffline': false,
      };
    }

    return {
      ...resultado,
      'precisaAtivar': true,
      'valida': false,
      'verificacaoOnline': true,
      'modoOffline': false,
    };
  }

  Future<void> desativar() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_chaveAtivada);
    await prefs.remove(_chaveEmail);
    await prefs.remove(_chavePlano);
    await prefs.remove(_chaveDataExpiracao);
    await prefs.remove(_chaveVitalicia);
    await prefs.remove(
      _chaveUltimaVerificacao,
    );
  }
}