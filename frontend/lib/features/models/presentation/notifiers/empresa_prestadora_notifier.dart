import 'package:flutter/material.dart';
import '../../../../models/empresa_prestadora.dart';
import '../../../../infrastructure/repositories/sqflite_empresa_prestadora_repository.dart';

class EmpresaPrestadoraNotifier extends ChangeNotifier {
  final SqfliteEmpresaPrestadoraRepository _repository;

  List<EmpresaPrestadora> _empresas = [];
  List<EmpresaPrestadora> get empresas => _empresas;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  EmpresaPrestadoraNotifier(this._repository);

  Future<void> buscarTodas() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _empresas = await _repository.buscarTodas();
    } catch (e) {
      _erro = 'Erro ao buscar empresas: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<EmpresaPrestadora?> buscarPorId(int idEmpresa) async {
    try {
      return await _repository.buscarPorId(idEmpresa);
    } catch (e) {
      _erro = 'Erro ao buscar empresa: $e';
      notifyListeners();
      return null;
    }
  }

  Future<EmpresaPrestadora?> buscarPorCnpj(String cnpj) async {
    try {
      return await _repository.buscarPorCnpj(cnpj);
    } catch (e) {
      _erro = 'Erro ao buscar empresa: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> salvar(EmpresaPrestadora empresa) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final novaEmpresa = await _repository.salvar(empresa);
      
      if (empresa.idEmpresa == null) {
        _empresas.add(novaEmpresa);
      } else {
        final index = _empresas.indexWhere((e) => e.idEmpresa == empresa.idEmpresa);
        if (index != -1) {
          _empresas[index] = novaEmpresa;
        }
      }
    } catch (e) {
      _erro = 'Erro ao salvar empresa: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> remover(int idEmpresa) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _repository.remover(idEmpresa);
      _empresas.removeWhere((e) => e.idEmpresa == idEmpresa);
    } catch (e) {
      _erro = 'Erro ao remover empresa: $e';
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
