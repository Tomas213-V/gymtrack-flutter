import 'package:flutter/material.dart';
import '../models/pago_model.dart';
import '../models/plan_membresia_model.dart';
import '../models/socio_model.dart';
import '../services/pago_service.dart';
import '../services/plan_membresia_service.dart';
import '../services/socio_service.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  final PagoService _pagoService = PagoService();
  final PlanMembresiaService _planService = PlanMembresiaService();
  final SocioService _socioService = SocioService();
  final TextEditingController _searchController = TextEditingController();

  List<PagoModel> _pagos = [];
  List<PlanMembresiaModel> _planesActivos = [];
  List<SocioModel> _sociosDisponibles = [];
  ResumenPagosModel _resumen = ResumenPagosModel.defaultResumen();
  bool _isLoading = true;
  String _filtroEstado = 'todos'; // 'todos', 'pagado', 'pendiente', 'vencido'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final resumen = await _pagoService.getResumen();
    final pagos = await _pagoService.getPagos(
      search: _searchController.text.trim(),
      estado: _filtroEstado,
    );
    final planes = await _planService.getPlanes(estado: 'activo');
    final sociosData = await _socioService.getSocios(limit: 100);
    final socios = (sociosData['socios'] as List<SocioModel>?) ?? [];

    if (!mounted) return;

    setState(() {
      _resumen = resumen;
      _pagos = pagos;
      _planesActivos = planes;
      _sociosDisponibles = socios;
      _isLoading = false;
    });
  }

  void _showRegistrarPagoModal({SocioModel? preselectedSocio}) async {
    if (_planesActivos.isEmpty) {
      final planes = await _planService.getPlanes(estado: 'activo');
      if (mounted) {
        setState(() => _planesActivos = planes);
      }
    }
    if (_sociosDisponibles.isEmpty) {
      final sociosData = await _socioService.getSocios(limit: 100);
      final socios = (sociosData['socios'] as List<SocioModel>?) ?? [];
      if (mounted) {
        setState(() => _sociosDisponibles = socios);
      }
    }

    final initialPlan = _planesActivos.isNotEmpty ? _planesActivos.first : null;
    final socioNombreCtrl = TextEditingController(text: preselectedSocio?.nombreCompleto ?? '');
    TextEditingController? autocompleteController;
    SocioModel? socioSeleccionado = preselectedSocio;

    PlanMembresiaModel? matchedPreselected;
    if (preselectedSocio?.plan != null) {
      for (final p in _planesActivos) {
        if (p.nombre.toLowerCase().trim() == preselectedSocio!.plan!.toLowerCase().trim() ||
            p.nombre.toLowerCase().contains(preselectedSocio.plan!.toLowerCase()) ||
            preselectedSocio.plan!.toLowerCase().contains(p.nombre.toLowerCase())) {
          matchedPreselected = p;
          break;
        }
      }
    }

    final initialPrecio = matchedPreselected != null
        ? matchedPreselected.precio
        : (preselectedSocio?.precio ?? (initialPlan != null ? initialPlan.precio : 18000.0));

    final montoCtrl = TextEditingController(
      text: initialPrecio.toStringAsFixed(0),
    );
    String selectedPlan = matchedPreselected?.nombre ?? (preselectedSocio?.plan ?? (initialPlan != null ? initialPlan.nombre : 'Plan Mensual'));
    String selectedMetodo = 'Efectivo';
    String selectedEstado = 'pagado';
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void selectSocio(SocioModel socio) {
              setModalState(() {
                socioSeleccionado = socio;
                socioNombreCtrl.text = socio.nombreCompleto;
                if (autocompleteController != null) {
                  autocompleteController!.text = socio.nombreCompleto;
                }
                if (socio.plan != null && socio.plan!.isNotEmpty) {
                  for (final p in _planesActivos) {
                    if (p.nombre.toLowerCase().trim() == socio.plan!.toLowerCase().trim() ||
                        p.nombre.toLowerCase().contains(socio.plan!.toLowerCase()) ||
                        socio.plan!.toLowerCase().contains(p.nombre.toLowerCase())) {
                      selectedPlan = p.nombre;
                      montoCtrl.text = p.precio.toStringAsFixed(0);
                      break;
                    }
                  }
                }
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Registrar Pago',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Autocomplete para el nombre del socio con búsqueda en tiempo real
                      RawAutocomplete<SocioModel>(
                        displayStringForOption: (s) => s.nombreCompleto,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.trim().isEmpty) {
                            return const Iterable<SocioModel>.empty();
                          }
                          final query = textEditingValue.text.toLowerCase().trim();
                          return _sociosDisponibles.where((s) =>
                              s.nombreCompleto.toLowerCase().contains(query) ||
                              s.dni.toLowerCase().contains(query));
                        },
                        onSelected: (SocioModel selection) {
                          selectSocio(selection);
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          autocompleteController = controller;
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              'Nombre del Socio * (Autocompleta nombre o DNI)',
                              Icons.person_outline,
                            ),
                            validator: (v) {
                              if ((v == null || v.trim().isEmpty) &&
                                  socioNombreCtrl.text.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              socioNombreCtrl.text = val;
                              if (socioSeleccionado != null &&
                                  val != socioSeleccionado!.nombreCompleto) {
                                setModalState(() {
                                  socioSeleccionado = null;
                                });
                              }
                            },
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 8,
                              color: const Color(0xFF1E282D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFF2B3A42)),
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width - 40,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  child: ListView.separated(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(color: Color(0xFF2B3A42), height: 1),
                                    itemBuilder: (context, index) {
                                      final socio = options.elementAt(index);
                                      return ListTile(
                                        dense: true,
                                        leading: CircleAvatar(
                                          radius: 14,
                                          backgroundColor: const Color(0xFF11251A),
                                          child: Text(
                                            socio.nombre.isNotEmpty
                                                ? socio.nombre[0].toUpperCase()
                                                : 'S',
                                            style: const TextStyle(
                                              color: Color(0xFF00E676),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          socio.nombreCompleto,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'DNI: ${socio.dni}${socio.plan != null ? " • ${socio.plan}" : ""}',
                                          style: const TextStyle(
                                            color: Color(0xFF8F9CA3),
                                            fontSize: 11,
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.check_circle_outline,
                                          color: Color(0xFF00E676),
                                          size: 16,
                                        ),
                                        onTap: () => onSelected(socio),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      // Ayuda visual: socio seleccionado o chips de socios sugeridos
                      if (socioSeleccionado != null)
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF11251A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      socioSeleccionado!.nombreCompleto,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'DNI: ${socioSeleccionado!.dni}${socioSeleccionado!.plan != null ? " • Plan: ${socioSeleccionado!.plan}" : ""}',
                                      style: const TextStyle(color: Color(0xFF00E676), fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                                onPressed: () {
                                  setModalState(() {
                                    socioSeleccionado = null;
                                    socioNombreCtrl.clear();
                                    if (autocompleteController != null) {
                                      autocompleteController!.clear();
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      else if (_sociosDisponibles.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            const Text(
                              'Sugerencias rápidas de socios:',
                              style: TextStyle(color: Color(0xFF8F9CA3), fontSize: 11),
                            ),
                            const SizedBox(height: 4),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _sociosDisponibles.take(6).map((socio) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ActionChip(
                                      backgroundColor: const Color(0xFF1E282D),
                                      side: const BorderSide(color: Color(0xFF2B3A42)),
                                      avatar: const Icon(Icons.person, color: Color(0xFF00E676), size: 14),
                                      label: Text(
                                        socio.nombreCompleto,
                                        style: const TextStyle(color: Colors.white, fontSize: 11),
                                      ),
                                      onPressed: () => selectSocio(socio),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 12),
                      TextFormField(
                        controller: montoCtrl,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: _inputDecoration('Monto (\$) *', Icons.attach_money),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPlan,
                        dropdownColor: const Color(0xFF1E282D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Plan Activo', Icons.card_membership_outlined),
                        items: _planesActivos
                            .map((p) => DropdownMenuItem(
                                  value: p.nombre,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(p.nombre),
                                      const SizedBox(width: 8),
                                      Text(
                                        '\$${p.precio.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: Color(0xFF00E676),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() {
                              selectedPlan = val;
                              final matched = _planesActivos.firstWhere(
                                (p) => p.nombre == val,
                                orElse: () => _planesActivos.first,
                              );
                              montoCtrl.text = matched.precio.toStringAsFixed(0);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedMetodo,
                        dropdownColor: const Color(0xFF1E282D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Método de Pago', Icons.payments_outlined),
                        items: ['Efectivo', 'Transferencia', 'Tarjeta', 'Mercado Pago']
                            .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedMetodo = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedEstado,
                        dropdownColor: const Color(0xFF1E282D),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Estado del Pago', Icons.check_circle_outline),
                        items: const [
                          DropdownMenuItem(value: 'pagado', child: Text('Pagado')),
                          DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedEstado = val);
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() => isSaving = true);

                                  final nombreFinal = (autocompleteController?.text.trim().isNotEmpty == true)
                                      ? autocompleteController!.text.trim()
                                      : socioNombreCtrl.text.trim();

                                  final monto = double.tryParse(montoCtrl.text.trim()) ?? 18000;
                                  final ok = await _pagoService.registrarPago(
                                    socioNombre: nombreFinal,
                                    monto: monto,
                                    plan: selectedPlan,
                                    idSocio: socioSeleccionado?.idSocio is int
                                        ? socioSeleccionado!.idSocio as int
                                        : int.tryParse(socioSeleccionado?.idSocio?.toString() ?? ''),
                                    dniSocio: socioSeleccionado?.dni,
                                    metodoPago: selectedMetodo,
                                    estado: selectedEstado,
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(ok
                                            ? 'Pago registrado exitosamente'
                                            : 'Pago guardado'),
                                        backgroundColor: const Color(0xFF1B5E20),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    _loadData();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00E676),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Text(
                                  'REGISTRAR PAGO',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF8F9CA3), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF00E676), size: 20),
      filled: true,
      fillColor: const Color(0xFF1E282D),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2B3A42)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00E676)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  void _showDetallePagoModal(PagoModel pago) {
    Color badgeBg;
    Color badgeText;
    String badgeLabel;
    IconData badgeIcon;

    if (pago.isPagado) {
      badgeBg = const Color(0xFF133820);
      badgeText = const Color(0xFF00E676);
      badgeLabel = 'PAGADO';
      badgeIcon = Icons.check_circle_rounded;
    } else if (pago.isPendiente) {
      badgeBg = const Color(0xFF3E2E14);
      badgeText = const Color(0xFFF59E0B);
      badgeLabel = 'PENDIENTE';
      badgeIcon = Icons.schedule_rounded;
    } else {
      badgeBg = const Color(0xFF3E1818);
      badgeText = const Color(0xFFEF4444);
      badgeLabel = 'VENCIDO';
      badgeIcon = Icons.warning_amber_rounded;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.receipt_long_rounded, color: Color(0xFF00E676), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Detalle del Pago',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(modalContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF12181B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF243037), width: 1.2),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: badgeText.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(badgeIcon, color: badgeText, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              badgeLabel,
                              style: TextStyle(
                                color: badgeText,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        pago.formattedMonto,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pago.plan,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Color(0xFF243037), thickness: 1),
                      const SizedBox(height: 12),
                      _buildDetalleRow(Icons.person_outline, 'Socio', pago.socioNombre),
                      if (pago.dniSocio != null && pago.dniSocio!.isNotEmpty)
                        _buildDetalleRow(Icons.badge_outlined, 'DNI', pago.dniSocio!),
                      _buildDetalleRow(
                        Icons.confirmation_number_outlined,
                        'Comprobante',
                        pago.comprobante ?? 'COMP-${pago.idPago}',
                      ),
                      _buildDetalleRow(Icons.calendar_today_outlined, 'Fecha de pago', pago.fechaPago),
                      _buildDetalleRow(Icons.payments_outlined, 'Método de pago', pago.metodoPago ?? 'Efectivo'),
                      _buildDetalleRow(
                        Icons.event_available_outlined,
                        'Vencimiento cuota',
                        pago.fechaVencimiento ?? 'A 30 días',
                      ),
                      _buildDetalleRow(
                        Icons.verified_outlined,
                        'Estado membresía',
                        pago.isPagado ? 'Al día / Vigente' : (pago.isPendiente ? 'Pago pendiente' : 'Vencida'),
                        valueColor: pago.isPagado
                            ? const Color(0xFF00E676)
                            : (pago.isPendiente ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (pago.isPendiente)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _pagoService.marcarComoPagado(pago.idPago);
                          if (!modalContext.mounted) return;
                          Navigator.pop(modalContext);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pago marcado como Pagado'),
                              backgroundColor: Color(0xFF1B5E20),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          _loadData();
                        },
                        icon: const Icon(Icons.check, color: Colors.black),
                        label: const Text('MARCAR COMO PAGADO', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E676),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(modalContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Comprobante #${pago.comprobante ?? pago.idPago} listo para compartir'),
                          backgroundColor: const Color(0xFF1B5E20),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_outlined, color: Color(0xFF00E676), size: 18),
                    label: const Text(
                      'COMPARTIR COMPROBANTE',
                      style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00E676)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEstadoCuotasModal() {
    String modalFiltro = 'todos';
    final searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final query = searchCtrl.text.trim().toLowerCase();
            final filtrados = _sociosDisponibles.where((s) {
              final matchQuery = query.isEmpty ||
                  s.nombreCompleto.toLowerCase().contains(query) ||
                  s.dni.toLowerCase().contains(query);
              if (!matchQuery) return false;

              if (modalFiltro == 'todos') return true;
              if (modalFiltro == 'activo') return s.isActivo;
              if (modalFiltro == 'pendiente') return s.isPendiente;
              if (modalFiltro == 'vencido') return s.isInactivo;
              return true;
            }).toList();

            final int alDiaCount = _sociosDisponibles.where((s) => s.isActivo).length;
            final int pendientesCount = _sociosDisponibles.where((s) => s.isPendiente).length;
            final int vencidosCount = _sociosDisponibles.where((s) => s.isInactivo).length;

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.description_outlined, color: Color(0xFF00E676), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'Estado de Cuotas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Control y seguimiento de cuotas y vencimientos de socios',
                    style: TextStyle(color: Color(0xFF8F9CA3), fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildCuotaKpiCard('Al día', alDiaCount, const Color(0xFF133820), const Color(0xFF00E676)),
                      const SizedBox(width: 8),
                      _buildCuotaKpiCard('Pendientes', pendientesCount, const Color(0xFF3E2E14), const Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      _buildCuotaKpiCard('Vencidas', vencidosCount, const Color(0xFF3E1818), const Color(0xFFEF4444)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E282D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF27343B)),
                    ),
                    child: TextField(
                      controller: searchCtrl,
                      onChanged: (val) => setModalState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Buscar por nombre o DNI...',
                        hintStyle: TextStyle(color: Color(0xFF6B7B84), fontSize: 12),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF8F9CA3), size: 18),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildModalFilterChip('todos', 'Todos (${_sociosDisponibles.length})', modalFiltro, (v) => setModalState(() => modalFiltro = v)),
                        const SizedBox(width: 6),
                        _buildModalFilterChip('activo', 'Al día ($alDiaCount)', modalFiltro, (v) => setModalState(() => modalFiltro = v)),
                        const SizedBox(width: 6),
                        _buildModalFilterChip('pendiente', 'Pendientes ($pendientesCount)', modalFiltro, (v) => setModalState(() => modalFiltro = v)),
                        const SizedBox(width: 6),
                        _buildModalFilterChip('vencido', 'Vencidas ($vencidosCount)', modalFiltro, (v) => setModalState(() => modalFiltro = v)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtrados.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay socios para este filtro',
                              style: TextStyle(color: Color(0xFF8F9CA3), fontSize: 13),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filtrados.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final socio = filtrados[index];
                              Color tagBg;
                              Color tagColor;
                              String tagText;

                              if (socio.isActivo) {
                                tagBg = const Color(0xFF133820);
                                tagColor = const Color(0xFF00E676);
                                tagText = 'Al día';
                              } else if (socio.isPendiente) {
                                tagBg = const Color(0xFF3E2E14);
                                tagColor = const Color(0xFFF59E0B);
                                tagText = 'Pendiente';
                              } else {
                                tagBg = const Color(0xFF3E1818);
                                tagColor = const Color(0xFFEF4444);
                                tagText = 'Vencida';
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF12181B),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFF243037)),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: const Color(0xFF1E282D),
                                      child: Text(
                                        socio.nombre.isNotEmpty ? socio.nombre[0].toUpperCase() : 'S',
                                        style: const TextStyle(
                                          color: Color(0xFF00E676),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            socio.nombreCompleto,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'DNI: ${socio.dni} • ${socio.plan ?? "Sin plan"}',
                                            style: const TextStyle(
                                              color: Color(0xFF8F9CA3),
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Vence: ${socio.fechaVencimiento ?? "No definida"}',
                                            style: TextStyle(
                                              color: socio.isActivo ? const Color(0xFF8F9CA3) : tagColor,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: tagBg,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            tagText,
                                            style: TextStyle(
                                              color: tagColor,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        if (socio.isPendiente || socio.isInactivo)
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                              _showRegistrarPagoModal(preselectedSocio: socio);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00E676),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Cobrar',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          )
                                        else
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                              setState(() {
                                                _searchController.text = socio.nombreCompleto;
                                              });
                                              _loadData();
                                            },
                                            child: const Text(
                                              'Ver pagos',
                                              style: TextStyle(
                                                color: Color(0xFF00E676),
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFiltrosSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161E22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtros de Pagos',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Estado del Pago:',
                    style: TextStyle(color: Color(0xFF8F9CA3), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildModalFilterChip('todos', 'Todos', _filtroEstado, (val) {
                        setState(() => _filtroEstado = val);
                        setModalState(() {});
                        _loadData();
                      }),
                      _buildModalFilterChip('pagado', 'Pagados', _filtroEstado, (val) {
                        setState(() => _filtroEstado = val);
                        setModalState(() {});
                        _loadData();
                      }),
                      _buildModalFilterChip('pendiente', 'Pendientes', _filtroEstado, (val) {
                        setState(() => _filtroEstado = val);
                        setModalState(() {});
                        _loadData();
                      }),
                      _buildModalFilterChip('vencido', 'Vencidos', _filtroEstado, (val) {
                        setState(() => _filtroEstado = val);
                        setModalState(() {});
                        _loadData();
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('LISTO', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFiltroPill(String estado, String label) {
    final isSelected = _filtroEstado.toLowerCase() == estado.toLowerCase();
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroEstado = estado;
        });
        _loadData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E676) : const Color(0xFF161E22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : const Color(0xFF27343B),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : const Color(0xFF8F9CA3),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDetalleRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00E676), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF8F9CA3), fontSize: 13),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuotaKpiCard(String title, int count, Color bg, Color text) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: text.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalFilterChip(String value, String label, String current, Function(String) onSelected) {
    final isSelected = value == current;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00E676) : const Color(0xFF1E282D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : const Color(0xFF27343B),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1416),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFF00E676),
          backgroundColor: const Color(0xFF182024),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Dos tarjetas de acción rápida
                Row(
                  children: [
                    // Tarjeta 1: Registrar pago
                    Expanded(
                      child: GestureDetector(
                        onTap: _showRegistrarPagoModal,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF11251A),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF00E676).withValues(alpha: 0.8),
                              width: 1.4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E676).withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF00E676),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '\$',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Registrar pago',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Registrar un nuevo pago de un socio',
                                style: TextStyle(
                                  color: Color(0xFF8F9CA3),
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Tarjeta 2: Estado de cuota
                    Expanded(
                      child: GestureDetector(
                        onTap: _showEstadoCuotasModal,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161E22),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFF243037),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF222D33),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.description_outlined,
                                      color: Color(0xFF00E676),
                                      size: 20,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: Color(0xFF8F9CA3),
                                    size: 22,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Estado de cuota',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Ver estado de cuotas de los socios',
                                style: TextStyle(
                                  color: Color(0xFF8F9CA3),
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 2. Buscador y Filtros
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161E22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF27343B), width: 1),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {});
                            _loadData();
                          },
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Buscar socio o plan...',
                            hintStyle: const TextStyle(color: Color(0xFF6B7B84), fontSize: 12),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF8F9CA3), size: 20),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Color(0xFF8F9CA3), size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                      _loadData();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _showFiltrosSheet,
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161E22),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _filtroEstado != 'todos' ? const Color(0xFF00E676) : const Color(0xFF27343B),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.tune_rounded,
                              color: _filtroEstado != 'todos' ? const Color(0xFF00E676) : const Color(0xFF00E676),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _filtroEstado != 'todos'
                                  ? _filtroEstado[0].toUpperCase() + _filtroEstado.substring(1)
                                  : 'Filtros',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Filtros rápidos por estado
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFiltroPill('todos', 'Todos (${_pagos.length})'),
                      const SizedBox(width: 8),
                      _buildFiltroPill('pagado', 'Pagados'),
                      const SizedBox(width: 8),
                      _buildFiltroPill('pendiente', 'Pendientes'),
                      const SizedBox(width: 8),
                      _buildFiltroPill('vencido', 'Vencidos'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Pagos recientes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pagos recientes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _filtroEstado = 'todos';
                          _searchController.clear();
                        });
                        _loadData();
                      },
                      child: const Text(
                        'Ver todos',
                        style: TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Lista de tarjetas de pagos recientes
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: CircularProgressIndicator(color: Color(0xFF00E676)),
                    ),
                  )
                else if (_pagos.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161E22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF243037)),
                    ),
                    child: const Text(
                      'No se encontraron pagos registrados para la búsqueda.',
                      style: TextStyle(color: Color(0xFF8F9CA3), fontSize: 13),
                    ),
                  )
                else
                  ..._pagos.map((pago) => _buildPagoCard(pago)),

                const SizedBox(height: 20),

                // 4. Tarjeta Resumen de pagos (Este mes)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161E22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF243037), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resumen de pagos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Este mes',
                                style: TextStyle(
                                  color: Color(0xFF8F9CA3),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF00E676), width: 1.2),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Ver estadísticas',
                              style: TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // 3 Columnas de métricas con separadores
                      Row(
                        children: [
                          // Columna 1: Total recaudado
                          Expanded(
                            child: _buildResumenMetric(
                              icon: const Text(
                                '\$',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              iconBg: const Color(0xFF8B5CF6),
                              value: _resumen.formattedTotalRecaudado,
                              label: 'Total recaudado',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: const Color(0xFF243037),
                          ),

                          // Columna 2: Pagos realizados
                          Expanded(
                            child: _buildResumenMetric(
                              icon: const Icon(Icons.check, color: Colors.black, size: 16),
                              iconBg: const Color(0xFF00E676),
                              value: _resumen.pagosRealizados.toString(),
                              label: 'Pagos realizados',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: const Color(0xFF243037),
                          ),

                          // Columna 3: Pendientes
                          Expanded(
                            child: _buildResumenMetric(
                              icon: const Icon(Icons.access_time_filled, color: Colors.black, size: 16),
                              iconBg: const Color(0xFFF59E0B),
                              value: _resumen.pagosPendientes.toString(),
                              label: 'Pendientes',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagoCard(PagoModel pago) {
    Color badgeBg;
    Color badgeText;
    String badgeLabel;

    if (pago.isPagado) {
      badgeBg = const Color(0xFF133820);
      badgeText = const Color(0xFF00E676);
      badgeLabel = 'Pagado';
    } else if (pago.isPendiente) {
      badgeBg = const Color(0xFF3E2E14);
      badgeText = const Color(0xFFF59E0B);
      badgeLabel = 'Pendiente';
    } else {
      badgeBg = const Color(0xFF3E1818);
      badgeText = const Color(0xFFEF4444);
      badgeLabel = 'Vencido';
    }

    return GestureDetector(
      onTap: () => _showDetallePagoModal(pago),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF161E22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF243037), width: 1),
        ),
        child: Row(
          children: [
            // Avatar del socio
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.7), width: 1.5),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF00E676),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Nombre, Plan y Fecha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pago.socioNombre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    pago.plan,
                    style: const TextStyle(
                      color: Color(0xFF8F9CA3),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pago.fechaPago,
                    style: const TextStyle(
                      color: Color(0xFF8F9CA3),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Monto y Badge de estado
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  pago.formattedMonto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeLabel,
                    style: TextStyle(
                      color: badgeText,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Color(0xFF6B7B84), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenMetric({
    required Widget icon,
    required Color iconBg,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Center(child: icon),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8F9CA3),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
