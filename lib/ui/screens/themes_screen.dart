import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/themes_bloc/themes_bloc.dart';
import 'package:torrents_digger/themes/light_theme.dart';
import 'package:torrents_digger/themes/matrix_theme.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Themes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<ThemesBloc, ThemesState>(
            builder: (context, state) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.color_lens_outlined),
                    title: Text("Matrix"),
                    onTap: () {
                      context.read<ThemesBloc>().add(
                        ThemesEvent.changeTheme(appTheme: MatrixTheme()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.color_lens_outlined),
                    title: Text("Light"),
                    onTap: () {
                      context.read<ThemesBloc>().add(
                        ThemesEvent.changeTheme(appTheme: LightTheme()),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
