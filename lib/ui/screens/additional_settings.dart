import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';

class AdditionalSettings extends StatelessWidget {
  const AdditionalSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Additional Settings',
          style: TextStyle(color: context.appColors.appBarTextColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        children: [
          BlocBuilder<SourceBloc, SourceState>(
            builder: (context, state) {
              return SwitchListTile(
                secondary: Icon(
                  Icons.manage_history_outlined,
                  color: context.appColors.settingsIconsColor,
                ),
                title: Text(
                  'Remember Selections',
                  style: TextStyle(color: context.appColors.settingsTextColor),
                ),
                subtitle: Text(
                  'Remember selected category, filter, etc for each source.',
                  style: TextStyle(
                    color: context.appColors.settingsTextColor,
                    fontSize: 12,
                  ),
                ),
                inactiveTrackColor:
                    context.appColors.settingsSwitchListTileInactiveTrackColor,
                inactiveThumbColor:
                    context.appColors.settingsSwitchListTileInactiveThumbColor,
                activeThumbColor:
                    context.appColors.settingsSwitchListTileActiveThumbColor,
                value: state.rememberSelections,
                onChanged: (value) {
                  context.read<SourceBloc>().add(
                    ToggleRememberSelections(value),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
