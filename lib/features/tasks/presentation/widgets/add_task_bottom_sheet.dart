import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'time_picker_spinner.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final void Function(String title, DateTime dueDate) onAdd;

  const AddTaskBottomSheet({super.key, required this.onAdd});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final _titleCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  String? _titleError;
  String? _dateError;

  @override
  void dispose() {
    _titleCtrl.dispose();
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

    final time = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => TimePickerSpinner(
        initialTime: _selectedTime ?? TimeOfDay.now(),
        onTimeSelected: (selectedTime) {},
      ),
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

    final totalSeconds = difference.inSeconds;
    final minutes = (totalSeconds / 60).ceil();
    final hours = (totalSeconds / 3600).floor();
    final days = (totalSeconds / 86400).floor();

    if (minutes < 60) {
      return 'Vence en ${minutes}m';
    } else if (hours < 24) {
      final remainingMinutes = ((totalSeconds % 3600) / 60).ceil();
      return 'Vence en ${hours}h ${remainingMinutes}m';
    } else {
      final remainingHours = ((totalSeconds % 86400) / 3600).floor();
      return 'Vence en ${days}d ${remainingHours}h';
    }
  }

  /// Formatea TimeOfDay a formato 12h AM/PM
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _handleAdd() {
    final title = _titleCtrl.text.trim();

    // Validaciones
    if (title.isEmpty) {
      setState(() => _titleError = 'El título es obligatorio');
      return;
    }

    // if (_selectedDate == null) {
    //   setState(() => _dateError = 'Selecciona fecha y hora');
    //   return;
    // }

    final dueDate = _getFullDueDate();
    if (dueDate.isBefore(DateTime.now())) {
      setState(() => _dateError = 'La fecha no puede ser pasada');
      return;
    }

    widget.onAdd(title, dueDate);
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
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,

              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.20),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Crear Nueva Tarea',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
                      ),
                    ),
                    onChanged: (_) {
                      if (_titleError != null) {
                        setState(() => _titleError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // FECHA Y HORA
                  const Text(
                    'Fecha límite',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
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
                                : DateFormat(
                                    'dd/MM/yyyy',
                                  ).format(_selectedDate!),
                            style: const TextStyle(fontSize: 14),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(
                              color: _dateError != null
                                  ? Colors.red
                                  : const Color(0xFFD9D9D9),
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
                                : _formatTime(_selectedTime!),
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

                  // Preview tiempo restante
                  if (_selectedDate != null && _dateError == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: Colors.green.shade700,
                          ),
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
                      child: const Text(
                        'Agregar Tarea',
                        style: TextStyle(fontSize: 16),
                      ),
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
