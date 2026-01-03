import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final void Function(String title, String description, DateTime dueDate, int priority) onAdd;

  const AddTaskBottomSheet({super.key, required this.onAdd});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _priority = 2; // 1=Baja, 2=Media, 3=Alta

  String? _titleError;
  String? _dateError;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// Abre DatePicker para seleccionar fecha
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dateError = null;
      });
    }
  }

  /// Abre TimePicker para seleccionar hora
  Future<void> _pickTime() async {
    if (_selectedDate == null) {
      setState(() => _dateError = 'Primero selecciona una fecha');
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input, // Modo entrada para evitar bugs visuales
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
        _dateError = null;
      });
    }
  }

  /// Obtiene DateTime completo combinando fecha y hora
  DateTime _getFullDueDate() {
    final date = _selectedDate ?? DateTime.now();
    final time = _selectedTime ?? const TimeOfDay(hour: 23, minute: 59);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  /// Calcula texto preview "Vence en X horas/días"
  String _getTimeRemainingPreview() {
    if (_selectedDate == null) return '';

    final dueDate = _getFullDueDate();
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) return 'Fecha pasada';
    if (difference.inMinutes < 60) return 'Vence en ${difference.inMinutes}m';
    if (difference.inHours < 24) return 'Vence en ${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    return 'Vence en ${difference.inDays}d ${difference.inHours.remainder(24)}h';
  }

  void _handleAdd() {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    // Validaciones
    if (title.isEmpty) {
      setState(() => _titleError = 'El título es obligatorio');
      return;
    }

    if (_selectedDate == null) {
      setState(() => _dateError = 'Selecciona fecha y hora');
      return;
    }

    final dueDate = _getFullDueDate();
    if (dueDate.isBefore(DateTime.now())) {
      setState(() => _dateError = 'La fecha no puede ser pasada');
      return;
    }

    widget.onAdd(
      title,
      desc.isEmpty ? '(Sin descripción)' : desc,
      dueDate,
      _priority,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.20),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crear Nueva Tarea',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),

                  // TÍTULO
                  const Text('Título', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      hintText: 'Ej: Reunión con el equipo',
                      errorText: _titleError,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                    ),
                    onChanged: (_) {
                      if (_titleError != null) setState(() => _titleError = null);
                    },
                  ),

                  const SizedBox(height: 12),

                  // DESCRIPCIÓN
                  const Text('Descripción', style: TextStyle(fontSize: 14)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Detalles adicionales (opcional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // FECHA Y HORA
                  const Text('Fecha límite', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            _selectedDate == null
                                ? 'Fecha'
                                : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: _dateError != null ? Colors.red : const Color(0xFFD9D9D9),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickTime,
                          icon: const Icon(Icons.access_time, size: 18),
                          label: Text(
                            _selectedTime == null
                                ? 'Hora'
                                : _selectedTime!.format(context),
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFD9D9D9)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Error fecha
                  if (_dateError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _dateError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),

                  // Preview tiempo restante
                  if (_selectedDate != null && _dateError == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 4),
                          Text(
                            _getTimeRemainingPreview(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // PRIORIDAD
                  const Text('Prioridad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 1, label: Text('Baja'), icon: Icon(Icons.arrow_downward, size: 16)),
                      ButtonSegment(value: 2, label: Text('Media'), icon: Icon(Icons.remove, size: 16)),
                      ButtonSegment(value: 3, label: Text('Alta'), icon: Icon(Icons.arrow_upward, size: 16)),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() => _priority = newSelection.first);
                    },
                    style: ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BOTÓN AGREGAR
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6750A4),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _handleAdd,
                      child: const Text('Agregar Tarea', style: TextStyle(fontSize: 16)),
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
}
