import '../../models/servico.dart';

abstract interface class IServicoRepository {
  Future<List<Servico>> buscarTodas();
  Future<Servico?> buscarPorId(int idServico);
  Future<List<Servico>> buscarPorEmpresa(int idEmpresa);
  Future<Servico> salvar(Servico servico);
  Future<void> remover(int idServico);
}
