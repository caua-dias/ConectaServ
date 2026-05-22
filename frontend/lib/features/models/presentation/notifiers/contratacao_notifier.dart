import 'package:flutter/material.dart';
import '../../../../models/contratacao.dart';
import '../../../../infrastructure/repositories/sqflite_contratacao_repository.dart';

class ContratacaoNotifier extends ChangeNotifier {
  final SqfliteContratacaoRepository _repository;

  List<Contratacao> _contratacoes = [];
  List<Contratacao> get contratacoes => _contratacoes;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  ContratacaoNotifier(this._repository);

  Future<void> buscarTodas() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _contratacoes = await _repository.buscarTodas();
    } catch (e) {
      _erro = 'Erro ao buscar contratações: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> buscarPorCliente(int idCliente) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _contratacoes = await _repository.buscarPorCliente(idCliente);
    } catch (e) {
      _erro = 'Erro ao buscar contratações: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> buscarPorServico(int idServico) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _contratacoes = await _repository.buscarPorServico(idServico);
    } catch (e) {
      _erro = 'Erro ao buscar contratações: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<Contratacao?> buscarPorId(int idContratacao) async {
    try {
      return await _repository.buscarPorId(idContratacao);
    } catch (e) {
      _erro = 'Erro ao buscar contratação: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> salvar(Contratacao contratacao) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final novaContratacao = await _repository.salvar(contratacao);
      
      if (contratacao.idContratacao == null) {
        _contratacoes.add(novaContratacao);
      } else {
        final index = _contratacoes.indexWhere((c) => c.idContratacao == contratacao.idContratacao);
        if (index != -1) {
          _contratacoes[index] = novaContratacao;
        }
      }
    } catch (e) {
      _erro = 'Erro ao salvar contratação: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> remover(int idContratacao) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _repository.remover(idContratacao);
      _contratacoes.removeWhere((c) => c.idContratacao == idContratacao);
    } catch (e) {
      _erro = 'Erro ao remover contratação: $e';
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
