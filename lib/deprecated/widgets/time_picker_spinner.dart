import 'package:flutter/material.dart';

/// Selector de tiempo con rueditas deslizables
/// Formato: 12 horas con AM/PM
class TimePickerSpinner extends StatefulWidget {
  final TimeOfDay initialTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerSpinner({
    super.key,
    required this.initialTime,
    required this.onTimeSelected,
  });

  @override
  State<TimePickerSpinner> createState() => _TimePickerSpinnerState();
}

class _TimePickerSpinnerState extends State<TimePickerSpinner> {
  late int _hour;
  late int _minute;
  late bool _isPM;
  
  final FixedExtentScrollController _hourScrollController = FixedExtentScrollController();
  final FixedExtentScrollController _minuteScrollController = FixedExtentScrollController();
  final FixedExtentScrollController _periodScrollController = FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    
    // Convertir hora de 24h a 12h
    final hour24 = widget.initialTime.hour;
    _isPM = hour24 >= 12;
    _hour = hour24 > 12 ? hour24 - 12 : (hour24 == 0 ? 12 : hour24);
    _minute = widget.initialTime.minute;
    
    // Inicializar scroll controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hourScrollController.jumpToItem(_hour - 1);
      _minuteScrollController.jumpToItem(_minute);
      _periodScrollController.jumpToItem(_isPM ? 1 : 0);
    });
  }

  @override
  void dispose() {
    _hourScrollController.dispose();
    _minuteScrollController.dispose();
    _periodScrollController.dispose();
    super.dispose();
  }

  TimeOfDay _getCurrentTime() {
    // Convertir de 12h a 24h
    int hour24 = _hour;
    if (_isPM && _hour != 12) {
      hour24 = _hour + 12;
    } else if (!_isPM && _hour == 12) {
      hour24 = 0;
    }
    return TimeOfDay(hour: hour24, minute: _minute);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 420),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Seleccionar hora',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Display de hora seleccionada
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isPM ? 'PM' : 'AM',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Rueditas (spinners)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spinner de horas
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: _hourScrollController,
                      itemExtent: 45,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => _hour = index + 1);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 12,
                        builder: (context, index) {
                          final hour = index + 1;
                          final isSelected = hour == _hour;
                          return Center(
                            child: Text(
                              hour.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 20,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.blue : Colors.grey.shade400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(':', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                  
                  // Spinner de minutos
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: _minuteScrollController,
                      itemExtent: 45,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => _minute = index);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: 60,
                        builder: (context, index) {
                          final isSelected = index == _minute;
                          return Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: isSelected ? 28 : 20,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.blue : Colors.grey.shade400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Spinner AM/PM
                  SizedBox(
                    width: 55,
                    child: ListWheelScrollView(
                      controller: _periodScrollController,
                      itemExtent: 45,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => _isPM = index == 1);
                      },
                      children: [
                        Center(
                          child: Text(
                            'AM',
                            style: TextStyle(
                              fontSize: !_isPM ? 22 : 18,
                              fontWeight: !_isPM ? FontWeight.bold : FontWeight.normal,
                              color: !_isPM ? Colors.blue : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            'PM',
                            style: TextStyle(
                              fontSize: _isPM ? 22 : 18,
                              fontWeight: _isPM ? FontWeight.bold : FontWeight.normal,
                              color: _isPM ? Colors.blue : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _getCurrentTime()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Aceptar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
