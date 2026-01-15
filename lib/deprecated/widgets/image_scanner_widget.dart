import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

/// Widget para capturar o seleccionar imagen y procesarla
/// 
/// Muestra opciones:
/// - Tomar foto con cámara
/// - Seleccionar de galería
/// 
/// Comprime la imagen antes de retornarla para optimizar llamada a IA.
class ImageScannerWidget extends StatelessWidget {
  final void Function(Uint8List imageBytes) onImageSelected;
  
  const ImageScannerWidget({
    super.key,
    required this.onImageSelected,
  });

  /// Captura foto desde cámara
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
          Navigator.pop(context); // Cerrar bottom sheet
          onImageSelected(compressed);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al capturar foto: $e')),
        );
      }
    }
  }

  /// Selecciona imagen desde galería
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
          Navigator.pop(context); // Cerrar bottom sheet
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

  /// Comprime imagen para reducir payload a Gemini
  /// 
  /// Límite: 3000 imágenes por request según docs.
  /// Compresión agresiva para stay bajo 500KB por imagen.
  Future<Uint8List> _compressImage(Uint8List bytes) async {
    try {
      final image = img.decodeImage(bytes);
      if (image == null) {
        debugPrint('⚠️ No se pudo decodificar imagen, usando original');
        return bytes;
      }

      // Validar tamaño mínimo para evitar "Invalid size"
      if (image.width < 10 || image.height < 10) {
        debugPrint('⚠️ Imagen muy pequeña (${image.width}x${image.height}), usando original');
        return bytes;
      }

      debugPrint('📷 Imagen original: ${image.width}x${image.height}');

      // Solo redimensionar si es necesario
      if (image.width <= 1920 && image.height <= 1920) {
        debugPrint('✓ Imagen dentro de límites, sin redimensionar');
        final compressed = img.encodeJpg(image, quality: 85);
        return Uint8List.fromList(compressed);
      }

      // Resize si es muy grande (max 1920px lado largo)
      final resized = img.copyResize(
        image,
        width: image.width > 1920 ? 1920 : null,
        height: image.height > 1920 ? 1920 : null,
      );

      debugPrint('✓ Imagen redimensionada a: ${resized.width}x${resized.height}');

      // Encode como JPEG con quality 85
      final compressed = img.encodeJpg(resized, quality: 85);
      final sizeKB = compressed.length / 1024;
      debugPrint('✓ Imagen comprimida: ${sizeKB.toStringAsFixed(1)} KB');
      
      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('❌ Error comprimiendo imagen: $e');
      debugPrint('⚠️ Usando imagen original sin comprimir');
      return bytes; // Fallback a imagen original
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
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
            'Escanear con IA',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toma una foto o selecciona una imagen para extraer la tarea',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 24),

          // Opción Cámara
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
            subtitle: const Text('Usa la cámara para capturar'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _captureFromCamera(context),
          ),

          const SizedBox(height: 8),

          // Opción Galería
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
            subtitle: const Text('Selecciona una imagen existente'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _pickFromGallery(context),
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
