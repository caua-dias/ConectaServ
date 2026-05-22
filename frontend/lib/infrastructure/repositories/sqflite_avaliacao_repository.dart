import 'package:sqflite/sqflite.dart';
import '../../models/avaliacao.dart';
import '../../domain/repositories/i_avaliacao_repository.dart';

final class SqfliteAvaliacaoRepository implements IAvaliacaoRepository {
  const SqfliteAvaliacaoRepository(this._db);
  final Database _db;

  @override
  Future<List<Avaliacao>> buscarTodas() async {
    final rows = await _db.query('avaliacoes');
    return rows.map((m) => Avaliacao.fromMap(m)).toList();
  }

  @override
  Future<List<Avaliacao>> buscarPorContratacao(int idContratacao) async {
    final rows = await _db.query(
      'avaliacoes',
      where: 'id_contratacao = ?',
      whereArgs: [idContratacao],
    );
    return rows.map((m) => Avaliacao.fromMap(m)).toList();
  }

  @override
  Future<Avaliacao> salvar(Avaliacao avaliacao) async {
    if (avaliacao.idAvaliacao == null) {
      // Inserir nova avaliação e obter o ID gerado pelo SQLite
      final id = await _db.insert(
        'avaliacoes',
        avaliacao.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return avaliacao.copyWith(idAvaliacao: id);
    }
    
    // Atualizar avaliação existente
    await _db.update(
      'avaliacoes',
      avaliacao.toMap(),
      where: 'id_avaliacao = ?',
      whereArgs: [avaliacao.idAvaliacao],
    );
    return avaliacao;
  }

  @override
  Future<void> remover(int idAvaliacao) async {
    await _db.delete(
      'avaliacoes',
      where: 'id_avaliacao = ?',
      whereArgs: [idAvaliacao],
    );
  }
}