import 'package:flutter/material.dart';

class NavigateDatasWidget extends StatefulWidget {
  final String text;
  final VoidCallback onClickedPrevious;
  final VoidCallback onClickedNext;

  const NavigateDatasWidget({
    super.key,
    required this.text,
    required this.onClickedPrevious,
    required this.onClickedNext,
  });

  @override
  _NavigateDatasWidgetState createState() => _NavigateDatasWidgetState();
}

class _NavigateDatasWidgetState extends State<NavigateDatasWidget> {
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: widget.onClickedPrevious,
            icon: const Icon(Icons.navigate_before),
            iconSize: 48,
          ),
          Text(
            widget.text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: widget.onClickedNext,
            icon: const Icon(Icons.navigate_next),
            iconSize: 48,
          ),
        ],
      );
}
