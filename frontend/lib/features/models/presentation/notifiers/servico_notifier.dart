import 'package:flutter/material.dart';
import '../../../../models/servico.dart';
import '../../../../infrastructure/repositories/sqflite_servico_repository.dart';

class ServicoNotifier extends ChangeNotifier {
  final SqfliteServicoRepository _repository;

  List<Servico> _servicos = [];
  List<Servico> get servicos => _servicos;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  ServicoNotifier(this._repository);

  Future<void> buscarTodos() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _servicos = await _repository.buscarTodas();
    } catch (e) {
      _erro = 'Erro ao buscar serviços: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> buscarPorEmpresa(int idEmpresa) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _servicos = await _repository.buscarPorEmpresa(idEmpresa);
    } catch (e) {
      _erro = 'Erro ao buscar serviços: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<Servico?> buscarPorId(int idServico) async {
    try {
      return await _repository.buscarPorId(idServico);
    } catch (e) {
      _erro = 'Erro ao buscar serviço: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> salvar(Servico servico) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final novoServico = await _repository.salvar(servico);
      
      if (servico.idServico == null) {
        _servicos.add(novoServico);
      } else {
        final index = _servicos.indexWhere((s) => s.idServico == servico.idServico);
        if (index != -1) {
          _servicos[index] = novoServico;
        }
      }
    } catch (e) {
      _erro = 'Erro ao salvar serviço: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> remover(int idServico) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _repository.remover(idServico);
      _servicos.removeWhere((s) => s.idServico == idServico);
    } catch (e) {
      _erro = 'Erro ao remover serviço: $e';
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
