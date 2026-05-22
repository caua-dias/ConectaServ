import '../../models/cliente.dart';

abstract interface class IClienteRepository {
  Future<List<Cliente>> buscarTodas();
  Future<Cliente?> buscarPorId(int idCliente);
  Future<Cliente?> buscarPorCpfCnpj(String cpfCnpj);
  Future<Cliente> salvar(Cliente cliente);
  Future<void> remover(int idCliente);
}
