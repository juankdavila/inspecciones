import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'nuevo_inspector.dart';

class GestionInspectores extends StatelessWidget {
  const GestionInspectores({
    super.key,
  });

  static const Color _azulMarca = Color(0xFF0D1B4C);
  static const Color _azulClaro = Color(0xFF1D4ED8);
  static const Color _fondo = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _azulMarca,

        title: const Row(
          children: [
            Icon(
              Icons.people_alt_rounded,
              color: _azulMarca,
              size: 25,
            ),

            SizedBox(width: 10),

            Text(
              'Inspectores',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _azulMarca,
              ),
            ),
          ],
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Nuevo inspector',

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NuevoInspector(),
                  ),
                );
              },

              icon: const Icon(
                Icons.person_add_alt_1_rounded,
                color: _azulMarca,
              ),
            ),
          ),
        ],
      ),

      // ============================================================
      // CONTENIDO
      // ============================================================

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .where(
              'rol',
              isEqualTo: 'inspector',
            )
            .snapshots(),

        builder: (
          context,
          snapshot,
        ) {
          // ========================================================
          // CARGANDO
          // ========================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: _azulMarca,
              ),
            );
          }

          // ========================================================
          // ERROR
          // ========================================================

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 50,
                      color: Colors.red.shade400,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'No se pudieron cargar los inspectores',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

          final inspectores =
              snapshot.data?.docs ?? [];

          // ========================================================
          // SIN INSPECTORES
          // ========================================================

          if (inspectores.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(25),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Container(
                      width: 80,
                      height: 80,

                      decoration: BoxDecoration(
                        color: _azulClaro.withValues(
                          alpha: 0.08,
                        ),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.people_outline_rounded,
                        size: 40,
                        color: _azulClaro,
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'No hay inspectores registrados',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _azulMarca,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'Cuando registres un inspector '
                      'aparecerá aquí.',

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

          // ========================================================
          // LISTA
          // ========================================================

          return ListView(
            padding: const EdgeInsets.all(20),

            children: [
              // ====================================================
              // ENCABEZADO
              // ====================================================

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

                  borderRadius:
                      BorderRadius.circular(18),

                  boxShadow: [
                    BoxShadow(
                      color: _azulMarca.withValues(
                        alpha: 0.16,
                      ),
                      blurRadius: 18,
                      offset:
                          const Offset(0, 7),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,

                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.15,
                        ),
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Gestión de Inspectores',

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            '${inspectores.length} '
                            '${inspectores.length == 1 ? 'inspector registrado' : 'inspectores registrados'}',

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

              // ====================================================
              // TÍTULO
              // ====================================================

              const Text(
                'Inspectores registrados',

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _azulMarca,
                ),
              ),

              const SizedBox(height: 14),

              // ====================================================
              // TARJETAS
              // ====================================================

              ...inspectores.map(
                (documento) {
                  final datos =
                      documento.data();

                  final nombre =
                      datos['nombre']
                              ?.toString()
                              .trim()
                              .isNotEmpty ==
                          true
                      ? datos['nombre']
                          .toString()
                      : 'Sin nombre';

                  final usuario =
                      datos['usuario']
                              ?.toString()
                              .trim()
                              .isNotEmpty ==
                          true
                      ? datos['usuario']
                          .toString()
                      : 'Sin usuario';

                  final activo =
                      datos['activo'] == true;

                  return _TarjetaInspector(
                    uid: documento.id,
                    nombre: nombre,
                    usuario: usuario,
                    activo: activo,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ==================================================================
// TARJETA DEL INSPECTOR
// ==================================================================

class _TarjetaInspector extends StatelessWidget {
  final String uid;
  final String nombre;
  final String usuario;
  final bool activo;

  const _TarjetaInspector({
    required this.uid,
    required this.nombre,
    required this.usuario,
    required this.activo,
  });

  static const Color _azulMarca =
      Color(0xFF0D1B4C);

  // ==============================================================
  // CAMBIAR ESTADO
  // ==============================================================

  Future<void> _cambiarEstado(
    BuildContext context,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .update({
        'activo': !activo,
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            activo
                ? 'Inspector desactivado correctamente.'
                : 'Inspector activado correctamente.',
          ),

          backgroundColor:
              activo
                  ? Colors.orange.shade700
                  : Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo cambiar el estado:\n$e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==============================================================
  // EDITAR INSPECTOR
  // ==============================================================

  Future<void> _editarInspector(
    BuildContext context,
  ) async {
    final nombreController =
        TextEditingController(
      text: nombre,
    );

    final usuarioController =
        TextEditingController(
      text: usuario,
    );

    final formKey =
        GlobalKey<FormState>();

    try {
      final resultado =
          await showDialog<bool>(
        context: context,

        barrierDismissible: false,

        builder: (dialogContext) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  color: _azulMarca,
                ),

                SizedBox(width: 10),

                Text(
                  'Editar inspector',
                ),
              ],
            ),

            content: Form(
              key: formKey,

              child: Column(
                mainAxisSize:
                    MainAxisSize.min,

                children: [
                  // ==================================================
                  // NOMBRE
                  // ==================================================

                  TextFormField(
                    controller:
                        nombreController,

                    textCapitalization:
                        TextCapitalization.words,

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Nombre completo',

                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                      ),

                      border:
                          OutlineInputBorder(),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Ingresa el nombre';
                      }

                      if (value.trim().length <
                          3) {
                        return 'Nombre demasiado corto';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // USUARIO
                  // ==================================================

                  TextFormField(
                    controller:
                        usuarioController,

                    decoration:
                        const InputDecoration(
                      labelText:
                          'Usuario',

                      prefixIcon: Icon(
                        Icons.account_circle_outlined,
                      ),

                      border:
                          OutlineInputBorder(),
                    ),

                    validator: (value) {
                      final texto =
                          value?.trim() ?? '';

                      if (texto.isEmpty) {
                        return 'Ingresa el usuario';
                      }

                      if (texto.length < 3) {
                        return 'Mínimo 3 caracteres';
                      }

                      if (texto.contains(' ')) {
                        return 'No puede contener espacios';
                      }

                      return null;
                    },
                  ),
                ],
              ),
            ),

            actions: [
              // ====================================================
              // CANCELAR
              // ====================================================

              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },

                child: const Text(
                  'Cancelar',
                ),
              ),

              // ====================================================
              // GUARDAR
              // ====================================================

              ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      _azulMarca,
                  foregroundColor:
                      Colors.white,
                ),

                onPressed: () async {
                  if (!formKey
                      .currentState!
                      .validate()) {
                    return;
                  }

                  final nuevoNombre =
                      nombreController
                          .text
                          .trim();

                  final nuevoUsuario =
                      usuarioController
                          .text
                          .trim()
                          .toLowerCase();

                  try {
                    // ==============================================
                    // VERIFICAR USUARIO
                    // ==============================================

                    if (nuevoUsuario !=
                        usuario.toLowerCase()) {
                      final existente =
                          await FirebaseFirestore
                              .instance
                              .collection(
                                'usuarios',
                              )
                              .where(
                                'usuario',
                                isEqualTo:
                                    nuevoUsuario,
                              )
                              .limit(1)
                              .get();

                      if (existente
                          .docs
                          .isNotEmpty) {
                        final otroUid =
                            existente
                                .docs
                                .first
                                .id;

                        if (otroUid != uid) {
                          if (!dialogContext
                              .mounted) {
                            return;
                          }

                          ScaffoldMessenger
                              .of(
                            dialogContext,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ese usuario ya está registrado.',
                              ),
                              backgroundColor:
                                  Colors.red,
                            ),
                          );

                          return;
                        }
                      }
                    }

                    // ==============================================
                    // ACTUALIZAR
                    // ==============================================

                    await FirebaseFirestore
                        .instance
                        .collection(
                          'usuarios',
                        )
                        .doc(uid)
                        .update({
                      'nombre':
                          nuevoNombre,
                      'usuario':
                          nuevoUsuario,
                    });

                    if (!dialogContext
                        .mounted) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  } catch (e) {
                    if (!dialogContext
                        .mounted) {
                      return;
                    }

                    ScaffoldMessenger
                        .of(
                      dialogContext,
                    ).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al actualizar:\n$e',
                        ),
                        backgroundColor:
                            Colors.red,
                      ),
                    );
                  }
                },

                child: const Text(
                  'Guardar',
                ),
              ),
            ],
          );
        },
      );

      if (!context.mounted) return;

      if (resultado == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Inspector actualizado correctamente.',
            ),
            backgroundColor:
                Colors.green,
          ),
        );
      }
    } finally {
      nombreController.dispose();
      usuarioController.dispose();
    }
  }

  // ==============================================================
  // ELIMINAR INSPECTOR
  // ==============================================================

  Future<void> _eliminarInspector(
    BuildContext context,
  ) async {
    final confirmar =
        await showDialog<bool>(
      context: context,

      barrierDismissible: false,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
              ),

              SizedBox(width: 10),

              Text(
                'Eliminar inspector',
              ),
            ],
          ),

          content: Text(
            '¿Estás seguro de que deseas eliminar a '
            '"$nombre"?\n\n'
            'Se eliminará su registro de Firestore.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },

              child: const Text(
                'Cancelar',
              ),
            ),

            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),

              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              child: const Text(
                'Eliminar',
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      // ==========================================================
      // ELIMINAR DOCUMENTO DE FIRESTORE
      // ==========================================================

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .delete();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Inspector eliminado correctamente.',
          ),
          backgroundColor:
              Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo eliminar el inspector:\n$e',
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  // ==============================================================
  // MOSTRAR OPCIONES
  // ==============================================================

  Future<void> _mostrarOpciones(
    BuildContext context,
  ) async {
    final opcion =
        await showModalBottomSheet<String>(
      context: context,

      backgroundColor:
          Colors.white,

      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),

      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              vertical: 10,
            ),

            child: Column(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                // ==================================================
                // INDICADOR
                // ==================================================

                Container(
                  width: 40,
                  height: 4,

                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        Colors.grey.shade300,

                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                // ==================================================
                // INFORMACIÓN
                // ==================================================

                ListTile(
                  leading:
                      const Icon(
                    Icons.person_rounded,
                    color: _azulMarca,
                  ),

                  title: Text(
                    nombre,

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w700,
                      color: _azulMarca,
                    ),
                  ),

                  subtitle:
                      Text('@$usuario'),
                ),

                const Divider(),

                // ==================================================
                // EDITAR
                // ==================================================

                ListTile(
                  leading:
                      const Icon(
                    Icons.edit_outlined,
                    color: _azulMarca,
                  ),

                  title:
                      const Text(
                    'Editar inspector',
                  ),

                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      'editar',
                    );
                  },
                ),

                // ==================================================
                // ACTIVAR / DESACTIVAR
                // ==================================================

                ListTile(
                  leading: Icon(
                    activo
                        ? Icons
                            .toggle_off_outlined
                        : Icons
                            .toggle_on_outlined,

                    color: activo
                        ? Colors.orange
                            .shade700
                        : Colors.green
                            .shade700,
                  ),

                  title: Text(
                    activo
                        ? 'Desactivar inspector'
                        : 'Activar inspector',
                  ),

                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      'estado',
                    );
                  },
                ),

                // ==================================================
                // ELIMINAR
                // ==================================================

                ListTile(
                  leading: Icon(
                    Icons
                        .delete_outline_rounded,
                    color:
                        Colors.red.shade700,
                  ),

                  title: Text(
                    'Eliminar inspector',

                    style: TextStyle(
                      color:
                          Colors.red.shade700,
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      'eliminar',
                    );
                  },
                ),

                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!context.mounted ||
        opcion == null) {
      return;
    }

    // ============================================================
    // IMPORTANTE:
    // ESPERAR A QUE EL BOTTOM SHEET TERMINE DE CERRARSE
    // ============================================================

    await Future.delayed(
      const Duration(
        milliseconds: 200,
      ),
    );

    if (!context.mounted) {
      return;
    }

    // ============================================================
    // EJECUTAR OPCIÓN
    // ============================================================

    switch (opcion) {
      case 'editar':
        await _editarInspector(
          context,
        );
        break;

      case 'estado':
        await _cambiarEstado(
          context,
        );
        break;

      case 'eliminar':
        await _eliminarInspector(
          context,
        );
        break;
    }
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),

      padding:
          const EdgeInsets.all(16),

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color:
              Colors.grey.shade200,
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
          // ========================================================
          // AVATAR
          // ========================================================

          Container(
            width: 52,
            height: 52,

            decoration:
                BoxDecoration(
              color:
                  _azulMarca.withValues(
                alpha: 0.08,
              ),

              shape:
                  BoxShape.circle,
            ),

            child:
                const Icon(
              Icons.person_rounded,
              color:
                  _azulMarca,
              size: 28,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          // ========================================================
          // INFORMACIÓN
          // ========================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  nombre,

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style:
                      const TextStyle(
                    fontSize: 15,
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
                  'Usuario: $usuario',

                  maxLines: 1,

                  overflow:
                      TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                // ==================================================
                // ESTADO
                // ==================================================

                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,

                      decoration:
                          BoxDecoration(
                        color: activo
                            ? Colors.green
                            : Colors.red,

                        shape:
                            BoxShape.circle,
                      ),
                    ),

                    const SizedBox(
                      width: 6,
                    ),

                    Text(
                      activo
                          ? 'Activo'
                          : 'Inactivo',

                      style:
                          TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,

                        color: activo
                            ? Colors.green
                                .shade700
                            : Colors.red
                                .shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ========================================================
          // MENÚ
          // ========================================================

          IconButton(
            tooltip:
                'Opciones',

            onPressed: () {
              _mostrarOpciones(
                context,
              );
            },

            icon: Icon(
              Icons.more_vert_rounded,
              color:
                  Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}