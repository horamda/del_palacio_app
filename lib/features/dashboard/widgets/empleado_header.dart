import 'dart:convert';
import 'package:flutter/material.dart';

class PerfilEmpleadoHeader extends StatefulWidget {
  const PerfilEmpleadoHeader({
    super.key,
    required this.nombre,
    required this.sector,
    required this.dni,
    required this.ultimaFecha,
    this.imagenBase64,
    this.onTapAvatar,
    this.isOnline = true,
  });

  final String nombre;
  final String sector;
  final String dni;
  final String ultimaFecha;
  final String? imagenBase64;
  final VoidCallback? onTapAvatar;
  final bool isOnline;

  @override
  State<PerfilEmpleadoHeader> createState() => _PerfilEmpleadoHeaderState();
}

class _PerfilEmpleadoHeaderState extends State<PerfilEmpleadoHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  ImageProvider? _cachedImage;
  bool _imageError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _loadImage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PerfilEmpleadoHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagenBase64 != widget.imagenBase64) {
      _loadImage();
    }
  }

  void _loadImage() {
    setState(() {
      _imageError = false;
      _cachedImage = null;
    });

    if (widget.imagenBase64 == null || widget.imagenBase64!.isEmpty) return;

    try {
      final cleanBase64 = widget.imagenBase64!.contains(',')
          ? widget.imagenBase64!.split(',').last
          : widget.imagenBase64!;
      
      final bytes = base64Decode(cleanBase64);
      _cachedImage = MemoryImage(bytes);
    } catch (e) {
      setState(() {
        _imageError = true;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '¡Buenos días, ${widget.nombre}!';
    if (hour < 18) return '¡Buenas tardes, ${widget.nombre}!';
    return '¡Buenas noches, ${widget.nombre}!';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.indigo.shade800,
                  Colors.indigo.shade900,
                  Colors.deepPurple.shade900,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                onTap: widget.onTapAvatar,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildEmployeeInfo(context),
                      ),
                      _buildStatusIndicator(),
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

  Widget _buildAvatar() {
    return Hero(
      tag: 'avatar_${widget.dni}',
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundImage: _cachedImage,
              backgroundColor: Colors.grey.shade700,
              child: _cachedImage == null
                  ? Icon(
                      _imageError ? Icons.error_outline : Icons.person,
                      size: 32,
                      color: Colors.white70,
                    )
                  : null,
            ),
          ),
          if (widget.isOnline)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmployeeInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getGreeting(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        _buildInfoChip(
          icon: Icons.business,
          text: widget.sector,
          context: context,
        ),
        const SizedBox(height: 4),
        _buildInfoChip(
          icon: Icons.badge,
          text: 'DNI ${widget.dni}',
          context: context,
        ),
        const SizedBox(height: 4),
        _buildInfoChip(
          icon: Icons.analytics,
          text: 'Último KPI: ${widget.ultimaFecha}',
          context: context,
          isHighlight: true,
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required BuildContext context,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isHighlight ? Colors.amber.shade300 : Colors.white60,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isHighlight ? Colors.amber.shade200 : Colors.white70,
                  fontWeight: isHighlight ? FontWeight.w500 : FontWeight.normal,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isOnline
                ? Colors.green.shade400.withOpacity(0.2)
                : Colors.grey.shade600.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isOnline
                  ? Colors.green.shade400.withOpacity(0.4)
                  : Colors.grey.shade500.withOpacity(0.4),
            ),
          ),
          child: Text(
            widget.isOnline ? 'Activo' : 'Inactivo',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: widget.isOnline
                      ? Colors.green.shade300
                      : Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
          ),
        ),
        const SizedBox(height: 8),
        Icon(
          Icons.chevron_right,
          color: Colors.white30,
          size: 20,
        ),
      ],
    );
  }
}
