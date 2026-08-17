import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConfiguracionAdministrador extends StatefulWidget {
  const ConfiguracionAdministrador({super.key});

  @override
  State<ConfiguracionAdministrador> createState() =>
      _ConfiguracionAdministradorState();
}

class _ConfiguracionAdministradorState
    extends State<ConfiguracionAdministrador> {
  // ==========================================================================
  // COLORES
  // ==========================================================================

  static const Color _azulMarca = Color(0xFF0D1B4C);
  static const Color _azulClaro = Color(0xFF1D4ED8);
  static const Color _fondo = Color(0xFFF5F7FB);
  static const Color _verde = Color(0xFF16A34A);
  static const Color _naranja = Color(0xFFEA580C);
  static const Color _rojo = Color(0xFFDC2626);

  // ==========================================================================
  // FIREBASE
  // ==========================================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ==========================================================================
  // ESTADO
  // ==========================================================================

  bool _cargando = true;
  bool _guardando = false;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _usuarios = [];

  String? _usuarioSeleccionadoId;

  Map<String, bool> _permisos = {};

  // ==========================================================================
  // PERMISOS DISPONIBLES
  // ==========================================================================

  final List<Map<String, dynamic>> _listaPermisos = [
    {
      'id': 'verInspecciones',
      'nombre': 'Ver inspecciones',
      'descripcion': 'Permite consultar las inspecciones registradas.',
      'icono': Icons.visibility_rounded,
    },
    {
      'id': 'crearInspecciones',
      'nombre': 'Crear inspecciones',
      'descripcion': 'Permite registrar nuevas inspecciones.',
      'icono': Icons.add_circle_rounded,
    },
    {
      'id': 'editarInspecciones',
      'nombre': 'Editar inspecciones',
      'descripcion': 'Permite modificar inspecciones existentes.',
      'icono': Icons.edit_rounded,
    },
    {
      'id': 'generarReportes',
      'nombre': 'Generar reportes',
      'descripcion': 'Permite generar y consultar reportes.',
      'icono': Icons.picture_as_pdf_rounded,
    },
    {
      'id': 'enviarInformacion',
      'nombre': 'Enviar información',
      'descripcion': 'Permite enviar información de las inspecciones.',
      'icono': Icons.send_rounded,
    },
    {
      'id': 'gestionarUsuarios',
      'nombre': 'Gestionar usuarios',
      'descripcion': 'Permite administrar usuarios y sus permisos.',
      'icono': Icons.people_alt_rounded,
    },
    {
      'id': 'configuracion',
      'nombre': 'Configuración',
      'descripcion': 'Permite acceder a la configuración del sistema.',
      'icono': Icons.settings_rounded,
    },
    {
      'id': 'eliminar',
      'nombre': 'Eliminar registros',
      'descripcion': 'Permite eliminar registros del sistema.',
      'icono': Icons.delete_rounded,
    },
  ];

  // ==========================================================================
  // INICIO
  // ==========================================================================

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  // ==========================================================================
  // CARGAR USUARIOS
  // ==========================================================================

  Future<void> _cargarUsuarios() async {
    try {
      final consulta = await _firestore
          .collection('usuarios')
          .orderBy('nombre')
          .get();

      if (!mounted) return;

      setState(() {
        _usuarios = consulta.docs;
        _cargando = false;
      });

      // Seleccionar automáticamente el primer usuario
      if (_usuarios.isNotEmpty) {
        _seleccionarUsuario(_usuarios.first);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      _mostrarMensaje(
        'No se pudieron cargar los usuarios.',
        error: true,
      );
    }
  }

  // ==========================================================================
  // SELECCIONAR USUARIO
  // ==========================================================================

  void _seleccionarUsuario(
    QueryDocumentSnapshot<Map<String, dynamic>> usuario,
  ) {
    final datos = usuario.data();

    final permisosGuardados =
        datos['permisos'] as Map<String, dynamic>?;

    final nuevosPermisos = <String, bool>{};

    for (final permiso in _listaPermisos) {
      final id = permiso['id'] as String;

      nuevosPermisos[id] =
          permisosGuardados?[id] == true;
    }

    setState(() {
      _usuarioSeleccionadoId = usuario.id;
      _permisos = nuevosPermisos;
    });
  }

  // ==========================================================================
  // CAMBIAR PERMISO
  // ==========================================================================

  void _cambiarPermiso(
    String permiso,
    bool valor,
  ) {
    setState(() {
      _permisos[permiso] = valor;
    });
  }

  // ==========================================================================
  // GUARDAR PERMISOS
  // ==========================================================================

  Future<void> _guardarPermisos() async {
    if (_usuarioSeleccionadoId == null) {
      _mostrarMensaje(
        'Seleccione un usuario.',
        error: true,
      );
      return;
    }

    if (_guardando) return;

    final usuarioActual = _auth.currentUser;

    // Evitar modificar accidentalmente al administrador actual
    if (_usuarioSeleccionadoId == usuarioActual?.uid) {
      _mostrarMensaje(
        'No puedes modificar los permisos de tu propia cuenta.',
        error: true,
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      await _firestore
          .collection('usuarios')
          .doc(_usuarioSeleccionadoId)
          .update({
        'permisos': _permisos,
        'fechaActualizacionPermisos':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _mostrarMensaje(
        'Permisos guardados correctamente.',
      );

      await _cargarUsuarios();
    } catch (e) {
      if (!mounted) return;

      _mostrarMensaje(
        'No se pudieron guardar los permisos.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  // ==========================================================================
  // ACTIVAR TODOS
  // ==========================================================================

  void _activarTodos() {
    setState(() {
      for (final permiso in _listaPermisos) {
        _permisos[permiso['id'] as String] = true;
      }
    });
  }

  // ==========================================================================
  // DESACTIVAR TODOS
  // ==========================================================================

  void _desactivarTodos() {
    setState(() {
      for (final permiso in _listaPermisos) {
        _permisos[permiso['id'] as String] = false;
      }
    });
  }

  // ==========================================================================
  // MENSAJE
  // ==========================================================================

  void _mostrarMensaje(
    String mensaje, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor:
            error ? _rojo : _verde,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,

      // ========================================================================
      // APP BAR
      // ========================================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _azulMarca,

        title: const Row(
          children: [
            Icon(
              Icons.admin_panel_settings_rounded,
              color: _azulMarca,
              size: 24,
            ),

            SizedBox(width: 10),

            Text(
              'Permisos',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _azulMarca,
              ),
            ),
          ],
        ),
      ),

      // ========================================================================
      // CONTENIDO
      // ========================================================================

      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: _azulMarca,
              ),
            )
          : RefreshIndicator(
              color: _azulMarca,
              onRefresh: _cargarUsuarios,
              child: SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  35,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    // ==========================================================
                    // ENCABEZADO
                    // ==========================================================

                    _encabezado(),

                    const SizedBox(height: 25),

                    // ==========================================================
                    // USUARIOS
                    // ==========================================================

                    _tituloSeccion(
                      Icons.people_alt_rounded,
                      'USUARIOS',
                    ),

                    const SizedBox(height: 10),

                    _listaUsuarios(),

                    const SizedBox(height: 25),

                    // ==========================================================
                    // PERMISOS
                    // ==========================================================

                    if (_usuarioSeleccionadoId != null) ...[
                      _tituloSeccion(
                        Icons.lock_person_rounded,
                        'PERMISOS DEL USUARIO',
                      ),

                      const SizedBox(height: 10),

                      _tarjetaPermisos(),

                      const SizedBox(height: 20),

                      // ========================================================
                      // BOTÓN GUARDAR
                      // ========================================================

                      _botonGuardar(),
                    ],

                    const SizedBox(height: 25),

                    // ==========================================================
                    // CUENTA ACTUAL
                    // ==========================================================

                    _tituloSeccion(
                      Icons.account_circle_rounded,
                      'CUENTA ACTUAL',
                    ),

                    const SizedBox(height: 10),

                    _cuentaActual(),
                  ],
                ),
              ),
            ),
    );
  }

  // ==========================================================================
  // ENCABEZADO
  // ==========================================================================

  Widget _encabezado() {
    return Container(
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
        borderRadius:
            BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _azulMarca.withValues(
              alpha: 0.18,
            ),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [

          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.14,
              ),
              borderRadius:
                  BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.20,
                ),
              ),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  'Administración de permisos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                SizedBox(height: 5),

                Text(
                  'Controla qué funciones puede utilizar cada usuario.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
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
  // TÍTULO DE SECCIÓN
  // ==========================================================================

  Widget _tituloSeccion(
    IconData icono,
    String titulo,
  ) {
    return Row(
      children: [

        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _azulMarca.withValues(
              alpha: 0.08,
            ),
            borderRadius:
                BorderRadius.circular(9),
          ),
          child: Icon(
            icono,
            color: _azulMarca,
            size: 18,
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
    );
  }

  // ==========================================================================
  // LISTA DE USUARIOS
  // ==========================================================================

  Widget _listaUsuarios() {
    if (_usuarios.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: const Column(
          children: [

            Icon(
              Icons.people_outline_rounded,
              size: 45,
              color: Colors.grey,
            ),

            SizedBox(height: 10),

            Text(
              'No hay usuarios registrados.',
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: List.generate(
          _usuarios.length,
          (index) {
            final usuario =
                _usuarios[index];

            final datos =
                usuario.data();

            final nombre =
                datos['nombre']
                        ?.toString() ??
                    'Sin nombre';

            final correo =
                datos['correo']
                        ?.toString() ??
                    datos['email']
                        ?.toString() ??
                    'Sin correo';

            final rol =
                datos['rol']
                        ?.toString() ??
                    'Usuario';

            final seleccionado =
                _usuarioSeleccionadoId ==
                    usuario.id;

            return Column(
              children: [

                InkWell(
                  onTap: () =>
                      _seleccionarUsuario(
                    usuario,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(
                      14,
                    ),
                    child: Row(
                      children: [

                        Container(
                          width: 45,
                          height: 45,
                          decoration:
                              BoxDecoration(
                            color: seleccionado
                                ? _azulClaro
                                    .withValues(
                                    alpha: 0.10,
                                  )
                                : Colors.grey
                                    .withValues(
                                    alpha: 0.08,
                                  ),
                            shape:
                                BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: seleccionado
                                ? _azulClaro
                                : Colors.grey
                                    .shade600,
                            size: 23,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              Text(
                                nombre,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  color:
                                      _azulMarca,
                                ),
                              ),

                              const SizedBox(
                                height: 3,
                              ),

                              Text(
                                correo,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors
                                      .grey
                                      .shade600,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      _naranja
                                          .withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    6,
                                  ),
                                ),
                                child: Text(
                                  rol
                                      .toUpperCase(),
                                  style:
                                      const TextStyle(
                                    fontSize: 9,
                                    fontWeight:
                                        FontWeight
                                            .w800,
                                    color:
                                        _naranja,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Icon(
                          seleccionado
                              ? Icons
                                  .check_circle_rounded
                              : Icons
                                  .radio_button_unchecked,
                          color: seleccionado
                              ? _azulClaro
                              : Colors.grey
                                  .shade400,
                          size: 23,
                        ),
                      ],
                    ),
                  ),
                ),

                if (index <
                    _usuarios.length - 1)
                  Divider(
                    height: 1,
                    indent: 70,
                    endIndent: 15,
                    color:
                        Colors.grey.shade200,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // TARJETA DE PERMISOS
  // ==========================================================================

  Widget _tarjetaPermisos() {
    final usuario =
        _usuarios.firstWhere(
      (element) =>
          element.id ==
          _usuarioSeleccionadoId,
    );

    final datos = usuario.data();

    final nombre =
        datos['nombre']?.toString() ??
            'Usuario';

    final correo =
        datos['correo']?.toString() ??
            datos['email']?.toString() ??
            '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [

          // ====================================================================
          // USUARIO SELECCIONADO
          // ====================================================================

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _azulMarca
                  .withValues(
                alpha: 0.035,
              ),
              borderRadius:
                  const BorderRadius.only(
                topLeft:
                    Radius.circular(16),
                topRight:
                    Radius.circular(16),
              ),
            ),
            child: Row(
              children: [

                Container(
                  width: 45,
                  height: 45,
                  decoration:
                      BoxDecoration(
                    color: _azulClaro
                        .withValues(
                      alpha: 0.10,
                    ),
                    shape:
                        BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: _azulClaro,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [

                      Text(
                        nombre,
                        style:
                            const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight
                                  .w800,
                          color:
                              _azulMarca,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        correo,
                        maxLines: 1,
                        overflow:
                            TextOverflow
                                .ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ====================================================================
          // BOTONES RÁPIDOS
          // ====================================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              15,
              16,
              5,
            ),
            child: Row(
              children: [

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _activarTodos,
                    icon: const Icon(
                      Icons.done_all_rounded,
                      size: 17,
                    ),
                    label: const Text(
                      'Activar todos',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          _verde,
                      side:
                          BorderSide(
                        color: _verde
                            .withValues(
                          alpha: 0.35,
                        ),
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        _desactivarTodos,
                    icon: const Icon(
                      Icons
                          .remove_done_rounded,
                      size: 17,
                    ),
                    label: const Text(
                      'Desactivar todos',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          _rojo,
                      side:
                          BorderSide(
                        color: _rojo
                            .withValues(
                          alpha: 0.25,
                        ),
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          10,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ====================================================================
          // PERMISOS
          // ====================================================================

          Padding(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                _listaPermisos.length,
                (index) {

                  final permiso =
                      _listaPermisos[index];

                  final id =
                      permiso['id']
                          as String;

                  final nombrePermiso =
                      permiso['nombre']
                          as String;

                  final descripcion =
                      permiso['descripcion']
                          as String;

                  final icono =
                      permiso['icono']
                          as IconData;

                  final activo =
                      _permisos[id] ?? false;

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),
                    decoration:
                        BoxDecoration(
                      color: activo
                          ? _azulClaro
                              .withValues(
                              alpha: 0.045,
                            )
                          : _fondo,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                      border:
                          Border.all(
                        color: activo
                            ? _azulClaro
                                .withValues(
                                alpha: 0.18,
                              )
                            : Colors.grey
                                .withValues(
                                alpha: 0.15,
                              ),
                      ),
                    ),
                    child: SwitchListTile(
                      value: activo,
                      onChanged:
                          (valor) =>
                              _cambiarPermiso(
                        id,
                        valor,
                      ),
                      activeThumbColor:
                          _azulClaro,
                      contentPadding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                        vertical: 3,
                      ),
                      secondary:
                          Container(
                        width: 40,
                        height: 40,
                        decoration:
                            BoxDecoration(
                          color: activo
                              ? _azulClaro
                                  .withValues(
                                  alpha: 0.10,
                                )
                              : Colors.grey
                                  .withValues(
                                  alpha: 0.08,
                                ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        child: Icon(
                          icono,
                          color: activo
                              ? _azulClaro
                              : Colors.grey
                                  .shade600,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        nombrePermiso,
                        style:
                            const TextStyle(
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w700,
                          color:
                              _azulMarca,
                        ),
                      ),
                      subtitle: Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          top: 3,
                        ),
                        child: Text(
                          descripcion,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1.3,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // BOTÓN GUARDAR
  // ==========================================================================

  Widget _botonGuardar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _guardando
            ? null
            : _guardarPermisos,
        style:
            ElevatedButton.styleFrom(
          backgroundColor:
              _azulMarca,
          foregroundColor:
              Colors.white,
          disabledBackgroundColor:
              Colors.grey.shade300,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              14,
            ),
          ),
        ),
        child: _guardando
            ? const SizedBox(
                width: 23,
                height: 23,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color:
                      Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [

                  Icon(
                    Icons.save_rounded,
                    size: 21,
                  ),

                  SizedBox(width: 9),

                  Text(
                    'GUARDAR PERMISOS',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ==========================================================================
  // CUENTA ACTUAL
  // ==========================================================================

  Widget _cuentaActual() {
    final usuario =
        _auth.currentUser;

    final correo =
        usuario?.email ??
            'No disponible';

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(15),
        border: Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [

          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(
              color: _naranja
                  .withValues(
                alpha: 0.10,
              ),
              shape:
                  BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: _naranja,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                const Text(
                  'Administrador',
                  style:
                      TextStyle(
                    fontSize: 13,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        _azulMarca,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  correo,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors
                        .grey
                        .shade600,
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