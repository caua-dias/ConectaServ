import 'package:flutter_test/flutter_test.dart';
// Substitua "seu_projeto" pelo nome do seu pacote
import 'package:conecta_serv/models/Cliente.dart';
import 'package:conecta_serv/models/enums.dart';

void main() {
  final clienteOriginal = const Cliente(
    idCliente: 1,
    tipo: TipoCliente.pessoaFisica,
    cpfCnpj: '12345678900',
  );

  final clienteJson = {
    'idCliente': 1,
    'tipo': 'pessoaFisica',
    'cpfCnpj': '12345678900',
  };

  test('Deve criar um Cliente corretamente a partir do fromJson', () {
    final result = Cliente.fromJson(clienteJson);
    expect(result, equals(clienteOriginal));
  });

  test('Deve gerar um Map correto a partir do toJson', () {
    final result = clienteOriginal.toJson();
    expect(result, equals(clienteJson));
  });

  test('Deve criar uma cópia alterando campos específicos com copyWith', () {
    final alterado = clienteOriginal.copyWith(cpfCnpj: '00000000000');
    expect(alterado.idCliente, 1);
    expect(alterado.cpfCnpj, '00000000000');
    expect(alterado.tipo, TipoCliente.pessoaFisica);
  });
}
