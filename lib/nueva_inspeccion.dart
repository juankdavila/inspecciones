import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signature/signature.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'datos_inspeccion.dart';
import 'resumen.dart';

// Convierte automáticamente todo lo que se escribe a mayúsculas
class _MayusculasFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

// Fuerza el formato: exactamente 4 letras + hasta 7 números, todo en mayúscula
class _ContenedorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String texto = newValue.text.toUpperCase();

    String letras = '';
    String numeros = '';

    for (int i = 0; i < texto.length; i++) {
      final caracter = texto[i];
      if (letras.length < 4 && RegExp(r'[A-Z]').hasMatch(caracter)) {
        letras += caracter;
      } else if (letras.length == 4 &&
          numeros.length < 7 &&
          RegExp(r'[0-9]').hasMatch(caracter)) {
        numeros += caracter;
      }
    }

    final resultado = letras + numeros;

    return TextEditingValue(
      text: resultado,
      selection: TextSelection.collapsed(offset: resultado.length),
    );
  }
}

// Representa una fila de la tabla de "Detalle de la inspección"
class _FilaBulto {
  final bultoController = TextEditingController();
  final referenciaController = TextEditingController();
  final despachadaController = TextEditingController();
  final recibidaController = TextEditingController();
  final faltanteController = TextEditingController();
  final averiadaController = TextEditingController();
  final vrUnitarioController = TextEditingController();
  final observacionesController = TextEditingController();
}

class PantallaNuevaInspeccion extends StatefulWidget {
  const PantallaNuevaInspeccion({super.key});

  @override
  State<PantallaNuevaInspeccion> createState() =>
      _PantallaNuevaInspeccionState();
}

class _PantallaNuevaInspeccionState extends State<PantallaNuevaInspeccion> {
  static const Color _azulMarca = Color(0xFF0D1B4C);
  final _formKey = GlobalKey<FormState>();

  final _ciudadController = TextEditingController();
  final _fechaController = TextEditingController();
  final _solicitanteController = TextEditingController();
  final _aseguradoController = TextEditingController();
  final _polizaController = TextEditingController();
  final _aplicacionController = TextEditingController();
  final _pedidoController = TextEditingController();
  final _proveedoresController = TextEditingController();
  final _facturaController = TextEditingController();
  final _lineaAereaController = TextEditingController();
  final _blGuiaController = TextEditingController();
  final _puertoSalidaController = TextEditingController();
  final _puertoLlegadaController = TextEditingController();
  final _direccionController = TextEditingController();
  final _marcasContenedorController = TextEditingController();
  final _cantidadBultosController = TextEditingController();
  final _clasesEmpaqueController = TextEditingController();
  final _pesoBrutoController = TextEditingController();
  final _novedadesController = TextEditingController();
  final _unidFaltantesController = TextEditingController();
  final _unidAveriadasController = TextEditingController();
  final _valorPerdidaController = TextEditingController();
  bool _noHayFaltantes = false;
  bool _noHayAveriadas = false;
  bool _noHayPerdida = false;
  final _nombreRepresentanteController = TextEditingController();
  final _cedulaRepresentanteController = TextEditingController();
  final _telefonoRepresentanteController = TextEditingController();
  final _horaEntradaController = TextEditingController();
  final _horaSalidaController = TextEditingController();
  final List<File> _fotos = [];
  final ImagePicker _imagePicker = ImagePicker();

  final SignatureController _firmaAseguradoController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  // --- Detalle de la inspección (lista de bultos) ---
  final List<_FilaBulto> _bultos = [_FilaBulto()];

  // Formato válido: 4 letras seguidas de 7 números (ej: HLBU2397790)
  final RegExp _regexContenedor = RegExp(r'^[A-Z]{4}[0-9]{7}$');

  @override
void initState() {
  super.initState();

  final hoy = DateTime.now();

  _fechaController.text =
      '${hoy.day.toString().padLeft(2, '0')}/'
      '${hoy.month.toString().padLeft(2, '0')}/'
      '${hoy.year}';
}

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (fecha != null) {
      setState(() {
        _fechaController.text =
            '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
      });
    }
  }

  Future<void> _seleccionarHora(TextEditingController controller) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora != null) {
      setState(() {
        controller.text =
            '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  void _agregarBulto() {
    setState(() {
      _bultos.add(_FilaBulto());
    });
  }

  void _eliminarBulto(int index) {
    if (_bultos.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe haber al menos un bulto')),
      );
      return;
    }
    setState(() {
      _bultos.removeAt(index);
    });
  }

  Future<void> _tomarFoto() async {
    final foto = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 40,
      maxWidth: 1024,
    );
    if (foto != null) {
      setState(() {
        _fotos.add(File(foto.path));
      });
    }
  }

  Future<void> _elegirDeGaleria() async {
    final fotos = await _imagePicker.pickMultiImage(
      imageQuality: 40,
      maxWidth: 1024,
    );
    if (fotos.isNotEmpty) {
      setState(() {
        _fotos.addAll(fotos.map((f) => File(f.path)));
      });
    }
  }

  void _eliminarFoto(int index) {
    setState(() {
      _fotos.removeAt(index);
    });
  }

  String? _validarObligatorio(String? valor, String nombreCampo) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresá $nombreCampo';
    }
    return null;
  }

  String? _validarContenedor(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Ingresá el número de contenedor';
    }
    if (!_regexContenedor.hasMatch(valor.trim())) {
      return 'Formato inválido: 4 letras + 7 números (ej: HLBU2397790)';
    }
    return null;
  }

  Widget _campo(
    String etiqueta,
    TextEditingController controller, {
    bool soloLectura = false,
    VoidCallback? onTap,
    TextInputType? tipo,
    IconData? icono,
    String? sufijo,
    String? Function(String?)? validador,
    List<TextInputFormatter>? formateadores,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: soloLectura,
        onTap: onTap,
        keyboardType: tipo,
        textCapitalization: TextCapitalization.characters,
        inputFormatters: formateadores ?? [_MayusculasFormatter()],
        validator: validador ?? (valor) => _validarObligatorio(valor, etiqueta),
        decoration: InputDecoration(
          labelText: etiqueta,
          prefixIcon: icono != null ? Icon(icono, size: 20) : null,
          suffixText: sufijo,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _tituloSeccion(String texto) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: _azulMarca,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _campoConNoHay(
    String etiqueta,
    TextEditingController controller,
    bool noHay,
    void Function(bool) onCambiarNoHay,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              enabled: !noHay,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [_MayusculasFormatter()],
              validator: (valor) {
                if (noHay) return null;
                return _validarObligatorio(valor, etiqueta);
              },
              decoration: InputDecoration(
                labelText: etiqueta,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No hay', style: TextStyle(fontSize: 11)),
              Switch(
                value: noHay,
                onChanged: (valor) {
                  onCambiarNoHay(valor);
                  if (valor) controller.text = 'NO HAY';
                  if (!valor) controller.clear();
                },
                activeThumbColor: _azulMarca,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaBulto(int index) {
    final fila = _bultos[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bulto ${index + 1}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: _azulMarca),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _eliminarBulto(index),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _campo('N° de bulto', fila.bultoController,
                    tipo: TextInputType.number,
                    formateadores: [FilteringTextInputFormatter.digitsOnly]),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _campo(
                    'Referencia / Contenido', fila.referenciaController),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _campo('Despachada', fila.despachadaController,
                    tipo: TextInputType.number,
                    formateadores: [FilteringTextInputFormatter.digitsOnly]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _campo('Recibida', fila.recibidaController,
                    tipo: TextInputType.number,
                    formateadores: [FilteringTextInputFormatter.digitsOnly]),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _campo('Faltante', fila.faltanteController,
                    tipo: TextInputType.number,
                    formateadores: [FilteringTextInputFormatter.digitsOnly]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _campo('Averiada', fila.averiadaController,
                    tipo: TextInputType.number,
                    formateadores: [FilteringTextInputFormatter.digitsOnly]),
              ),
            ],
          ),
          _campo('V/R Unitario', fila.vrUnitarioController,
              tipo: const TextInputType.numberWithOptions(decimal: true),
              sufijo: 'USD'),
          _campo('Observaciones', fila.observacionesController),
        ],
      ),
    );
  }

  Widget _seccionFotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _tomarFoto,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Tomar foto'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _azulMarca,
                  side: const BorderSide(color: _azulMarca),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _elegirDeGaleria,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galería'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _azulMarca,
                  side: const BorderSide(color: _azulMarca),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (_fotos.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                'Todavía no agregaste fotos',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _fotos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_fotos[index], fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () => _eliminarFoto(index),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _firmaInspector() {
    final usuario = FirebaseAuth.instance.currentUser;
    final nombreInspector =
        usuario?.email?.split('@').first.toUpperCase() ?? 'INSPECTOR';
    final ahora = DateTime.now();
    final fechaHora =
        '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year} '
        '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            nombreInspector,
            style: const TextStyle(
              fontSize: 26,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: _azulMarca,
            ),
          ),
          const SizedBox(height: 6),
          const Divider(),
          Text(
            'Firmado digitalmente · $fechaHora',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _firmaAsegurado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Firma del asegurado',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Signature(
            controller: _firmaAseguradoController,
            height: 180,
            backgroundColor: Colors.white,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => setState(() => _firmaAseguradoController.clear()),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Borrar y firmar de nuevo'),
          ),
        ),
      ],
    );
  }

  Future<void> _continuar() async {
    if (!_formKey.currentState!.validate()) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisá los campos marcados en rojo'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_firmaAseguradoController.isEmpty) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falta la firma del asegurado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final firmaBytes = await _firmaAseguradoController.toPngBytes();
    if (firmaBytes == null) return;

    final usuario = FirebaseAuth.instance.currentUser;
    final nombreInspector =
        usuario?.email?.split('@').first.toUpperCase() ?? 'INSPECTOR';
    final ahora = DateTime.now();
    final fechaHora =
        '${ahora.day.toString().padLeft(2, '0')}/${ahora.month.toString().padLeft(2, '0')}/${ahora.year} '
        '${ahora.hour.toString().padLeft(2, '0')}:${ahora.minute.toString().padLeft(2, '0')}';

    final datos = DatosInspeccion(
      numeroInspeccion: '',
      ciudad: _ciudadController.text,
      fecha: _fechaController.text,
      solicitante: _solicitanteController.text,
      asegurado: _aseguradoController.text,
      poliza: _polizaController.text,
      aplicacion: _aplicacionController.text,
      pedido: _pedidoController.text,
      proveedores: _proveedoresController.text,
      factura: _facturaController.text,
      lineaAerea: _lineaAereaController.text,
      blGuia: _blGuiaController.text,
      puertoSalida: _puertoSalidaController.text,
      puertoLlegada: _puertoLlegadaController.text,
      direccion: _direccionController.text,
      marcasContenedor: _marcasContenedorController.text,
      cantidadBultos: _cantidadBultosController.text,
      clasesEmpaque: _clasesEmpaqueController.text,
      pesoBruto: _pesoBrutoController.text,
      bultos: _bultos
          .map((f) => DatosBulto(
                bulto: f.bultoController.text,
                referencia: f.referenciaController.text,
                despachada: f.despachadaController.text,
                recibida: f.recibidaController.text,
                faltante: f.faltanteController.text,
                averiada: f.averiadaController.text,
                vrUnitario: f.vrUnitarioController.text,
                observaciones: f.observacionesController.text,
              ))
          .toList(),
      novedades: _novedadesController.text,
      unidFaltantes: _unidFaltantesController.text,
      unidAveriadas: _unidAveriadasController.text,
      valorPerdida: _valorPerdidaController.text,
      nombreRepresentante: _nombreRepresentanteController.text,
      cedulaRepresentante: _cedulaRepresentanteController.text,
      telefonoRepresentante: _telefonoRepresentanteController.text,
      horaEntrada: _horaEntradaController.text,
      horaSalida: _horaSalidaController.text,
      nombreInspector: nombreInspector,
      fechaHoraFirmaInspector: fechaHora,
      firmaAsegurado: firmaBytes,
      fotos: _fotos,
    );

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaResumen(datos: datos)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        title: const Text('Nueva inspección'),
        backgroundColor: _azulMarca,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Text(
                'INFORME DE INSPECCIÓN FINAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _azulMarca,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(thickness: 1.5),
            const SizedBox(height: 12),

            _tituloSeccion('DATOS DE EMBARQUE'),

            Row(
              children: [
                Expanded(
                    child: _campo('Ciudad', _ciudadController,
                        icono: Icons.location_city)),
                const SizedBox(width: 12),
                Expanded(
                  child: _campo(
                    'Fecha',
                    _fechaController,
                    soloLectura: true,
                    onTap: _seleccionarFecha,
                    icono: Icons.calendar_today,
                    validador: (v) => _validarObligatorio(v, 'la fecha'),
                  ),
                ),
              ],
            ),
            _campo('Solicitante', _solicitanteController,
                icono: Icons.business),
            _campo('Asegurado / Cliente', _aseguradoController,
                icono: Icons.verified_user),

            Row(
              children: [
                Expanded(
                    child: _campo('Póliza N°', _polizaController,
                        icono: Icons.description)),
                const SizedBox(width: 12),
                Expanded(
                    child: _campo('Aplicación N°', _aplicacionController,
                        icono: Icons.numbers)),
              ],
            ),
            _campo('Pedido N°', _pedidoController,
                icono: Icons.receipt_long),
            _campo('Proveedores', _proveedoresController,
                icono: Icons.local_shipping),

            Row(
              children: [
                Expanded(
                    child: _campo('Factura N°', _facturaController,
                        icono: Icons.receipt)),
                const SizedBox(width: 12),
                Expanded(
                    child: _campo(
                        'M/N - Línea Aérea', _lineaAereaController,
                        icono: Icons.directions_boat)),
              ],
            ),
            _campo('B/L Guía', _blGuiaController,
                icono: Icons.confirmation_number),

            Row(
              children: [
                Expanded(
                    child: _campo('Puerto salida', _puertoSalidaController,
                        icono: Icons.anchor)),
                const SizedBox(width: 12),
                Expanded(
                    child: _campo(
                        'Puerto llegada', _puertoLlegadaController,
                        icono: Icons.anchor)),
              ],
            ),
            _campo('Dirección de reconocimiento', _direccionController,
                icono: Icons.place),

            // --- Campo con validación especial: 4 letras + 7 números ---
            _campo(
              'Marcas y N° de contenedor',
              _marcasContenedorController,
              icono: Icons.inventory_2,
              validador: _validarContenedor,
              formateadores: [
                _ContenedorFormatter(),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _campo(
                    'Cantidad de bultos',
                    _cantidadBultosController,
                    tipo: TextInputType.number,
                    icono: Icons.inventory,
                    formateadores: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: _campo(
                        'Clases de empaque', _clasesEmpaqueController,
                        icono: Icons.category)),
              ],
            ),

            // --- Campo de peso con sufijo KGS ---
            _campo(
              'Peso bruto',
              _pesoBrutoController,
              tipo: const TextInputType.numberWithOptions(decimal: true),
              icono: Icons.scale,
              sufijo: 'KGS',
              formateadores: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
            ),

            const SizedBox(height: 8),

            // --- Sección 2: Detalle de la inspección ---
            _tituloSeccion('DETALLE DE LA INSPECCIÓN'),

            ...List.generate(_bultos.length, (index) => _tarjetaBulto(index)),

            OutlinedButton.icon(
              onPressed: _agregarBulto,
              icon: const Icon(Icons.add),
              label: const Text('Agregar bulto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _azulMarca,
                side: const BorderSide(color: _azulMarca),
                minimumSize: const Size(double.infinity, 44),
              ),
            ),

            // --- Sección 3: Novedades y pérdida ---
            _tituloSeccion('DETALLE DE NOVEDADES'),
            TextFormField(
              controller: _novedadesController,
              maxLines: 4,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [_MayusculasFormatter()],
              validator: (v) => _validarObligatorio(v, 'las novedades'),
              decoration: const InputDecoration(
                labelText: 'Describí lo observado durante la inspección',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 20),

            _tituloSeccion('DETALLE DE LA PÉRDIDA'),
            _campoConNoHay(
              'Unidades faltantes',
              _unidFaltantesController,
              _noHayFaltantes,
              (valor) => setState(() => _noHayFaltantes = valor),
            ),
            _campoConNoHay(
              'Unidades averiadas',
              _unidAveriadasController,
              _noHayAveriadas,
              (valor) => setState(() => _noHayAveriadas = valor),
            ),
            _campoConNoHay(
              'Valor de la pérdida',
              _valorPerdidaController,
              _noHayPerdida,
              (valor) => setState(() => _noHayPerdida = valor),
            ),

            const SizedBox(height: 24),
            // --- Sección 5: Fotos ---
            _tituloSeccion('FOTOS'),
            _seccionFotos(),

            const SizedBox(height: 24),
            _tituloSeccion('REPRESENTANTE DEL ASEGURADO'),
            _campo('Nombre', _nombreRepresentanteController,
                icono: Icons.badge),
            _campo('Cédula N°', _cedulaRepresentanteController,
                icono: Icons.credit_card,
                tipo: TextInputType.number,
                formateadores: [FilteringTextInputFormatter.digitsOnly]),
            _campo('Teléfono', _telefonoRepresentanteController,
                icono: Icons.phone,
                tipo: TextInputType.phone,
                formateadores: [FilteringTextInputFormatter.digitsOnly]),
            Row(
              children: [
                Expanded(
                  child: _campo(
                    'Hora de entrada',
                    _horaEntradaController,
                    soloLectura: true,
                    onTap: () => _seleccionarHora(_horaEntradaController),
                    icono: Icons.login,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _campo(
                    'Hora de salida',
                    _horaSalidaController,
                    soloLectura: true,
                    onTap: () => _seleccionarHora(_horaSalidaController),
                    icono: Icons.logout,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _firmaAsegurado(),

            const SizedBox(height: 8),
            _tituloSeccion('FIRMA DEL INSPECTOR'),
            _firmaInspector(),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _continuar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _azulMarca,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('REVISAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}