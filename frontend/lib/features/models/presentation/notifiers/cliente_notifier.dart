import 'package:flutter/material.dart';
import '../../../../models/cliente.dart';
import '../../../../infrastructure/repositories/sqflite_cliente_repository.dart';

class ClienteNotifier extends ChangeNotifier {
  final SqfliteClienteRepository _repository;

  List<Cliente> _clientes = [];
  List<Cliente> get clientes => _clientes;

  bool _carregando = false;
  bool get carregando => _carregando;

  String? _erro;
  String? get erro => _erro;

  ClienteNotifier(this._repository);

  Future<void> buscarTodos() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _clientes = await _repository.buscarTodas();
    } catch (e) {
      _erro = 'Erro ao buscar clientes: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<Cliente?> buscarPorId(int idCliente) async {
    try {
      return await _repository.buscarPorId(idCliente);
    } catch (e) {
      _erro = 'Erro ao buscar cliente: $e';
      notifyListeners();
      return null;
    }
  }

  Future<void> salvar(Cliente cliente) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      final novoCliente = await _repository.salvar(cliente);
      
      if (cliente.idCliente == null) {
        _clientes.add(novoCliente);
      } else {
        final index = _clientes.indexWhere((c) => c.idCliente == cliente.idCliente);
        if (index != -1) {
          _clientes[index] = novoCliente;
        }
      }
    } catch (e) {
      _erro = 'Erro ao salvar cliente: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<void> remover(int idCliente) async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      await _repository.remover(idCliente);
      _clientes.removeWhere((c) => c.idCliente == idCliente);
    } catch (e) {
      _erro = 'Erro ao remover cliente: $e';
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
