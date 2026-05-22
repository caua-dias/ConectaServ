import '../../models/avaliacao.dart';

abstract interface class IAvaliacaoRepository {
  Future<List<Avaliacao>> buscarTodas();
  Future<List<Avaliacao>> buscarPorContratacao(int idContratacao);
  Future<Avaliacao> salvar(Avaliacao avaliacao);
  Future<void> remover(int idAvaliacao);
}