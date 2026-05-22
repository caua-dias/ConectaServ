import 'package:sqflite/sqflite.dart';
import '../../models/projeto_portfolio.dart';
import '../../domain/repositories/i_projeto_portfolio_repository.dart';

final class SqfliteProjetoPortfolioRepository
    implements IProjetoPortfolioRepository {
  const SqfliteProjetoPortfolioRepository(this._db);
  final Database _db;

  @override
  Future<List<ProjetoPortfolio>> buscarTodas() async {
    final rows = await _db.query('projetos_portfolio');
    return rows.map((m) => ProjetoPortfolio.fromMap(m)).toList();
  }

  @override
  Future<ProjetoPortfolio?> buscarPorId(int idProjeto) async {
    final rows = await _db.query(
      'projetos_portfolio',
      where: 'id_projeto = ?',
      whereArgs: [idProjeto],
    );
    if (rows.isEmpty) return null;
    return ProjetoPortfolio.fromMap(rows.first);
  }

  @override
  Future<List<ProjetoPortfolio>> buscarPorEmpresa(int idEmpresa) async {
    final rows = await _db.query(
      'projetos_portfolio',
      where: 'id_empresa = ?',
      whereArgs: [idEmpresa],
    );
    return rows.map((m) => ProjetoPortfolio.fromMap(m)).toList();
  }

  @override
  Future<ProjetoPortfolio> salvar(ProjetoPortfolio projeto) async {
    if (projeto.idProjeto == null) {
      final id = await _db.insert(
        'projetos_portfolio',
        projeto.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return projeto.copyWith(idProjeto: id);
    }

    await _db.update(
      'projetos_portfolio',
      projeto.toMap(),
      where: 'id_projeto = ?',
      whereArgs: [projeto.idProjeto],
    );
    return projeto;
  }

  @override
  Future<void> remover(int idProjeto) async {
    await _db.delete(
      'projetos_portfolio',
      where: 'id_projeto = ?',
      whereArgs: [idProjeto],
    );
  }
}
