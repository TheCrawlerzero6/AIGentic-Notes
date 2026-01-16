import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mi_agenda/features/tasks/domain/dtos/task_dtos.dart';

import '../../domain/entities/task.dart';
import '../cubit/detail_cubit.dart';
import '../cubit/detail_state.dart';
import '../widgets/time_picker_spinner.dart';

class TaskDetailScreen extends StatefulWidget {
  final int taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController? _titleCtrl;
  late TextEditingController? _descCtrl;
  late DateTime? _selectedDate;
  late TimeOfDay? _selectedTime;
  late int _priority = 2;
  late bool _isCompleted = false;

  bool _initialized = false;

  void _initFromTask(Task task) {
    _titleCtrl = TextEditingController(text: task.title);
    _descCtrl = TextEditingController(text: task.description);

    final parsedDate = task.dueDate;
    _selectedDate = parsedDate;
    _selectedTime = parsedDate != null
        ? TimeOfDay.fromDateTime(parsedDate)
        : null;

    _priority = task.priority;
    _isCompleted = task.isCompleted;

    _initialized = true;
  }

  @override
  void dispose() {
    _titleCtrl?.dispose();
    _descCtrl?.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
        initialTime: _selectedTime ?? TimeOfDay.now(),
        onTimeSelected: (selectedTime) {},
      ),
    );
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
    }
  }

  /// Guarda cambios en la tarea
  Future<void> _saveChanges() async {
    if (!_initialized) return;
    if (_titleCtrl!.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El título no puede estar vacío')),
      );
      return;
    }

    final dueDateTime = (_selectedDate != null && _selectedTime != null)
        ? DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          )
        : null;
    final task = context.read<DetailCubit>().selectedTask;
    if (task == null) return;

    final updatedTask = UpdateTaskDto(
      id: task.id!,
      projectId: task.projectId,
      title: _titleCtrl?.text.trim() ?? "",
      description: _descCtrl?.text.trim() ?? "",
      dueDate: dueDateTime,
      isCompleted: _isCompleted,
      completedAt: _isCompleted ? DateTime.now() : null,
      notificationId: task.notificationId,
      sourceType: task.sourceType,
      priority: _priority,
      createdAt: task.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      await context.read<DetailCubit>().updateTask(updatedTask);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea actualizada'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailCubit, DetailState>(
      builder: (context, state) {
        final isEditing = state is DetailEdit;
        if (state is DetailSuccess || state is DetailEdit) {
          if (!_initialized) {
            _initFromTask((state as DetailSuccess).selectedTask);
          }
        }
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(
              isEditing ? 'Editar Tarea' : 'Detalle de Tarea',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              if (!isEditing)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () => context.read<DetailCubit>().startEdit(),
                ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: _saveChanges,
                ),
              if (state is DetailSuccess || state is DetailEdit)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    Future.wait([context.read<DetailCubit>().deleteTask()]);
                    context.go(
                      "/projects/${(state as DetailSuccess).selectedProject.id}",
                    );
                  },
                ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: (state is DetailSuccess || state is DetailEdit)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Título'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleCtrl,
                          enabled: isEditing,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: _inputDecoration(),
                        ),

                        const SizedBox(height: 20),

                        _sectionLabel('Descripción'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descCtrl,
                          enabled: isEditing,
                          maxLines: 4,
                          decoration: _inputDecoration(),
                        ),

                        const SizedBox(height: 20),

                        _sectionLabel('Fecha Límite'),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: isEditing ? _pickDate : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedDate != null
                                      ? DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(_selectedDate!)
                                      : "",
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
                          onTap: isEditing ? _pickTime : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 20),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedTime != null
                                      ? MaterialLocalizations.of(
                                          context,
                                        ).formatTimeOfDay(
                                          _selectedTime!,
                                          alwaysUse24HourFormat: false,
                                        )
                                      : "",
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
                            ButtonSegment(
                              value: 1,
                              label: Text('Baja'),
                              icon: Icon(Icons.arrow_downward),
                            ),
                            ButtonSegment(
                              value: 2,
                              label: Text('Media'),
                              icon: Icon(Icons.remove),
                            ),
                            ButtonSegment(
                              value: 3,
                              label: Text('Alta'),
                              icon: Icon(Icons.arrow_upward),
                            ),
                          ],
                          selected: {_priority},
                          onSelectionChanged: isEditing
                              ? (Set<int> selected) {
                                  setState(() => _priority = selected.first);
                                }
                              : null,
                        ),

                        const SizedBox(height: 20),

                        SwitchListTile(
                          title: const Text('Tarea Completada'),
                          value: _isCompleted,
                          onChanged: isEditing
                              ? (value) => setState(() => _isCompleted = value)
                              : null,
                          activeTrackColor: const Color(0xFF6750A4),
                        ),

                        const SizedBox(height: 10),

                        if ((state as DetailSuccess).selectedTask.completedAt !=
                            null)
                          Text(
                            'Completada: ${DateFormat('dd/MM/yyyy h:mm a').format((state).selectedTask.completedAt!)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    )
                  : (state is DetailLoading)
                  ? Center(child: CircularProgressIndicator())
                  : Center(child: Text((state as DetailError).message)),
            ),
          ),
        );
      },
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
