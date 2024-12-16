// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:flutter/material.dart';

import '../utils/scalable_brackets.dart';

class SvgExporter {
  /// Generates SVG content from LaTeX using MathJax.
  static Future<String?> generateSvgContent(
      String latex, html.DivElement container) async {
    try {
      final mathJax = js_util.getProperty(js_util.globalThis, 'MathJax');
      if (mathJax == null) {
        throw Exception('MathJax not loaded');
      }

      await _waitForMathJax();
      // ignore: avoid_single_cascade_in_expression_statements
      container..style.display = 'inline-block';

      final containerId =
          'math-export-${DateTime.now().millisecondsSinceEpoch}';
      container.id = containerId;

      container.innerHtml = r'$$' + latex.trim() + r'$$';
      html.document.body!.append(container);

      final typesetPromise = js_util.getProperty(mathJax, 'typesetPromise');
      if (typesetPromise != null) {
        await js_util
            .promiseToFuture(js_util.callMethod(mathJax, 'typesetPromise', [
          [container]
        ]));
      } else {
        js_util.callMethod(mathJax, 'typeset', [
          [container]
        ]);
        final startup = js_util.getProperty(mathJax, 'startup');
        if (startup != null) {
          final startupPromise = js_util.getProperty(startup, 'promise');
          if (startupPromise != null) {
            await js_util.promiseToFuture(startupPromise);
          }
        }
      }

      final svgElement = container.querySelector('svg');
      if (svgElement == null) {
        throw Exception('No SVG element found');
      }

      svgElement
        ..setAttribute('xmlns', 'http://www.w3.org/2000/svg')
        ..setAttribute('style', '''
          background: transparent;
          fill: #000000;
          stroke: #000000;
          vertical-align: middle;
          display: inline-block;
        ''');

      svgElement.querySelectorAll('*').forEach((element) {
        element.setAttribute('fill', '#000000');
        if (element.hasAttribute('stroke')) {
          element.setAttribute('stroke', '#000000');
        }
      });

      final defs = html.querySelectorAll('defs');
      String defsContent = '';
      for (var def in defs) {
        defsContent += def.outerHtml ?? '';
      }

      final completeSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" style="background: transparent; fill: #000000; stroke: #000000;" width="${svgElement.getAttribute('width')}" height="${svgElement.getAttribute('height')}" viewBox="${svgElement.getAttribute('viewBox')}">
$defsContent
${svgElement.innerHtml}
</svg>
''';

      final completeSvgProcessed = completeSvg.replaceAll('xlink:href', 'href');
      final completeSvgFinal = completeSvgProcessed.replaceAll(
          'xmlns:xlink="http://www.w3.org/1999/xlink"', '');

      return completeSvgFinal;
    } catch (e) {
      return null;
    } finally {
      container.remove();
    }
  }

  /// Exports the given LaTeX expression as an SVG file.
  static Future<void> exportAsSvg(String latex, BuildContext context) async {
    try {
      String scalableLatex = MakeScalableBrackets.makeScalableBrackets(latex);
      final container = html.DivElement()
        ..style.position = 'absolute'
        ..style.left = '-9999px'
        ..style.top = '0';

      html.document.body!.append(container);

      final svgContent = await generateSvgContent(scalableLatex, container);
      if (svgContent == null || svgContent.isEmpty) {
        throw Exception('Failed to generate SVG content');
      }

      final String fullSvgContent = '''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" 
  "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
$svgContent
''';

      final blob = html.Blob([fullSvgContent], 'image/svg+xml');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..download = 'math_equation.svg'
        ..style.display = 'none';

      html.document.body!.append(anchor);
      anchor.click();

      Future.delayed(const Duration(milliseconds: 100), () {
        anchor.remove();
        html.Url.revokeObjectUrl(url);
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: ${e.toString()}')),
        );
      }
    }
  }

  /// Waits for MathJax to be fully loaded and initialized
  static Future<void> _waitForMathJax(
      {int retries = 5, Duration delay = const Duration(seconds: 1)}) async {
    for (int i = 0; i < retries; i++) {
      final mathJax = js_util.getProperty(js_util.globalThis, 'MathJax');
      if (mathJax != null) {
        final startup = js_util.getProperty(mathJax, 'startup');
        if (startup != null) {
          final promise = js_util.getProperty(startup, 'promise');
          if (promise != null) {
            await js_util.promiseToFuture(promise);
            return;
          }
        }
      }
      await Future.delayed(delay);
    }
    throw Exception(
        'MathJax startup.promise is null or undefined after retries.');
  }
}
