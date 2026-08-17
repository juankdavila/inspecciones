import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'inspecciones.dart';
import 'administrador.dart';

class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _cargando = false;
  bool _ocultarPassword = true;

  String? _errorMensaje;

  // ============================================================
  // COLOR DE MARCA
  // ============================================================

  static const Color _azulMarca = Color(0xFF0D1B4C);

  // ============================================================
// INICIAR SESIÓN
// ============================================================

Future<void> _iniciarSesion() async {
  final usuario =
      _usuarioController.text.trim().toLowerCase();

  final password =
      _passwordController.text.trim();

  // ==========================================================
  // VALIDAR CAMPOS
  // ==========================================================

  if (usuario.isEmpty || password.isEmpty) {
    setState(() {
      _errorMensaje =
          'Completá usuario y contraseña';
    });
    return;
  }

  setState(() {
    _cargando = true;
    _errorMensaje = null;
  });

  // ==========================================================
  // CORREO INTERNO
  // ==========================================================

  final correoInterno =
      '$usuario@inspecciones.app';

  try {
    // ========================================================
    // 1. AUTENTICAR EN FIREBASE
    // ========================================================

    final credencial =
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
      email: correoInterno,
      password: password,
    );

    final usuarioFirebase =
        credencial.user;

    // ========================================================
    // SEGURIDAD
    // ========================================================

    if (usuarioFirebase == null) {
      throw Exception(
        'No se pudo obtener el usuario autenticado.',
      );
    }

    // ========================================================
    // 2. BUSCAR EL PERFIL EN FIRESTORE
    // ========================================================

    final documento =
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(usuarioFirebase.uid)
            .get();

    // ========================================================
    // 3. VERIFICAR QUE EXISTA EL PERFIL
    // ========================================================

    if (!documento.exists) {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        setState(() {
          _errorMensaje =
              'El usuario no tiene un perfil configurado.';
        });
      }

      return;
    }

    final datos =
        documento.data();

    // ========================================================
    // 4. OBTENER DATOS DEL USUARIO
    // ========================================================

    final rol =
    datos?['rol']?.toString().toLowerCase();

final activo =
    datos?['activo'] == true;


    // ========================================================
    // 5. VERIFICAR SI ESTÁ ACTIVO
    // ========================================================

    if (!activo) {
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        setState(() {
          _errorMensaje =
              'Este usuario está desactivado. '
              'Contactá al administrador.';
        });
      }

      return;
    }

    // ========================================================
    // 6. DETERMINAR A QUÉ PANTALLA ENTRA
    // ========================================================

    if (!mounted) return;

    if (rol == 'admin') {
      // ======================================================
      // ADMINISTRADOR
      // ======================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PantallaAdministrador(),
        ),
      );

    } else if (rol == 'inspector') {

      // ======================================================
      // INSPECTOR
      // ======================================================

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PantallaInspecciones(),
        ),
      );

    } else {

      // ======================================================
      // ROL DESCONOCIDO
      // ======================================================

      await FirebaseAuth.instance.signOut();

      setState(() {
        _errorMensaje =
            'El usuario tiene un rol no válido.';
      });
    }

  } on FirebaseAuthException catch (e) {

    // ========================================================
    // ERRORES DE FIREBASE AUTH
    // ========================================================

    if (mounted) {
      setState(() {

        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {

          _errorMensaje =
              'Usuario o contraseña incorrectos';

        } else if (e.code == 'invalid-email') {

          _errorMensaje =
              'El usuario ingresado no es válido.';

        } else if (e.code == 'user-disabled') {

          _errorMensaje =
              'Este usuario está deshabilitado.';

        } else {

          _errorMensaje =
              'Error: ${e.message}';
        }
      });
    }

  } on FirebaseException catch (e) {

    // ========================================================
    // ERROR DE FIRESTORE
    // ========================================================

    if (mounted) {
      setState(() {
        _errorMensaje =
            'No se pudo consultar el perfil del usuario.\n'
            '${e.message ?? ''}';
      });
    }

  } catch (e) {

    // ========================================================
    // ERROR GENERAL
    // ========================================================

    if (mounted) {
      setState(() {
        _errorMensaje =
            'Ocurrió un error inesperado.';
      });
    }

  } finally {

    // ========================================================
    // FINALIZAR CARGA
    // ========================================================

    if (mounted) {
      setState(() {
        _cargando = false;
      });
    }
  }
}

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F4F8),

      body: SafeArea(
        child: Column(
          children: [

            // ==================================================
            // CONTENIDO
            // ==================================================

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),

                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 400,
                    ),

                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [

                        // ========================================
                        // LOGO
                        // ========================================

                        Image.asset(
                          'assets/image/colprevi.png',
                          height: 210,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        // ========================================
                        // TÍTULO
                        // ========================================

                        const Text(
                          'Inspecciones',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight:
                                FontWeight.bold,
                            color: _azulMarca,
                            letterSpacing: 0.2,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          'Ingresá con tu usuario asignado',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                const Color.fromARGB(255, 91, 91, 91),
                          ),
                        ),

                        const SizedBox(
                          height: 32,
                        ),

                        // ========================================
                        // TARJETA DEL FORMULARIO
                        // ========================================

                        Container(
                          padding:
                              const EdgeInsets.all(
                            24,
                          ),

                          decoration:
                              BoxDecoration(
                            color: Colors.white,

                            borderRadius:
                                BorderRadius.circular(
                              18,
                            ),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(
                                  alpha: 0.06,
                                ),
                                blurRadius: 20,
                                offset:
                                    const Offset(
                                  0,
                                  8,
                                ),
                              ),
                            ],
                          ),

                          child: Column(
                            children: [

                              // ==================================
                              // USUARIO
                              // ==================================

                              TextField(
                                controller:
                                    _usuarioController,

                                keyboardType:
                                    TextInputType
                                        .text,

                                textInputAction:
                                    TextInputAction
                                        .next,

                                decoration:
                                    InputDecoration(
                                  labelText:
                                      'Usuario',

                                  hintText:
                                      'Ingresa tu usuario',

                                  prefixIcon:
                                      const Icon(
                                    Icons
                                        .person_outline_rounded,
                                  ),

                                  filled: true,

                                  fillColor:
                                      const Color(
                                    0xFFF7F7FA,
                                  ),

                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12,
                                    ),
                                    borderSide:
                                        BorderSide.none,
                                  ),

                                  enabledBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12,
                                    ),
                                    borderSide:
                                        BorderSide.none,
                                  ),

                                  focusedBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12,
                                    ),
                                    borderSide:
                                        const BorderSide(
                                      color:
                                          _azulMarca,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(
                                height: 16,
                              ),

                              // ==================================
                              // CONTRASEÑA
                              // ==================================

                              TextField(
                                controller:
                                    _passwordController,

                                obscureText:
                                    _ocultarPassword,

                                textInputAction:
                                    TextInputAction
                                        .done,

                                onSubmitted: (_) {
                                  if (!_cargando) {
                                    _iniciarSesion();
                                  }
                                },

                                decoration:
                                    InputDecoration(
                                  labelText:
                                      'Contraseña',

                                  hintText:
                                      'Ingresa tu contraseña',

                                  prefixIcon:
                                      const Icon(
                                    Icons
                                        .lock_outline_rounded,
                                  ),

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

                                  filled: true,

                                  fillColor:
                                      const Color(
                                    0xFFF7F7FA,
                                  ),

                                  border:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12,
                                    ),
                                    borderSide:
                                        BorderSide.none,
                                  ),

                                  enabledBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12,
                                    ),
                                    borderSide:
                                        BorderSide.none,
                                  ),

                                  focusedBorder:
                                      OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12,
                                    ),
                                    borderSide:
                                        const BorderSide(
                                      color:
                                          _azulMarca,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),

                              // ==================================
                              // MENSAJE DE ERROR
                              // ==================================

                              if (_errorMensaje !=
                                  null) ...[
                                const SizedBox(
                                  height: 16,
                                ),

                                Container(
                                  width:
                                      double.infinity,

                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    vertical: 10,
                                    horizontal: 12,
                                  ),

                                  decoration:
                                      BoxDecoration(
                                    color: Colors
                                        .red.shade50,

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      10,
                                    ),

                                    border:
                                        Border.all(
                                      color: Colors
                                          .red.shade100,
                                    ),
                                  ),

                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Icon(
                                        Icons
                                            .error_outline_rounded,
                                        color: Colors
                                            .red.shade700,
                                        size: 20,
                                      ),

                                      const SizedBox(
                                        width: 8,
                                      ),

                                      Expanded(
                                        child: Text(
                                          _errorMensaje!,
                                          style:
                                              TextStyle(
                                            color: Colors
                                                .red
                                                .shade700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(
                                height: 24,
                              ),

                              // ==================================
                              // BOTÓN INGRESAR
                              // ==================================

                              SizedBox(
                                width:
                                    double.infinity,

                                height: 52,

                                child:
                                    ElevatedButton(
                                  onPressed:
                                      _cargando
                                          ? null
                                          : _iniciarSesion,

                                  style:
                                      ElevatedButton
                                          .styleFrom(
                                    backgroundColor:
                                        _azulMarca,

                                    foregroundColor:
                                        Colors.white,

                                    disabledBackgroundColor:
                                        _azulMarca
                                            .withValues(
                                      alpha: 0.65,
                                    ),

                                    elevation: 0,

                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        12,
                                      ),
                                    ),
                                  ),

                                  child: _cargando
                                      ? const SizedBox(
                                          height: 21,
                                          width: 21,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2.2,
                                            color:
                                                Colors.white,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                          children: [
                                            SizedBox(
                                              width: 8,
                                            ),

                                            Text(
                                              'Ingresar',
                                              style:
                                                  TextStyle(
                                                fontSize:
                                                    16,
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

            // ==================================================
            // FOOTER
            // ==================================================

            Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 18,
              ),

              child: Column(
                children: [

                  Container(
                    width: 35,
                    height: 2,

                    decoration:
                        BoxDecoration(
                      color: _azulMarca
                          .withValues(
                        alpha: 0.15,
                      ),

                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'Colprevi 2026',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          Colors.grey.shade500,
                      fontWeight:
                          FontWeight.w500,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}