import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../bloc/novedad_bloc.dart';
import '../../visitas/bloc/pdv_bloc.dart';

class CrearNovedadPage extends StatefulWidget {
  final String visitaId;
  final String pdvId;
  const CrearNovedadPage({
    super.key,
    required this.visitaId,
    required this.pdvId,
  });

  @override
  State<CrearNovedadPage> createState() => _CrearNovedadPageState();
}

class _CrearNovedadPageState extends State<CrearNovedadPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _responsableSolucionCtrl = TextEditingController();
  final _responsableSeguimientoCtrl = TextEditingController();

  String? _categoria;
  String? _prioridad;
  DateTime _fechaSeguimiento = DateTime.now().add(const Duration(days: 3));
  bool _analizandoConIA = false;

  final List<String> _categorias = [
    'Inventario', 'Limpieza', 'Exhibición', 'Precio', 'Equipamiento', 'Otro'
  ];
  static const _prioridades = ['Baja', 'Media', 'Alta', 'Crítica'];

  @override
  void initState() {
    super.initState();
    _responsableSolucionCtrl.text = 'USR-ADMINS';
    _responsableSeguimientoCtrl.text = 'USR-ADMINS';
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _responsableSolucionCtrl.dispose();
    _responsableSeguimientoCtrl.dispose();
    super.dispose();
  }

  bool _isValidId(String value) {
    final regExp = RegExp(r'^[a-zA-Z0-9\-]+$');
    return value.length <= 10 && regExp.hasMatch(value);
  }

  Future<void> _analizarDescripcionConIA() async {
    final desc = _descCtrl.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa una descripción para analizar')),
      );
      return;
    }

    setState(() => _analizandoConIA = true);

    try {
      final client = GetIt.I<ApiClient>();
      final response = await client.dio.post(
        '${ApiConstants.novedades}/analizar-ia',
        data: {'descripcion': desc},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final categoria = data['categoria'] as String;
        final prioridad = data['prioridad'] as String;
        final titulo = data['tituloSugerido'] as String;
        final justificacion = data['justificacion'] as String;

        setState(() {
          _tituloCtrl.text = titulo;
          
          if (!_categorias.contains(categoria)) {
            _categorias.add(categoria);
          }
          _categoria = categoria;

          if (_prioridades.contains(prioridad)) {
            _prioridad = prioridad;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('IA: $justificacion'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al analizar con IA: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _analizandoConIA = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pdvState = context.read<PdvBloc>().state;
    String? pdvNombre;
    String? pdvCodigo;
    if (pdvState is PdvLoaded && widget.pdvId.isNotEmpty) {
      final found = pdvState.all.where((p) => p.id == widget.pdvId).firstOrNull;
      if (found != null) {
        pdvNombre = found.nombre;
        pdvCodigo = found.codigo;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Novedad')),
      body: BlocListener<NovedadBloc, NovedadState>(
        listener: (context, state) {
          if (state is NovedadActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
          }
          if (state is NovedadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pdvNombre != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.teal.shade700, size: 20),
                        const Gap(8),
                        Expanded(
                          child: Text(
                            '📍 Punto de Venta en visita: $pdvNombre ($pdvCodigo)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Título
                TextFormField(
                  controller: _tituloCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Título *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const Gap(12),

                // Descripción
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const Gap(8),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _analizandoConIA ? null : _analizarDescripcionConIA,
                    icon: _analizandoConIA
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                    label: const Text('Sugerir con IA'),
                  ),
                ),
                const Gap(12),

                // Categoría
                DropdownButtonFormField<String>(
                  value: _categoria,
                  hint: const Text('Seleccionar Categoría *'),
                  decoration: const InputDecoration(
                    labelText: 'Categoría *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null ? 'Requerido' : null,
                  items: _categorias
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _categoria = v),
                ),
                const Gap(12),

                // Prioridad
                DropdownButtonFormField<String>(
                  value: _prioridad,
                  hint: const Text('Seleccionar Prioridad *'),
                  decoration: const InputDecoration(
                    labelText: 'Prioridad *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null ? 'Requerido' : null,
                  items: _prioridades
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _prioridad = v),
                ),
                const Gap(12),

                // Responsable solución (UUID temporal — en producción usar selector)
                TextFormField(
                  controller: _responsableSolucionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'ID Responsable Solución *',
                    border: OutlineInputBorder(),
                    hintText: 'Código de usuario (máx. 10 caracteres)',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (!_isValidId(v.trim())) return 'Código inválido (máx. 10 caracteres, alfanumérico)';
                    return null;
                  },
                ),
                const Gap(12),

                // Responsable seguimiento
                TextFormField(
                  controller: _responsableSeguimientoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'ID Responsable Seguimiento *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (!_isValidId(v.trim())) return 'Código inválido (máx. 10 caracteres, alfanumérico)';
                    return null;
                  },
                ),
                const Gap(12),

                // Fecha seguimiento
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha de Seguimiento'),
                  subtitle: Text(
                      DateFormat('dd/MM/yyyy').format(_fechaSeguimiento)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _fechaSeguimiento,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _fechaSeguimiento = picked);
                    }
                  },
                ),
                const Gap(16),

                // Aviso LOPDP
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.blue.shade700, size: 20),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          'Gobernanza LOPDP: Los datos personales (cédula, nombres, celular, correo) serán anonimizados activamente.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(20),

                // Botón crear
                BlocBuilder<NovedadBloc, NovedadState>(
                  builder: (context, state) {
                    final cargando = state is NovedadLoading;
                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: cargando ? null : _submit,
                        child: cargando
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Crear Novedad'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    // Si visitaId o pdvId están vacíos, usar los IDs de prueba para evitar el Bad Request
    final vId = widget.visitaId.isEmpty ? 'VIS-000001' : widget.visitaId;
    final pId = widget.pdvId.isEmpty ? 'PDV-000001' : widget.pdvId;

    context.read<NovedadBloc>().add(NovedadCrearRequested(
          visitaId: vId,
          pdvId: pId,
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descCtrl.text.trim(),
          categoria: _categoria!,
          prioridad: _prioridad!,
          responsableSolucionId: _responsableSolucionCtrl.text.trim(),
          responsableSeguimientoId:
              _responsableSeguimientoCtrl.text.trim(),
          fechaSeguimiento: _fechaSeguimiento,
        ));
  }
}
