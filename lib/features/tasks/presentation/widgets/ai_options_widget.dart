import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class AIOptionsWidget extends StatelessWidget {
  final void Function(Uint8List imageBytes) onImageSelected;
  final VoidCallback onAudioSelected;
  final VoidCallback onFileSelected;

  const AIOptionsWidget({
    super.key,
    required this.onImageSelected,
    required this.onAudioSelected,
    required this.onFileSelected,
  });

  Future<void> _captureFromCamera(BuildContext context) async {
    final picker = ImagePicker();

    try {
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        final compressed = await _compressImage(bytes);
        if (context.mounted) {
          Navigator.pop(context);
          onImageSelected(compressed);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al capturar foto: $e')));
      }
    }
  }

  Future<void> _pickFromGallery(BuildContext context) async {
    final picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final compressed = await _compressImage(bytes);
        if (context.mounted) {
          Navigator.pop(context);
          onImageSelected(compressed);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar imagen: $e')),
        );
      }
    }
  }

  Future<Uint8List> _compressImage(Uint8List bytes) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) {
        debugPrint('⚠️ No se pudo decodificar imagen, usando original');
        return bytes;
      }

      // Validar tamaño mínimo para evitar "Invalid size"
      if (image.width < 10 || image.height < 10) {
        debugPrint(
          '⚠️ Imagen muy pequeña (${image.width}x${image.height}), usando original',
        );
        return bytes;
      }

      debugPrint('📷 Imagen: ${image.width}x${image.height}');

      // Solo redimensionar si es necesario
      if (image.width <= 1920 && image.height <= 1920) {
        final compressed = img.encodeJpg(image, quality: 85);
        return Uint8List.fromList(compressed);
      }

      final resized = img.copyResize(
        image,
        width: image.width > 1920 ? 1920 : null,
        height: image.height > 1920 ? 1920 : null,
      );

      final compressed = img.encodeJpg(resized, quality: 85);
      debugPrint('✓ Comprimida: ${compressed.length / 1024} KB');
      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('❌ Error comprimiendo: $e');
      return bytes;
    }
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Escanear Imagen',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.camera_alt, color: Colors.purple.shade700),
              ),
              title: const Text(
                'Tomar Foto',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Usa la cámara'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _captureFromCamera(context),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.photo_library, color: Colors.blue.shade700),
              ),
              title: const Text(
                'Galería',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Selecciona imagen'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _pickFromGallery(context),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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

          const Text(
            'Crear con IA',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Elige cómo quieres crear la tarea',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 24),

          // Opción 1: IMAGEN (Funcional)
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.image, color: Colors.purple.shade700, size: 24),
            ),
            title: const Text(
              'Escanear Imagen',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Foto o captura de pantalla'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ACTIVO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () => _showImageOptions(context),
          ),

          const Divider(height: 24),

          // Opción 2: AUDIO (Funcional)
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.mic, color: Colors.orange.shade700, size: 24),
            ),
            title: const Text(
              'Dictar con Voz',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Graba un mensaje de audio'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ACTIVO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              onAudioSelected();
            },
          ),

          const Divider(height: 24),

          // Opción 3: EXCEL (Placeholder)
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.table_chart,
                color: Colors.teal.shade700,
                size: 24,
              ),
            ),
            title: const Text(
              'Importar Excel',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Sube un archivo .xlsx'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PRÓXIMAMENTE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context);
              onFileSelected();
            },
          ),

          const SizedBox(height: 16),

          // Botón cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
