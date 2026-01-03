import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/task_model.dart';
import '../../../providers/task_provider.dart';
import 'package:intl/intl.dart';
import '../../widgets/time_picker_spinner.dart';

/// Pantalla de detalle/edición de tarea
/// 
/// Permite ver todos los campos de una tarea y editarlos
/// - Título
/// - Descripción
/// - Fecha límite
/// - Hora
/// - Prioridad
/// - Estado completado
class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _priority;
  late bool _isCompleted;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _descCtrl = TextEditingController(text: widget.task.description);
    final parsedDate = DateTime.parse(widget.task.dueDate);
    _selectedDate = parsedDate;
    _selectedTime = TimeOfDay.fromDateTime(parsedDate);
    _priority = widget.task.priority;
    _isCompleted = widget.task.isCompleted == 1;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// Abre selector de fecha
  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  /// Abre selector de hora
  Future<void> _pickTime() async {
    final pickedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => TimePickerSpinner(
        initialTime: _selectedTime,
        onTimeSelected: (selectedTime) {},
      ),
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  /// Guarda cambios en la tarea
  Future<void> _saveChanges() async {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título no puede estar vacío')),
      );
      return;
    }

    final dueDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final updatedTask = TaskModel(
      id: widget.task.id,
      userId: widget.task.userId,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      dueDate: dueDateTime.toIso8601String(),
      isCompleted: _isCompleted ? 1 : 0,
      completedAt: _isCompleted ? DateTime.now().toIso8601String() : null,
      notificationId: widget.task.notificationId,
      sourceType: widget.task.sourceType,
      priority: _priority,
    );

    try {
      await context.read<TaskProvider>().updateTask(updatedTask);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea actualizada'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _isEditing = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }

  // ignore: use_build_context_synchronously
  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Tarea'),
        content: const Text('¿Estás seguro de eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await context.read<TaskProvider>().deleteTask(widget.task.id!);
        if (!mounted) return;
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarea eliminada'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Editar Tarea' : 'Detalle de Tarea',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: _saveChanges,
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Título'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleCtrl,
                enabled: _isEditing,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: _inputDecoration(),
              ),

              const SizedBox(height: 20),

              _sectionLabel('Descripción'),
              const SizedBox(height: 8),
              TextField(
                controller: _descCtrl,
                enabled: _isEditing,
                maxLines: 4,
                decoration: _inputDecoration(),
              ),

              const SizedBox(height: 20),

              _sectionLabel('Fecha Límite'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isEditing ? _pickDate : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _sectionLabel('Hora'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _isEditing ? _pickTime : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        MaterialLocalizations.of(context).formatTimeOfDay(_selectedTime, alwaysUse24HourFormat: false),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _sectionLabel('Prioridad'),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('Baja'), icon: Icon(Icons.arrow_downward)),
                  ButtonSegment(value: 2, label: Text('Media'), icon: Icon(Icons.remove)),
                  ButtonSegment(value: 3, label: Text('Alta'), icon: Icon(Icons.arrow_upward)),
                ],
                selected: {_priority},
                onSelectionChanged: _isEditing
                    ? (Set<int> selected) {
                        setState(() => _priority = selected.first);
                      }
                    : null,
              ),

              const SizedBox(height: 20),

              SwitchListTile(
                title: const Text('Tarea Completada'),
                value: _isCompleted,
                onChanged: _isEditing
                    ? (value) => setState(() => _isCompleted = value)
                    : null,
                activeTrackColor: const Color(0xFF6750A4),
              ),

              const SizedBox(height: 10),

              if (widget.task.completedAt != null)
                Text(
                  'Completada: ${DateFormat('dd/MM/yyyy h:mm a').format(DateTime.parse(widget.task.completedAt!))}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
