import 'package:flutter/material.dart';

import 'image_editor.dart';

class ImagePreviewOverlay {
  static OverlayEntry? _currentEntry;

  static void show(BuildContext context, String imageUrl, VoidCallback onSave) {
    hide();
    _currentEntry = OverlayEntry(
      builder: (context) => _AnimatedPreviewWidget(
        imageUrl: imageUrl,
        onDismiss: hide,
        onSave: onSave,
      ),
    );
    Overlay.of(context).insert(_currentEntry!);
    Future.delayed(const Duration(seconds: 10), hide);
  }

  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _AnimatedPreviewWidget extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onDismiss;
  final VoidCallback onSave;

  const _AnimatedPreviewWidget({
    required this.imageUrl,
    required this.onDismiss,
    required this.onSave,
  });

  @override
  State<_AnimatedPreviewWidget> createState() => _AnimatedPreviewWidgetState();
}

class _AnimatedPreviewWidgetState extends State<_AnimatedPreviewWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: FadeTransition(
        opacity: _animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.2, 0),
            end: Offset.zero,
          ).animate(_animation),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: Material(
              color: Colors.transparent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(_isHovered ? 0.15 : 0.1),
                      blurRadius: _isHovered ? 15 : 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildImagePreview(),
                    const SizedBox(height: 16),
                    _buildActionButtons(context),
                    const SizedBox(height: 8),
                    const Text(
                      'Image copied to clipboard',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            // Show ImageEditor as dialog
            showDialog(
                context: context,
                builder: (context) => ImageEditor(
                      imageUrl: widget.imageUrl,
                    ));
            _controller.reverse().then((_) => widget.onDismiss());
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Image.network(
                  widget.imageUrl,
                  width: 240,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                if (_isHovered)
                  Container(
                    width: 240,
                    height: 120,
                    color: Colors.black26,
                    child: const Center(
                      child: Text(
                        'Click to edit',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: Icons.save_alt,
          label: 'Save',
          primary: true,
          onPressed: widget.onSave,
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: Icons.share,
          label: 'Share',
          onPressed: () {
            // Implement share functionality
            // For now, just copy the URL
            widget.onSave();
          },
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: Icons.close,
          label: 'Dismiss',
          onPressed: () {
            _controller.reverse().then((_) => widget.onDismiss());
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return primary
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
            ),
          );
  }
}
