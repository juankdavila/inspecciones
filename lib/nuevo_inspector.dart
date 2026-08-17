import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

class NuevoInspector extends StatefulWidget {
  const NuevoInspector({super.key});

  @override
  State<NuevoInspector> createState() => _NuevoInspectorState();
}

class _NuevoInspectorState extends State<NuevoInspector> {
  // ============================================================
  // COLORES
  // ============================================================

  static const Color _azulMarca = Color(0xFF0D1B4C);
  static const Color _azulClaro = Color(0xFF1D4ED8);
  static const Color _fondo = Color(0xFFF5F7FB);

  // ============================================================
  // CONTROLADORES
  // ============================================================

  final _nombreController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();

  // ============================================================
  // VARIABLES
  // ============================================================

  bool _ocultarPassword = true;
  bool _ocultarConfirmacion = true;
  bool _cargando = false;

  bool _activo = true;

  static const String _rol = 'inspector';

  // ============================================================
  // FORMULARIO
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  // ============================================================
  // CREAR INSPECTOR
  // ============================================================

  Future<void> _crearInspector() async {
  FocusScope.of(context).unfocus();

  if (!_formKey.currentState!.validate()) {
    return;
  }

  setState(() {
    _cargando = true;
  });

  FirebaseApp? appSecundaria;

  try {
    final nombre = _nombreController.text.trim();
    final usuario = _usuarioController.text.trim().toLowerCase();
    final password = _passwordController.text;

    // ==========================================================
    // CORREO INTERNO PARA FIREBASE AUTH
    // ==========================================================

    final correoInterno =
        '$usuario@inspecciones.app';

    // ==========================================================
    // VERIFICAR QUE EL USUARIO NO EXISTA EN FIRESTORE
    // ==========================================================

    final existente = await FirebaseFirestore.instance
        .collection('usuarios')
        .where(
          'usuario',
          isEqualTo: usuario,
        )
        .limit(1)
        .get();

    if (existente.docs.isNotEmpty) {
      throw Exception(
        'Ese usuario ya está registrado.',
      );
    }

    // ==========================================================
    // CREAR UNA SEGUNDA INSTANCIA DE FIREBASE
    //
    // IMPORTANTE:
    // Esto permite crear al inspector sin cerrar
    // la sesión del administrador.
    // ==========================================================

    appSecundaria = await Firebase.initializeApp(
      name: 'crearInspector',
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final authSecundario =
        FirebaseAuth.instanceFor(
      app: appSecundaria,
    );

    // ==========================================================
    // CREAR USUARIO EN FIREBASE AUTHENTICATION
    // ==========================================================

    final credencial =
        await authSecundario
            .createUserWithEmailAndPassword(
      email: correoInterno,
      password: password,
    );

    final nuevoUsuario = credencial.user;

    if (nuevoUsuario == null) {
      throw Exception(
        'No se pudo crear el usuario en Authentication.',
      );
    }

    final uid = nuevoUsuario.uid;

    // ==========================================================
    // GUARDAR PERFIL EN FIRESTORE
    // ==========================================================

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .set({
        'uid': uid,
        'nombre': nombre,
        'usuario': usuario,
        'activo': _activo,
        'rol': _rol,
        'creadoEn': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // ========================================================
      // SI FIRESTORE FALLA, ELIMINAMOS EL AUTH
      // PARA NO DEJAR UN USUARIO INCOMPLETO.
      // ========================================================

      await authSecundario.currentUser?.delete();

      rethrow;
    }

    // ==========================================================
    // CERRAR SESIÓN DE LA INSTANCIA SECUNDARIA
    // ==========================================================

    await authSecundario.signOut();

    // ==========================================================
    // ELIMINAR LA INSTANCIA SECUNDARIA
    // ==========================================================

    await appSecundaria.delete();
    appSecundaria = null;

    if (!mounted) return;

    setState(() {
      _cargando = false;
    });

    // ==========================================================
    // MENSAJE DE ÉXITO
    // ==========================================================

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Inspector creado correctamente.',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // ==========================================================
    // REGRESAR
    // ==========================================================

    Navigator.pop(context);

  } on FirebaseAuthException catch (e) {
    if (!mounted) return;

    String mensaje;

    switch (e.code) {
      case 'email-already-in-use':
        mensaje =
            'Ese usuario ya está registrado.';
        break;

      case 'invalid-email':
        mensaje =
            'El usuario ingresado no es válido.';
        break;

      case 'weak-password':
        mensaje =
            'La contraseña es demasiado débil.';
        break;

      case 'operation-not-allowed':
        mensaje =
            'El inicio de sesión con correo y contraseña '
            'no está habilitado en Firebase.';
        break;

      default:
        mensaje =
            e.message ??
            'No se pudo crear el usuario.';
    }

    setState(() {
      _cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
      ),
    );

  } on FirebaseException catch (e) {
    if (!mounted) return;

    setState(() {
      _cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.message ??
              'No se pudo guardar el inspector.',
        ),
        backgroundColor: Colors.red,
      ),
    );

  } catch (e) {
    if (!mounted) return;

    setState(() {
      _cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceFirst(
            'Exception: ',
            '',
          ),
        ),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    // ==========================================================
    // POR SEGURIDAD, SI QUEDÓ UNA INSTANCIA ABIERTA,
    // LA ELIMINAMOS.
    // ==========================================================

    if (appSecundaria != null) {
      try {
        await appSecundaria.delete();
      } catch (_) {}
    }
  }
}

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nombreController.dispose();
    _usuarioController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _azulMarca,

        title: const Row(
          children: [
            Icon(
              Icons.person_add_alt_1_rounded,
              color: _azulMarca,
              size: 25,
            ),

            SizedBox(width: 10),

            Text(
              'Nuevo Inspector',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _azulMarca,
              ),
            ),
          ],
        ),
      ),

      // ==========================================================
      // CONTENIDO
      // ==========================================================

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // ENCABEZADO
                  // ==================================================

                  Container(
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

                      borderRadius:
                          BorderRadius.circular(20),

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

                    child: const Row(
                      children: [
                        Icon(
                          Icons.person_add_alt_1_rounded,
                          color: Colors.white,
                          size: 42,
                        ),

                        SizedBox(width: 15),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registrar inspector',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),

                              SizedBox(height: 5),

                              Text(
                                'Ingresa los datos del nuevo inspector.',
                                style: TextStyle(
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

                  // ==================================================
                  // TARJETA
                  // ==================================================

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius:
                          BorderRadius.circular(18),

                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.035,
                          ),
                          blurRadius: 12,
                          offset:
                              const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        // ==========================================
                        // NOMBRE
                        // ==========================================

                        TextFormField(
                          controller:
                              _nombreController,

                          textCapitalization:
                              TextCapitalization.words,

                          decoration: _decoracion(
                            label:
                                'Nombre completo',
                            hint:
                                'Ej. Juan Pérez',
                            icon:
                                Icons.person_outline_rounded,
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Ingresa el nombre del inspector';
                            }

                            if (value.trim().length < 3) {
                              return 'El nombre es demasiado corto';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 17),

                        // ==========================================
                        // USUARIO
                        // ==========================================

                        TextFormField(
                          controller:
                              _usuarioController,

                          keyboardType:
                              TextInputType.text,

                          decoration: _decoracion(
                            label: 'Usuario',
                            hint: 'Ej. jperez',
                            icon: Icons
                                .account_circle_outlined,
                          ),

                          validator: (value) {
                            final usuario =
                                value?.trim() ?? '';

                            if (usuario.isEmpty) {
                              return 'Ingresa el usuario';
                            }

                            if (usuario.length < 3) {
                              return 'El usuario debe tener al menos 3 caracteres';
                            }

                            if (usuario.contains(' ')) {
                              return 'El usuario no puede contener espacios';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 17),

                        // ==========================================
                        // CONTRASEÑA
                        // ==========================================

                        TextFormField(
                          controller:
                              _passwordController,

                          obscureText:
                              _ocultarPassword,

                          decoration: _decoracion(
                            label: 'Contraseña',
                            hint:
                                'Ingresa una contraseña',
                            icon: Icons
                                .lock_outline_rounded,

                            suffixIcon:
                                IconButton(
                              tooltip:
                                  _ocultarPassword
                                      ? 'Mostrar contraseña'
                                      : 'Ocultar contraseña',

                              icon: Icon(
                                _ocultarPassword
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,
                              ),

                              onPressed: () {
                                setState(() {
                                  _ocultarPassword =
                                      !_ocultarPassword;
                                });
                              },
                            ),
                          ),

                          validator: (value) {
                            final password =
                                value ?? '';

                            if (password.isEmpty) {
                              return 'Ingresa una contraseña';
                            }

                            if (password.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 17),

                        // ==========================================
                        // CONFIRMAR CONTRASEÑA
                        // ==========================================

                        TextFormField(
                          controller:
                              _confirmarPasswordController,

                          obscureText:
                              _ocultarConfirmacion,

                          decoration: _decoracion(
                            label:
                                'Confirmar contraseña',
                            hint:
                                'Repite la contraseña',
                            icon: Icons
                                .lock_reset_rounded,

                            suffixIcon:
                                IconButton(
                              tooltip:
                                  _ocultarConfirmacion
                                      ? 'Mostrar contraseña'
                                      : 'Ocultar contraseña',

                              icon: Icon(
                                _ocultarConfirmacion
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,
                              ),

                              onPressed: () {
                                setState(() {
                                  _ocultarConfirmacion =
                                      !_ocultarConfirmacion;
                                });
                              },
                            ),
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Confirma la contraseña';
                            }

                            if (value !=
                                _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // ==========================================
                        // ESTADO
                        // ==========================================

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFF7F7FA),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),

                          child: SwitchListTile(
                            contentPadding:
                                EdgeInsets.zero,

                            title: const Text(
                              'Estado',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                                color: _azulMarca,
                              ),
                            ),

                            subtitle: Text(
                              _activo
                                  ? 'Inspector activo'
                                  : 'Inspector inactivo',
                              style: TextStyle(
                                fontSize: 12,
                                color: _activo
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),

                            secondary: Icon(
                              _activo
                                  ? Icons
                                      .check_circle_outline_rounded
                                  : Icons
                                      .cancel_outlined,
                              color: _activo
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),

                            value: _activo,

                            onChanged: (value) {
                              setState(() {
                                _activo = value;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 17),

                        // ==========================================
                        // ROL
                        // ==========================================

                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 14,
                          ),

                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFF7F7FA),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),

                          child: Row(
                            children: [
                              const Icon(
                                Icons
                                    .admin_panel_settings_outlined,
                                color: _azulMarca,
                              ),

                              const SizedBox(width: 12),

                              const Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Rol',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            Colors.grey,
                                      ),
                                    ),

                                    SizedBox(height: 3),

                                    Text(
                                      'Inspector',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                            FontWeight.w600,
                                        color:
                                            _azulMarca,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),

                                decoration: BoxDecoration(
                                  color: _azulClaro
                                      .withValues(
                                    alpha: 0.10,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                child: const Text(
                                  'INSPECTOR',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight:
                                        FontWeight.w700,
                                    color: _azulClaro,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ==========================================
                        // BOTÓN
                        // ==========================================

                        SizedBox(
                          width: double.infinity,
                          height: 52,

                          child: ElevatedButton(
                            onPressed:
                                _cargando
                                    ? null
                                    : _crearInspector,

                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  _azulMarca,

                              foregroundColor:
                                  Colors.white,

                              disabledBackgroundColor:
                                  _azulMarca.withValues(
                                alpha: 0.65,
                              ),

                              elevation: 0,

                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),
                            ),

                            child: _cargando
                                ? const SizedBox(
                                    width: 21,
                                    height: 21,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2.2,
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
                                        Icons
                                            .person_add_alt_1_rounded,
                                        size: 20,
                                      ),

                                      SizedBox(width: 8),

                                      Text(
                                        'Crear inspector',
                                        style:
                                            TextStyle(
                                          fontSize: 16,
                                          fontWeight:
                                              FontWeight
                                                  .w600,
                                        ),
                                      ),
                                    ],
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
        ),
      ),
    );
  }

  // ============================================================
  // DECORACIÓN
  // ============================================================

  InputDecoration _decoracion({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,

      prefixIcon: Icon(icon),

      suffixIcon: suffixIcon,

      filled: true,

      fillColor: const Color(0xFFF7F7FA),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _azulMarca,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.red.shade300,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.red.shade400,
          width: 1.5,
        ),
      ),
    );
  }
}