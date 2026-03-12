import 'package:flutter_test/flutter_test.dart';
import 'package:conecta_serv/models/projeto_portfolio.dart';

void main() {
  final projetoOriginal = const ProjetoPortfolio(
    idProjeto: 1,
    idEmpresa: 1,
    arquivo: 'url_do_arquivo.pdf',
  );

  final projetoJson = {
    'idProjeto': 1,
    'idEmpresa': 1,
    'arquivo': 'url_do_arquivo.pdf',
  };

  test('Deve popular ProjetoPortfolio a partir do fromJson', () {
    expect(ProjetoPortfolio.fromJson(projetoJson), equals(projetoOriginal));
  });

  test('Deve exportar para JSON via toJson', () {
    expect(projetoOriginal.toJson(), equals(projetoJson));
  });

  test('Deve clonar e alterar propriedade no copyWith', () {
    final alterado = projetoOriginal.copyWith(arquivo: 'novo_arquivo.png');
    expect(alterado.arquivo, 'novo_arquivo.png');
    expect(alterado.idProjeto, 1);
  });
}
