import 'package:flutter/material.dart';

class CustomDropdownMenu extends StatefulWidget {
  final String label;
  final List<String> entries;
  final Function(String?)? onSelected;
  final bool enableFilter;
  final bool requestFocusOnTap;
  final double? width;
  final TextEditingController? controller; // Add this line

  const CustomDropdownMenu({
    super.key,
    required this.label,
    required this.entries,
    this.onSelected,
    this.enableFilter = true,
    this.requestFocusOnTap = false,
    this.width,
    this.controller, // Add this line
  });

  @override
  State<CustomDropdownMenu> createState() => _CustomDropdownMenuState();
}

class _CustomDropdownMenuState extends State<CustomDropdownMenu> {
  late final TextEditingController _internalController;
  final FocusNode focusNode = FocusNode();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    // Use external controller if provided, otherwise create internal one
    _internalController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    focusNode.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final menuWidth = widget.width ?? 350;

    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(36, 69, 80, 112),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(2, 4),
          )
        ],
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownMenu<String>(
        width: menuWidth,
        controller: _internalController,
        focusNode: focusNode,
        label: Text(widget.label),
        enableFilter: widget.enableFilter,
        requestFocusOnTap: widget.requestFocusOnTap,
        menuStyle: MenuStyle(
          backgroundColor: const WidgetStatePropertyAll(Colors.white),
          minimumSize: WidgetStatePropertyAll(
              Size(menuWidth, 0)), // Use 0 for min height
          fixedSize: WidgetStatePropertyAll(Size(
              menuWidth, double.infinity)), // Use infinity for flexible height
          elevation: const WidgetStatePropertyAll(8),
        ),
        onSelected: (String? value) {
          setState(() {
            selectedValue = value;
            if (value != null) {
              _internalController.text = value;
            }
          });
          focusNode.unfocus();
          widget.onSelected?.call(value);
        },
        dropdownMenuEntries: widget.entries
            .map<DropdownMenuEntry<String>>(
              (String entry) => DropdownMenuEntry<String>(
                value: entry,
                label: entry,
              ),
            )
            .toList(),
      ),
    );
  }
}
