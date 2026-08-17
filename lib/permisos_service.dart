import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PermisosService {
  // ==========================================================================
  // FIREBASE
  // ==========================================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ==========================================================================
  // PERMISOS DEL USUARIO
  // ==========================================================================

  Map<String, bool> _permisos = {};

  bool _cargados = false;

  // ==========================================================================
  // CARGAR PERMISOS DEL USUARIO ACTUAL
  // ==========================================================================

  Future<void> cargarPermisos() async {
    final usuario = _auth.currentUser;

    if (usuario == null) {
      _permisos = {};
      _cargados = true;
      return;
    }

    try {
      final documento = await _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .get();

      if (!documento.exists) {
        _permisos = {};
        _cargados = true;
        return;
      }

      final datos = documento.data();

      if (datos == null) {
        _permisos = {};
        _cargados = true;
        return;
      }

      final permisosGuardados =
          datos['permisos'] as Map<String, dynamic>?;

      _permisos = {};

      if (permisosGuardados != null) {
        permisosGuardados.forEach((clave, valor) {
          _permisos[clave] = valor == true;
        });
      }

      _cargados = true;
    } catch (e) {
      _permisos = {};
      _cargados = true;

      rethrow;
    }
  }

  // ==========================================================================
  // VERIFICAR PERMISO
  // ==========================================================================

  bool tienePermiso(String permiso) {
    return _permisos[permiso] == true;
  }

  // ==========================================================================
  // OBTENER TODOS LOS PERMISOS
  // ==========================================================================

  Map<String, bool> get permisos {
    return Map.unmodifiable(_permisos);
  }

  // ==========================================================================
  // SABER SI LOS PERMISOS YA FUERON CARGADOS
  // ==========================================================================

  bool get cargados => _cargados;

  // ==========================================================================
  // LIMPIAR PERMISOS
  // ==========================================================================

  void limpiar() {
    _permisos = {};
    _cargados = false;
  }

  // ==========================================================================
  // PERMISOS ESPECÍFICOS
  // ==========================================================================

  bool get puedeVerInspecciones =>
      tienePermiso('verInspecciones');

  bool get puedeCrearInspecciones =>
      tienePermiso('crearInspecciones');

  bool get puedeEditarInspecciones =>
      tienePermiso('editarInspecciones');

  bool get puedeGenerarReportes =>
      tienePermiso('generarReportes');

  bool get puedeEnviarInformacion =>
      tienePermiso('enviarInformacion');

  bool get puedeGestionarUsuarios =>
      tienePermiso('gestionarUsuarios');

  bool get puedeAccederConfiguracion =>
      tienePermiso('configuracion');

  bool get puedeEliminar =>
      tienePermiso('eliminar');
}