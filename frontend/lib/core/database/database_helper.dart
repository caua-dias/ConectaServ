import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

final class DatabaseHelper {
  DatabaseHelper._();
  static final instance = DatabaseHelper._();
  
  static const _versao = 1;
  static const _nomeBanco = 'conectaserv.db';
  
  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, _nomeBanco),
      version: _versao,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, _) => db.transaction((t) => Future.wait([
        t.execute(_sqlClientes),
        t.execute(_sqlEmpresasPrestadoras),
        t.execute(_sqlServicos),
        t.execute(_sqlContratacoes),
        t.execute(_sqlAvaliacoes),
        t.execute(_sqlProjetosPortfolio),
      ])),
    );
  }

  static const _sqlClientes = '''
    CREATE TABLE clientes (
      id_cliente INTEGER PRIMARY KEY AUTOINCREMENT,
      tipo TEXT NOT NULL,
      cpf_cnpj TEXT NOT NULL UNIQUE
    )
  ''';

  static const _sqlEmpresasPrestadoras = '''
    CREATE TABLE empresas_prestadoras (
      id_empresa INTEGER PRIMARY KEY AUTOINCREMENT,
      cnpj TEXT NOT NULL UNIQUE,
      status_curadoria TEXT NOT NULL,
      reputacao TEXT NOT NULL
    )
  ''';

  static const _sqlServicos = '''
    CREATE TABLE servicos (
      id_servico INTEGER PRIMARY KEY AUTOINCREMENT,
      id_empresa INTEGER NOT NULL,
      descricao TEXT NOT NULL,
      preco REAL NOT NULL,
      categoria TEXT NOT NULL,
      FOREIGN KEY (id_empresa) REFERENCES empresas_prestadoras (id_empresa) ON DELETE CASCADE
    )
  ''';

  static const _sqlContratacoes = '''
    CREATE TABLE contratacoes (
      id_contratacao INTEGER PRIMARY KEY AUTOINCREMENT,
      id_cliente INTEGER NOT NULL,
      id_servico INTEGER NOT NULL,
      status_pagamento TEXT NOT NULL,
      FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente) ON DELETE CASCADE,
      FOREIGN KEY (id_servico) REFERENCES servicos (id_servico) ON DELETE CASCADE
    )
  ''';

  static const _sqlAvaliacoes = '''
    CREATE TABLE avaliacoes (
      id_avaliacao INTEGER PRIMARY KEY AUTOINCREMENT,
      id_contratacao INTEGER NOT NULL,
      estrelas INTEGER NOT NULL,
      comentarios TEXT,
      foto TEXT,
      FOREIGN KEY (id_contratacao) REFERENCES contratacoes (id_contratacao) ON DELETE CASCADE
    )
  ''';

  static const _sqlProjetosPortfolio = '''
    CREATE TABLE projetos_portfolio (
      id_projeto INTEGER PRIMARY KEY AUTOINCREMENT,
      id_empresa INTEGER NOT NULL,
      arquivo TEXT NOT NULL,
      FOREIGN KEY (id_empresa) REFERENCES empresas_prestadoras (id_empresa) ON DELETE CASCADE
    )
  ''';
}