import 'package:flutter_test/flutter_test.dart';
import 'package:conecta_serv/models/servico.dart';
import 'package:conecta_serv/models/enums.dart';

void main() {
  final servicoOriginal = const Servico(
    idServico: 10,
    idEmpresa: 1,
    descricao: 'Desenvolvimento Web',
    preco: 1500.0,
    categoria: Categoria.desenvolvimento,
  );

  final servicoJson = {
    'idServico': 10,
    'idEmpresa': 1,
    'descricao': 'Desenvolvimento Web',
    'preco': 1500.0,
    'categoria': 'desenvolvimento',
  };

  test('Deve criar um Servico a partir do fromJson', () {
    expect(Servico.fromJson(servicoJson), equals(servicoOriginal));
  });

  test('Deve gerar um Map a partir do toJson', () {
    expect(servicoOriginal.toJson(), equals(servicoJson));
  });

  test('Deve criar uma cópia modificada com copyWith', () {
    final alterado = servicoOriginal.copyWith(preco: 2000.0);
    expect(alterado.preco, 2000.0);
    expect(alterado.idServico, 10);
  });
}
