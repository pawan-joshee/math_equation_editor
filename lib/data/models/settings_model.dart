import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart' as math_fork;

import '../../math_expression/types/latex_renderer.dart';
import '../../math_expression/utils/custom_text_decoration.dart';

/// A model representing the application's settings.
class Settings {
  // Existing properties...
  bool showPreview;
  bool autoSave;
  int autoSaveInterval;
  String defaultTemplate;
  bool useCustomFonts;
  String mathFont;
  bool enableAutoComplete;
  bool enableInlineSuggestions;
  String exportFormat;
  bool highContrastMode;
  Map<String, String> keyboardShortcuts;
  double fontSize;
  Color expressionColor;
  Color backgroundColor;
  math_fork.MathStyle mathStyle;

  // New TextStyle properties
  FontWeight fontWeight;
  FontStyle fontStyle;
  CustomTextDecoration textDecoration; // Updated type

  // New Container styling properties
  double containerPadding;
  double containerMargin;
  Color containerBorderColor;
  double containerBorderRadius;

  // New Container Size Properties
  double containerHeight;
  double containerWidth;
  double maxHeightFactor;
  double maxWidthFactor;
  // Add new property
  final LatexRenderer latexRenderer;

  Settings({
    required this.showPreview,
    required this.autoSave,
    required this.autoSaveInterval,
    required this.defaultTemplate,
    required this.useCustomFonts,
    required this.mathFont,
    required this.enableAutoComplete,
    required this.enableInlineSuggestions,
    required this.exportFormat,
    required this.highContrastMode,
    required this.keyboardShortcuts,
    required this.fontSize,
    required this.expressionColor,
    required this.backgroundColor,
    required this.mathStyle,
    // Initialize new properties with default values
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.textDecoration = CustomTextDecoration.none, // Default value
    this.containerPadding = 3.0,
    this.containerMargin = 3.0,
    this.containerBorderColor = Colors.transparent,
    this.containerBorderRadius = 8.0,

    // Initialize New Container Size Properties
    this.containerHeight = 30.0, // Increased default height
    this.containerWidth = 30.0, // Increased default width

    // Add to constructor
    this.latexRenderer = LatexRenderer.mathFork,
    required this.maxHeightFactor,
    required this.maxWidthFactor,
  });

  /// Creates a [Settings] instance from a JSON Map.
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      showPreview: json['showPreview'] ?? true,
      autoSave: json['autoSave'] ?? true,
      autoSaveInterval: json['autoSaveInterval'] ?? 5,
      defaultTemplate: json['defaultTemplate'] ?? 'article',
      useCustomFonts: json['useCustomFonts'] ?? false,
      mathFont: json['mathFont'] ?? 'Latin Modern Math',
      enableAutoComplete: json['enableAutoComplete'] ?? true,
      enableInlineSuggestions: json['enableInlineSuggestions'] ?? true,
      exportFormat: json['exportFormat'] ?? 'PNG',
      highContrastMode: json['highContrastMode'] ?? false,
      keyboardShortcuts: json['keyboardShortcuts'] != null
          ? Map<String, String>.from(json['keyboardShortcuts'])
          : {},
      fontSize: (json['fontSize'] ?? 40.0).toDouble(),
      expressionColor: Color(json['expressionColor'] ?? Colors.black.value),
      backgroundColor: Color(json['backgroundColor'] ?? Colors.white.value),
      mathStyle: math_fork
          .MathStyle.values[json['mathStyle'] ?? 0], // Handle invalid index
      fontWeight:
          FontWeight.values[json['fontWeight'] ?? FontWeight.normal.index],
      fontStyle: FontStyle.values[json['fontStyle'] ?? FontStyle.normal.index],
      textDecoration: CustomTextDecoration
          .values[json['textDecoration'] ?? CustomTextDecoration.none.index],
      containerPadding: (json['containerPadding'] ?? 3.0).toDouble(),
      containerMargin: (json['containerMargin'] ?? 3.0).toDouble(),
      containerBorderColor:
          Color(json['containerBorderColor'] ?? Colors.transparent.value),
      containerBorderRadius: (json['containerBorderRadius'] ?? 8.0).toDouble(),
      containerHeight: (json['containerHeight'] ?? 30.0).toDouble(),
      containerWidth: (json['containerWidth'] ?? 30.0).toDouble(),
      maxHeightFactor: (json['maxHeightFactor'] ?? 0.5).toDouble(),
      maxWidthFactor: (json['maxWidthFactor'] ?? 0.5).toDouble(),

      // Add to fromJson
      latexRenderer: LatexRenderer.values[json['latexRenderer'] ?? 0],
    );
  }

  /// Converts the [Settings] instance to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      // Existing properties...
      'showPreview': showPreview,
      'autoSave': autoSave,
      'autoSaveInterval': autoSaveInterval,
      'defaultTemplate': defaultTemplate,
      'useCustomFonts': useCustomFonts,
      'mathFont': mathFont,
      'enableAutoComplete': enableAutoComplete,
      'enableInlineSuggestions': enableInlineSuggestions,
      'exportFormat': exportFormat,
      'highContrastMode': highContrastMode,
      'keyboardShortcuts': keyboardShortcuts,
      'fontSize': fontSize,
      'expressionColor': expressionColor.value,
      'backgroundColor': backgroundColor.value,
      'mathStyle': mathStyle.index,
      // Serialize new properties
      'fontWeight': fontWeight.index,
      'fontStyle': fontStyle.index,
      'textDecoration': textDecoration.index, // Serialize enum as index
      'containerPadding': containerPadding,
      'containerMargin': containerMargin,
      'containerBorderColor': containerBorderColor.value,
      'containerBorderRadius': containerBorderRadius,

      // Serialize New Container Size Properties
      'containerHeight': containerHeight,
      'containerWidth': containerWidth,
      'maxHeightFactor': maxHeightFactor,
      'maxWidthFactor': maxWidthFactor,

      // Add to toJson
      'latexRenderer': latexRenderer.index,
    };
  }

  Settings copyWith({
    bool? showPreview,
    bool? autoSave,
    int? autoSaveInterval,
    String? defaultTemplate,
    bool? useCustomFonts,
    String? mathFont,
    bool? enableAutoComplete,
    bool? enableInlineSuggestions,
    String? exportFormat,
    bool? highContrastMode,
    Map<String, String>? keyboardShortcuts,
    double? fontSize,
    Color? expressionColor,
    Color? backgroundColor,
    math_fork.MathStyle? mathStyle,
    // New properties
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    CustomTextDecoration? textDecoration,
    double? containerPadding,
    double? containerMargin,
    Color? containerBorderColor,
    double? containerBorderRadius,
    // New Container Size Properties
    double? containerHeight,
    double? containerWidth,
    double? maxHeightFactor,
    double? maxWidthFactor,

    // Add to copyWith
    LatexRenderer? latexRenderer,
  }) {
    return Settings(
      showPreview: showPreview ?? this.showPreview,
      autoSave: autoSave ?? this.autoSave,
      autoSaveInterval: autoSaveInterval ?? this.autoSaveInterval,
      defaultTemplate: defaultTemplate ?? this.defaultTemplate,
      useCustomFonts: useCustomFonts ?? this.useCustomFonts,
      mathFont: mathFont ?? this.mathFont,
      enableAutoComplete: enableAutoComplete ?? this.enableAutoComplete,
      enableInlineSuggestions:
          enableInlineSuggestions ?? this.enableInlineSuggestions,
      exportFormat: exportFormat ?? this.exportFormat,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      keyboardShortcuts: keyboardShortcuts ?? this.keyboardShortcuts,
      fontSize: fontSize ?? this.fontSize,
      expressionColor: expressionColor ?? this.expressionColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      mathStyle: mathStyle ?? this.mathStyle,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      textDecoration: textDecoration ?? this.textDecoration,
      containerPadding: containerPadding ?? this.containerPadding,
      containerMargin: containerMargin ?? this.containerMargin,
      containerBorderColor: containerBorderColor ?? this.containerBorderColor,
      containerBorderRadius:
          containerBorderRadius ?? this.containerBorderRadius,
      containerHeight: containerHeight ?? this.containerHeight,
      containerWidth: containerWidth ?? this.containerWidth,
      maxHeightFactor: maxHeightFactor ?? this.maxHeightFactor,
      maxWidthFactor: maxWidthFactor ?? this.maxWidthFactor,
      // Add to copyWith
      latexRenderer: latexRenderer ?? this.latexRenderer,
    );
  }
}
