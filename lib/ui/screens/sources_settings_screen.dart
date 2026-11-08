import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:torrents_digger/blocs/sources_bloc/source_bloc.dart';
import 'package:torrents_digger/configs/extensions.dart';
import 'package:torrents_digger/configs/nsfw_helper.dart';

class SourcesSettingsScreen extends StatelessWidget {
  const SourcesSettingsScreen({super.key});

  static const List<String> fallbackSources = [
    "Nyaa",
    "Nyaa Sukebei",
    "Torrents Csv",
    "Uindex",
    "Lime Torrents",
    "Solid Torrents",
    "Knaben Database",
    "The Pirate Bay",
    "1337x",
    "YTS",
    "SubsPlease",
    "TheRARBG",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Torrent Sources',
          style: TextStyle(color: context.appColors.appBarTextColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SourceBloc, SourceState>(
        builder: (context, state) {
          final allSources = state.sources.isNotEmpty
              ? state.sources.map((s) => s.sourceName).toList()
              : fallbackSources;

          return ListView(
            children: [
              const SizedBox(height: 8),
              // NSFW Toggle
              SwitchListTile(
                secondary: Icon(
                  Icons.explicit_outlined,
                  color: context.appColors.settingsIconsColor,
                ),
                title: Text(
                  'Hide NSFW',
                  style: TextStyle(
                    color: context.appColors.settingsTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Hide adult content sources and NSFW categories from search and listings.',
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
                value: state.hideNsfw,
                onChanged: (val) {
                  context.read<SourceBloc>().add(ToggleHideNsfw(val));
                },
              ),
              const Divider(height: 24),

              // actions dropdown
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Sources',
                            style: TextStyle(
                              color: context.appColors.settingsTextColor,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Default sources enabled out of the box',
                            style: TextStyle(
                              color: context.appColors.settingsTextColor
                                  .withValues(alpha: 0.6),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      tooltip: 'Quick Actions',
                      onSelected: (val) {
                        if (val == 'defaults') {
                          context
                              .read<SourceBloc>()
                              .add(EnableDefaultSources());
                        } else if (val == 'all') {
                          context.read<SourceBloc>().add(EnableAllSources());
                        } else if (val == 'none') {
                          context
                              .read<SourceBloc>()
                              .add(DisableAllSources(allSources));
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'defaults',
                          child: Row(
                            children: [
                              Icon(Icons.restart_alt, size: 20),
                              SizedBox(width: 12),
                              Text('Enable Defaults'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'all',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 20),
                              SizedBox(width: 12),
                              Text('Enable All'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'none',
                          child: Row(
                            children: [
                              Icon(Icons.remove_circle_outline, size: 20),
                              SizedBox(width: 12),
                              Text('Disable All'),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt_outlined,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Actions',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Sources list
              ...allSources.map((sourceName) {
                final isNsfw = NsfwHelper.isNsfwSource(sourceName);
                final isDefault = SourcesConfig.isDefaultEnabled(sourceName);
                final isBlockedByNsfw = state.hideNsfw && isNsfw;
                final isEnabled =
                    !isBlockedByNsfw && state.isSourceEnabled(sourceName);

                return SwitchListTile(
                  secondary: Icon(
                    isNsfw
                        ? Icons.warning_amber_rounded
                        : Icons.cloud_outlined,
                    color: isBlockedByNsfw
                        ? Colors.grey
                        : context.appColors.settingsIconsColor,
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          sourceName,
                          style: TextStyle(
                            color: isBlockedByNsfw
                                ? Colors.grey
                                : context.appColors.settingsTextColor,
                          ),
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.blueAccent.withValues(alpha: 0.5),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      if (isNsfw) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.redAccent.withValues(alpha: 0.6),
                              width: 0.8,
                            ),
                          ),
                          child: const Text(
                            'NSFW',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: isBlockedByNsfw
                      ? const Text(
                          'Disabled because "Hide NSFW" is enabled',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        )
                      : null,
                  inactiveTrackColor: context
                      .appColors.settingsSwitchListTileInactiveTrackColor,
                  inactiveThumbColor: context
                      .appColors.settingsSwitchListTileInactiveThumbColor,
                  activeThumbColor:
                      context.appColors.settingsSwitchListTileActiveThumbColor,
                  value: isEnabled,
                  onChanged: isBlockedByNsfw
                      ? null
                      : (val) {
                          context.read<SourceBloc>().add(
                                ToggleSource(
                                  sourceName: sourceName,
                                  isEnabled: val,
                                ),
                              );
                        },
                );
              }),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
