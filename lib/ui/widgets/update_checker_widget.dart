import 'package:flutter/material.dart';
import 'package:torrents_digger/src/rust/api/app.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

class UpdateChecker extends StatefulWidget {
  const UpdateChecker({super.key});

  @override
  State<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends State<UpdateChecker> {
  bool _isLoading = false;

  void checkNewRelease() async {
    setState(() {
      _isLoading = true; // show the spinner
    });

    try {
      var returnedValue = await checkNewUpdate();

      if (returnedValue == 0) {
        createSnackBar(
          message: "New Version is Available \n Update it...",
          duration: 5,
        );
      } else if (returnedValue == 1) {
        createSnackBar(message: "You are using latest version...", duration: 5);
      }
    } catch (e) {
      createSnackBar(message: "Error : ${e.toString()}", duration: 10);
    } finally {
      setState(() {
        _isLoading = false; // hide the spinner
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.update),
      title: const Text('Check For Update'),
      onTap: _isLoading ? null : checkNewRelease, // disable while loading
    );
  }
}
