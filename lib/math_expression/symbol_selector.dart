import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_math_fork/flutter_math.dart' as math_fork;

import '../bloc/math_expression/math_expression_bloc.dart';
import 'utils/constants.dart';

class SymbolSelector extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> updateSearchQuery;
  final bool showSuggestions;
  final List<String> suggestions;
  final ValueChanged<String> onSymbolSelected;

  const SymbolSelector({
    super.key,
    required this.searchQuery,
    required this.updateSearchQuery,
    required this.showSuggestions,
    required this.suggestions,
    required this.onSymbolSelected,
  });

  @override
  State<SymbolSelector> createState() => _SymbolSelectorState();
}

class _SymbolSelectorState extends State<SymbolSelector>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: Constants.symbolCategories.length, vsync: this);
    selectedCategory = Constants.symbolCategories.first;
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        selectedCategory = Constants.symbolCategories[_tabController.index];
      });
    }
  }

  List<String> _filterSymbols(List<String> symbols, String query) {
    if (query.isEmpty) return symbols;
    return symbols.where((symbol) {
      final lowerQuery = query.toLowerCase();
      final symbolName =
          symbol.replaceAll('\\', '').replaceAll('{}', '').toLowerCase();
      return symbolName.contains(lowerQuery);
    }).toList();
  }

  Widget _buildSymbolButton(String symbol, double fontSize, Size buttonSize) {
    return Tooltip(
      message:
          Constants.symbolDescriptions[symbol] ?? symbol.replaceAll(r'\', ''),
      child: Draggable<String>(
        data: symbol,
        feedback: Material(
          color: Colors.transparent,
          child: FittedBox(
            fit: BoxFit.contain,
            child: math_fork.Math.tex(
              symbol,
              textStyle: TextStyle(fontSize: fontSize),
            ),
          ),
        ),
        childWhenDragging: Container(),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6.0),
            onTap: () {
              context.read<MathExpressionBloc>().add(UpdateExpression(symbol));
              widget.onSymbolSelected(symbol);
            },
            child: Container(
              width: buttonSize.width,
              height: buttonSize.height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: math_fork.Math.tex(
                    symbol,
                    textStyle: TextStyle(fontSize: fontSize),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = _calculateCrossAxisCount(screenWidth);
    final childAspectRatio = _calculateChildAspectRatio(screenWidth);
    final fontSize = _calculateFontSize(screenWidth);
    final buttonSize = _calculateButtonSize(screenWidth);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: Constants.symbolCategories
              .map((category) => Tab(text: category))
              .toList(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search symbols...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: widget.updateSearchQuery,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: Constants.symbolCategories.map((category) {
              final symbols = Constants.symbols[category] ?? [];
              final filteredSymbols =
                  _filterSymbols(symbols, widget.searchQuery);

              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: filteredSymbols.length,
                itemBuilder: (context, index) => _buildSymbolButton(
                  filteredSymbols[index],
                  fontSize,
                  buttonSize,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  int _calculateCrossAxisCount(double width) {
    if (width > 1200) return 4;
    if (width > 800) return 6;
    return 8;
  }

  double _calculateChildAspectRatio(double width) {
    if (width > 1200) return 1.5;
    if (width > 800) return 1.4;
    if (width > 600) return 1.3;
    return 1.1;
  }

  double _calculateFontSize(double width) {
    if (width < 600) return 14;
    if (width < 1000) return 18;
    return 22;
  }

  Size _calculateButtonSize(double width) {
    if (width < 600) return const Size(50, 50);
    if (width < 1000) return const Size(60, 60);
    return const Size(70, 70);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }
}
