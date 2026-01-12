import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/theme_mode_controller.dart';
import '../../core/widgets/key_value_row.dart';
import '../../core/theme/dynamic_color_controller.dart';
import '../../data/db/usb_ids_update_controller.dart';
import '../../core/usb/usb_attach_pref_controller.dart';
import '../history/controllers/device_history_controller.dart';
import '../history/models/device_history_entry.dart';
import 'about_screen.dart';
import 'widgets/donation_sheet.dart';
import 'widgets/section_card.dart';
import 'widgets/support_pill.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const routeName = 'settings';

  static const String _appName = 'USBDevInfo';
  static const String _developerLabel = 'KaijinLab Inc.';
  static const String _repoUrl = 'https://github.com/iodn/android-usb-device-info';
  static const String _issuesUrl = 'https://github.com/iodn/android-usb-device-info/issues';

  static const String _btcAddress = 'bc1qtf79uecssueu4u4u86zct46vcs0vcd2cnmvw6f';
  static const String _ethAddress = '0xCaCc52Cd2D534D869a5C61dD3cAac57455f3c2fD';
  static const String _liberapayUrl = 'https://liberapay.com/KaijinLab/donate';

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No browser available'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _copyToClipboard(
    BuildContext context, {
    required String text,
    required String message,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    HapticFeedback.selectionClick();
  }

  void _openDonationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: DonationSheet(
            appName: _appName,
            repoUrl: _repoUrl,
            btcAddress: _btcAddress,
            ethAddress: _ethAddress,
            liberapayUrl: _liberapayUrl,
            onCopy: (text, message) => _copyToClipboard(ctx, text: text, message: message),
          ),
        );
      },
    );
  }

  Future<void> _changeTheme(WidgetRef ref, ThemeMode mode) async {
    await ref.read(themeModeControllerProvider.notifier).setThemeMode(mode);
    HapticFeedback.selectionClick();
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Auto Theme';
      case ThemeMode.light:
        return 'Light Theme';
      case ThemeMode.dark:
        return 'Dark Theme';
    }
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return Icons.auto_awesome_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }

  String _getThemeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follows your device settings';
      case ThemeMode.light:
        return 'Always bright and clear';
      case ThemeMode.dark:
        return 'Easy on the eyes';
    }
  }

  String _getThemeHint(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Theme automatically switches when you change your device settings between light and dark mode';
      case ThemeMode.light:
        return 'Perfect for daytime use and well-lit environments';
      case ThemeMode.dark:
        return 'Reduces eye strain in low-light conditions and saves battery on OLED screens';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(usbIdsAutoCheckCoordinatorProvider);
    final themeMode = ref.watch(themeModeControllerProvider);
    final updateAsync = ref.watch(usbIdsUpdateControllerProvider);
    final historyAsync = ref.watch(deviceHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 10),
            _buildDonationsSection(context, ref),
            const SizedBox(height: 10),
           _buildAppearanceSection(context, ref, themeMode),
           const SizedBox(height: 10),
           _buildUsbBehaviorSection(context, ref),
           const SizedBox(height: 10),
           _buildBackupSection(context, ref, historyAsync),
            const SizedBox(height: 10),
            updateAsync.when(
              loading: () => const _LoadingSection(),
              error: (e, _) => _ErrorSection(error: e.toString()),
              data: (st) => _usbIdsSection(context, ref, st),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _FooterNote(
                text: 'Tip: Exports are copied to your clipboard so you can paste them into a note, email, or GitHub issue.',
              ),
            ),
            const SizedBox(height: 10),
            _buildAboutSection(context),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationsSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SectionCard(
        title: 'Support Development',
        subtitle: 'Keep this app fast, free, and maintained',
        leading: Icon(Icons.volunteer_activism_rounded, color: cs.primary),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.secondaryContainer.withOpacity(0.7),
                      cs.secondaryContainer.withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'No ads, no tracking, fully offline. Your support helps fund maintenance, USB device compatibility fixes, and faster updates to the USB IDs database.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _openDonationSheet(context),
                      icon: const Icon(Icons.favorite_rounded),
                      label: const Text('Donate'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _launchUrl(context, _repoUrl),
                      onLongPress: () => _copyToClipboard(
                        context,
                        text: _repoUrl,
                        message: 'Repository link copied',
                      ),
                      icon: const Icon(Icons.star_border_rounded),
                      label: const Text('Star Repo'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SupportPill(icon: Icons.lock_outline_rounded, label: 'Local-only'),
                  SupportPill(icon: Icons.shield_outlined, label: 'No tracking'),
                  SupportPill(icon: Icons.speed_rounded, label: 'Lightweight'),
                  SupportPill(icon: Icons.code_rounded, label: 'Open-source'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context, WidgetRef ref, ThemeMode mode) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SectionCard(
        title: 'Appearance',
        subtitle: 'Customize your visual experience',
        leading: Icon(Icons.palette_outlined, color: cs.primary),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      cs.primaryContainer.withOpacity(0.6),
                      cs.primaryContainer.withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getThemeIcon(mode),
                        size: 20,
                        color: cs.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getThemeName(mode),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getThemeDescription(mode),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onPrimaryContainer.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ThemeCard(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Auto',
                      isSelected: mode == ThemeMode.system,
                      onTap: () => _changeTheme(ref, ThemeMode.system),
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ThemeCard(
                      icon: Icons.light_mode_rounded,
                      label: 'Light',
                      isSelected: mode == ThemeMode.light,
                      onTap: () => _changeTheme(ref, ThemeMode.light),
                      theme: theme,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ThemeCard(
                      icon: Icons.dark_mode_rounded,
                      label: 'Dark',
                      isSelected: mode == ThemeMode.dark,
                      onTap: () => _changeTheme(ref, ThemeMode.dark),
                      theme: theme,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
             SwitchListTile.adaptive(
               secondary: const Icon(Icons.wallpaper_rounded),
               title: const Text('Use dynamic colors'),
               subtitle: const Text('Match Material You palette on Android 12+. Disable to use the app palette.'),
               value: ref.watch(dynamicColorsControllerProvider),
               onChanged: (v) async {
                 await ref.read(dynamicColorsControllerProvider.notifier).setEnabled(v);
                 HapticFeedback.selectionClick();
               },
             ),
             const SizedBox(height: 12),
             Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getThemeHint(mode),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsbBehaviorSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final enabled = ref.watch(usbOfferAttachControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SectionCard(
        title: 'USB behavior',
        subtitle: 'Control system prompts when a USB device is attached',
        leading: Icon(Icons.usb_rounded, color: cs.primary),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Offer to open on USB attach'),
                subtitle: const Text('Appear in the Android chooser when a USB device is plugged in.'),
                value: enabled,
                onChanged: (v) async {
                  await ref.read(usbOfferAttachControllerProvider.notifier).setEnabled(v);
                  HapticFeedback.selectionClick();
                },
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.3)),
                ),
                child: Text(
                  'Disable this to stop Android from suggesting USBDevInfo on device attach. The app will still detect devices while open.',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackupSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<dynamic>> historyAsync,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    int? count;
    DateTime? latest;

    historyAsync.whenData((items) {
      count = items.length;
      if (items.isNotEmpty) {
        final first = items.first as dynamic;
        final testedAt = first.testedAt as DateTime?;
        latest = testedAt;
      }
    });

    final countLabel = count == null
        ? 'Loading…'
        : count == 0
            ? 'No history yet'
            : '$count item${count == 1 ? '' : 's'} recorded';
    final latestLabel = latest == null ? '—' : DateFormat('yyyy-MM-dd HH:mm').format(latest!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SectionCard(
        title: 'Backup & data',
        subtitle: 'Export your device history as JSON',
        leading: Icon(Icons.backup_rounded, color: cs.primary),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KeyValueRow(label: 'History', value: countLabel, allowCopy: false),
              KeyValueRow(label: 'Most recent', value: latestLabel, allowCopy: false),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cs.outlineVariant.withOpacity(0.22)),
                ),
                child: Text(
                  'Export includes vendor/product IDs, resolved names, strings, class/protocol, timestamps, and advanced details (descriptors, configurations, interfaces, HID reports) when permission was granted.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.80),
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: historyAsync.isLoading ? null : () => _exportHistoryJson(context, ref),
                      icon: const Icon(Icons.file_download_rounded),
                      label: const Text('Export JSON'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: historyAsync.isLoading ? null : () => _importHistoryJson(context, ref),
                      icon: const Icon(Icons.file_upload_rounded),
                      label: const Text('Import JSON'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _usbIdsSection(
    BuildContext context,
    WidgetRef ref,
    UsbIdsUpdateState st,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    String dt(DateTime? v) {
      if (v == null) return '—';
      return DateFormat('yyyy-MM-dd HH:mm').format(v);
    }

    final installed = (st.installedSha256 ?? '').trim().toLowerCase();
    final remote = (st.remoteSha256 ?? '').trim().toLowerCase();
    final hasInstalled = installed.isNotEmpty;
    final hasRemote = remote.isNotEmpty;
    final shaMatch = hasInstalled && hasRemote && installed == remote;

    final statusLine = !hasRemote
        ? 'Remote SHA not fetched yet.'
        : !hasInstalled
            ? 'Installed SHA will be saved after a successful update.'
            : shaMatch
                ? 'Installed SHA matches remote.'
                : 'Installed SHA differs from remote (update available).';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SectionCard(
        title: 'USB IDs database',
        subtitle: 'Metadata and updater',
        leading: Icon(Icons.storage_rounded, color: cs.primary),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KeyValueRow(label: 'Local version', value: st.localMeta.versionLabel),
              KeyValueRow(label: 'Local date', value: st.localMeta.dateLabel),
              const SizedBox(height: 10),
              Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(top: 8),
                  shape: const RoundedRectangleBorder(side: BorderSide.none),
                  collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
                  title: Text(
                    'Details',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    statusLine,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  children: [
                    KeyValueRow(
                      label: 'Installed SHA-256',
                      value: hasInstalled ? installed : '—',
                      valueStyle: theme.textTheme.bodySmall,
                    ),
                    KeyValueRow(
                      label: 'Remote SHA-256',
                      value: hasRemote ? remote : '—',
                      valueStyle: theme.textTheme.bodySmall,
                    ),
                    KeyValueRow(
                      label: 'SHA match',
                      value: (!hasInstalled || !hasRemote) ? '—' : (shaMatch ? 'Yes' : 'No'),
                      allowCopy: false,
                    ),
                    const Divider(height: 24),
                    KeyValueRow(label: 'Last checked', value: dt(st.lastCheckedAt), allowCopy: false),
                    KeyValueRow(
                      label: 'Update hint',
                      value: st.updateAvailableHint ? 'Available' : 'None',
                      allowCopy: false,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto-check for updates'),
                      subtitle: const Text('Checks the remote .sha256 about once per week.'),
                      value: st.autoCheckEnabled,
                      onChanged: st.busy
                          ? null
                          : (v) async {
                              await ref.read(usbIdsUpdateControllerProvider.notifier).setAutoCheckEnabled(v);
                              HapticFeedback.selectionClick();
                            },
                    ),
                    const SizedBox(height: 8),
                    if (st.busy) ...[
                      Row(
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              st.message ?? 'Working…',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(value: st.progress),
                      const SizedBox(height: 12),
                    ] else if ((st.message ?? '').trim().isNotEmpty) ...[
                      Text(
                        st.message!.trim(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if ((st.error ?? '').trim().isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.errorContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          st.error!.trim(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onErrorContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: st.busy
                                ? null
                                : () async {
                                    await ref.read(usbIdsUpdateControllerProvider.notifier).checkAndUpdateNow();
                                  },
                            icon: const Icon(Icons.system_update_alt_rounded),
                            label: Text(st.updateAvailableHint ? 'Update now' : 'Check now'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: st.busy
                              ? null
                              : () async {
                                  await ref.read(usbIdsUpdateControllerProvider.notifier).backgroundCheckIfDue();
                                  ref.invalidate(usbIdsUpdateControllerProvider);
                                },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SectionCard(
        title: 'About',
        subtitle: 'App information and legal',
        leading: Icon(Icons.info_outline, color: cs.primary),
        child: Column(
          children: [
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final info = snapshot.data;
                final version = info == null ? '—' : '${info.version}+${info.buildNumber}';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer.withOpacity(0.6),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  title: Text('$_appName - $_developerLabel'),
                  subtitle: Text('Version $version'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => AboutScreen(repoUrl: _repoUrl, issuesUrl: _issuesUrl, liberapayUrl: _liberapayUrl)),
                    );
                  },
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Licenses'),
              subtitle: const Text('Open source licenses'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: _appName,
                  applicationVersion: 'by $_developerLabel',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Report an issue'),
              subtitle: const Text('Bugs & feature requests'),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchUrl(context, _issuesUrl),
              onLongPress: () => _copyToClipboard(
                context,
                text: _issuesUrl,
                message: 'Issues link copied',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportHistoryJson(BuildContext context, WidgetRef ref) async {
    try {
      final items = await ref.read(deviceHistoryControllerProvider.future);
      if (!context.mounted) return;

      if (items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No history to export.')));
        return;
      }

      final payload = <String, Object?>{
        'schema': 'device_history_export_v1',
        'exportedAt': DateTime.now().toIso8601String(),
        'count': items.length,
        'items': items.map((e) => (e as dynamic).toMap()).toList(),
      };

      final pretty = const JsonEncoder.withIndent('  ').convert(payload);
      final compact = jsonEncode(payload);

      await showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        builder: (ctx) {
          return FractionallySizedBox(
            heightFactor: 0.92,
            child: _ExportHistorySheet(
              count: items.length,
              prettyJson: pretty,
              compactJson: compact,
              onCopy: (text) => _copyToClipboard(ctx, text: text, message: 'Export copied to clipboard.'),
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _importHistoryJson(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => _ImportHistorySheet(
        onImport: (text) async {
          try {
            final dynamic decoded = jsonDecode(text);
            List<dynamic> itemsDyn;

            if (decoded is Map && decoded['schema'] == 'device_history_export_v1') {
              itemsDyn = (decoded['items'] as List?) ?? const [];
            } else if (decoded is List) {
              itemsDyn = decoded;
            } else {
              throw 'Unsupported JSON format. Expecting an array or an export payload with schema=device_history_export_v1.';
            }

            final items = itemsDyn
                .whereType<Map>()
                .map((m) => DeviceHistoryEntry.fromMap(m.cast<Object?, Object?>()))
                .where((e) => e.id.isNotEmpty)
                .toList();

            if (items.isEmpty) throw 'No valid history entries found.';

            await ref.read(deviceHistoryControllerProvider.notifier).replaceAll(items);

            if (!ctx.mounted) return;
            Navigator.of(ctx).pop();

            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported ${items.length} item(s).')));
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
          }
        },
      ),
    );
  }

  Future<void> _confirmClearHistory(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This will remove all recorded devices from local storage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await ref.read(deviceHistoryControllerProvider.notifier).clearAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('History cleared.')));
      HapticFeedback.selectionClick();
    }
  }
}

class _ThemeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ThemeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer.withOpacity(0.7) : cs.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? cs.primary.withOpacity(0.5) : cs.outlineVariant.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : cs.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: 4),
              Icon(Icons.check_circle, size: 16, color: cs.primary),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SectionCard(
        title: 'USB IDs database',
        subtitle: 'Metadata and updater',
        leading: Icon(Icons.storage_rounded, color: cs.primary),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 10),
              Expanded(child: Text('Loading…')),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  const _ErrorSection({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SectionCard(
        title: 'USB IDs database',
        subtitle: 'Metadata and updater',
        leading: Icon(Icons.storage_rounded, color: cs.primary),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onErrorContainer),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportHistorySheet extends StatefulWidget {
  const _ExportHistorySheet({
    required this.count,
    required this.prettyJson,
    required this.compactJson,
    required this.onCopy,
  });

  final int count;
  final String prettyJson;
  final String compactJson;
  final Future<void> Function(String text) onCopy;

  @override
  State<_ExportHistorySheet> createState() => _ExportHistorySheetState();
}

class _ExportHistorySheetState extends State<_ExportHistorySheet> {
  bool _pretty = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final content = _pretty ? widget.prettyJson : widget.compactJson;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 6,
        bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: cs.primaryContainer.withOpacity(0.70),
                child: Icon(Icons.backup_rounded, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export history',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.count} item${widget.count == 1 ? '' : 's'} • JSON',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Pretty'),
                      icon: Icon(Icons.format_align_left_rounded),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Compact'),
                      icon: Icon(Icons.compress_rounded),
                    ),
                  ],
                  selected: {_pretty},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _pretty = s.first),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: () => widget.onCopy(content),
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withOpacity(0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  content,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12.5,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const _FooterNote(
            text: 'This export is safe to share for debugging, but it may contain device names/paths and serials.',
          ),
        ],
      ),
    );
  }
}

class _ImportHistorySheet extends StatefulWidget {
  const _ImportHistorySheet({required this.onImport});

  final Future<void> Function(String text) onImport;

  @override
  State<_ImportHistorySheet> createState() => _ImportHistorySheetState();
}

class _ImportHistorySheetState extends State<_ImportHistorySheet> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    final text = (data?.text ?? '').trim();
    if (!mounted) return;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clipboard is empty.')));
      return;
    }
    setState(() => _controller.text = text);
    HapticFeedback.selectionClick();
  }

  Future<void> _runImport() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Paste JSON first.')));
      return;
    }

    setState(() => _busy = true);
    try {
      await widget.onImport(text);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 6,
        bottom: 12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: cs.tertiaryContainer.withOpacity(0.70),
                child: Icon(Icons.file_upload_rounded, color: cs.onTertiaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import history',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Paste an export payload or a raw list of entries',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.72),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withOpacity(0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withOpacity(0.25)),
            ),
            child: Text(
              'Supported formats: device_history_export_v1 payload (recommended) or a raw JSON array of history entry maps.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              autocorrect: false,
              enableSuggestions: false,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12.5,
                height: 1.25,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'Paste JSON here…',
                filled: true,
                fillColor: cs.surfaceContainerHighest.withOpacity(0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.35)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.35)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: cs.primary.withOpacity(0.65), width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _pasteFromClipboard,
                  icon: const Icon(Icons.content_paste_rounded),
                  label: const Text('Paste'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _runImport,
                  icon: _busy
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.file_upload_rounded),
                  label: Text(_busy ? 'Importing…' : 'Import'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const _FooterNote(text: 'Import replaces your current history. If you are unsure, export first.'),
        ],
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  final String text;

  const _FooterNote({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.65)),
      ),
    );
  }
}
