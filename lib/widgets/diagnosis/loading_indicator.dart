import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64.0),
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Running AI Diagnostics...", style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
