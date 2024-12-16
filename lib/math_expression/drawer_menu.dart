// lib/widgets/drawer_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/math_expression/math_expression_bloc.dart';
import 'dialogs/saved_expressions_dialog.dart';

class DrawerMenu extends StatelessWidget {
  final VoidCallback importExpression;
  final VoidCallback exportAsImage;
  final VoidCallback exportAsEps;
  final VoidCallback exportAsOle;

  final VoidCallback showSettings;
  final VoidCallback showAboutDialog;

  const DrawerMenu({
    super.key,
    required this.importExpression,
    required this.exportAsImage,
    required this.showSettings,
    required this.showAboutDialog,
    required this.exportAsEps,
    required this.exportAsOle,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text('Saved Expressions'),
            onTap: () {
              Navigator.pop(context);
              context.read<MathExpressionBloc>().add(LoadExpressions());
              showDialog(
                context: context,
                builder: (context) => const SavedExpressionsDialog(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import Expression'),
            onTap: () {
              Navigator.pop(context);
              importExpression();
            },
          ),
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Export as Image'),
            onTap: () {
              Navigator.pop(context);
              exportAsImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Export as EPS'),
            onTap: () {
              Navigator.pop(context);
              exportAsEps();
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Export as OLE'),
            onTap: () {
              Navigator.pop(context);
              exportAsOle();
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              showSettings();
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog();
            },
          ),
        ],
      ),
    );
  }
}
