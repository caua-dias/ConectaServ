import '../../models/contratacao.dart';

abstract interface class IContratacaoRepository {
  Future<List<Contratacao>> buscarTodas();
  Future<Contratacao?> buscarPorId(int idContratacao);
  Future<List<Contratacao>> buscarPorCliente(int idCliente);
  Future<List<Contratacao>> buscarPorServico(int idServico);
  Future<Contratacao> salvar(Contratacao contratacao);
  Future<void> remover(int idContratacao);
}
