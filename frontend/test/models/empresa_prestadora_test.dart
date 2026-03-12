import 'package:flutter_test/flutter_test.dart';
import 'package:conecta_serv/models/empresa_prestadora.dart';
import 'package:conecta_serv/models/enums.dart';

void main() {
  final empresaOriginal = const EmpresaPrestadora(
    idEmpresa: 1,
    cnpj: '12345678000199',
    statusCuradoria: StatusCuradoria.aprovada,
    reputacao: 'Excelente',
  );

  final empresaJson = {
    'idEmpresa': 1,
    'cnpj': '12345678000199',
    'statusCuradoria': 'aprovada',
    'reputacao': 'Excelente',
  };

  test(
    'Deve criar uma EmpresaPrestadora corretamente a partir do fromJson',
    () {
      expect(EmpresaPrestadora.fromJson(empresaJson), equals(empresaOriginal));
    },
  );

  test('Deve gerar um Map correto a partir do toJson', () {
    expect(empresaOriginal.toJson(), equals(empresaJson));
  });

  test('Deve criar uma cópia com copyWith mantendo os valores originais', () {
    final alterada = empresaOriginal.copyWith(reputacao: 'Boa');
    expect(alterada.reputacao, 'Boa');
    expect(alterada.idEmpresa, 1);
  });
}
