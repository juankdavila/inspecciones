import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pdf_inspeccion.dart';

class DetalleInspeccion extends StatelessWidget {
  final String inspeccionId;
  final Map<String, dynamic> datos;

  const DetalleInspeccion({
    super.key,
    required this.inspeccionId,
    required this.datos,
  });

  static const Color _azulMarca = Color(0xFF0D1B4C);

  Widget _fila(String etiqueta, dynamic valor) {
    final texto = valor?.toString() ?? '';
    if (texto.trim().isEmpty) return const SizedBox.shrink();
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
            child: Text(texto, style: const TextStyle(fontSize: 14)),
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

  @override
  Widget build(BuildContext context) {
    final bultos = (datos['bultos'] as List<dynamic>? ?? []);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: Text('Inspección N° ${datos['numeroInspeccion'] ?? ''}'),
        backgroundColor: _azulMarca,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Compartir comprobante en PDF',
            onPressed: () => PdfInspeccion.generarYCompartir(context, datos),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tarjeta('DATOS DE EMBARQUE', [
            _fila('Ciudad', datos['ciudad']),
            _fila('Fecha', datos['fecha']),
            _fila('Solicitante', datos['solicitante']),
            _fila('Asegurado', datos['asegurado']),
            _fila('Póliza N°', datos['poliza']),
            _fila('Aplicación N°', datos['aplicacion']),
            _fila('Pedido N°', datos['pedido']),
            _fila('Proveedores', datos['proveedores']),
            _fila('Factura N°', datos['factura']),
            _fila('Línea aérea', datos['lineaAerea']),
            _fila('B/L Guía', datos['blGuia']),
            _fila('Puerto salida', datos['puertoSalida']),
            _fila('Puerto llegada', datos['puertoLlegada']),
            _fila('Dirección', datos['direccion']),
            _fila('Contenedor', datos['marcasContenedor']),
            _fila('Cantidad bultos', datos['cantidadBultos']),
            _fila('Clase de empaque', datos['clasesEmpaque']),
            _fila('Peso bruto',
                '${datos['pesoBruto'] ?? ''} ${(datos['pesoBruto'] ?? '').toString().isEmpty ? '' : 'KGS'}'),
          ]),
          if (bultos.isNotEmpty)
            _tarjeta(
              'DETALLE DE LA INSPECCIÓN (${bultos.length})',
              bultos.asMap().entries.map((entrada) {
                final i = entrada.key;
                final b = entrada.value as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bulto ${i + 1}',
                          style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                      _fila('N°', b['bulto']),
                      _fila('Referencia', b['referencia']),
                      _fila('Despachada', b['despachada']),
                      _fila('Recibida', b['recibida']),
                      _fila('Faltante', b['faltante']),
                      _fila('Averiada', b['averiada']),
                      _fila('V/R Unitario', b['vrUnitario']),
                      _fila('Observaciones', b['observaciones']),
                      if (i < bultos.length - 1) const Divider(),
                    ],
                  ),
                );
              }).toList(),
            ),
          _tarjeta('NOVEDADES Y PÉRDIDA', [
            _fila('Novedades', datos['novedades']),
            _fila('Unid. faltantes', datos['unidFaltantes']),
            _fila('Unid. averiadas', datos['unidAveriadas']),
            _fila('Valor pérdida', datos['valorPerdida']),
          ]),
          _tarjeta('REPRESENTANTE DEL ASEGURADO', [
            _fila('Nombre', datos['nombreRepresentante']),
            _fila('Cédula', datos['cedulaRepresentante']),
            _fila('Teléfono', datos['telefonoRepresentante']),
            _fila('Hora entrada', datos['horaEntrada']),
            _fila('Hora salida', datos['horaSalida']),
          ]),
          _tarjeta('FIRMAS', [
            _fila('Inspector', datos['nombreInspector']),
            _fila('Firmado', datos['fechaHoraFirmaInspector']),
            if (datos['firmaAseguradoBase64'] != null) ...[
              const SizedBox(height: 8),
              const Text('Firma del asegurado:',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.memory(
                  base64Decode(datos['firmaAseguradoBase64']),
                  height: 100,
                ),
              ),
            ],
          ]),

          // --- Fotos: se cargan desde la subcolección ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('inspecciones')
                .doc(inspeccionId)
                .collection('fotos')
                .orderBy('orden')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SizedBox.shrink();
              }
              final fotos = snapshot.data!.docs;
              return _tarjeta('FOTOS (${fotos.length})', [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: fotos.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final fotoDatos =
                        fotos[index].data() as Map<String, dynamic>;
                    final bytes = base64Decode(fotoDatos['base64']);
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(bytes, fit: BoxFit.cover),
                    );
                  },
                ),
              ]);
            },
          ),
        ],
      ),
    );
  }
}