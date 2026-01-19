import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mi_agenda/core/domain/dtos/task_dtos.dart';

import '../cubit/detail_cubit.dart';
import '../cubit/detail_state.dart';
import '../widgets/radio_checkbox.dart';
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

  late DateTime? _selectedNotificationDate;
  late TimeOfDay? _selectedNotificationTime;
  late int _priority = 2;
  late bool _isCompleted = false;

  bool _initialized = false;

  void _initFromTask(DetailedTaskDto task) {
    _titleCtrl = TextEditingController(text: task.title);
    _descCtrl = TextEditingController(text: task.description);

    final parsedDate = task.dueDate;
    _selectedDate = parsedDate;
    _selectedTime = parsedDate != null
        ? TimeOfDay.fromDateTime(parsedDate)
        : null;
    _selectedNotificationDate = task.notification?.notificationDate;
    _selectedNotificationTime = task.notification?.notificationDate != null
        ? TimeOfDay.fromDateTime(task.notification!.notificationDate)
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

  Future<void> _pickNotificationDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedNotificationDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() => _selectedNotificationDate = pickedDate);
    }
  }

  Future<void> _pickNotificationTime() async {
    final pickedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => TimePickerSpinner(
        initialTime: _selectedNotificationTime ?? TimeOfDay.now(),
        onTimeSelected: (selectedTime) {},
      ),
    );
    if (pickedTime != null) {
      setState(() => _selectedNotificationTime = pickedTime);
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

    final notificationDateTime =
        (_selectedNotificationDate != null && _selectedNotificationTime != null)
        ? DateTime(
            _selectedNotificationDate!.year,
            _selectedNotificationDate!.month,
            _selectedNotificationDate!.day,
            _selectedNotificationTime!.hour,
            _selectedNotificationTime!.minute,
          )
        : null;

    final task = context.read<DetailCubit>().selectedTask;
    if (task == null) return;

    final updatedTask = UpdateTaskDto(
      id: task.id,
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
      if (notificationDateTime != null) {
        await context.read<DetailCubit>().scheduleNotification(
          task.id,
          notificationDateTime,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea actualizada'),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
      context.pushReplacement("/projects/${task.projectId}");
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DetailCubit, DetailState>(
      listener: (context, state) {},
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
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            actions: [
              if (!isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => context.read<DetailCubit>().startEdit(),
                ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: _saveChanges,
                ),
            ],
          ),
          body: ColoredBox(
            color: Theme.of(context).colorScheme.primary.withAlpha(60),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: (state is DetailSuccess || state is DetailEdit)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _listItemEditable(
                                      task:
                                          (state as DetailSuccess).selectedTask,
                                      isEditing: state is DetailEdit,
                                    ),
                                    const SizedBox(height: 12),
                                    _detailCard(
                                      editInput: _editInput(
                                        icon: Icons.list_alt_outlined,
                                        controller: _descCtrl!,
                                        placeholder: "Añadir Descripción",
                                        isEditing: isEditing,
                                      ),
                                    ),
                                    _detailCard(
                                      editInput: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                              right: 8,
                                              top: 12,
                                              bottom: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: _editDatePicker(
                                                    icon: Icons.calendar_today,
                                                    placeholder: "Fecha Límite",
                                                    isEditing: isEditing,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: _editTimePicker(
                                                    icon: Icons.access_time,
                                                    placeholder: "Hora Límite",
                                                    isEditing: isEditing,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Divider(),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 8.0,
                                              right: 8,
                                              top: 12,
                                              bottom: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child:
                                                      _editNotificationDatePicker(
                                                        icon:
                                                            Icons.notifications,
                                                        placeholder:
                                                            "Fecha Límite",
                                                        isEditing: isEditing,
                                                      ),
                                                ),
                                                Expanded(
                                                  child:
                                                      _editNotificationTimePicker(
                                                        icon: Icons.access_time,
                                                        placeholder:
                                                            "Hora Límite",
                                                        isEditing: isEditing,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Divider(),
                                          ),
                                          _editInput(
                                            icon: Icons.loop,
                                            controller: TextEditingController(),
                                            placeholder: "Repetir...",
                                            isEditing: isEditing,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                ((state).selectedTask.completedAt != null)
                                    ? Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 8,
                                        ),
                                        color: Theme.of(
                                          context,
                                        ).appBarTheme.backgroundColor!,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,

                                          children: [
                                            Text(
                                              'Completada: ${DateFormat('dd/MM/yyyy h:mm a').format((state).selectedTask.completedAt!)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 24,
                                                color: Colors.red,
                                              ),
                                              onPressed: () async {
                                                Future.wait([
                                                  context
                                                      .read<DetailCubit>()
                                                      .deleteTask(),
                                                ]);
                                                context.pop();
                                                context.pushReplacement(
                                                  "/projects/${(state).selectedProject.id}",
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox(),
                              ],
                            )
                          : (state is DetailLoading)
                          ? Center(child: CircularProgressIndicator())
                          : Center(child: Text((state as DetailError).message)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _editNotificationTimePicker({
    required IconData icon,
    required String placeholder,
    required bool isEditing,

    EdgeInsets? padding,
  }) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 16),

      child: Row(
        spacing: 16,
        children: [
          Icon(icon),
          InkWell(
            onTap: isEditing ? _pickNotificationTime : null,
            child: SizedBox(
              child: Text(
                _selectedNotificationTime != null
                    ? MaterialLocalizations.of(context).formatTimeOfDay(
                        _selectedNotificationTime!,
                        alwaysUse24HourFormat: false,
                      )
                    : placeholder,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editNotificationDatePicker({
    required IconData icon,
    required String placeholder,
    required bool isEditing,

    EdgeInsets? padding,
  }) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 16),

      child: Row(
        spacing: 16,
        children: [
          Icon(icon),
          InkWell(
            onTap: isEditing ? _pickNotificationDate : null,
            child: SizedBox(
              child: Text(
                _selectedNotificationDate != null
                    ? DateFormat(
                        'dd/MM/yyyy',
                      ).format(_selectedNotificationDate!)
                    : placeholder,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editTimePicker({
    required IconData icon,
    required String placeholder,
    required bool isEditing,

    EdgeInsets? padding,
  }) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 16),

      child: Row(
        spacing: 16,
        children: [
          Icon(icon),
          InkWell(
            onTap: isEditing ? _pickTime : null,
            child: SizedBox(
              child: Text(
                _selectedTime != null
                    ? MaterialLocalizations.of(context).formatTimeOfDay(
                        _selectedTime!,
                        alwaysUse24HourFormat: false,
                      )
                    : placeholder,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editDatePicker({
    required IconData icon,
    required String placeholder,
    required bool isEditing,

    EdgeInsets? padding,
  }) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 16),

      child: Row(
        spacing: 16,
        children: [
          Icon(icon),
          InkWell(
            onTap: isEditing ? _pickDate : null,
            child: SizedBox(
              child: Text(
                _selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                    : placeholder,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editInput({
    required IconData icon,
    required TextEditingController controller,
    required String placeholder,
    required bool isEditing,
    EdgeInsets? padding,
  }) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        spacing: 4,
        children: [
          Icon(icon),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: isEditing,
              minLines: 1,
              maxLines: 4,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              decoration: InputDecoration(
                hintText: placeholder,
                isDense: true,
                border: const UnderlineInputBorder(),

                hintStyle: TextStyle(color: Theme.of(context).hintColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailCard({required Widget editInput}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 2,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
          child: editInput,
        ),
      ),
    );
  }

  Widget _listItemEditable({
    required DetailedTaskDto task,
    required bool isEditing,
  }) {
    return Material(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: ListTile(
        leading: RadioCheckbox(
          value: _isCompleted,
          color: Theme.of(context).textTheme.bodyLarge!.color!,
          borderColor: Theme.of(
            context,
          ).textTheme.bodyLarge!.color!.withAlpha(160),
          onTap: () =>
              isEditing ? setState(() => _isCompleted = !_isCompleted) : null,
        ),
        minTileHeight: 64,
        title: TextField(
          controller: _titleCtrl,
          enabled: isEditing,

          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge!.color,
          ),
          decoration: _inputDecoration(),
        ),
        subtitle: null,
        trailing: IconButton(
          onPressed: () {},
          icon: Icon(Icons.favorite_outline),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(color: Theme.of(context).hintColor),
    );
  }
}
