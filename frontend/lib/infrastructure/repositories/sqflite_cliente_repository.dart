import 'package:sqflite/sqflite.dart';
import '../../models/cliente.dart';
import '../../domain/repositories/i_cliente_repository.dart';

final class SqfliteClienteRepository implements IClienteRepository {
  const SqfliteClienteRepository(this._db);
  final Database _db;

  @override
  Future<List<Cliente>> buscarTodas() async {
    final rows = await _db.query('clientes');
    return rows.map((m) => Cliente.fromMap(m)).toList();
  }

  @override
  Future<Cliente?> buscarPorId(int idCliente) async {
    final rows = await _db.query(
      'clientes',
      where: 'id_cliente = ?',
      whereArgs: [idCliente],
    );
    if (rows.isEmpty) return null;
    return Cliente.fromMap(rows.first);
  }

  @override
  Future<Cliente?> buscarPorCpfCnpj(String cpfCnpj) async {
    final rows = await _db.query(
      'clientes',
      where: 'cpf_cnpj = ?',
      whereArgs: [cpfCnpj],
    );
    if (rows.isEmpty) return null;
    return Cliente.fromMap(rows.first);
  }

  @override
  Future<Cliente> salvar(Cliente cliente) async {
    if (cliente.idCliente == null) {
      final id = await _db.insert(
        'clientes',
        cliente.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return cliente.copyWith(idCliente: id);
    }

    await _db.update(
      'clientes',
      cliente.toMap(),
      where: 'id_cliente = ?',
      whereArgs: [cliente.idCliente],
    );
    return cliente;
  }

  @override
  Future<void> remover(int idCliente) async {
    await _db.delete(
      'clientes',
      where: 'id_cliente = ?',
      whereArgs: [idCliente],
    );
  }
}
