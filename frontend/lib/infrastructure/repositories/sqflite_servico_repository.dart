import 'package:sqflite/sqflite.dart';
import '../../models/servico.dart';
import '../../domain/repositories/i_servico_repository.dart';

final class SqfliteServicoRepository implements IServicoRepository {
  const SqfliteServicoRepository(this._db);
  final Database _db;

  @override
  Future<List<Servico>> buscarTodas() async {
    final rows = await _db.query('servicos');
    return rows.map((m) => Servico.fromMap(m)).toList();
  }

  @override
  Future<Servico?> buscarPorId(int idServico) async {
    final rows = await _db.query(
      'servicos',
      where: 'id_servico = ?',
      whereArgs: [idServico],
    );
    if (rows.isEmpty) return null;
    return Servico.fromMap(rows.first);
  }

  @override
  Future<List<Servico>> buscarPorEmpresa(int idEmpresa) async {
    final rows = await _db.query(
      'servicos',
      where: 'id_empresa = ?',
      whereArgs: [idEmpresa],
    );
    return rows.map((m) => Servico.fromMap(m)).toList();
  }

  @override
  Future<Servico> salvar(Servico servico) async {
    if (servico.idServico == null) {
      final id = await _db.insert(
        'servicos',
        servico.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return servico.copyWith(idServico: id);
    }

    await _db.update(
      'servicos',
      servico.toMap(),
      where: 'id_servico = ?',
      whereArgs: [servico.idServico],
    );
    return servico;
  }

  @override
  Future<void> remover(int idServico) async {
    await _db.delete(
      'servicos',
      where: 'id_servico = ?',
      whereArgs: [idServico],
    );
  }
}
