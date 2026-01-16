import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:mi_agenda/core/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Widget para grabar audio y enviarlo al procesamiento de IA
class AudioRecorderWidget extends StatefulWidget {
  final void Function(Uint8List audioBytes) onAudioRecorded;

  const AudioRecorderWidget({super.key, required this.onAudioRecorded});

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final _audioRecorder = FlutterSoundRecorder();

  bool _isRecording = false;
  bool _isProcessing = false;
  bool _isRecorderInitialized = false;
  int _secondsElapsed = 0;
  Timer? _timer;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isRecorderInitialized) {
      _audioRecorder.closeRecorder();
    }
    super.dispose();
  }

  /// Inicializa el recorder
  Future<void> _initializeRecorder() async {
    try {
      await _audioRecorder.openRecorder();
      setState(() => _isRecorderInitialized = true);
    } catch (e) {
      debugPrint('Error inicializando recorder: $e');
    }
  }

  /// Solicita permisos de micrófono
  Future<bool> _requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Inicia grabación de audio
  Future<void> _startRecording() async {
    if (!_isRecorderInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recorder no inicializado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Verificar permisos
      final hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Se requiere permiso de micrófono'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Configurar path temporal
      final tempDir = await getTemporaryDirectory();
      _recordedFilePath =
          '${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      // Iniciar grabación en formato AAC
      await _audioRecorder.startRecorder(
        toFile: _recordedFilePath!,
        codec: Codec.aacADTS, // AAC = mejor compresión
        bitRate: 128000, // 128kbps = calidad suficiente para voz
        sampleRate: 44100,
      );

      setState(() {
        _isRecording = true;
        _secondsElapsed = 0;
      });

      // Iniciar timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _secondsElapsed++);

        // Auto-detener al llegar al límite
        if (_secondsElapsed >= Constants.MAX_AUDIO_DURATION_SECONDS) {
          _stopRecording();
        }
      });

      debugPrint('🎤 Grabación iniciada: $_recordedFilePath');
    } catch (e) {
      debugPrint('Error iniciando grabación: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al grabar: $e')));
      }
    }
  }

  /// Detiene grabación y envía audio al padre
  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      _timer?.cancel();

      await _audioRecorder.stopRecorder();

      setState(() {
        _isRecording = false;
        _isProcessing = true;
      });

      if (_recordedFilePath == null) {
        throw Exception('No se generó archivo de audio');
      }

      debugPrint(
        '🎤 Grabación detenida: $_recordedFilePath (${_secondsElapsed}s)',
      );

      // Validar duración mínima (2 segundos)
      if (_secondsElapsed < 2) {
        throw Exception('Audio muy corto. Graba al menos 2 segundos');
      }

      // Leer bytes del archivo
      final file = File(_recordedFilePath!);
      final audioBytes = await file.readAsBytes();

      debugPrint('📦 Audio leído: ${audioBytes.length} bytes');

      // Eliminar archivo temporal
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Archivo temporal eliminado');
      }

      // Llamar callback (el padre maneja el cierre del bottom sheet)
      if (mounted) {
        widget.onAudioRecorded(audioBytes);
      }
    } catch (e) {
      debugPrint('Error deteniendo grabación: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Cancela grabación sin procesar
  Future<void> _cancelRecording() async {
    _timer?.cancel();
    if (_isRecording && _isRecorderInitialized) {
      await _audioRecorder.stopRecorder();
    }

    // Eliminar archivo si existe
    if (_recordedFilePath != null) {
      final file = File(_recordedFilePath!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          if (_isProcessing) ...[
            // Estado: Procesando
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'Procesando audio...',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ] else if (_isRecording) ...[
            // Estado: Grabando
            _buildRecordingUI(),
          ] else ...[
            // Estado: Idle
            _buildIdleUI(),
          ],
        ],
      ),
    );
  }

  Widget _buildIdleUI() {
    return Column(
      children: [
        // Icono de micrófono
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mic, size: 40, color: Colors.blue.shade400),
        ),

        const SizedBox(height: 24),

        const Text(
          'Dictar tarea con voz',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 12),

        Text(
          'Presiona grabar y dicta tu tarea.\nLa IA transcribirá y creará la tarea automáticamente.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Máximo: ${Constants.MAX_AUDIO_DURATION_SECONDS} segundos',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),

        const SizedBox(height: 32),

        // Botón grabar
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startRecording,
            icon: const Icon(Icons.fiber_manual_record),
            label: const Text('Iniciar grabación'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Botón cancelar
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordingUI() {
    final progress = _secondsElapsed / Constants.MAX_AUDIO_DURATION_SECONDS;

    return Column(
      children: [
        // Indicador visual pulsante
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.9, end: 1.1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade200,
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.mic, size: 50, color: Colors.white),
              ),
            );
          },
          onEnd: () {
            if (_isRecording && mounted) {
              setState(() {}); // Trigger rebuild para loop animación
            }
          },
        ),

        const SizedBox(height: 24),

        const Text(
          'Grabando...',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        // Timer
        Text(
          _formatDuration(_secondsElapsed),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade400,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),

        const SizedBox(height: 8),

        // Barra de progreso
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade400),
        ),

        const SizedBox(height: 32),

        // Botones
        Row(
          children: [
            // Cancelar
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _cancelRecording,
                icon: const Icon(Icons.close),
                label: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Detener
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _stopRecording,
                icon: const Icon(Icons.stop),
                label: const Text('Enviar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
