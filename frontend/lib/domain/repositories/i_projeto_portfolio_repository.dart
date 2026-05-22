import '../../models/projeto_portfolio.dart';

abstract interface class IProjetoPortfolioRepository {
  Future<List<ProjetoPortfolio>> buscarTodas();
  Future<ProjetoPortfolio?> buscarPorId(int idProjeto);
  Future<List<ProjetoPortfolio>> buscarPorEmpresa(int idEmpresa);
  Future<ProjetoPortfolio> salvar(ProjetoPortfolio projeto);
  Future<void> remover(int idProjeto);
}
