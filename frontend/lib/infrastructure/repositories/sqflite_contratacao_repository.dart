import 'package:sqflite/sqflite.dart';
import '../../models/contratacao.dart';
import '../../domain/repositories/i_contratacao_repository.dart';

final class SqfliteContratacaoRepository implements IContratacaoRepository {
  const SqfliteContratacaoRepository(this._db);
  final Database _db;

  @override
  Future<List<Contratacao>> buscarTodas() async {
    final rows = await _db.query('contratacoes');
    return rows.map((m) => Contratacao.fromMap(m)).toList();
  }

  @override
  Future<Contratacao?> buscarPorId(int idContratacao) async {
    final rows = await _db.query(
      'contratacoes',
      where: 'id_contratacao = ?',
      whereArgs: [idContratacao],
    );
    if (rows.isEmpty) return null;
    return Contratacao.fromMap(rows.first);
  }

  @override
  Future<List<Contratacao>> buscarPorCliente(int idCliente) async {
    final rows = await _db.query(
      'contratacoes',
      where: 'id_cliente = ?',
      whereArgs: [idCliente],
    );
    return rows.map((m) => Contratacao.fromMap(m)).toList();
  }

  @override
  Future<List<Contratacao>> buscarPorServico(int idServico) async {
    final rows = await _db.query(
      'contratacoes',
      where: 'id_servico = ?',
      whereArgs: [idServico],
    );
    return rows.map((m) => Contratacao.fromMap(m)).toList();
  }

  @override
  Future<Contratacao> salvar(Contratacao contratacao) async {
    if (contratacao.idContratacao == null) {
      final id = await _db.insert(
        'contratacoes',
        contratacao.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return contratacao.copyWith(idContratacao: id);
    }

    await _db.update(
      'contratacoes',
      contratacao.toMap(),
      where: 'id_contratacao = ?',
      whereArgs: [contratacao.idContratacao],
    );
    return contratacao;
  }

  @override
  Future<void> remover(int idContratacao) async {
    await _db.delete(
      'contratacoes',
      where: 'id_contratacao = ?',
      whereArgs: [idContratacao],
    );
  }
}
