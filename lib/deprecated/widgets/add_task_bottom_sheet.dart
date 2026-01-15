// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'dart:typed_data';
// import '../../data/services/ai_service.dart';
// import 'time_picker_spinner.dart';
// import 'ai_options_widget.dart';
// import 'audio_recorder_widget.dart';
// import 'file_picker_widget.dart';

// class AddTaskBottomSheet extends StatefulWidget {
//   final void Function(String title, String description, DateTime dueDate, int priority) onAdd;

//   const AddTaskBottomSheet({super.key, required this.onAdd});

//   @override
//   State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
// }

// class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();

//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   int _priority = 2; // 1=Baja, 2=Media, 3=Alta

//   String? _titleError;
//   String? _dateError;
  
//   bool _isProcessingAI = false;

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _descCtrl.dispose();
//     super.dispose();
//   }

//   /// Abre DatePicker para seleccionar fecha
//   Future<void> _pickDate() async {
//     final now = DateTime.now();
//     final date = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? now,
//       firstDate: now,
//       lastDate: DateTime(now.year + 2),
//     );

//     if (date != null) {
//       setState(() {
//         _selectedDate = date;
//         _dateError = null;
//       });
//     }
//   }

//   /// Abre TimePicker para seleccionar hora
//   Future<void> _pickTime() async {
//     if (_selectedDate == null) {
//       setState(() => _dateError = 'Primero selecciona una fecha');
//       return;
//     }

//     final time = await showDialog<TimeOfDay>(
//       context: context,
//       builder: (context) => TimePickerSpinner(
//         initialTime: _selectedTime ?? TimeOfDay.now(),
//         onTimeSelected: (selectedTime) {},
//       ),
//     );

//     if (time != null) {
//       setState(() {
//         _selectedTime = time;
//         _dateError = null;
//       });
//     }
//   }

//   /// Obtiene DateTime completo combinando fecha y hora
//   DateTime _getFullDueDate() {
//     final date = _selectedDate ?? DateTime.now();
//     final time = _selectedTime ?? const TimeOfDay(hour: 23, minute: 59);
//     return DateTime(date.year, date.month, date.day, time.hour, time.minute);
//   }

//   /// Calcula texto preview "Vence en X horas/días"
//   String _getTimeRemainingPreview() {
//     if (_selectedDate == null) return '';

//     final dueDate = _getFullDueDate();
//     final now = DateTime.now();
//     final difference = dueDate.difference(now);

//     if (difference.isNegative) return 'Fecha pasada';
    
//     final totalSeconds = difference.inSeconds;
//     final minutes = (totalSeconds / 60).ceil();
//     final hours = (totalSeconds / 3600).floor();
//     final days = (totalSeconds / 86400).floor();
    
//     if (minutes < 60) {
//       return 'Vence en ${minutes}m';
//     } else if (hours < 24) {
//       final remainingMinutes = ((totalSeconds % 3600) / 60).ceil();
//       return 'Vence en ${hours}h ${remainingMinutes}m';
//     } else {
//       final remainingHours = ((totalSeconds % 86400) / 3600).floor();
//       return 'Vence en ${days}d ${remainingHours}h';
//     }
//   }

//   /// Formatea TimeOfDay a formato 12h AM/PM
//   String _formatTime(TimeOfDay time) {
//     final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
//     final minute = time.minute.toString().padLeft(2, '0');
//     final period = time.period == DayPeriod.am ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }

//   /// Muestra opciones multimodales de IA
//   void _showAIOptions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (context) => AIOptionsWidget(
//         onImageSelected: (bytes) => _processWithAI(bytes, ContentType.image),
//         onAudioSelected: _showAudioRecorder,
//         onFileSelected: _showFilePlaceholder,
//       ),
//     );
//   }

//   /// Muestra grabador de audio
//   void _showAudioRecorder() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       isDismissible: false, // No cerrar accidentalmente durante grabación
//       enableDrag: false,
//       builder: (context) => AudioRecorderWidget(
//         onAudioRecorded: (bytes) => _processWithAI(bytes, ContentType.audio),
//       ),
//     );
//   }

//   /// Muestra placeholder de Excel
//   void _showFilePlaceholder() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const FilePickerWidget(),
//     );
//   }

//   /// Procesa contenido con IA y autocompleta formulario
//   Future<void> _processWithAI(Uint8List data, ContentType type) async {
//     setState(() => _isProcessingAI = true);

//     try {
//       final aiService = AiService();
//       const userId = 1;
      
//       final tasks = await aiService.processMultimodalContent(
//         data: data,
//         type: type,
//         userId: userId,
//       );

//       if (tasks.isEmpty) {
//         if (mounted) {
//           // Cerrar grabador/opciones de IA
//           Navigator.pop(context);
          
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('No se encontraron tareas en ${type == ContentType.image ? 'la imagen' : 'el audio'}'),
//             ),
//           );
//         }
//         return;
//       }

//       // Autocompletar con primera tarea (MVP: solo 1 tarea)
//       final task = tasks.first;
//       setState(() {
//         _titleCtrl.text = task.title;
//         _descCtrl.text = task.description;
        
//         // Parsear dueDate string a DateTime
//         final dueDate = DateTime.parse(task.dueDate);
//         _selectedDate = dueDate;
//         _selectedTime = TimeOfDay.fromDateTime(dueDate);
        
//         _priority = task.priority;
        
//         // Limpiar errores
//         _titleError = null;
//         _dateError = null;
//       });

//       if (mounted) {
//         // Cerrar el bottom sheet del grabador/opciones de IA automáticamente
//         Navigator.pop(context);
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('✓ Campos completados con IA (${type == ContentType.audio ? 'audio' : 'imagen'})'),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('❌ Error procesando contenido (${type.name}): $e');
      
//       if (mounted) {
//         // Cerrar grabador/opciones de IA antes de mostrar error
//         Navigator.pop(context);
        
//         String errorMsg = type == ContentType.audio 
//             ? 'Error procesando audio' 
//             : 'Error procesando imagen';
        
//         // Mensajes específicos según el tipo de error
//         if (e.toString().contains('no pudo extraer información válida')) {
//           errorMsg = type == ContentType.audio
//               ? 'No se detectó una tarea clara en el audio'
//               : 'La imagen no contiene texto legible o tareas';
//         } else if (e.toString().contains('Configura tu API key')) {
//           errorMsg = 'Configura tu API key de Gemini en Google AI Studio';
//         } else if (e.toString().contains('quota') || e.toString().contains('Límite de API')) {
//           errorMsg = 'Límite de API alcanzado. Intenta más tarde';
//         } else if (e.toString().contains('no pudo procesar')) {
//           errorMsg = type == ContentType.audio
//               ? 'La IA no pudo transcribir el audio. Habla más claro'
//               : 'La IA no pudo leer la imagen. Intenta con otra más clara';
//         } else if (e.toString().contains('no encontraron tareas')) {
//           errorMsg = type == ContentType.audio
//               ? 'No se encontraron tareas en el audio'
//               : 'No se encontraron tareas en la imagen';
//         } else if (e.toString().contains('muy corto')) {
//           errorMsg = 'Audio muy corto. Graba al menos 2 segundos';
//         } else if (e.toString().contains('permiso')) {
//           errorMsg = 'Se requiere permiso de micrófono';
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMsg),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 4),
//             action: SnackBarAction(
//               label: 'OK',
//               textColor: Colors.white,
//               onPressed: () {},
//             ),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessingAI = false);
//       }
//     }
//   }

//   void _handleAdd() {
//     final title = _titleCtrl.text.trim();
//     final desc = _descCtrl.text.trim();

//     // Validaciones
//     if (title.isEmpty) {
//       setState(() => _titleError = 'El título es obligatorio');
//       return;
//     }

//     if (_selectedDate == null) {
//       setState(() => _dateError = 'Selecciona fecha y hora');
//       return;
//     }

//     final dueDate = _getFullDueDate();
//     if (dueDate.isBefore(DateTime.now())) {
//       setState(() => _dateError = 'La fecha no puede ser pasada');
//       return;
//     }

//     widget.onAdd(
//       title,
//       desc.isEmpty ? '(Sin descripción)' : desc,
//       dueDate,
//       _priority,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Container(
//         padding: EdgeInsets.only(bottom: bottomPadding),
//         child: Align(
//           alignment: Alignment.bottomCenter,
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(28),
//                 topRight: Radius.circular(28),
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Color.fromRGBO(0, 0, 0, 0.20),
//                   blurRadius: 10,
//                   offset: Offset(0, -2),
//                 )
//               ],
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Crear Nueva Tarea',
//                         style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//                       ),
//                       // Botón IA mejorado
//                       _isProcessingAI
//                           ? const Padding(
//                               padding: EdgeInsets.all(8.0),
//                               child: SizedBox(
//                                 width: 24,
//                                 height: 24,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               ),
//                             )
//                           : TextButton.icon(
//                               onPressed: _showAIOptions,
//                               icon: const Icon(Icons.auto_awesome, size: 20),
//                               label: const Text('Llenar con IA'),
//                               style: TextButton.styleFrom(
//                                 foregroundColor: Colors.purple.shade700,
//                                 backgroundColor: Colors.purple.shade50,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 8,
//                                 ),
//                               ),
//                             ),
//                     ],
//                   ),
//                   const SizedBox(height: 14),

//                   // TÍTULO
//                   const Text('Título', style: TextStyle(fontSize: 14)),
//                   const SizedBox(height: 6),
//                   TextField(
//                     controller: _titleCtrl,
//                     decoration: InputDecoration(
//                       hintText: 'Ej: Reunión con el equipo',
//                       errorText: _titleError,
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
//                       ),
//                     ),
//                     onChanged: (_) {
//                       if (_titleError != null) setState(() => _titleError = null);
//                     },
//                   ),

//                   const SizedBox(height: 12),

//                   // DESCRIPCIÓN
//                   const Text('Descripción', style: TextStyle(fontSize: 14)),
//                   const SizedBox(height: 6),
//                   TextField(
//                     controller: _descCtrl,
//                     maxLines: 2,
//                     decoration: InputDecoration(
//                       hintText: 'Detalles adicionales (opcional)',
//                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: const BorderSide(color: Color(0xFFD9D9D9)),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // FECHA Y HORA
//                   const Text('Fecha límite', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 8),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: _pickDate,
//                           icon: const Icon(Icons.calendar_today, size: 18),
//                           label: Text(
//                             _selectedDate == null
//                                 ? 'Fecha'
//                                 : DateFormat('dd/MM/yyyy').format(_selectedDate!),
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             side: BorderSide(
//                               color: _dateError != null ? Colors.red : const Color(0xFFD9D9D9),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: OutlinedButton.icon(
//                           onPressed: _pickTime,
//                           icon: const Icon(Icons.access_time, size: 18),
//                           label: Text(
//                             _selectedTime == null
//                                 ? 'Hora'
//                                 : _formatTime(_selectedTime!),
//                             style: const TextStyle(fontSize: 14),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             side: const BorderSide(color: Color(0xFFD9D9D9)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Error fecha
//                   if (_dateError != null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 4),
//                       child: Text(
//                         _dateError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ),

//                   // Preview tiempo restante
//                   if (_selectedDate != null && _dateError == null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 6),
//                       child: Row(
//                         children: [
//                           Icon(Icons.timer_outlined, size: 16, color: Colors.green.shade700),
//                           const SizedBox(width: 4),
//                           Text(
//                             _getTimeRemainingPreview(),
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.green.shade700,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   const SizedBox(height: 16),

//                   // PRIORIDAD
//                   const Text('Prioridad', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//                   const SizedBox(height: 8),
//                   SegmentedButton<int>(
//                     segments: const [
//                       ButtonSegment(value: 1, label: Text('Baja'), icon: Icon(Icons.arrow_downward, size: 16)),
//                       ButtonSegment(value: 2, label: Text('Media'), icon: Icon(Icons.remove, size: 16)),
//                       ButtonSegment(value: 3, label: Text('Alta'), icon: Icon(Icons.arrow_upward, size: 16)),
//                     ],
//                     selected: {_priority},
//                     onSelectionChanged: (Set<int> newSelection) {
//                       setState(() => _priority = newSelection.first);
//                     },
//                     style: ButtonStyle(
//                       visualDensity: VisualDensity.compact,
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // BOTÓN AGREGAR
//                   SizedBox(
//                     width: double.infinity,
//                     height: 44,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF6750A4),
//                         foregroundColor: Colors.white,
//                         shape: const StadiumBorder(),
//                       ),
//                       onPressed: _handleAdd,
//                       child: const Text('Agregar Tarea', style: TextStyle(fontSize: 16)),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
