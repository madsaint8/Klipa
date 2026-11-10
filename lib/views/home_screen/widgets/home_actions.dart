import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodel/home_view_model.dart';


class HomeActions extends StatelessWidget {
  const HomeActions({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeViewModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: vm.logout,
          child: const Text("Logout"),
        ),
      ],
    );
  }
}
