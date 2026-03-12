import 'package:flutter_test/flutter_test.dart';
import 'package:conecta_serv/models/avaliacao.dart';

void main() {
  final avaliacaoOriginal = const Avaliacao(
    idAvaliacao: 1,
    idContratacao: 1,
    estrelas: 5,
    comentarios: null,
    foto: null,
  );

  final avaliacaoJson = {
    'idAvaliacao': 1,
    'idContratacao': 1,
    'estrelas': 5,
    'comentarios': null,
    'foto': null,
  };

  test('Deve instanciar Avaliacao corretamente com fromJson', () {
    expect(Avaliacao.fromJson(avaliacaoJson), equals(avaliacaoOriginal));
  });

  test('Deve serializar Avaliacao com toJson', () {
    expect(avaliacaoOriginal.toJson(), equals(avaliacaoJson));
  });

  test('Deve criar uma cópia alterando campos específicos com copyWith', () {
    final alterado = avaliacaoOriginal.copyWith(comentarios: 'Gostei muito!');
    expect(alterado.comentarios, 'Gostei muito!');
    expect(alterado.estrelas, 5);
  });
}
