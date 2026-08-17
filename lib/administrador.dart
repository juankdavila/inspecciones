import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'gestion_inspectores.dart';
import 'inspecciones_admin.dart';
import 'config.dart';

class PantallaAdministrador extends StatelessWidget {
  const PantallaAdministrador({
    super.key,
  });

  static const Color _azulMarca = Color(0xFF0D1B4C);
  static const Color _azulClaro = Color(0xFF1D4ED8);
  static const Color _fondo = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _fondo,

      // ======================================================
      // APP BAR
      // ======================================================

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: _azulMarca,

        title: const Row(
          children: [
            Icon(
              Icons.admin_panel_settings_rounded,
              size: 26,
              color: _azulMarca,
            ),

            SizedBox(width: 10),

            Text(
              'Panel de Administración',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _azulMarca,
              ),
            ),
          ],
        ),

        // ====================================================
        // CERRAR SESIÓN
        // ====================================================

        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',

            icon: const Icon(
              Icons.logout_rounded,
              color: _azulMarca,
            ),

            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),

          const SizedBox(width: 8),
        ],
      ),

      // ======================================================
      // CONTENIDO
      // ======================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // ==================================================
            // BIENVENIDA
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

                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    color: _azulMarca.withValues(
                      alpha: 0.18,
                    ),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),

              child: const Row(
                children: [

                  // ICONO ADMINISTRADOR

                  Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 45,
                  ),

                  SizedBox(width: 15),

                  // TEXTO

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          'Bienvenido, Administrador',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 5),

                        Text(
                          'Control general del sistema',
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
            // TÍTULO
            // ==================================================

            const Text(
              'Administración',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _azulMarca,
              ),
            ),

            const SizedBox(height: 15),

            // ==================================================
            // BOTONES DE ADMINISTRACIÓN
            // ==================================================

            Column(
              children: [

                // ==================================================
                // INSPECCIONES
                // ==================================================

                _BotonAdmin(
                  icono: Icons.assignment_rounded,
                  titulo: 'Inspecciones',
                  subtitulo:
                      'Ver y controlar inspecciones',
                  color: const Color(0xFF1D4ED8),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const InspeccionesAdministrador(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // ==================================================
                // INSPECTORES
                // ==================================================

                _BotonAdmin(
                  icono: Icons.people_alt_rounded,
                  titulo: 'Inspectores',
                  subtitulo:
                      'Gestionar inspectores',
                  color: const Color(0xFF16A34A),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const GestionInspectores(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // ==================================================
                // REPORTES
                // ==================================================

                _BotonAdmin(
                  icono: Icons.bar_chart_rounded,
                  titulo: 'Reportes',
                  subtitulo:
                      'Consultar estadísticas',
                  color: const Color(0xFF9333EA),

                  onTap: () {
                    // Próximamente
                  },
                ),

                const SizedBox(height: 10),

                // ==================================================
                // CONFIGURACIÓN
                // ==================================================

                _BotonAdmin(
                  icono: Icons.settings_rounded,
                  titulo: 'Configuración',
                  subtitulo:
                      'Configurar sistema',
                  color: const Color(0xFFEA580C),

                  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ConfiguracionAdministrador(),
      ),
    );
  },
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// BOTÓN ADMINISTRADOR
// =================================================================

class _BotonAdmin extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const _BotonAdmin({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,

      borderRadius: BorderRadius.circular(14),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(14),

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),

            border: Border.all(
              color: Colors.grey.shade200,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.025,
                ),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),

          child: Row(
            children: [

              // ==================================================
              // ICONO
              // ==================================================

              Container(
                width: 45,
                height: 45,

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
                  size: 23,
                ),
              ),

              const SizedBox(width: 14),

              // ==================================================
              // TEXTO
              // ==================================================

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

                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w700,
                        color: Color(0xFF0D1B4C),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitulo,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // ==================================================
              // FLECHA
              // ==================================================

              Container(
                width: 32,
                height: 32,

                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF0D1B4C),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}