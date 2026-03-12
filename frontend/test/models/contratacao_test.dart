import 'package:flutter_test/flutter_test.dart';
import 'package:conecta_serv/models/contratacao.dart';
import 'package:conecta_serv/models/enums.dart';

void main() {
  final contratacaoOriginal = const Contratacao(
    idContratacao: 1,
    idCliente: 5,
    idServico: 10,
    statusPagamento: StatusPagamento.pendente,
  );

  final contratacaoJson = {
    'idContratacao': 1,
    'idCliente': 5,
    'idServico': 10,
    'statusPagamento': 'pendente',
  };

  test('Deve gerar objeto Contratacao pelo fromJson', () {
    expect(Contratacao.fromJson(contratacaoJson), equals(contratacaoOriginal));
  });

  test('Deve mapear json de Contratacao no toJson', () {
    expect(contratacaoOriginal.toJson(), equals(contratacaoJson));
  });

  test('Deve atualizar dados usando copyWith', () {
    final alterado = contratacaoOriginal.copyWith(
      statusPagamento: StatusPagamento.aprovado,
    );
    expect(alterado.statusPagamento, StatusPagamento.aprovado);
    expect(alterado.idCliente, 5);
  });
}
