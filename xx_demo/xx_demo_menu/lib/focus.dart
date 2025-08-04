part of 'menu_demo.dart';


class FocusButton extends StatefulWidget {
  const FocusButton({super.key});

  @override
  State<FocusButton> createState() => _FocusButtonState();
}

class _FocusButtonState extends State<FocusButton> {
  late FocusScopeNode _focusNode;
  @override
  void initState() {
    _focusNode = FocusScopeNode(debugLabel: 'button');
    FocusManager.instance.addListener(_onFocusChanged);
    super.initState();
  }

  void _onFocusChanged() {
    print('focus ${FocusManager.instance.primaryFocus}');
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _focusNode,
      child: GestureDetector(
        onTapUp: (e) {
          _focusNode.requestFocus();
        },
        child: Text('测试焦点'),
      ),
    );
  }
}
