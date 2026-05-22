import 'enums.dart';

class Cliente {
  final int? idCliente;
  final TipoCliente tipo;
  final String cpfCnpj;

  const Cliente({
    this.idCliente,
    required this.tipo,
    required this.cpfCnpj,
  });

  Map<String, dynamic> toMap() {
    return {
      if (idCliente != null) 'id_cliente': idCliente,
      'tipo': tipo.name,
      'cpf_cnpj': cpfCnpj,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      idCliente: map['id_cliente'] as int?,
      tipo: TipoCliente.values.byName(map['tipo']),
      cpfCnpj: map['cpf_cnpj'] as String,
    );
  }

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      idCliente: json['idCliente'] as int?,
      tipo: TipoCliente.values.byName(json['tipo']),
      cpfCnpj: json['cpfCnpj'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'idCliente': idCliente, 'tipo': tipo.name, 'cpfCnpj': cpfCnpj};
  }

  Cliente copyWith({int? idCliente, TipoCliente? tipo, String? cpfCnpj}) {
    return Cliente(
      idCliente: idCliente ?? this.idCliente,
      tipo: tipo ?? this.tipo,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cliente &&
        other.idCliente == idCliente &&
        other.tipo == tipo &&
        other.cpfCnpj == cpfCnpj;
  }

  @override
  int get hashCode => idCliente.hashCode ^ tipo.hashCode ^ cpfCnpj.hashCode;
}
