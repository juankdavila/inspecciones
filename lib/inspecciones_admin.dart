// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================================
// PANTALLA ADMINISTRADOR - INSPECCIONES
// ============================================================================

class InspeccionesAdministrador extends StatefulWidget {
  const InspeccionesAdministrador({super.key});

  @override
  State<InspeccionesAdministrador> createState() =>
      _InspeccionesAdministradorState();
}
class _InspeccionesAdministradorState
    extends State<InspeccionesAdministrador> {

  static const Color _azulMarca = Color(0xFF0D1B4C);
  static const Color _azulClaro = Color(0xFF1D4ED8);
  static const Color _fondo = Color(0xFFF5F7FB);

    final TextEditingController _busquedaController =
      TextEditingController();

  // ignore: unused_field
  String _busqueda = '';

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,

      // ======================================================================
      // APP BAR
      // ======================================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _azulMarca,
        title: const Row(
          children: [
            Icon(
              Icons.admin_panel_settings_rounded,
              color: _azulMarca,
              size: 25,
            ),
            SizedBox(width: 10),
            Text(
              'Administrador',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _azulMarca,
              ),
            ),
          ],
        ),
      ),

      // ======================================================================
      // CONTENIDO
      // ======================================================================

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('inspecciones')
            .orderBy(
              'fechaCreacion',
              descending: true,
            )
            .snapshots(),

        builder: (context, snapshot) {
          // ==================================================================
          // ERROR
          // ==================================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 55,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'No se pudieron cargar las inspecciones',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _azulMarca,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==================================================================
          // CARGANDO
          // ==================================================================

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _azulMarca,
              ),
            );
          }

          final inspecciones = snapshot.data?.docs ?? [];

          // ==================================================================
          // SIN INSPECCIONES
          // ==================================================================

          if (inspecciones.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: _azulMarca.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.assignment_outlined,
                        size: 45,
                        color: _azulMarca,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No hay inspecciones registradas',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: _azulMarca,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cuando se registre una inspección aparecerá aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ==================================================================
          // LISTA
          // ==================================================================

          return RefreshIndicator(
            color: _azulMarca,

            onRefresh: () async {
              await Future.delayed(
                const Duration(milliseconds: 500),
              );
            },

            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                30,
              ),
              children: [
                // ==============================================================
                // ENCABEZADO
                // ==============================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _azulMarca,
                        _azulClaro,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _azulMarca.withValues(alpha: 0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          color: Colors.white,
                          size: 29,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gestión de inspecciones',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${inspecciones.length} '
                              '${inspecciones.length == 1 ? 'inspección registrada' : 'inspecciones registradas'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==============================================================
                // TÍTULO
                // ==============================================================

                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Inspecciones registradas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _azulMarca,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _azulMarca.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${inspecciones.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _azulMarca,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ==============================================================
                // BOTONES DE INSPECCIONES
                // ==============================================================

                ...inspecciones.map(
                  (documento) {
                    final datos = documento.data();

                    return _BotonInspeccion(
                      datos: datos,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetalleInspeccionAdministrador(
                              datos: datos,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// BOTÓN DE INSPECCIÓN
// ============================================================================

class _BotonInspeccion extends StatelessWidget {
  final Map<String, dynamic> datos;
  final VoidCallback onTap;

  const _BotonInspeccion({
    required this.datos,
    required this.onTap,
  });

  static const Color _azulMarca = Color(0xFF0D1B4C);
  static const Color _azulClaro = Color(0xFF1D4ED8);

  String _texto(
    String campo, {
    String defecto = 'No registrado',
  }) {
    final valor = datos[campo];

    if (valor == null) {
      return defecto;
    }

    final texto = valor.toString().trim();

    if (texto.isEmpty) {
      return defecto;
    }

    return texto;
  }

  @override
  Widget build(BuildContext context) {
    final numero = _texto(
      'numeroInspeccion',
      defecto: 'Sin número',
    );

    final cliente = _texto(
      'asegurado',
      defecto: 'Sin cliente',
    );

    final ciudad = _texto(
      'ciudad',
      defecto: 'Sin ciudad',
    );

    final fecha = _texto(
      'fecha',
      defecto: 'Sin fecha',
    );

    final inspector = _texto(
      'nombreInspector',
      defecto: 'Sin inspector',
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,

          child: Padding(
            padding: const EdgeInsets.all(15),

            child: Row(
              children: [
                // ============================================================
                // ICONO
                // ============================================================

                Container(
                  width: 52,
                  height: 52,

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _azulMarca,
                        _azulClaro,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),

                  child: const Icon(
                    Icons.assignment_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 14),

                // ============================================================
                // INFORMACIÓN
                // ============================================================

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INSPECCIÓN N° $numero',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: _azulMarca,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 15,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              cliente,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          Icon(
                            Icons.person_rounded,
                            size: 15,
                            color: _azulClaro,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              inspector,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _azulMarca,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                fecha,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                ciudad,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ============================================================
                // FLECHA
                // ============================================================

                Container(
                  width: 35,
                  height: 35,

                  decoration: BoxDecoration(
                    color: _azulMarca.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: _azulMarca,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DETALLE DE INSPECCIÓN - ADMINISTRADOR
// ============================================================================

class DetalleInspeccionAdministrador extends StatelessWidget {
  final Map<String, dynamic> datos;

  const DetalleInspeccionAdministrador({
    super.key,
    required this.datos,
  });

  static const Color _azulMarca = Color(0xFF0D1B4C);
  static const Color _azulClaro = Color(0xFF1D4ED8);
  static const Color _fondo = Color(0xFFF5F7FB);

  static const Color _verde = Color(0xFF15803D);
  static const Color _rojo = Color(0xFFDC2626);
  static const Color _naranja = Color(0xFFEA580C);

  // ==========================================================================
  // OBTENER TEXTO
  // ==========================================================================

  String _texto(
    String campo, {
    String defecto = 'No registrado',
  }) {
    final valor = datos[campo];

    if (valor == null) {
      return defecto;
    }

    final texto = valor.toString().trim();

    if (texto.isEmpty) {
      return defecto;
    }

    return texto;
  }

  // ==========================================================================
  // CONVERTIR VALOR A NÚMERO
  // ==========================================================================

  double _numero(
    String campo,
  ) {
    final valor = datos[campo];

    if (valor == null) {
      return 0;
    }

    if (valor is num) {
      return valor.toDouble();
    }

    final texto = valor.toString().trim();

    if (texto.isEmpty) {
      return 0;
    }

    final limpio = texto
        .replaceAll('\$', '')
        .replaceAll('USD', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(limpio) ?? 0;
  }

  // ==========================================================================
  // DETERMINAR SI EXISTE PÉRDIDA
  // ==========================================================================

  bool _hayPerdida() {
    final faltantes = _numero('unidFaltantes');
    final averiadas = _numero('unidAveriadas');
    final valor = _numero('valorPerdida');

    return faltantes > 0 || averiadas > 0 || valor > 0;
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final numero = _texto(
      'numeroInspeccion',
      defecto: 'Sin número',
    );

    final bultos = datos['bultos'] is List
        ? List<dynamic>.from(datos['bultos'])
        : <dynamic>[];

    return Scaffold(
      backgroundColor: _fondo,

      // ======================================================================
      // APP BAR
      // ======================================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _azulMarca,

        title: const Text(
          'Detalle de inspección',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _azulMarca,
          ),
        ),
      ),

      // ======================================================================
      // CONTENIDO
      // ======================================================================

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          18,
          18,
          40,
        ),

        children: [
          // ==================================================================
          // ENCABEZADO
          // ==================================================================

          _encabezadoInforme(numero),

          const SizedBox(height: 22),

          // ==================================================================
          // DATOS GENERALES
          // ==================================================================

          _tituloSeccion(
            icono: Icons.info_outline_rounded,
            titulo: 'DATOS GENERALES',
          ),

          _bloqueInformacion(
            children: [
              _dato(
                'Ciudad',
                _texto('ciudad'),
                Icons.location_city_rounded,
              ),
              _dato(
                'Fecha',
                _texto('fecha'),
                Icons.calendar_today_rounded,
              ),
              _dato(
                'Solicitante',
                _texto('solicitante'),
                Icons.business_rounded,
              ),
              _dato(
                'Asegurado / Cliente',
                _texto('asegurado'),
                Icons.verified_user_rounded,
              ),
              _dato(
                'Póliza N°',
                _texto('poliza'),
                Icons.description_rounded,
              ),
              _dato(
                'Aplicación N°',
                _texto('aplicacion'),
                Icons.numbers_rounded,
              ),
              _dato(
                'Pedido N°',
                _texto('pedido'),
                Icons.receipt_long_rounded,
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ==================================================================
          // DATOS DE EMBARQUE
          // ==================================================================

          _tituloSeccion(
            icono: Icons.directions_boat_rounded,
            titulo: 'DATOS DE EMBARQUE',
          ),

          _bloqueInformacion(
            children: [
              _dato(
                'Proveedores',
                _texto('proveedores'),
                Icons.local_shipping_rounded,
              ),
              _dato(
                'Factura N°',
                _texto('factura'),
                Icons.receipt_rounded,
              ),
              _dato(
                'M/N - Línea Aérea',
                _texto('lineaAerea'),
                Icons.flight_rounded,
              ),
              _dato(
                'B/L Guía',
                _texto('blGuia'),
                Icons.confirmation_number_rounded,
              ),
              _dato(
                'Puerto de salida',
                _texto('puertoSalida'),
                Icons.anchor_rounded,
              ),
              _dato(
                'Puerto de llegada',
                _texto('puertoLlegada'),
                Icons.anchor_rounded,
              ),
              _datoGrande(
                'Dirección de reconocimiento',
                _texto('direccion'),
                Icons.place_rounded,
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ==================================================================
          // CARGA
          // ==================================================================

          _tituloSeccion(
            icono: Icons.inventory_2_rounded,
            titulo: 'CARGA INSPECCIONADA',
          ),

          _bloqueCarga(),

          const SizedBox(height: 22),

          // ==================================================================
          // DETALLE DE BULTOS
          // ==================================================================

          _tituloSeccion(
            icono: Icons.inventory_rounded,
            titulo: 'DETALLE DE LA INSPECCIÓN',
          ),

          if (bultos.isEmpty)
            _mensajeSinDatos(
              'No hay detalle de bultos registrado.',
            )
          else
            ...List.generate(
              bultos.length,
              (index) {
                final bulto = bultos[index] is Map
                    ? Map<String, dynamic>.from(
                        bultos[index],
                      )
                    : <String, dynamic>{};

                return _bulto(
                  index,
                  bulto,
                );
              },
            ),

          const SizedBox(height: 22),

          // ==================================================================
          // NOVEDADES
          // ==================================================================

          _tituloSeccion(
            icono: Icons.warning_amber_rounded,
            titulo: 'DETALLE DE NOVEDADES',
          ),

          _bloqueNovedades(),

          const SizedBox(height: 22),

          // ==================================================================
          // PÉRDIDA
          // ==================================================================

          _tituloSeccion(
            icono: Icons.report_problem_rounded,
            titulo: 'DETALLE DE LA PÉRDIDA',
          ),

          _bloquePerdida(),

          const SizedBox(height: 22),

          // ==================================================================
          // REPRESENTANTE
          // ==================================================================

          _tituloSeccion(
            icono: Icons.person_outline_rounded,
            titulo: 'REPRESENTANTE DEL ASEGURADO',
          ),

          _bloqueInformacion(
            children: [
              _dato(
                'Nombre',
                _texto('nombreRepresentante'),
                Icons.badge_rounded,
              ),
              _dato(
                'Cédula N°',
                _texto('cedulaRepresentante'),
                Icons.credit_card_rounded,
              ),
              _dato(
                'Teléfono',
                _texto('telefonoRepresentante'),
                Icons.phone_rounded,
              ),
              _dato(
                'Hora de entrada',
                _texto('horaEntrada'),
                Icons.login_rounded,
              ),
              _dato(
                'Hora de salida',
                _texto('horaSalida'),
                Icons.logout_rounded,
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ==================================================================
          // FIRMA
          // ==================================================================

          _tituloSeccion(
            icono: Icons.verified_rounded,
            titulo: 'FIRMA DEL INSPECTOR',
          ),

          _bloqueFirma(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================================================
  // ENCABEZADO
  // ==========================================================================

  Widget _encabezadoInforme(
    String numero,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _azulMarca,
            _azulClaro,
          ],
        ),

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: _azulMarca.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 55,
                height: 55,

                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),

                child: const Icon(
                  Icons.assignment_rounded,
                  color: Colors.white,
                  size: 29,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'INFORME DE INSPECCIÓN FINAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'N° $numero',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.18),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _datoEncabezado(
                  'INSPECTOR',
                  _texto(
                    'nombreInspector',
                    defecto: 'No registrado',
                  ),
                  Icons.person_rounded,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _datoEncabezado(
                  'FECHA',
                  _texto(
                    'fecha',
                    defecto: 'No registrada',
                  ),
                  Icons.calendar_today_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // DATO ENCABEZADO
  // ==========================================================================

  Widget _datoEncabezado(
    String titulo,
    String valor,
    IconData icono,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        children: [
          Icon(
            icono,
            size: 18,
            color: Colors.white70,
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  valor,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TÍTULO SECCIÓN
  // ==========================================================================

  Widget _tituloSeccion({
    required IconData icono,
    required String titulo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 11,
      ),

      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,

            decoration: BoxDecoration(
              color: _azulMarca.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
            ),

            child: Icon(
              icono,
              size: 18,
              color: _azulMarca,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _azulMarca,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BLOQUE INFORMACIÓN
  // ==========================================================================

  Widget _bloqueInformacion({
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        border: Border.all(
          color: Colors.grey.shade200,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Wrap(
        spacing: 12,
        runSpacing: 12,

        children: children.map(
          (widget) {
            return SizedBox(
              width: 145,
              child: widget,
            );
          },
        ).toList(),
      ),
    );
  }

  // ==========================================================================
  // DATO
  // ==========================================================================

  Widget _dato(
    String titulo,
    String valor,
    IconData icono,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: _fondo,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icono,
                size: 15,
                color: _azulClaro,
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  titulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            valor,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // DATO GRANDE
  // ==========================================================================

  Widget _datoGrande(
    String titulo,
    String valor,
    IconData icono,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),

      decoration: BoxDecoration(
        color: _fondo,
        borderRadius: BorderRadius.circular(10),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            size: 17,
            color: _azulClaro,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CARGA
  // ==========================================================================

  Widget _bloqueCarga() {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        border: Border.all(
          color: Colors.grey.shade200,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _datoCarga(
                  'CONTENEDOR',
                  _texto('marcasContenedor'),
                  Icons.inventory_2_rounded,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _datoCarga(
                  'BULTOS',
                  _texto('cantidadBultos'),
                  Icons.inventory_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _datoCarga(
                  'EMPAQUE',
                  _texto('clasesEmpaque'),
                  Icons.category_rounded,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _datoCarga(
                  'PESO BRUTO',
                  '${_texto('pesoBruto')} KGS',
                  Icons.scale_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // DATO CARGA
  // ==========================================================================

  Widget _datoCarga(
    String titulo,
    String valor,
    IconData icono,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: _fondo,
        borderRadius: BorderRadius.circular(11),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            size: 20,
            color: _azulClaro,
          ),

          const SizedBox(height: 7),

          Text(
            titulo,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            valor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _azulMarca,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BULTO
  // ==========================================================================

  Widget _bulto(
    int index,
    Map<String, dynamic> bulto,
  ) {
    String valor(String campo) {
      final dato = bulto[campo];

      if (dato == null || dato.toString().trim().isEmpty) {
        return 'No registrado';
      }

      return dato.toString();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        children: [
          // ------------------------------------------------------------------
          // CABECERA
          // ------------------------------------------------------------------

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 11,
            ),

            decoration: BoxDecoration(
              color: _azulMarca.withValues(alpha: 0.05),

              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),

            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,

                  decoration: const BoxDecoration(
                    color: _azulMarca,
                    shape: BoxShape.circle,
                  ),

                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'BULTO',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _azulMarca,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------------------------
          // INFORMACIÓN
          // ------------------------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(14),

            child: Column(
              children: [
                _filaBulto(
                  'N° de bulto',
                  valor('bulto'),
                ),

                _filaBulto(
                  'Referencia / Contenido',
                  valor('referencia'),
                ),

                _filaBulto(
                  'Despachada',
                  valor('despachada'),
                ),

                _filaBulto(
                  'Recibida',
                  valor('recibida'),
                ),

                _filaBulto(
                  'Faltante',
                  valor('faltante'),
                ),

                _filaBulto(
                  'Averiada',
                  valor('averiada'),
                ),

                _filaBulto(
                  'V/R Unitario',
                  '${valor('vrUnitario')} USD',
                ),

                _filaBulto(
                  'Observaciones',
                  valor('observaciones'),
                  ultimo: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // FILA BULTO
  // ==========================================================================

  Widget _filaBulto(
    String titulo,
    String valor, {
    bool ultimo = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),

      decoration: BoxDecoration(
        border: ultimo
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              titulo,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
// NOVEDADES
// ==========================================================================

Widget _bloqueNovedades() {
  final valor = datos['novedades'];

  final tieneNovedades = valor != null &&
      valor.toString().trim().isNotEmpty &&
      valor.toString().trim().toLowerCase() != 'no' &&
      valor.toString().trim().toLowerCase() != 'no hay' &&
      valor.toString().trim().toLowerCase() != 'ninguna' &&
      valor.toString().trim().toLowerCase() != 'sin novedades' &&
      valor.toString().trim().toLowerCase() != 'n/a';

  final novedades = tieneNovedades
      ? valor.toString().trim()
      : 'No se registraron novedades.';

  // ------------------------------------------------------------------------
  // SI NO HAY NOVEDADES
  // ------------------------------------------------------------------------

  if (!tieneNovedades) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),

            child: Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.grey.shade500,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sin novedades',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  novedades,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------------------
  // SI SÍ HAY NOVEDADES
  // ------------------------------------------------------------------------

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: Colors.orange.shade100,
      ),
    ),

    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,

          decoration: BoxDecoration(
            color: _naranja.withValues(
              alpha: 0.10,
            ),
            borderRadius: BorderRadius.circular(10),
          ),

          child: const Icon(
            Icons.warning_amber_rounded,
            color: _naranja,
            size: 21,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            novedades,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}

  // ==========================================================================
  // DETALLE DE LA PÉRDIDA
  // ==========================================================================

  Widget _bloquePerdida() {
    final hayPerdida = _hayPerdida();

    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(15),

        // ================================================================
        // AQUÍ ESTÁ EL CAMBIO PRINCIPAL:
        //
        // Si NO hay pérdida -> borde verde
        // Si SÍ hay pérdida -> borde rojo
        // ================================================================

        border: Border.all(
          color: hayPerdida
              ? _rojo.withValues(alpha: 0.25)
              : _verde.withValues(alpha: 0.25),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        children: [
          // ================================================================
          // ESTADO GENERAL
          // ================================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),

            decoration: BoxDecoration(
              color: hayPerdida
                  ? _rojo.withValues(alpha: 0.06)
                  : _verde.withValues(alpha: 0.06),

              borderRadius: BorderRadius.circular(11),
            ),

            child: Row(
              children: [
                Icon(
                  hayPerdida
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_rounded,

                  color: hayPerdida ? _rojo : _verde,

                  size: 22,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    hayPerdida
                        ? 'SE REGISTRA PÉRDIDA'
                        : 'NO HAY PÉRDIDA',

                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: hayPerdida ? _rojo : _verde,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ================================================================
          // UNIDADES FALTANTES
          // ================================================================

          _datoPerdida(
            'UNIDADES FALTANTES',
            _texto(
              'unidFaltantes',
              defecto: '0',
            ),
            Icons.inventory_2_outlined
            
          ),

          const SizedBox(height: 10),

          // ================================================================
          // UNIDADES AVERIADAS
          // ================================================================

          _datoPerdida(
            'UNIDADES AVERIADAS',
            _texto(
              'unidAveriadas',
              defecto: '0',
            ),
            Icons.warning_amber_rounded
          ),

          const SizedBox(height: 10),

          // ================================================================
          // VALOR DE PÉRDIDA
          // ================================================================

          _datoPerdida(
            'VALOR DE LA PÉRDIDA',
            _texto(
              'valorPerdida',
              defecto: '0',
            ),
            Icons.attach_money_rounded
          ),
        ],
      ),
    );
  }

  // ==========================================================================
// DATO PÉRDIDA
// ==========================================================================

Widget _datoPerdida(
  String titulo,
  String valor,
  IconData icono,
  
) {
  final texto = valor.trim().toLowerCase();

  // Detectar cuando realmente NO existe pérdida
  final sinPerdida =
      texto.isEmpty ||
      texto == '0' ||
      texto == '0.0' ||
      texto == 'no' ||
      texto == 'no hay' ||
      texto == 'ninguna' ||
      texto == 'sin pérdida' ||
      texto == 'sin perdida' ||
      texto == 'no registrado';

  final colorPrincipal =
      sinPerdida ? Colors.grey.shade600 : _azulMarca;

  final colorFondo =
      sinPerdida
          ? Colors.grey.withValues(alpha: 0.04)
          : _azulMarca.withValues(alpha: 0.035);

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),

    decoration: BoxDecoration(
      color: colorFondo,
      borderRadius: BorderRadius.circular(10),
    ),

    child: Row(
      children: [
        Icon(
          sinPerdida
              ? Icons.check_circle_outline_rounded
              : icono,
          color: colorPrincipal,
          size: 21,
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
        ),

        Text(
          valor,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: colorPrincipal,
          ),
        ),
      ],
    ),
  );
}

  // ==========================================================================
  // FIRMA
  // ==========================================================================

  Widget _bloqueFirma() {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,

            decoration: BoxDecoration(
              color: _verde.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons.verified_rounded,
              color: _verde,
              size: 31,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            _texto(
              'nombreInspector',
              defecto: 'Inspector no registrado',
            ),

            textAlign: TextAlign.center,

            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: _azulMarca,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Inspector responsable',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 15),

          Container(
            height: 1,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 15,
                color: Colors.grey.shade500,
              ),

              const SizedBox(width: 6),

              Flexible(
                child: Text(
                  _texto(
                    'fechaHoraFirmaInspector',
                    defecto: 'Fecha y hora no registrada',
                  ),

                  overflow: TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SIN DATOS
  // ==========================================================================

  Widget _mensajeSinDatos(
    String mensaje,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),

        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),

      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: Colors.grey.shade500,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}