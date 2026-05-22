import 'package:flutter/material.dart';
import '../../../../models/projeto_portfolio.dart';
import '../../../../infrastructure/repositories/sqflite_projeto_portfolio_repository.dart';

class ProjetoPortfolioNotifier extends ChangeNotifier {
  final SqfliteProjetoPortfolioRepository _repository;

  List<ProjetoPortfolio> _projetos = [];
  List<ProjetoPortfolio> get projetos => _projetos;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  ProjetoPortfolioNotifier(this._repository);

  Future<void> buscarTodas() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _projetos = await _repository.buscarTodas();
    } catch (e) {
      _erro = 'Erro ao buscar projetos: $e';
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
      _projetos = await _repository.buscarPorEmpresa(idEmpresa);
    } catch (e) {
      _erro = 'Erro ao buscar projetos: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<ProjetoPortfolio?> buscarPorId(int idProjeto) async {
    try {
      return await _repository.buscarPorId(idProjeto);
    } catch (e) {
      _erro = 'Erro ao buscar projeto: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> salvar(ProjetoPortfolio projeto) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final novoProjeto = await _repository.salvar(projeto);
      
      if (projeto.idProjeto == null) {
        _projetos.add(novoProjeto);
      } else {
        final index = _projetos.indexWhere((p) => p.idProjeto == projeto.idProjeto);
        if (index != -1) {
          _projetos[index] = novoProjeto;
        }
      }
    } catch (e) {
      _erro = 'Erro ao salvar projeto: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> remover(int idProjeto) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _repository.remover(idProjeto);
      _projetos.removeWhere((p) => p.idProjeto == idProjeto);
    } catch (e) {
      _erro = 'Erro ao remover projeto: $e';
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
