import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';

/// A scaffold to be used by all spot check demos
class SpotCheckScaffold extends StatelessWidget {
  const SpotCheckScaffold({
    super.key,
    required this.content,
    this.supplemental,
    this.overlay,
  });

  /// Primary demo content.
  final Widget content;

  /// An (optional) supplemental control panel for the demo.
  final Widget? supplemental;

  /// An (optional) widget that's displayed on top of all content in this scaffold.
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFF222222),
            body: Stack(
              children: [
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        child: content,
                      ),
                      if (supplemental != null) //
                        _buildSupplementalPanel(),
                    ],
                  ),
                ),
                if (overlay != null) //
                  Positioned.fill(
                    child: overlay!,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSupplementalPanel() {
    return Container(
      width: 250,
      height: double.infinity,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.biotech,
              color: Colors.white.withValues(alpha: 0.05),
              size: 84,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: double.infinity,
                child: SingleChildScrollView(
                  child: supplemental!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Makes text light, for use during dark mode styling.
final darkModeStyles = [
  StyleRule(
    BlockSelector.all,
    (doc, docNode) {
      return {
        Styles.textStyle: const TextStyle(
          color: Color(0xFFCCCCCC),
          fontSize: 32,
        ),
      };
    },
  ),
  StyleRule(
    const BlockSelector("header1"),
    (doc, docNode) {
      return {
        Styles.textStyle: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 48,
        ),
      };
    },
  ),
  StyleRule(
    const BlockSelector("header2"),
    (doc, docNode) {
      return {
        Styles.textStyle: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 42,
        ),
      };
    },
  ),
  StyleRule(
    const BlockSelector("header3"),
    (doc, docNode) {
      return {
        Styles.textStyle: const TextStyle(
          color: Color(0xFF888888),
          fontSize: 36,
        ),
      };
    },
  ),
];
