import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/database/get_settings_data.dart';

class AdditionalSettings extends StatefulWidget {
  const AdditionalSettings({super.key});

  @override
  State<AdditionalSettings> createState() => _AdditionalSettingsState();
}

class _AdditionalSettingsState extends State<AdditionalSettings> {
  bool _useInAppBrowser = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final val = await getUseInAppBrowser();
    if (mounted) {
      setState(() {
        _useInAppBrowser = val;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleInAppBrowser(bool value) async {
    setState(() {
      _useInAppBrowser = value;
    });
    await setUseInAppBrowser(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Additional Settings',
          style: TextStyle(color: context.appColors.appBarTextColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
          SwitchListTile(
            secondary: Icon(
              Icons.language_outlined,
              color: context.appColors.settingsIconsColor,
            ),
            title: Text(
              'In-App Browser',
              style: TextStyle(color: context.appColors.settingsTextColor),
            ),
            subtitle: Text(
              'Open links inside the app using an in-app WebView instead of an external browser.',
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
            value: _useInAppBrowser,
            onChanged: _isLoading ? null : _toggleInAppBrowser,
          ),
        ],
      ),
    );
  }
}
