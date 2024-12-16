// lib/pages/math_keyboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:math_keyboard/math_keyboard.dart';

import '../../bloc/math_expression/math_expression_bloc.dart';
import '../../bloc/settings/settings_bloc.dart';
import '../action_buttons.dart';
import '../dialogs/rendered_expression_dialog.dart';
import '../dialogs/settings_dialog.dart';
import '../drawer_menu.dart';
import '../export/export_image_web.dart';
import '../export/export_svg_eps_ole.dart';
import '../export/svg_exporter.dart';
import '../math_field_widget.dart';
import '../rendered_expression.dart';
import '../symbol_selector.dart';
import '../toolbar.dart';

// Add these constants at the top of the file
const double kDesktopBreakpoint = 1200.0;
const double kTabletBreakpoint = 800.0;
const double kMobileBreakpoint = 600.0;
const double kSymbolSelectorDesktopWidth = 300.0;
const double kSymbolSelectorTabletHeight = 250.0;
const double kMinPadding = 8.0;
const double kDefaultPadding = 16.0;

class MathKeyboardPage extends StatefulWidget {
  const MathKeyboardPage({super.key});

  @override
  MathKeyboardPageState createState() => MathKeyboardPageState();
}

class MathKeyboardPageState extends State<MathKeyboardPage> {
  late MathFieldEditingController _controller;
  final GlobalKey _expressionKey = GlobalKey();

  String _searchQuery = '';
  final List<String> _suggestions = [];
  bool _showSymbolSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller = MathFieldEditingController();
    _controller.addListener(_onExpressionChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onExpressionChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onExpressionChanged() {
    final expression = _controller.currentEditingValue();
    context.read<MathExpressionBloc>().add(UpdateExpression(expression));
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _clearExpression() {
    _controller.clear();
    context.read<MathExpressionBloc>().add(const UpdateExpression(''));
  }

  Future<void> _showSettings() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return const SettingsDialog();
      },
    );
  }

  Future<void> _showRenderedExpressionSettings(context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return const RenderedExpressionDialog();
      },
    );
  }

  void _importExpression() async {
    final importType = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Select Import Type'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'latex'),
              child: const Text('Import LaTeX'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'mathml'),
              child: const Text('Import MathML'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'asciimath'),
              child: const Text('Import AsciiMath'),
            ),
          ],
        );
      },
    );

    if (importType == 'latex') {
      await _importLatex();
    } else if (importType == 'mathml') {
      await _importMathML();
    } else if (importType == 'asciimath') {
      await _importAsciiMath();
    }
  }

  Future<void> _importLatex() async {
    final latex = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: const Text('Import LaTeX'),
          content: TextField(
            onChanged: (value) => input = value,
            decoration: const InputDecoration(
              hintText: 'Enter LaTeX code here',
            ),
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('Import'),
            ),
          ],
        );
      },
    );

    if (latex != null && latex.isNotEmpty && mounted) {
      // Dispatch event to set expression
      context.read<MathExpressionBloc>().add(SetExpression(latex));
    }
  }

  Future<void> _importMathML() async {
    final mathML = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: const Text('Import MathML'),
          content: TextField(
            onChanged: (value) => input = value,
            decoration: const InputDecoration(
              hintText: 'Enter MathML code here',
            ),
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
    if (mathML != null && mathML.isNotEmpty && mounted) {
      // Dispatch event to convert and set expression
      context.read<MathExpressionBloc>().add(ConvertMathML(mathML));
    }
  }

  Future<void> _importAsciiMath() async {
    final asciiMath = await showDialog<String>(
      context: context,
      builder: (context) {
        String input = '';
        return AlertDialog(
          title: const Text('Import AsciiMath'),
          content: TextField(
            onChanged: (value) => input = value,
            decoration: const InputDecoration(
              hintText: 'Enter AsciiMath code here',
            ),
            maxLines: null,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, input),
              child: const Text('Import'),
            ),
          ],
        );
      },
    );

    if (asciiMath != null && asciiMath.isNotEmpty && mounted) {
      // Dispatch event to convert and set expression
      context.read<MathExpressionBloc>().add(ConvertAsciiMath(asciiMath));
    }
  }

  Future<void> _exportAsImage() async {
    await WebImageExporter.exportAsImage(_expressionKey, context);
  }

  Future<void> _copyAsImage() async {
    await WebImageExporter.copyAsImage(_expressionKey, context);
  }

  Future<void> _exportAsSVG() async {
    try {
      final state = context.read<MathExpressionBloc>().state;
      if (state is MathExpressionUpdated && state.expression.isNotEmpty) {
        await SvgExporter.exportAsSvg(state.expression, context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No valid expression available to export')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export as SVG: $e')),
      );
    }
  }

  Future<void> _exportAsEps() async {
    // Retrieve the current expression (LaTeX format) from the bloc or controller
    final state = context.read<MathExpressionBloc>().state;
    if (state is MathExpressionUpdated) {
      // await WebImageExporter.exportAsSvg(state.expression, context);
      await FormatConverter.exportAsEps(state.expression, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expression available to export')),
      );
    }
  }

  Future<void> _exportAsOle() async {
    // Retrieve the current expression (LaTeX format) from the bloc or controller
    final state = context.read<MathExpressionBloc>().state;
    if (state is MathExpressionUpdated) {
      // await WebImageExporter.exportAsSvg(state.expression, context);
      await FormatConverter.exportAsOle(state.expression, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No expression available to export')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MathKeyboardViewInsets(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        drawer: DrawerMenu(
          importExpression: _importExpression,
          exportAsImage: _exportAsImage,
          showSettings: _showSettings,
          exportAsEps: _exportAsEps,
          exportAsOle: _exportAsOle,
          showAboutDialog: () {
            showAboutDialog(
              context: context,
              applicationName: 'Math Equation Editor',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.calculate),
              children: const [
                Text(
                    'A Flutter-based math expression editor with extensive features.'),
              ],
            );
          },
        ),
        appBar: _buildResponsiveAppBar(),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return _buildResponsiveLayout(constraints);
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar() {
    final width = MediaQuery.of(context).size.width;
    return AppBar(
      title: const Text('Math Equation Editor'),
      actions: [
        if (width > kMobileBreakpoint) ...[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearExpression,
            tooltip: 'Clear Expression',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importExpression,
            tooltip: 'Import Expression',
          ),
          if (width > kTabletBreakpoint)
            ElevatedButton.icon(
              onPressed: _copyLatexToClipboard,
              icon: const Icon(Icons.code),
              label: const Text('Copy LaTeX'),
            )
          else
            IconButton(
              icon: const Icon(Icons.code),
              onPressed: _copyLatexToClipboard,
              tooltip: 'Copy LaTeX',
            ),
        ] else ...[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearExpression,
            tooltip: 'Clear Expression',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
        ],
      ],
    );
  }

  Widget _buildResponsiveLayout(BoxConstraints constraints) {
    if (constraints.maxWidth > kDesktopBreakpoint) {
      return _buildDesktopLayout();
    } else if (constraints.maxWidth > kTabletBreakpoint) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(
          width: kSymbolSelectorDesktopWidth,
          child: _buildSymbolSelector(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: _buildMainContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        SizedBox(
          height: kSymbolSelectorTabletHeight,
          child: _buildSymbolSelector(),
        ),
        const Divider(height: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(kMinPadding),
            child: _buildMainContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: kSymbolSelectorTabletHeight,
                    child: _buildSymbolSelector(),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(kMinPadding),
                    child: MathFieldWidget(
                      controller: _controller,
                      onClear: _clearExpression,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildMobileActionButtons(),
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            _buildMobilePreviewSection(),
        ],
      ),
    );
  }

  Widget _buildMobileActionButtons() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: kMinPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyAsImage,
            tooltip: 'Copy as Image',
          ),
          IconButton(
            icon: const Icon(Icons.functions),
            onPressed: _copyAsFormula,
            tooltip: 'Copy as Formula',
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _exportAsImage,
            tooltip: 'Export as Image',
          ),
          IconButton(
            icon: const Icon(Icons.photo_size_select_large_rounded),
            onPressed: _exportAsSVG,
            tooltip: 'Export as SVG',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExpression,
            tooltip: 'Save Expression',
          ),
          IconButton(
            icon: const Icon(Icons.settings_suggest_outlined),
            onPressed: () => _showRenderedExpressionSettings(context),
            tooltip: 'Expression Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildMobilePreviewSection() {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoadSuccess && state.settings.showPreview) {
          return Container(
            height: 120,
            margin: const EdgeInsets.all(kMinPadding),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: RepaintBoundary(
              key: _expressionKey,
              child: const RenderedExpression(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  SymbolSelector _buildSymbolSelector() {
    return SymbolSelector(
      searchQuery: _searchQuery,
      updateSearchQuery: _updateSearchQuery,
      showSuggestions: _showSymbolSuggestions,
      suggestions: _suggestions,
      onSymbolSelected: (symbol) {
        _controller.addLeaf(symbol);
        setState(() {
          _showSymbolSuggestions = false;
        });
      },
    );
  }

  Widget _buildMainContent() {
    if (MediaQuery.of(context).size.width <= kMobileBreakpoint) {
      return const SizedBox.shrink(); // Don't build main content for mobile
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    bool highContrast = state is SettingsLoadSuccess
                        ? state.settings.highContrastMode
                        : false;
                    return Toolbar(
                      showFontSizeDialog: _showFontSizeDialog,
                      toggleTheme: () {
                        context.read<SettingsBloc>().add(UpdateSetting(
                              key: 'highContrastMode',
                              value: !highContrast,
                            ));
                      },
                      theme: highContrast ? 'dark' : 'light',
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kMinPadding,
                    vertical: kMinPadding / 2,
                  ),
                  child: MathFieldWidget(
                    controller: _controller,
                    onClear: _clearExpression,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kMinPadding,
                    vertical: kMinPadding / 2,
                  ),
                  child: ActionButtons(
                    copyAsImage: _copyAsImage,
                    copyLatexToClipboard: _copyLatexToClipboard,
                    copyAsFormula: _copyAsFormula,
                    exportAsImage: _exportAsImage,
                    exportAsSVG: _exportAsSVG,
                    saveExpression: _saveExpression,
                    showRenderedExpressionSettings: () =>
                        _showRenderedExpressionSettings(context),
                  ),
                ),
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, state) {
                    if (state is SettingsLoadSuccess &&
                        state.settings.showPreview) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: kMinPadding,
                          vertical: kMinPadding / 2,
                        ),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                          minHeight: 100,
                        ),
                        child: RepaintBoundary(
                          key: _expressionKey,
                          child: const RenderedExpression(),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showFontSizeDialog() {
    // Initialize tempFontSize with current font size from settings
    double tempFontSize = 24;
    final currentState = context.read<SettingsBloc>().state;
    if (currentState is SettingsLoadSuccess) {
      tempFontSize = currentState.settings.fontSize;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Font Size'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: tempFontSize,
                    min: 12,
                    max: 200,
                    divisions: 88,
                    label: tempFontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        tempFontSize = value;
                      });
                      // Update font size in real-time
                      context.read<SettingsBloc>().add(UpdateSetting(
                            key: 'fontSize',
                            value: tempFontSize,
                          ));
                    },
                  ),
                  Text(
                    'Selected size: ${tempFontSize.round()}',
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  void _copyLatexToClipboard() async {
    final state = context.read<MathExpressionBloc>().state;
    if (state is MathExpressionUpdated) {
      await WebImageExporter.copyLatexToClipboard(state.expression, context);
    }
  }

  Future<void> _copyAsFormula() async {
    final state = context.read<MathExpressionBloc>().state;
    if (state is MathExpressionUpdated) {
      await WebImageExporter.copyLatexAsFormula(state.expression, context);
    }
  }

  void _saveExpression() {
    final state = context.read<MathExpressionBloc>().state;
    if (state is MathExpressionUpdated) {
      context.read<MathExpressionBloc>().add(SaveExpression());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expression saved')),
      );
    }
  }
}
