import '../../models/empresa_prestadora.dart';

abstract interface class IEmpresaPrestadoraRepository {
  Future<List<EmpresaPrestadora>> buscarTodas();
  Future<EmpresaPrestadora?> buscarPorId(int idEmpresa);
  Future<EmpresaPrestadora?> buscarPorCnpj(String cnpj);
  Future<EmpresaPrestadora> salvar(EmpresaPrestadora empresa);
  Future<void> remover(int idEmpresa);
}
