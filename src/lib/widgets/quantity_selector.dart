import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuantitySelector extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;

  const QuantitySelector({
    Key? key,
    required this.initialValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialValue;
  }

  void _increment() {
    setState(() {
      _quantity++;
      widget.onChanged(_quantity);
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        widget.onChanged(_quantity);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: _quantity > 1 ? _decrement : null,
            color: AppTheme.primaryColor,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _quantity.toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _increment,
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}