import 'package:flutter/material.dart';
import '../../../../models/avaliacao.dart';
import '../../../../infrastructure/repositories/sqflite_avaliacao_repository.dart';

class AvaliacaoNotifier extends ChangeNotifier {
  final SqfliteAvaliacaoRepository _repository;

  List<Avaliacao> _avaliacoes = [];
  List<Avaliacao> get avaliacoes => _avaliacoes;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  AvaliacaoNotifier(this._repository);

  Future<void> buscarTodas() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _avaliacoes = await _repository.buscarTodas();
    } catch (e) {
      _erro = 'Erro ao buscar avaliações: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> buscarPorContratacao(int idContratacao) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _avaliacoes = await _repository.buscarPorContratacao(idContratacao);
    } catch (e) {
      _erro = 'Erro ao buscar avaliações: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> salvar(Avaliacao avaliacao) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final novaAvaliacao = await _repository.salvar(avaliacao);
      
      if (avaliacao.idAvaliacao == null) {
        _avaliacoes.add(novaAvaliacao);
      } else {
        final index = _avaliacoes.indexWhere((a) => a.idAvaliacao == avaliacao.idAvaliacao);
        if (index != -1) {
          _avaliacoes[index] = novaAvaliacao;
        }
      }
    } catch (e) {
      _erro = 'Erro ao salvar avaliação: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> remover(int idAvaliacao) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _repository.remover(idAvaliacao);
      _avaliacoes.removeWhere((a) => a.idAvaliacao == idAvaliacao);
    } catch (e) {
      _erro = 'Erro ao remover avaliação: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  void limparErro() {
    _erro = null;
    notifyListeners();
  }
}
