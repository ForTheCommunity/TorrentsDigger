import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:torrents_digger/configs/build_context_extension.dart';
import 'package:torrents_digger/ui/widgets/launch_url.dart';
import 'package:torrents_digger/ui/widgets/scaffold_messenger.dart';

class ContributeScreen extends StatelessWidget {
  const ContributeScreen({super.key});

  final String _xmrAddress =
      "83eg4LiD5PEWGu6JpU2mfQVmVdNJQfKzGAi5GUGZKBkBdWBaGxxUrifCj1WyiUEtUfLNaxQjcfHDaDtxfZhr7RboPCVvTYf";
  final String _sourceCodeGitRepo =
      "https://gitlab.com/ForTheCommunity/TorrentsDigger";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contribute',
          style: TextStyle(color: context.appColors.appBarTextColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.handshake,
              size: 64,
              color: context.appColors.contributeGetInvolvedIconColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Get Involved',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.appColors.settingsTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us improve Torrents Digger by contributing code or supporting development.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.appColors.settingsTextColor,
              ),
            ),
            const SizedBox(height: 32),

            Card(
              color: context.appColors.contributeCardBackgroundColor,
              shadowColor: context.appColors.contributeCardShadowColor,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.code,
                        size: 32,
                        color: context.appColors.contributeSourceCodeIconColor,
                      ),
                      title: Text(
                        'Source Code',
                        style: TextStyle(
                          color: context.appColors.settingsTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Star the repo, report bugs, or submit pull requests.',
                        style: TextStyle(
                          color: context.appColors.settingsTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          createSnackBar(
                            message: "Opening Source Code Repository...",
                            duration: 2,
                          );
                          await openUrl(
                            urlType: UrlType.normalLink,
                            clipboardCopy: false,
                            url: _sourceCodeGitRepo,
                          );
                        },
                        icon: Icon(
                          Icons.open_in_new,
                          size: 18,
                          color: context.appColors.generalTextColor,
                        ),
                        label: Text(
                          "View Repository",
                          style: TextStyle(
                            color: context.appColors.generalTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            Card(
              color: context.appColors.contributeCardBackgroundColor,
              shadowColor: context.appColors.contributeCardShadowColor,
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.card_giftcard,
                        size: 32,
                        color: context
                            .appColors
                            .contributeSupportDevelopmentDonationIconColor,
                      ),
                      title: Text(
                        'Support Development',
                        style: TextStyle(
                          color: context.appColors.settingsTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Your support is essential for keeping the project alive.',
                        style: TextStyle(
                          color: context.appColors.settingsTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context
                            .appColors
                            .contributeCryptoAddressBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context
                              .appColors
                              .contributeCryptoAddressBorderColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Monero XMR Address",
                            style: TextStyle(
                              color: context.appColors.settingsTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            _xmrAddress,
                            style: TextStyle(
                              color: context
                                  .appColors
                                  .contributeCryptoAddressTextColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context
                              .appColors
                              .contributeCryptoAddressButtonBackgroundColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: _xmrAddress),
                          );
                          createSnackBar(
                            message: "Monero XMR address copied to clipboard",
                            duration: 2,
                          );
                        },
                        icon: Icon(
                          Icons.copy,
                          size: 19,
                          color: context.appColors.generalTextColor,
                        ),
                        label: Text(
                          "Copy Address",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: context.appColors.generalTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
