import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'datos_inspeccion.dart';
import 'numeracion.dart';

class PantallaResumen extends StatefulWidget {
  final DatosInspeccion datos;

  const PantallaResumen({super.key, required this.datos});

  @override
  State<PantallaResumen> createState() => _PantallaResumenState();
}

class _PantallaResumenState extends State<PantallaResumen> {
  static const Color _azulMarca = Color(0xFF0D1B4C);
  bool _guardando = false;

  Widget _fila(String etiqueta, String valor) {
    if (valor.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              etiqueta,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(valor, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _tarjeta(String titulo, List<Widget> hijos) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: _azulMarca, fontSize: 14),
          ),
          const SizedBox(height: 10),
          ...hijos,
        ],
      ),
    );
  }

  Future<void> _guardarInspeccion() async {
    setState(() => _guardando = true);

    try {
      final datos = widget.datos;

      // El número real y definitivo se genera y reserva recién acá,
      // en el momento en que se confirma el guardado
      final numeroInspeccion = await Numeracion.generarNumeroInspeccion();

      final usuarioActual = FirebaseAuth.instance.currentUser;
      if (usuarioActual == null) {
        throw Exception('Debes iniciar sesión para guardar la inspección.');
      }

      // Convertir la firma a texto Base64
      final firmaBase64 = base64Encode(datos.firmaAsegurado);

      final docRef = FirebaseFirestore.instance
          .collection('inspecciones')
          .doc(numeroInspeccion);

      final fotos = await _subirFotosAStorage(numeroInspeccion);

      await docRef.set({
        'numeroInspeccion': numeroInspeccion,
        'ciudad': datos.ciudad,
        'fecha': datos.fecha,
        'solicitante': datos.solicitante,
        'asegurado': datos.asegurado,
        'poliza': datos.poliza,
        'aplicacion': datos.aplicacion,
        'pedido': datos.pedido,
        'proveedores': datos.proveedores,
        'factura': datos.factura,
        'lineaAerea': datos.lineaAerea,
        'blGuia': datos.blGuia,
        'puertoSalida': datos.puertoSalida,
        'puertoLlegada': datos.puertoLlegada,
        'direccion': datos.direccion,
        'marcasContenedor': datos.marcasContenedor,
        'cantidadBultos': datos.cantidadBultos,
        'clasesEmpaque': datos.clasesEmpaque,
        'pesoBruto': datos.pesoBruto,
        'bultos': datos.bultos
            .map((b) => {
                  'bulto': b.bulto,
                  'referencia': b.referencia,
                  'despachada': b.despachada,
                  'recibida': b.recibida,
                  'faltante': b.faltante,
                  'averiada': b.averiada,
                  'vrUnitario': b.vrUnitario,
                  'observaciones': b.observaciones,
                })
            .toList(),
        'novedades': datos.novedades,
        'unidFaltantes': datos.unidFaltantes,
        'unidAveriadas': datos.unidAveriadas,
        'valorPerdida': datos.valorPerdida,
        'nombreRepresentante': datos.nombreRepresentante,
        'cedulaRepresentante': datos.cedulaRepresentante,
        'telefonoRepresentante': datos.telefonoRepresentante,
        'horaEntrada': datos.horaEntrada,
        'horaSalida': datos.horaSalida,
        'nombreInspector': datos.nombreInspector,
        'fechaHoraFirmaInspector': datos.fechaHoraFirmaInspector,
        'firmaAseguradoBase64': firmaBase64,
        'inspectorUid': usuarioActual.uid,
        'cantidadFotos': fotos.length,
        'fotos': fotos,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Inspección N° $numeroInspeccion guardada correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Volver hasta la lista de inspecciones (cerrando resumen y formulario)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<List<Map<String, dynamic>>> _subirFotosAStorage(
    String numeroInspeccion,
  ) async {
    final storage = FirebaseStorage.instance;
    final fotosSubidas = <Map<String, dynamic>>[];

    for (int i = 0; i < widget.datos.fotos.length; i++) {
      final foto = widget.datos.fotos[i];
      final nombreArchivo = 'foto_${i.toString().padLeft(3, '0')}.jpg';
      final rutaStorage = 'inspecciones/$numeroInspeccion/$nombreArchivo';
      final referencia = storage.ref(rutaStorage);

      await referencia.putFile(
        foto,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'numeroInspeccion': numeroInspeccion,
            'orden': i.toString(),
          },
        ),
      );

      fotosSubidas.add({
        'orden': i,
        'nombreArchivo': nombreArchivo,
        'rutaStorage': rutaStorage,
        'url': await referencia.getDownloadURL(),
      });
    }

    return fotosSubidas;
  }

  @override
  Widget build(BuildContext context) {
    final datos = widget.datos;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: const Text('Revisar inspección'),
        backgroundColor: _azulMarca,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _azulMarca.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'N° de inspección: se asignará al confirmar',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: _azulMarca),
            ),
          ),
          _tarjeta('DATOS DE EMBARQUE', [
            _fila('Ciudad', datos.ciudad),
            _fila('Fecha', datos.fecha),
            _fila('Solicitante', datos.solicitante),
            _fila('Asegurado', datos.asegurado),
            _fila('Póliza N°', datos.poliza),
            _fila('Aplicación N°', datos.aplicacion),
            _fila('Pedido N°', datos.pedido),
            _fila('Proveedores', datos.proveedores),
            _fila('Factura N°', datos.factura),
            _fila('Línea aérea', datos.lineaAerea),
            _fila('B/L Guía', datos.blGuia),
            _fila('Puerto salida', datos.puertoSalida),
            _fila('Puerto llegada', datos.puertoLlegada),
            _fila('Dirección', datos.direccion),
            _fila('Contenedor', datos.marcasContenedor),
            _fila('Cantidad bultos', datos.cantidadBultos),
            _fila('Clase de empaque', datos.clasesEmpaque),
            _fila('Peso bruto', '${datos.pesoBruto} KGS'),
          ]),
          _tarjeta(
            'DETALLE DE LA INSPECCIÓN (${datos.bultos.length} bulto${datos.bultos.length == 1 ? '' : 's'})',
            datos.bultos.asMap().entries.map((entrada) {
              final i = entrada.key;
              final b = entrada.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bulto ${i + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    _fila('N°', b.bulto),
                    _fila('Referencia', b.referencia),
                    _fila('Despachada', b.despachada),
                    _fila('Recibida', b.recibida),
                    _fila('Faltante', b.faltante),
                    _fila('Averiada', b.averiada),
                    _fila('V/R Unitario', '${b.vrUnitario} USD'),
                    _fila('Observaciones', b.observaciones),
                    if (i < datos.bultos.length - 1) const Divider(),
                  ],
                ),
              );
            }).toList(),
          ),
          _tarjeta('REPRESENTANTE DEL ASEGURADO', [
            _fila('Nombre', datos.nombreRepresentante),
            _fila('Cédula', datos.cedulaRepresentante),
            _fila('Teléfono', datos.telefonoRepresentante),
            _fila('Hora entrada', datos.horaEntrada),
            _fila('Hora salida', datos.horaSalida),
            const SizedBox(height: 8),
            const Text('Firma:',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.memory(datos.firmaAsegurado, height: 100),
            ),
          ]),
          _tarjeta('FIRMA DEL INSPECTOR', [
            _fila('Inspector', datos.nombreInspector),
            _fila('Firmado', datos.fechaHoraFirmaInspector),
          ]),
          if (datos.fotos.isNotEmpty)
            _tarjeta('FOTOS (${datos.fotos.length})', [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: datos.fotos.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(datos.fotos[index], fit: BoxFit.cover),
                ),
              ),
            ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _guardando ? null : _guardarInspeccion,
              icon: _guardando
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'Confirmar y guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _azulMarca,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _guardando ? null : () => Navigator.pop(context),
              child: const Text('Volver a editar'),
            ),
          ),
        ],
      ),
    );
  }
}