import 'package:flutter/material.dart';

Future<void> showTrendingFilterBottomSheet(
  BuildContext context,
  String selectedOption,
  Function(String) onOptionSelected,
) {
  return showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SizedBox(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 120),
                    const Text(
                      "Trending Coins",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 100),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.cancel),
                    )
                  ],
                ),
                const Divider(),
                _buildOption(
                  context,
                  'Showing market stats for the last 24 hours. Tap to see more details',
                  selectedOption,
                  onOptionSelected,
                ),
                _buildOption(
                  context,
                  'Showing market stats for the last 7 days. Tap to see more details',
                  selectedOption,
                  onOptionSelected,
                ),
              ],
            ),
          );
        },
      );
    },
  );
}


Widget _buildOption(
  BuildContext context,
  String option,
  String selectedOption,
  Function(String) onOptionSelected,
) {
  return ListTile(
    title: Text(option),
    trailing: selectedOption == option
        ? const Icon(Icons.check, color: Colors.black)
        : null,
    onTap: () {
      onOptionSelected(option);
      Navigator.pop(context);
    },
  );
}
