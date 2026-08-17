import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'login.dart';
import 'inspecciones.dart';
import 'administrador.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inspecciones',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      home: const DecisorDeInicio(),
    );
  }
}

// ============================================================
// DECIDIR PANTALLA INICIAL
// ============================================================

class DecisorDeInicio extends StatelessWidget {
  const DecisorDeInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),

      builder: (context, snapshot) {
        // ======================================================
        // ESPERANDO ESTADO DE FIREBASE
        // ======================================================

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ======================================================
        // NO HAY USUARIO AUTENTICADO
        // ======================================================

        if (!snapshot.hasData) {
          return const PantallaLogin();
        }

        // ======================================================
        // USUARIO AUTENTICADO
        // ======================================================

        final usuario = snapshot.data!;

        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection('usuarios')
              .doc(usuario.uid)
              .get(),

          builder: (context, perfilSnapshot) {
            // ==================================================
            // ESPERANDO PERFIL
            // ==================================================

            if (perfilSnapshot.connectionState ==
                ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // ==================================================
            // ERROR AL CONSULTAR FIRESTORE
            // ==================================================

            if (perfilSnapshot.hasError) {
              return const Scaffold(
                body: Center(
                  child: Text(
                    'No se pudo cargar el perfil del usuario.',
                  ),
                ),
              );
            }

            // ==================================================
            // PERFIL NO EXISTE
            // ==================================================

            if (!perfilSnapshot.hasData ||
                !perfilSnapshot.data!.exists) {
              FirebaseAuth.instance.signOut();

              return const PantallaLogin();
            }

            // ==================================================
            // OBTENER DATOS
            // ==================================================

            final datos = perfilSnapshot.data!.data();

            final rol = datos?['rol']
                ?.toString()
                .toLowerCase();

            final activo = datos?['activo'] == true;

            // ==================================================
            // USUARIO DESACTIVADO
            // ==================================================

            if (!activo) {
              FirebaseAuth.instance.signOut();

              return const PantallaLogin();
            }

            // ==================================================
            // ADMINISTRADOR
            // ==================================================

            if (rol == 'admin') {
              return const PantallaAdministrador();
            }

            // ==================================================
            // INSPECTOR
            // ==================================================

            if (rol == 'inspector') {
              return const PantallaInspecciones();
            }

            // ==================================================
            // ROL NO VÁLIDO
            // ==================================================

            FirebaseAuth.instance.signOut();

            return const PantallaLogin();
          },
        );
      },
    );
  }
}