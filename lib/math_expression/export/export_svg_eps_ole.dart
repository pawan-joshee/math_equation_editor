// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util; // Add this import

import 'package:flutter/material.dart';

import '../utils/scalable_brackets.dart';
import 'svg_exporter.dart'; // Add this import

class FormatConverter {
  static Future<String?> _getSvgContent(String latex) async {
    final container = html.DivElement()
      ..style.position = 'absolute'
      ..style.left = '-9999px'
      ..style.top = '0';

    try {
      String scalableLatex = MakeScalableBrackets.makeScalableBrackets(latex);
      return await SvgExporter.generateSvgContent(scalableLatex, container);
    } finally {
      container.remove();
    }
  }

  static Future<void> exportAsEps(String latex, BuildContext context) async {
    try {
      final svgContent = await _getSvgContent(latex);
      if (svgContent == null) {
        throw Exception('Failed to generate SVG content');
      }

      // Get the epsConverter object
      final epsConverter = js_util.getProperty(html.window, 'epsConverter');
      if (epsConverter == null) {
        throw Exception('EPS converter not found');
      }

      // Call the convertToPS method using js_util
      final result = await js_util.promiseToFuture<String>(
          js_util.callMethod(epsConverter, 'convertToPS', [svgContent]));

      if (result.isEmpty) {
        throw Exception('Generated EPS data is empty');
      }

      final epsBlob = html.Blob([result], 'application/postscript');
      final epsUrl = html.Url.createObjectUrlFromBlob(epsBlob);

      final anchor = html.AnchorElement(href: epsUrl)
        ..setAttribute(
            'download', 'equation_${DateTime.now().millisecondsSinceEpoch}.eps')
        ..style.display = 'none';

      html.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(epsUrl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('EPS exported successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error exporting EPS: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export EPS: ${e.toString()}')),
        );
      }
    }
  }

  static Future<void> exportAsOle(String latex, BuildContext context) async {
    try {
      final svgContent = await _getSvgContent(latex);
      if (svgContent == null) {
        throw Exception('Failed to generate SVG content');
      }

      final oleData = '''
        <?xml version="1.0" encoding="UTF-8"?>
        <package xmlns="http://schemas.microsoft.com/office/2006/xmlPackage">
          <part name="equation">
            $svgContent
          </part>
        </package>
      ''';

      final oleBlob = html.Blob([oleData], 'application/msword');
      final oleUrl = html.Url.createObjectUrlFromBlob(oleBlob);

      final anchor = html.AnchorElement(href: oleUrl)
        ..setAttribute(
            'download', 'equation_${DateTime.now().millisecondsSinceEpoch}.ole')
        ..style.display = 'none';

      html.document.body!.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(oleUrl);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OLE exported successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error exporting OLE: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export OLE: ${e.toString()}')),
        );
      }
    }
  }
}
