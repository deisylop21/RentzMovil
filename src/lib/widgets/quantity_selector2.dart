import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuantitySelector extends StatefulWidget {
  final void Function(int) onQuantityChanged;
  final int initialValue;

  const QuantitySelector({
    Key? key,
    required this.onQuantityChanged,
    this.initialValue = 1,
  }) : super(key: key);

  @override
  _QuantitySelectorState createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialValue;
  }

  void _updateQuantity(int newQuantity) {
    setState(() {
      quantity = newQuantity;
    });
    widget.onQuantityChanged(newQuantity);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: quantity > 1
                ? () => _updateQuantity(quantity - 1)
                : null,
            color: AppTheme.primaryColor,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              quantity.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _updateQuantity(quantity + 1),
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}