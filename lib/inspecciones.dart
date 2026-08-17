import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'nueva_inspeccion.dart';
import 'detalle_inspeccion.dart';
import 'permisos_service.dart';

class PantallaInspecciones extends StatefulWidget {
  const PantallaInspecciones({super.key});

  @override
  State<PantallaInspecciones> createState() =>
      _PantallaInspeccionesState();
}

class _PantallaInspeccionesState extends State<PantallaInspecciones> {
  static const Color _azulMarca = Color(0xFF0D1B4C);
  static const Color _azulClaro = Color(0xFF1D4ED8);
  static const Color _fondo = Color(0xFFF5F7FB);

  // ============================================================
  // SERVICIO DE PERMISOS
  // ============================================================

  final PermisosService _permisosService = PermisosService();

  bool _cargandoPermisos = true;
  bool _puedeVerInspecciones = false;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();
    _cargarPermisos();
  }

  // ============================================================
  // CARGAR PERMISO VER INSPECCIONES
  // ============================================================

  Future<void> _cargarPermisos() async {
    try {
      await _permisosService.cargarPermisos();

      if (!mounted) return;

      setState(() {
        _puedeVerInspecciones =
            _permisosService.puedeVerInspecciones;

        _cargandoPermisos = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _puedeVerInspecciones = false;
        _cargandoPermisos = false;
      });
    }
  }

  // ============================================================
  // PANTALLA SIN PERMISO
  // ============================================================

  Widget _pantallaSinPermiso() {
    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _azulMarca,
        title: const Text(
          'Mis Inspecciones',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: _azulMarca,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(
              Icons.logout_rounded,
              size: 22,
              color: _azulMarca,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  size: 48,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Acceso restringido',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: _azulMarca,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'No tienes permiso para ver las inspecciones.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azulMarca,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // CARGANDO PERMISOS
    // ==========================================================

    if (_cargandoPermisos) {
      return const Scaffold(
        backgroundColor: _fondo,
        body: Center(
          child: CircularProgressIndicator(
            color: _azulMarca,
          ),
        ),
      );
    }

    // ==========================================================
    // SIN PERMISO
    // ==========================================================

    if (!_puedeVerInspecciones) {
      return _pantallaSinPermiso();
    }

    // ==========================================================
    // USUARIO
    // ==========================================================

    final usuario = FirebaseAuth.instance.currentUser;

    final nombreUsuario =
        usuario?.email?.split('@').first ?? 'Inspector';

    // ==========================================================
    // PANTALLA PRINCIPAL
    // ==========================================================

    return Scaffold(
      backgroundColor: _fondo,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _azulMarca,
        titleSpacing: 12,

        // ======================================================
        // LOGO + TÍTULO
        // ======================================================

        title: Row(
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset(
                'assets/image/colprevi.png',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(width: 0),

            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mis Inspecciones',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _azulMarca,
                    ),
                  ),

                  SizedBox(height: 2),

                  Text(
                    'Gestiona tus inspecciones',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ======================================================
        // CERRAR SESIÓN
        // ======================================================

        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(
              Icons.logout_rounded,
              size: 22,
              color: _azulMarca,
            ),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ========================================================
      // CONTENIDO
      // ========================================================

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('inspecciones')
            .orderBy(
              'fechaCreacion',
              descending: true,
            )
            .snapshots(),

        builder: (context, snapshot) {
          // ====================================================
          // ERROR
          // ====================================================

          if (snapshot.hasError) {
            return _PantallaError(
              mensaje:
                  'No pudimos cargar tus inspecciones.\n\n'
                  '${snapshot.error}',
            );
          }

          // ====================================================
          // CARGANDO
          // ====================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _azulMarca,
              ),
            );
          }

          final documentos =
              snapshot.data?.docs ?? [];

          // ====================================================
          // CONTENIDO
          // ====================================================

          return RefreshIndicator(
            color: _azulMarca,

            onRefresh: () async {
              await Future.delayed(
                const Duration(milliseconds: 500),
              );
            },

            child: CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),

              slivers: [
                // ==================================================
                // SALUDO
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      12,
                    ),

                    child: Container(
                      padding:
                          const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(
                          begin:
                              Alignment.topLeft,
                          end:
                              Alignment.bottomRight,
                          colors: [
                            _azulMarca,
                            _azulClaro,
                          ],
                        ),

                        borderRadius:
                            BorderRadius.circular(20),

                        boxShadow: [
                          BoxShadow(
                            color: _azulMarca
                                .withValues(
                              alpha: 0.18,
                            ),
                            blurRadius: 18,
                            offset:
                                const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [
                          // AVATAR

                          Container(
                            width: 52,
                            height: 52,

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.white
                                      .withValues(
                                alpha: 0.15,
                              ),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(
                                color:
                                    Colors.white
                                        .withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            ),

                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          // TEXTO

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const Text(
                                  'Bienvenido',
                                  style: TextStyle(
                                    color:
                                        Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                Text(
                                  _capitalizar(
                                    nombreUsuario,
                                  ),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white,
                                    fontSize: 20,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),

                                const SizedBox(
                                  height: 3,
                                ),

                                const Text(
                                  'Aquí tienes tus inspecciones',
                                  style: TextStyle(
                                    color:
                                        Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // NUEVA INSPECCIÓN
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),

                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(
                              16,
                            ),

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const PantallaNuevaInspeccion(),
                                ),
                              );
                            },

                            child:
                                const _TarjetaResumen(
                              icono:
                                  Icons.add_circle_rounded,
                              titulo:
                                  'Nueva inspección',
                              valor:
                                  'Crear',
                              color:
                                  Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // TÍTULO DE LISTA
                // ==================================================

                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      8,
                    ),

                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Inspecciones recientes',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.w700,
                              color:
                                  _azulMarca,
                            ),
                          ),
                        ),

                        if (documentos.isNotEmpty)
                          Text(
                            '${documentos.length} registro${documentos.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // ==================================================
                // SIN INSPECCIONES
                // ==================================================

                if (documentos.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,

                    child: _EstadoVacio(
                      onNuevaInspeccion: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const PantallaNuevaInspeccion(),
                          ),
                        );
                      },
                    ),
                  )

                // ==================================================
                // LISTA DE INSPECCIONES
                // ==================================================

                else
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(
                      20,
                      4,
                      20,
                      110,
                    ),

                    sliver: SliverList(
                      delegate:
                          SliverChildBuilderDelegate(
                        (context, index) {
                          final doc =
                              documentos[index];

                          final datos =
                              doc.data()
                                  as Map<String,
                                      dynamic>;

                          return _TarjetaInspeccion(
                            datos: datos,

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetalleInspeccion(
                                    inspeccionId:
                                        doc.id,
                                    datos: datos,
                                  ),
                                ),
                              );
                            },
                          );
                        },

                        childCount:
                            documentos.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),

      // ==========================================================
      // BOTÓN NUEVA INSPECCIÓN
      // ==========================================================

      floatingActionButton:
          FloatingActionButton.extended(
        elevation: 6,

        backgroundColor: _azulMarca,
        foregroundColor: Colors.white,

        icon: const Icon(
          Icons.add_rounded,
        ),

        label: const Text(
          'Nueva inspección',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const PantallaNuevaInspeccion(),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CAPITALIZAR NOMBRE
  // ============================================================

  static String _capitalizar(String texto) {
    if (texto.isEmpty) return texto;

    return texto[0].toUpperCase() +
        texto.substring(1);
  }
}

// =================================================================
// TARJETA DE RESUMEN
// =================================================================

class _TarjetaResumen extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;
  final Color color;

  const _TarjetaResumen({
    required this.icono,
    required this.titulo,
    required this.valor,
    this.color = const Color(0xFF0D1B4C),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: Colors.grey.shade200,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: color.withValues(
                alpha: 0.10,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              icono,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 11,
                    color:
                        Colors.grey.shade600,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  valor,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 15,
                    color: color,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// TARJETA DE INSPECCIÓN
// =================================================================

class _TarjetaInspeccion extends StatelessWidget {
  final Map<String, dynamic> datos;
  final VoidCallback onTap;

  const _TarjetaInspeccion({
    required this.datos,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final numero =
        datos['numeroInspeccion']?.toString() ?? '-';

    final asegurado =
        datos['asegurado']?.toString() ??
            'Sin asegurado';

    final fecha =
        datos['fecha']?.toString() ??
            'Sin fecha';

    final ciudad =
        datos['ciudad']?.toString() ?? '';

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(17),

        border: Border.all(
          color: Colors.grey.shade200,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withValues(
              alpha: 0.035,
            ),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      clipBehavior:
          Clip.antiAlias,

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          onTap: onTap,

          child: Column(
            children: [
              // BORDE SUPERIOR

              Container(
                width:
                    double.infinity,
                height: 4,

                decoration:
                    const BoxDecoration(
                  color:
                      Color.fromARGB(
                    255,
                    9,
                    14,
                    88,
                  ),
                ),
              ),

              // CONTENIDO

              Padding(
                padding:
                    const EdgeInsets.all(
                  15,
                ),

                child: Row(
                  children: [
                    // ICONO

                    Container(
                      width: 50,
                      height: 50,

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFF0D1B4C,
                        ).withValues(
                          alpha: 0.08,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),

                      child:
                          const Icon(
                        Icons
                            .assignment_rounded,
                        color:
                            Color(
                          0xFF0D1B4C,
                        ),
                        size: 25,
                      ),
                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    // INFORMACIÓN

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'INSPECCIÓN N° $numero',
                            maxLines: 1,
                            overflow:
                                TextOverflow
                                    .ellipsis,

                            style:
                                const TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w800,
                              color:
                                  Color(
                                0xFF0D1B4C,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Row(
                            children: [
                              Icon(
                                Icons
                                    .business_rounded,
                                size: 15,
                                color:
                                    Colors.grey
                                        .shade500,
                              ),

                              const SizedBox(
                                width: 5,
                              ),

                              Expanded(
                                child: Text(
                                  asegurado,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      const TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 5,
                          ),

                          Wrap(
                            spacing: 12,
                            runSpacing: 4,

                            children: [
                              Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons
                                        .calendar_today_rounded,
                                    size: 13,
                                    color:
                                        Colors
                                            .grey
                                            .shade500,
                                  ),

                                  const SizedBox(
                                    width: 4,
                                  ),

                                  Text(
                                    fecha,
                                    style:
                                        TextStyle(
                                      fontSize: 11,
                                      color:
                                          Colors
                                              .grey
                                              .shade600,
                                    ),
                                  ),
                                ],
                              ),

                              if (ciudad.isNotEmpty)
                                Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons
                                          .location_on_rounded,
                                      size: 14,
                                      color:
                                          Colors
                                              .grey
                                              .shade500,
                                    ),

                                    const SizedBox(
                                      width: 3,
                                    ),

                                    Text(
                                      ciudad,
                                      style:
                                          TextStyle(
                                        fontSize: 11,
                                        color:
                                            Colors
                                                .grey
                                                .shade600,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    // FLECHA

                    Container(
                      width: 34,
                      height: 34,

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.grey.shade100,
                        shape:
                            BoxShape.circle,
                      ),

                      child:
                          const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 14,
                        color:
                            Color(
                          0xFF0D1B4C,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =================================================================
// ESTADO VACÍO
// =================================================================

class _EstadoVacio extends StatelessWidget {
  final VoidCallback onNuevaInspeccion;

  const _EstadoVacio({
    required this.onNuevaInspeccion,
  });

  @override
  Widget build(BuildContext context) {
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
                color: const Color(0xFF0D1B4C).withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assignment_rounded,
                size: 42,
                color: Color(0xFF0D1B4C),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Aún no tienes inspecciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D1B4C),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Cuando registres una nueva inspección, '
              'aparecerá aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed: onNuevaInspeccion,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear inspección'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D1B4C),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// ERROR
// =================================================================

class _PantallaError extends StatelessWidget {
  final String mensaje;

  const _PantallaError({
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            const Text(
              'No se pudieron cargar las inspecciones',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D1B4C),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              mensaje,
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
}