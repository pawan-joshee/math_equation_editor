import 'package:flutter/material.dart';

typedef OnColorSelected = void Function(Color color);

class CustomColorPicker extends StatefulWidget {
  final Color initialColor;
  final OnColorSelected onColorSelected;

  const CustomColorPicker({
    super.key,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  CustomColorPickerState createState() => CustomColorPickerState();
}

class CustomColorPickerState extends State<CustomColorPicker> {
  late double _alpha;
  late double _red;
  late double _green;
  late double _blue;
  late TextEditingController _hexController;

  static const List<Color> presetColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.yellow,
    Colors.pink,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();
    _initializeColorValues(widget.initialColor);
    _hexController = TextEditingController(
      text: _colorToHexString(widget.initialColor),
    );
  }

  void _initializeColorValues(Color color) {
    _alpha = color.alpha.toDouble();
    _red = color.red.toDouble();
    _green = color.green.toDouble();
    _blue = color.blue.toDouble();
  }

  String _colorToHexString(Color color) =>
      '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  Color get _currentColor => Color.fromARGB(
      _alpha.toInt(), _red.toInt(), _green.toInt(), _blue.toInt());

  void _updateColorAndHexCode() {
    widget.onColorSelected(_currentColor);
    _hexController.text = _colorToHexString(_currentColor);
  }

  void _updateFromHex(String value) {
    if (value.startsWith('#') && (value.length == 7 || value.length == 9)) {
      int a =
          value.length == 9 ? int.parse(value.substring(1, 3), radix: 16) : 255;
      int r = int.parse(value.substring(value.length - 6, value.length - 4),
          radix: 16);
      int g = int.parse(value.substring(value.length - 4, value.length - 2),
          radix: 16);
      int b = int.parse(value.substring(value.length - 2), radix: 16);

      setState(() {
        _alpha = a.toDouble();
        _red = r.toDouble();
        _green = g.toDouble();
        _blue = b.toDouble();
      });
      _updateColorAndHexCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Use a Stack to layer the checkerboard and color container
        Stack(
          children: [
            // Checkerboard pattern using CustomPaint (only if alpha < 255)
            if (_alpha < 255)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomPaint(
                  painter: CheckerboardPainter(),
                ),
              ),
            // Color container
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: _currentColor,
                border: Border.all(color: Colors.grey),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildColorSlider(
          label: 'Alpha',
          value: _alpha,
          activeColor: Colors.black,
          onChanged: (value) {
            setState(() => _alpha = value);
            _updateColorAndHexCode();
          },
          min: 0,
          max: 255,
          divisions: 255,
        ),
        _buildColorSlider(
          label: 'Red',
          value: _red,
          activeColor: Colors.red,
          onChanged: (value) {
            setState(() => _red = value);
            _updateColorAndHexCode();
          },
        ),
        _buildColorSlider(
          label: 'Green',
          value: _green,
          activeColor: Colors.green,
          onChanged: (value) {
            setState(() => _green = value);
            _updateColorAndHexCode();
          },
        ),
        _buildColorSlider(
          label: 'Blue',
          value: _blue,
          activeColor: Colors.blue,
          onChanged: (value) {
            setState(() => _blue = value);
            _updateColorAndHexCode();
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Hex Code:',
          style: TextStyle(fontSize: 16),
        ),
        TextField(
          controller: _hexController,
          decoration: const InputDecoration(
            hintText: '#AARRGGBB or #RRGGBB',
            border: OutlineInputBorder(),
          ),
          maxLength: 9,
          onChanged: _updateFromHex,
        ),
        const SizedBox(height: 20),
        const Text(
          'Preset Colors:',
          style: TextStyle(fontSize: 16),
        ),
        Wrap(
          spacing: 8.0,
          children: presetColors.map((presetColor) {
            return GestureDetector(
              onTap: () {
                setState(() => _initializeColorValues(presetColor));
                _updateColorAndHexCode();
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: presetColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSlider({
    required String label,
    required double value,
    required Color activeColor,
    required ValueChanged<double> onChanged,
    double min = 0,
    double max = 255,
    int? divisions = 255,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toInt()}',
          style: const TextStyle(fontSize: 16),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: activeColor,
          inactiveColor: activeColor.withOpacity(0.3),
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// CustomPainter to draw a simple checkerboard pattern
class CheckerboardPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double squareSize;

  CheckerboardPainter({
    this.color1 = Colors.white,
    this.color2 = Colors.grey,
    this.squareSize = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    bool toggle = false;

    for (double y = 0; y < size.height; y += squareSize) {
      toggle = !toggle;
      for (double x = 0; x < size.width; x += squareSize) {
        paint.color = toggle ? color1 : color2;
        canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), paint);
        toggle = !toggle;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CheckerboardPainter oldDelegate) {
    return oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2 ||
        oldDelegate.squareSize != squareSize;
  }
}
