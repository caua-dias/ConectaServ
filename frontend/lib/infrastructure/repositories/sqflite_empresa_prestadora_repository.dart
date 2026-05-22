import 'package:sqflite/sqflite.dart';
import '../../models/empresa_prestadora.dart';
import '../../domain/repositories/i_empresa_prestadora_repository.dart';

final class SqfliteEmpresaPrestadoraRepository
    implements IEmpresaPrestadoraRepository {
  const SqfliteEmpresaPrestadoraRepository(this._db);
  final Database _db;

  @override
  Future<List<EmpresaPrestadora>> buscarTodas() async {
    final rows = await _db.query('empresas_prestadoras');
    return rows.map((m) => EmpresaPrestadora.fromMap(m)).toList();
  }

  @override
  Future<EmpresaPrestadora?> buscarPorId(int idEmpresa) async {
    final rows = await _db.query(
      'empresas_prestadoras',
      where: 'id_empresa = ?',
      whereArgs: [idEmpresa],
    );
    if (rows.isEmpty) return null;
    return EmpresaPrestadora.fromMap(rows.first);
  }

  @override
  Future<EmpresaPrestadora?> buscarPorCnpj(String cnpj) async {
    final rows = await _db.query(
      'empresas_prestadoras',
      where: 'cnpj = ?',
      whereArgs: [cnpj],
    );
    if (rows.isEmpty) return null;
    return EmpresaPrestadora.fromMap(rows.first);
  }

  @override
  Future<EmpresaPrestadora> salvar(EmpresaPrestadora empresa) async {
    if (empresa.idEmpresa == null) {
      final id = await _db.insert(
        'empresas_prestadoras',
        empresa.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return empresa.copyWith(idEmpresa: id);
    }

    await _db.update(
      'empresas_prestadoras',
      empresa.toMap(),
      where: 'id_empresa = ?',
      whereArgs: [empresa.idEmpresa],
    );
    return empresa;
  }

  @override
  Future<void> remover(int idEmpresa) async {
    await _db.delete(
      'empresas_prestadoras',
      where: 'id_empresa = ?',
      whereArgs: [idEmpresa],
    );
  }
}
