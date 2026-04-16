import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/l10n.dart';
import 'widgets/section_card.dart';
import 'widgets/support_pill.dart';

class AboutScreen extends StatefulWidget {
  final String repoUrl;
  final String issuesUrl;
  final String liberapayUrl;

  const AboutScreen({
    super.key,
    required this.repoUrl,
    required this.issuesUrl,
    required this.liberapayUrl,
  });

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  PackageInfo? _info;
  String? _logoAssetPath;

  static const List<String> _logoCandidates = <String>[
    'assets/images/logo.png',
    'assets/logo.png',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    final logo = await _findFirstExistingAsset(_logoCandidates);
    if (!mounted) return;
    setState(() {
      _info = info;
      _logoAssetPath = logo;
    });
  }

  Future<String?> _findFirstExistingAsset(List<String> candidates) async {
    for (final p in candidates) {
      try {
        await rootBundle.load(p);
        return p;
      } catch (_) {}
    }
    return null;
  }

  Future<void> _copy(BuildContext context, String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
    HapticFeedback.selectionClick();
  }

  Future<void> _launchExternal(BuildContext context, String url) async {
    final l10n = context.l10n;
    try {
      final uri = Uri.parse(url);
      final ok = await canLaunchUrl(uri);
      if (!ok) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noBrowserAvailable),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.usbAboutFailedToOpenLink),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToOpen('$e')),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _buildModeLabel() {
    if (kReleaseMode) return 'release';
    if (kProfileMode) return 'profile';
    return 'debug';
  }

  String _versionLabel() {
    final info = _info;
    if (info == null) return '—';
    final v = info.version.trim().isEmpty ? '—' : info.version.trim();
    final b = info.buildNumber.trim().isEmpty ? '—' : info.buildNumber.trim();
    return '$v+$b';
  }

  String _packageName() => _info?.packageName ?? '—';
  String _appName() => (_info?.appName.trim().isNotEmpty ?? false) ? _info!.appName : 'USBDevInfo';

  List<_OtherApp> _otherApps() {
    return const <_OtherApp>[
      _OtherApp(name: 'IR Blaster', url: 'https://github.com/iodn/android-ir-blaster'),
      _OtherApp(name: 'USBDevInfo', url: 'https://github.com/iodn/android-usb-device-info'),
      _OtherApp(name: 'GadgetFS', url: 'https://github.com/iodn/gadgetfs'),
      _OtherApp(name: 'TapDucky', url: 'https://github.com/iodn/tap-ducky'),
      _OtherApp(name: 'HIDWiggle', url: 'https://github.com/iodn/hid-wiggle'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final appName = _appName();
    final ver = _versionLabel();
    final pkg = _packageName();
    final modeKey = _buildModeLabel();
    final mode = switch (modeKey) {
      'release' => context.l10n.usbAboutBuildModeRelease,
      'profile' => context.l10n.usbAboutBuildModeProfile,
      _ => context.l10n.usbAboutBuildModeDebug,
    };
    final year = DateTime.now().year;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Center(
            child: Column(
              children: [
                _AppLogo(
                  assetPath: _logoAssetPath,
                  size: 88,
                  backgroundColor: cs.primaryContainer.withOpacity(0.7),
                  iconColor: cs.onPrimaryContainer,
                ),
                const SizedBox(height: 12),
                Text(
                  appName,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.usbAboutVersion(ver),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'KaijinLab Inc.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: context.l10n.usbAboutLinksTitle,
            subtitle: context.l10n.usbAboutLinksSubtitle,
            leading: Icon(Icons.link_rounded, color: cs.primary),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.code_rounded),
                  title: Text(context.l10n.usbAboutRepositoryTitle),
                  subtitle: Text(widget.repoUrl),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () => _launchExternal(context, widget.repoUrl),
                  onLongPress: () => _copy(context, widget.repoUrl, context.l10n.repositoryLinkCopied),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: Text(context.l10n.usbAboutReportIssueTitle),
                  subtitle: Text(widget.issuesUrl),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () => _launchExternal(context, widget.issuesUrl),
                  onLongPress: () => _copy(context, widget.issuesUrl, context.l10n.usbAboutIssuesLinkCopied),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_rounded),
                  title: Text(context.l10n.usbAboutDonateTitle),
                  subtitle: Text(widget.liberapayUrl),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () => _launchExternal(context, widget.liberapayUrl),
                  onLongPress: () => _copy(context, widget.liberapayUrl, context.l10n.usbAboutLiberapayLinkCopied),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.l10n.usbAboutWhatThisAppIsTitle,
            subtitle: context.l10n.usbAboutWhatThisAppIsSubtitle,
            leading: Icon(Icons.usb_rounded, color: cs.primary),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.usbAboutWhatThisAppIsBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.85),
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SupportPill(icon: Icons.usb_rounded, label: context.l10n.usbAboutUsbHostPill),
                      SupportPill(icon: Icons.view_list_rounded, label: context.l10n.usbAboutDescriptorsPill),
                      SupportPill(icon: Icons.storage_rounded, label: context.l10n.usbAboutOfflineUsbIdsPill),
                      SupportPill(icon: Icons.history_rounded, label: context.l10n.historyScreenTitle),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.l10n.usbAboutBuildInformationTitle,
            subtitle: context.l10n.usbAboutBuildInformationSubtitle,
            leading: Icon(Icons.info_outline, color: cs.primary),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _InfoRow(label: context.l10n.usbAboutAppLabel, value: appName),
                  const SizedBox(height: 10),
                  _InfoRow(label: context.l10n.usbAboutVersionLabel, value: ver),
                  const SizedBox(height: 10),
                  _InfoRow(label: context.l10n.usbAboutPackageLabel, value: pkg),
                  const SizedBox(height: 10),
                  _InfoRow(label: context.l10n.usbAboutBuildLabel, value: mode),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.l10n.usbAboutOtherAppsTitle,
            subtitle: context.l10n.usbAboutOtherAppsSubtitle,
            leading: Icon(Icons.apps_rounded, color: cs.primary),
            child: Column(
              children: [
                for (final a in _otherApps()) ...[
                  ListTile(
                    leading: const Icon(Icons.launch_rounded),
                    title: Text(a.name),
                    subtitle: Text(context.l10n.usbAboutOpenGithubRepository),
                    trailing: const Icon(Icons.open_in_new_rounded),
                    onTap: () => _launchExternal(context, a.url),
                    onLongPress: () => _copy(context, a.url, context.l10n.repositoryLinkCopied),
                  ),
                  if (a != _otherApps().last) const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: context.l10n.usbAboutLegalTitle,
            subtitle: context.l10n.usbAboutLegalSubtitle,
            leading: Icon(Icons.gavel_rounded, color: cs.primary),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.article_outlined),
                  title: Text(context.l10n.openSourceLicenses),
                  subtitle: Text(context.l10n.usbAboutViewThirdPartyLicenses),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: appName,
                      applicationVersion: ver,
                      applicationIcon: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _AppLogo(
                          assetPath: _logoAssetPath,
                          size: 56,
                          backgroundColor: cs.primaryContainer.withOpacity(0.7),
                          iconColor: cs.onPrimaryContainer,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.content_copy_rounded),
                  title: Text(context.l10n.usbAboutCopyBuildDetailsTitle),
                  subtitle: Text(context.l10n.usbAboutCopyBuildDetailsSubtitle),
                  onTap: () {
                    final text =
                        '$appName\nVersion: $ver\nPackage: $pkg\nBuild: $mode\nRepo: ${widget.repoUrl}\n';
                    _copy(context, text, context.l10n.usbAboutBuildDetailsCopied);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              context.l10n.usbAboutCopyright(year),
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurface.withOpacity(0.55),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.65),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SelectableText(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface.withOpacity(0.9),
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppLogo extends StatelessWidget {
  final String? assetPath;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const _AppLogo({
    required this.assetPath,
    required this.size,
    required this.backgroundColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget child;
    if (assetPath != null) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(size / 5),
        child: Image.asset(
          assetPath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.usb_rounded, size: size * 0.6, color: iconColor);
          },
        ),
      );
    } else {
      child = Icon(Icons.usb_rounded, size: size * 0.6, color: iconColor);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size / 4),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class _OtherApp {
  final String name;
  final String url;

  const _OtherApp({
    required this.name,
    required this.url,
  });
}
