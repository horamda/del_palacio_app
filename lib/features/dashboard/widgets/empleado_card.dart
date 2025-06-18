import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class EmpleadoCard extends StatefulWidget {
  const EmpleadoCard({
    super.key,
    required this.nombre,
    required this.sector,
    required this.dni,
    this.imagenBase64,
    this.onTap,
    this.onLongPress,
    this.isActive = true,
    this.showStatus = false,
  });

  final String nombre;
  final String sector;
  final String dni;
  final String? imagenBase64;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isActive;
  final bool showStatus;

  @override
  State<EmpleadoCard> createState() => _EmpleadoCardState();
}

class _EmpleadoCardState extends State<EmpleadoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    Uint8List? imageBytes;
    if (widget.imagenBase64 != null && widget.imagenBase64!.isNotEmpty) {
      try {
        final cleaned = widget.imagenBase64!.split(',').last;
        imageBytes = base64Decode(cleaned);
      } catch (_) {
        // Error silencioso, se mostrará el ícono por defecto
      }
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? colorScheme.shadow.withOpacity(0.1)
                        : colorScheme.shadow.withOpacity(0.15),
                    blurRadius: _isPressed ? 8 : 12,
                    offset: _isPressed 
                        ? const Offset(0, 2) 
                        : const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: widget.isActive 
                    ? colorScheme.surface 
                    : colorScheme.surface.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Avatar con indicador de estado
                      Stack(
                        children: [
                          Hero(
                            tag: 'empleado_${widget.dni}',
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: widget.isActive 
                                      ? colorScheme.primary.withOpacity(0.2)
                                      : colorScheme.outline.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 32,
                                backgroundColor: colorScheme.primaryContainer,
                                backgroundImage: imageBytes != null 
                                    ? MemoryImage(imageBytes) 
                                    : null,
                                child: imageBytes == null
                                    ? Icon(
                                        Icons.person_rounded,
                                        size: 32,
                                        color: colorScheme.onPrimaryContainer,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          // Indicador de estado
                          if (widget.showStatus)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: widget.isActive 
                                      ? Colors.green 
                                      : Colors.grey,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Información del empleado
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre
                            Text(
                              widget.nombre,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: widget.isActive 
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // Sector con ícono
                            Row(
                              children: [
                                Icon(
                                  Icons.business_rounded,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    widget.sector,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: widget.isActive 
                                          ? colorScheme.onSurface.withOpacity(0.8)
                                          : colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 4),
                            
                            // DNI con ícono
                            Row(
                              children: [
                                Icon(
                                  Icons.credit_card_rounded,
                                  size: 16,
                                  color: colorScheme.outline,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'DNI: ${_formatDNI(widget.dni)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: widget.isActive 
                                        ? colorScheme.onSurface.withOpacity(0.7)
                                        : colorScheme.onSurface.withOpacity(0.4),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Ícono de navegación (opcional)
                      if (widget.onTap != null)
                        Icon(
                          Icons.chevron_right_rounded,
                          color: colorScheme.outline.withOpacity(0.6),
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDNI(String dni) {
    // Formatea el DNI con puntos para mejor legibilidad
    if (dni.length >= 8) {
      final reversed = dni.split('').reversed.join();
      final parts = <String>[];
      
      for (int i = 0; i < reversed.length; i += 3) {
        final end = i + 3;
        parts.add(reversed.substring(i, end > reversed.length ? reversed.length : end));
      }
      
      return parts.join('.').split('').reversed.join();
    }
    return dni;
  }
}

// Widget de ejemplo de uso
class EmpleadoListDemo extends StatelessWidget {
  const EmpleadoListDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empleados'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          EmpleadoCard(
            nombre: 'Juan Pérez',
            sector: 'Desarrollo de Software',
            dni: '12345678',
            isActive: true,
            showStatus: true,
            onTap: () {
              // Acción al tocar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Empleado seleccionado')),
              );
            },
            onLongPress: () {
              // Acción al mantener presionado
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opciones del empleado')),
              );
            },
          ),
          EmpleadoCard(
            nombre: 'María García',
            sector: 'Recursos Humanos',
            dni: '87654321',
            isActive: false,
            showStatus: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
