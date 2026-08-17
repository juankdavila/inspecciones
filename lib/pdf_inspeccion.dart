import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfInspeccion {
  static Future<void> generarYCompartir(
    BuildContext context,
    Map<String, dynamic> datos,
  ) async {
    final doc = pw.Document();

    // ============================================================
    // LOGO
    // ============================================================
    pw.MemoryImage? logo;

    try {
      final bytesLogo =
          await rootBundle.load('assets/image/colprevi.png');

      logo = pw.MemoryImage(
        bytesLogo.buffer.asUint8List(),
      );
    } catch (_) {
      logo = null;
    }

    // ============================================================
    // FIRMA DEL ASEGURADO
    // ============================================================
    Uint8List? firmaAseguradoBytes;

    if (datos['firmaAseguradoBase64'] != null) {
      firmaAseguradoBytes =
          base64Decode(datos['firmaAseguradoBase64']);
    }

    // ============================================================
    // BULTOS
    // ============================================================
    final bultos =
        (datos['bultos'] as List<dynamic>? ?? []);

    // ============================================================
    // FUNCIÓN PARA OBTENER VALORES
    // ============================================================
    String v(String campo) =>
        (datos[campo] ?? '').toString();

    // ============================================================
    // BORDE
    // ============================================================
    final borde = pw.BoxDecoration(
      border: pw.Border.all(
        color: PdfColors.black,
        width: 0.7,
      ),
    );

    // ============================================================
    // ESTILOS
    // ============================================================
    final tituloCampo = pw.TextStyle(
      fontSize: 8,
      color: PdfColors.grey700,
      fontWeight: pw.FontWeight.bold,
    );

    final valorCampo = pw.TextStyle(
      fontSize: 10,
    );

    // ============================================================
    // CONTENIDO DE UNA CELDA
    // ============================================================
    pw.Widget celdaContenido(
      String titulo,
      String valor,
    ) {
      return pw.Container(
        decoration: borde,
        padding: const pw.EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 4,
        ),
        child: pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              titulo,
              style: tituloCampo,
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              valor,
              style: valorCampo,
            ),
          ],
        ),
      );
    }

    // ============================================================
    // CONSTRUYE UNA FILA DE CELDAS
    // ============================================================
    pw.Widget filaCeldas(
      List<Map<String, String>> campos, {
      List<double>? anchos,
    }) {
      final widths =
          anchos ?? List.filled(campos.length, 1);

      final columnWidths =
          <int, pw.TableColumnWidth>{};

      for (var i = 0; i < widths.length; i++) {
        columnWidths[i] =
            pw.FlexColumnWidth(
          widths[i].toDouble(),
        );
      }

      return pw.Table(
        columnWidths: columnWidths,
        children: [
          pw.TableRow(
            children: campos
                .map(
                  (c) => celdaContenido(
                    c['titulo']!,
                    c['valor']!,
                  ),
                )
                .toList(),
          ),
        ],
      );
    }

    // ============================================================
    // ENCABEZADO
    // ============================================================
    final encabezado = pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [

        // ========================================================
        // TÍTULO + NÚMERO DE INSPECCIÓN
        // ========================================================
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 6,
          ),
          decoration: const pw.BoxDecoration(
            border: pw.Border(
              top: pw.BorderSide(
                color: PdfColors.black,
                width: 0.8,
              ),
              left: pw.BorderSide(
                color: PdfColors.black,
                width: 0.8,
              ),
              right: pw.BorderSide(
                color: PdfColors.black,
                width: 0.8,
              ),
              bottom: pw.BorderSide(
                color: PdfColors.black,
                width: 0.8,
              ),
            ),
          ),
          child: pw.Row(
            children: [

              // TÍTULO
              pw.Expanded(
                child: pw.Center(
                  child: pw.Text(
                    'INFORME DE INSPECCIÓN FINAL',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight:
                          pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                ),
              ),

              // NÚMERO
              pw.Text(
                'N° ${v('numeroInspeccion')}',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight:
                      pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        ),

        // ========================================================
        // DATOS DE EMBARQUE + LOGO
        // ========================================================
        pw.Table(
  border: pw.TableBorder.all(
    color: PdfColors.black,
    width: 0.8,
  ),
  columnWidths: {
    0: const pw.FlexColumnWidth(4.2),
    1: const pw.FlexColumnWidth(1.7),
  },
  children: [
    pw.TableRow(
      children: [

        // ==================================================
        // COLUMNA IZQUIERDA
        // ==================================================
        pw.Column(
          crossAxisAlignment:
              pw.CrossAxisAlignment.start,
          children: [

            // DATOS DE EMBARQUE
            pw.Container(
              width: double.infinity,
              padding:
                  const pw.EdgeInsets.symmetric(
                vertical: 3,
              ),
              decoration:
                  const pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: PdfColors.black,
                    width: 0.7,
                  ),
                ),
              ),
              child: pw.Center(
                child: pw.Text(
                  'DATOS DE EMBARQUE',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight:
                        pw.FontWeight.bold,
                  ),
                ),
              ),
            ),

            // CIUDAD / FECHA
            filaCeldas(
              [
                {
                  'titulo': 'Ciudad',
                  'valor': v('ciudad'),
                },
                {
                  'titulo': 'Fecha',
                  'valor': v('fecha'),
                },
              ],
              anchos: [
                1,
                1,
              ],
            ),

            // SOLICITANTE
            filaCeldas(
              [
                {
                  'titulo': 'Solicitante',
                  'valor': v('solicitante'),
                },
              ],
            ),
          ],
        ),

        // ==================================================
        // LOGO A LA DERECHA
        // ==================================================
        pw.Container(
          alignment: pw.Alignment.center,
          padding:
              const pw.EdgeInsets.all(8),
          child: logo != null
              ? pw.Image(
                  logo,
                  width: 110,
                  height: 145,
                  fit: pw.BoxFit.contain,
                )
              : pw.SizedBox(),
        ),
      ],
    ),
  ],
),

        pw.SizedBox(height: 6),

        // ========================================================
        // ASEGURADO / CLIENTE / PÓLIZA / APLICACIÓN / PEDIDO
        // ========================================================
        filaCeldas(
          [
            {
              'titulo':
                  'Asegurado / Cliente',
              'valor': v('asegurado'),
            },
            {
              'titulo': 'Póliza N°',
              'valor': v('poliza'),
            },
            {
              'titulo': 'Aplicación N°',
              'valor': v('aplicacion'),
            },
            {
              'titulo': 'Pedido N°',
              'valor': v('pedido'),
            },
          ],
          anchos: [
            2,
            1,
            1,
            1,
          ],
        ),

        // ========================================================
        // PROVEEDORES / FACTURA / M/N / B/L
        // ========================================================
        filaCeldas(
          [
            {
              'titulo': 'Proveedores',
              'valor': v('proveedores'),
            },
            {
              'titulo': 'Factura N°',
              'valor': v('factura'),
            },
            {
              'titulo':
                  'M/N - Línea Aérea',
              'valor': v('lineaAerea'),
            },
            {
              'titulo': 'B/L Guía',
              'valor': v('blGuia'),
            },
          ],
        ),

        // PUERTO SALIDA / PUERTO LLEGADA / DIRECCIÓN
            filaCeldas(
              [
                {
                  'titulo': 'Puerto Salida',
                  'valor': v('puertoSalida'),
                },
                {
                  'titulo': 'Puerto Llegada',
                  'valor': v('puertoLlegada'),
                },
                {
                  'titulo':
                      'Dirección Reconocimiento',
                  'valor': v('direccion'),
                },
              ],
              anchos: [
                1,
                1,
                2,
              ],
            ),

            // MARCAS / CONTENEDOR + CANTIDAD BULTOS
            // DEBAJO DE PUERTO SALIDA
            filaCeldas(
              [
                {
                  'titulo':
                      'Marcas y N° Contenedor',
                  'valor':
                      v('marcasContenedor'),
                },
                {
                  'titulo':
                      'Cantidad Bultos',
                  'valor':
                      v('cantidadBultos'),
                },
                {
                  'titulo':
                      'Clases de Empaque',
                  'valor':
                      v('clasesEmpaque'),
                },
                {
                  'titulo': 'Peso Bruto',
                  'valor':
                      '${v('pesoBruto')} KGS',
                },
              ],
              anchos: [
                1.6,
                1,
              ],
            ),
      ],

      
    );
    

    

    // ============================================================
    // TABLA DE BULTOS
    // ============================================================
    final encabezadosTabla = [
      'Bulto N°',
      'Referencia y/o Contenido',
      'Unid. Desp.',
      'Unid. Recib.',
      'Unid. Falt.',
      'Unid. Aver.',
      'V/R Unit.',
      'Observaciones',
    ];

    final filasTabla = bultos.map((b) {
      final bulto =
          b as Map<String, dynamic>;

      return [
        bulto['bulto']?.toString() ?? '',
        bulto['referencia']?.toString() ?? '',
        bulto['despachada']?.toString() ?? '',
        bulto['recibida']?.toString() ?? '',
        bulto['faltante']?.toString() ?? '-',
        bulto['averiada']?.toString() ?? '-',
        bulto['vrUnitario']?.toString() ?? '-',
        bulto['observaciones']?.toString() ?? '',
      ];
    }).toList();

    final tablaBultos = pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [

        pw.SizedBox(height: 10),

        pw.Container(
          padding:
              const pw.EdgeInsets.symmetric(
            vertical: 3,
          ),
          decoration:
              const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(
                color: PdfColors.black,
                width: 1,
              ),
            ),
          ),
          child: pw.Text(
            'DETALLE DE LA INSPECCIÓN',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight:
                  pw.FontWeight.bold,
            ),
          ),
        ),

        pw.SizedBox(height: 6),

        if (filasTabla.isNotEmpty)
          // ignore: deprecated_member_use
          pw.Table.fromTextArray(
            headers: encabezadosTabla,
            data: filasTabla,

            border: pw.TableBorder.all(
              color: PdfColors.black,
              width: 0.6,
            ),

            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight:
                  pw.FontWeight.bold,
              color: PdfColors.white,
            ),

            headerDecoration:
                const pw.BoxDecoration(
              color: PdfColors.blue900,
            ),

            cellStyle:
                const pw.TextStyle(
              fontSize: 8,
            ),

            cellAlignment:
                pw.Alignment.centerLeft,

            columnWidths: {
              0: const pw.FlexColumnWidth(0.8),
              1: const pw.FlexColumnWidth(1.8),
              2: const pw.FlexColumnWidth(0.9),
              3: const pw.FlexColumnWidth(0.9),
              4: const pw.FlexColumnWidth(0.9),
              5: const pw.FlexColumnWidth(0.9),
              6: const pw.FlexColumnWidth(0.9),
              7: const pw.FlexColumnWidth(2.2),
            },
          ),
      ],
    );

    // ============================================================
    // NOVEDADES Y PÉRDIDA
    // ============================================================
    final novedadesYPerdida = pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [

        pw.SizedBox(height: 10),

        pw.Text(
          'DETALLE DE NOVEDADES:',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 4),

        pw.Container(
          width: double.infinity,
          padding:
              const pw.EdgeInsets.all(6),
          decoration: borde,
          child: pw.Text(
            v('novedades'),
            style:
                const pw.TextStyle(
              fontSize: 9,
            ),
          ),
        ),

        pw.SizedBox(height: 10),

        pw.Text(
          'DETALLE DE LA PÉRDIDA:',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 4),

        filaCeldas(
          [
            {
              'titulo':
                  'Unid. Faltantes',
              'valor':
                  v('unidFaltantes'),
            },
            {
              'titulo':
                  'Unid. Averiadas',
              'valor':
                  v('unidAveriadas'),
            },
            {
              'titulo':
                  'Valor de la Pérdida',
              'valor':
                  v('valorPerdida'),
            },
          ],
        ),
      ],
    );

    // ============================================================
    // REPRESENTANTE Y FIRMAS
    // ============================================================
    final firmasSeccion = pw.Column(
      crossAxisAlignment:
          pw.CrossAxisAlignment.start,
      children: [

        pw.SizedBox(height: 10),

        pw.Text(
          'REPRESENTANTE DEL ASEGURADO',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight:
                pw.FontWeight.bold,
          ),
        ),

        pw.SizedBox(height: 4),

        filaCeldas(
          [
            {
              'titulo': 'Nombre',
              'valor':
                  v('nombreRepresentante'),
            },
            {
              'titulo': 'Cédula N°',
              'valor':
                  v('cedulaRepresentante'),
            },
          ],
          anchos: [
            2,
            1,
          ],
        ),

        filaCeldas(
          [
            {
              'titulo': 'Teléfono',
              'valor':
                  v('telefonoRepresentante'),
            },
            {
              'titulo':
                  'Hora de Entrada',
              'valor':
                  v('horaEntrada'),
            },
            {
              'titulo':
                  'Hora de Salida',
              'valor':
                  v('horaSalida'),
            },
          ],
        ),

        pw.SizedBox(height: 14),

        pw.Table(
          columnWidths: const {
            0: pw.FlexColumnWidth(1),
            1: pw.FlexColumnWidth(1),
          },
          children: [
            pw.TableRow(
              children: [

                // ==================================================
                // FIRMA ASEGURADO
                // ==================================================
                pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.center,
                  children: [

                    pw.Container(
                      height: 70,
                      margin:
                          const pw.EdgeInsets.only(
                        right: 8,
                      ),
                      decoration: borde,
                      child:
                          firmaAseguradoBytes !=
                                  null
                              ? pw.Image(
                                  pw.MemoryImage(
                                    firmaAseguradoBytes,
                                  ),
                                )
                              : null,
                    ),

                    pw.SizedBox(height: 4),

                    pw.Text(
                      'Firma y Sello Asegurado',
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),

                // ==================================================
                // FIRMA INSPECTOR
                // ==================================================
                pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.center,
                  children: [

                    pw.Container(
                      height: 70,
                      margin:
                          const pw.EdgeInsets.only(
                        left: 8,
                      ),
                      decoration: borde,
                      alignment:
                          pw.Alignment.center,
                      child: pw.Text(
                        v('nombreInspector'),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontStyle:
                              pw.FontStyle.italic,
                          fontWeight:
                              pw.FontWeight.bold,
                        ),
                      ),
                    ),

                    pw.SizedBox(height: 4),

                    pw.Text(
                      'Firma y Sello Inspector',
                      style:
                          const pw.TextStyle(
                        fontSize: 8,
                      ),
                    ),

                    pw.Text(
                      v(
                        'fechaHoraFirmaInspector',
                      ),
                      style:
                          const pw.TextStyle(
                        fontSize: 7,
                        color:
                            PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );

    // ============================================================
    // CREAR PDF
    // ============================================================
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          encabezado,
          tablaBultos,
          novedadesYPerdida,
          firmasSeccion,
        ],
      ),
    );

    // ============================================================
    // COMPARTIR PDF
    // ============================================================
    final numero =
        datos['numeroInspeccion'] ??
            'inspeccion';

    await Printing.sharePdf(
      bytes: await doc.save(),
      filename:
          'inspeccion_$numero.pdf',
    );
  }
}