import 'dart:io';
import 'dart:typed_data';

class DatosBulto {
  final String bulto;
  final String referencia;
  final String despachada;
  final String recibida;
  final String faltante;
  final String averiada;
  final String vrUnitario;
  final String observaciones;

  DatosBulto({
    required this.bulto,
    required this.referencia,
    required this.despachada,
    required this.recibida,
    required this.faltante,
    required this.averiada,
    required this.vrUnitario,
    required this.observaciones,
  });
}

class DatosInspeccion {
  final String numeroInspeccion;
  final String ciudad;
  final String fecha;
  final String solicitante;
  final String asegurado;
  final String poliza;
  final String aplicacion;
  final String pedido;
  final String proveedores;
  final String factura;
  final String lineaAerea;
  final String blGuia;
  final String puertoSalida;
  final String puertoLlegada;
  final String direccion;
  final String marcasContenedor;
  final String cantidadBultos;
  final String clasesEmpaque;
  final String pesoBruto;
  final List<DatosBulto> bultos;
  final String novedades;
  final String unidFaltantes;
  final String unidAveriadas;
  final String valorPerdida;
  final String nombreRepresentante;
  final String cedulaRepresentante;
  final String telefonoRepresentante;
  final String horaEntrada;
  final String horaSalida;
  final String nombreInspector;
  final String fechaHoraFirmaInspector;
  final Uint8List firmaAsegurado;
  final List<File> fotos;

  DatosInspeccion({
    required this.numeroInspeccion,
    required this.ciudad,
    required this.fecha,
    required this.solicitante,
    required this.asegurado,
    required this.poliza,
    required this.aplicacion,
    required this.pedido,
    required this.proveedores,
    required this.factura,
    required this.lineaAerea,
    required this.blGuia,
    required this.puertoSalida,
    required this.puertoLlegada,
    required this.direccion,
    required this.marcasContenedor,
    required this.cantidadBultos,
    required this.clasesEmpaque,
    required this.pesoBruto,
    required this.bultos,
    required this.novedades,
    required this.unidFaltantes,
    required this.unidAveriadas,
    required this.valorPerdida,
    required this.nombreRepresentante,
    required this.cedulaRepresentante,
    required this.telefonoRepresentante,
    required this.horaEntrada,
    required this.horaSalida,
    required this.nombreInspector,
    required this.fechaHoraFirmaInspector,
    required this.firmaAsegurado,
    required this.fotos,
  });
}