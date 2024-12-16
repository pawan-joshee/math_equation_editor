// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../../image editor/image_preview_overlay.dart';

class WebImageExporter {
  static Future<Uint8List?> captureImage(GlobalKey key) async {
    try {
      // Add delay to ensure rendering is complete
      await Future.delayed(const Duration(milliseconds: 500));

      // Find the RenderRepaintBoundary
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Capture the image with high quality
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      }
      return null;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  static Future<void> exportAsImage(GlobalKey key, BuildContext context) async {
    try {
      Uint8List? imageBytes = await captureImage(key);

      if (imageBytes == null) {
        throw Exception('Failed to capture image');
      }

      // Convert the image bytes to base64
      final base64Image = base64Encode(imageBytes);
      final dataUrl = 'data:image/png;base64,$base64Image';

      // Create a download link
      final anchor = html.AnchorElement(href: dataUrl)
        ..setAttribute(
            'download', 'equation_${DateTime.now().millisecondsSinceEpoch}.png')
        ..style.display = 'none';

      html.document.body!.children.add(anchor);
      anchor.click();
      anchor.remove();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image downloaded successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export image: ${e.toString()}')),
        );
      }
    }
  }

  static Future<void> copyAsImage(GlobalKey key, BuildContext context) async {
    try {
      Uint8List? imageBytes = await captureImage(key);

      if (imageBytes == null) {
        throw Exception('Failed to capture image');
      }

      final base64Image = base64Encode(imageBytes);
      final dataUrl = 'data:image/png;base64,$base64Image';

      // Copy to clipboard using JavaScript
      final jsScript = '''
      (async function() {
        const response = await fetch('$dataUrl');
        const blob = await response.blob();
        await navigator.clipboard.write([
          new ClipboardItem({'image/png': blob})
        ]);
      })().catch(console.error);
    ''';

      js.context.callMethod('eval', [jsScript]);

      if (context.mounted) {
        ImagePreviewOverlay.show(
          context,
          dataUrl,
          () {
            final anchor = html.AnchorElement(href: dataUrl)
              ..setAttribute('download',
                  'equation_${DateTime.now().millisecondsSinceEpoch}.png')
              ..style.display = 'none';
            html.document.body!.children.add(anchor);
            anchor.click();
            anchor.remove();
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Failed to copy image. Try using "Export as Image" instead.'),
          ),
        );
      }
    }
  }

  /// Wait for MathJax to be fully loaded and ready
  static Future<void> _waitForMathJax() async {
    final completer = Completer<void>();

    void checkMathJax() {
      if (js.context.hasProperty('MathJax') &&
          js.context['MathJax'].hasProperty('typesetPromise')) {
        completer.complete();
      } else {
        Future.delayed(const Duration(milliseconds: 100), checkMathJax);
      }
    }

    checkMathJax();
    return completer.future;
  }

  /// Ensures MathJax is loaded and initialized
  static Future<bool> _ensureMathJaxLoaded() async {
    final completer = Completer<bool>();

    if (!html.document.head!.children.any((element) =>
        element is html.ScriptElement && element.src.contains('mathjax'))) {
      // Add MathJax configuration script first
      final configScript = html.ScriptElement()
        ..type = 'text/x-mathjax-config'
        ..text = '''
          window.MathJax = {
            tex: {
              inlineMath: [['\$', '\$'], ['\\\\(', '\\\\)']],
              displayMath: [['\$\$', '\$\$'], ['\\\\[', '\\\\]']]
            },
            svg: {
              fontCache: 'global'
            },
            options: {
              skipHtmlTags: ['script', 'noscript', 'style', 'textarea', 'pre']
            }
          };
        ''';
      html.document.head!.children.add(configScript);

      // Use MathJax with SVG output
      final mathJaxScript = html.ScriptElement()
        ..src = 'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js'
        ..type = 'text/javascript'
        ..async = true;

      // Add load event listener
      mathJaxScript.onLoad.listen((_) async {
        try {
          await _waitForMathJax();
          completer.complete(true);
        } catch (e) {
          completer.complete(false);
        }
      });

      mathJaxScript.onError.listen((_) {
        completer.complete(false);
      });

      html.document.head!.children.add(mathJaxScript);
    } else {
      try {
        await _waitForMathJax();
        completer.complete(true);
      } catch (e) {
        completer.complete(false);
      }
    }

    return completer.future;
  }

  static Future<void> copyLatexAsFormula(
      String latex, BuildContext context) async {
    try {
      // Ensure MathJax is loaded before proceeding
      final mathJaxLoaded = await _ensureMathJaxLoaded();
      if (!mathJaxLoaded) {
        throw Exception('Failed to load MathJax');
      }

      // Create a hidden container to render the formula
      final container = html.DivElement()
        ..style.visibility = 'hidden'
        ..style.position = 'absolute'
        ..style.top = '0'
        ..style.left = '0';

      // Create a MathJax node
      final mathDiv = html.DivElement()..innerHtml = '\\($latex\\)';

      container.children.add(mathDiv);
      html.document.body!.children.add(container);

      // Use MathJax v3 API to render
      await js.context.callMethod('eval', [
        '''
        MathJax.typesetPromise([document.querySelector('div:last-child')])
          .catch(function(err) {
            console.error(err);
          });
      '''
      ]);

      // Wait a bit for rendering to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Extract the rendered text (not a perfect conversion)
      final String textFormula = js.context.callMethod('eval', [
        '''
        (function() {
          var element = document.querySelector('div:last-child mjx-container');
          if (!element) return '';
          
          function getTextContent(node) {
            var text = '';
            if (node.nodeType === 3) { // Text node
              return node.textContent.trim();
            }
            var children = node.childNodes;
            for (var i = 0; i < children.length; i++) {
              var child = children[i];
              if (child.nodeType === 1) { // Element node
                var childText = getTextContent(child);
                // Add spacing based on element type
                if (child.tagName === 'MJX-MFRAC') {
                  text += ' / ';
                } else if (child.tagName === 'MJX-MSQRT') {
                  text += '√(';
                  text += childText;
                  text += ')';
                } else if (child.tagName === 'MJX-MSUB') {
                  text += '_';
                } else if (child.tagName === 'MJX-MSUP') {
                  text += '^';
                } else {
                  text += childText;
                }
              } else {
                text += child.textContent.trim();
              }
            }
            return text.replace(/\\s+/g, ' ').trim();
          }
          
          return getTextContent(element);
        })();
      '''
      ]);

      // Copy to clipboard
      final String copyText = textFormula.isEmpty ? latex : textFormula;
      await Clipboard.setData(ClipboardData(text: copyText));

      // Cleanup
      container.remove();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Formula copied to clipboard')),
        );
      }
    } catch (e) {
      debugPrint('Error copying formula: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to copy formula: ${e.toString()}')),
        );
      }
    }
  }

  /// Simpler fallback method
  static Future<void> copyLatexToClipboard(
      String latex, BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: latex));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formula copied as plain text'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to copy formula: ${e.toString()}')),
        );
      }
    }
  }
}
