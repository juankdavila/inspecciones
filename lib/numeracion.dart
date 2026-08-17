import 'package:cloud_firestore/cloud_firestore.dart';

/// Genera un número correlativo único y corto para cada inspección,
/// usando un contador guardado en Firestore (colección "contadores").
class Numeracion {
  /// Reserva y devuelve el próximo número, gastándolo del contador.
  /// Usar solo cuando la inspección se guarda de verdad.
  static Future<String> generarNumeroInspeccion() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final contadorRef =
          firestore.collection('contadores').doc('inspecciones');

      final nuevoNumero =
          await firestore.runTransaction<int>((transaccion) async {
        final snapshot = await transaccion.get(contadorRef);

        int actual = 0;
        if (snapshot.exists) {
          actual = (snapshot.data()?['ultimoNumero'] ?? 0) as int;
        }

        final siguiente = actual + 1;

        transaccion.set(contadorRef, {'ultimoNumero': siguiente});

        return siguiente;
      });

      return nuevoNumero.toString().padLeft(6, '0');
    } catch (e) {
      // ignore: avoid_print
      print('ERROR AL GENERAR NÚMERO: $e');
      rethrow;
    }
  }

  /// Solo consulta cuál sería el próximo número, SIN gastarlo del contador.
  /// Usar para mostrarlo como referencia mientras se completa el formulario.
  static Future<String> verProximoNumero() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final contadorRef =
          firestore.collection('contadores').doc('inspecciones');

      final snapshot = await contadorRef.get();
      int actual = 0;
      if (snapshot.exists) {
        actual = (snapshot.data()?['ultimoNumero'] ?? 0) as int;
      }

      final siguiente = actual + 1;
      return siguiente.toString().padLeft(6, '0');
    } catch (e) {
      // ignore: avoid_print
      print('ERROR AL VER PRÓXIMO NÚMERO: $e');
      rethrow;
    }
  }
}