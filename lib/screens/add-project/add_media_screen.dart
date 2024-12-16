import 'package:flutter/material.dart';
import 'package:flutter_camera_example/screens/add-project/select_template_screen.dart';
import 'package:flutter_camera_example/utils/global_state.dart';
import 'package:flutter_camera_example/widgets/StepIndicator.dart';
import 'package:flutter_camera_example/widgets/media_upload.dart';
import 'package:provider/provider.dart';

class AddMediaScreen extends StatelessWidget {
  const AddMediaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateModel>(
      builder: (context, appState, child) {
        final memoryMediaList = appState.preferences.memoryMediaList;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: TextButton(
              child: const Text('חזור', style: TextStyle(color: Colors.black)),
              onPressed: () {
                appState.clearMemoryMediaList();
                Navigator.of(context).pop();
              },
            ),
            actions: [
              TextButton(
                child: const Text('הבא', style: TextStyle(color: Colors.green)),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const SelectTemplateScreen()),
                  );
                },
              ),
            ],
          ),
          body: Consumer<AppStateModel>(
            // Add this wrapper
            builder: (context, model, child) {
              final mediaItems =
                  model.getMediaItems(); // Get media items from state
              return const Column(
                children: [
                  StepIndicator(pageIndex: 1),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'הוסף מדיה',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: MediaUpload()),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

