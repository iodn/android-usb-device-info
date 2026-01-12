import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/device/device_detail_screen.dart';
import '../../features/history/history_entry_detail_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/settings/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: HomeScreen.routeName,
        pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const HomeScreen(),
        ),
        routes: [
          GoRoute(
            path: 'device/:id',
            name: DeviceDetailScreen.routeName,
            pageBuilder: (context, state) {
              final encoded = state.pathParameters['id'] ?? '';
              final deviceName = Uri.decodeComponent(encoded);
              return MaterialPage(
                key: state.pageKey,
                child: DeviceDetailScreen(
                  key: ValueKey(deviceName),
                  deviceName: deviceName,
                ),
              );
            },
          ),
          GoRoute(
            path: 'history',
            name: HistoryScreen.routeName,
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const HistoryScreen(),
            ),
            routes: [
              GoRoute(
                path: 'entry/:id',
                name: HistoryEntryDetailScreen.routeName,
                pageBuilder: (context, state) {
                  final encoded = state.pathParameters['id'] ?? '';
                  final entryId = Uri.decodeComponent(encoded);
                  return MaterialPage(
                    key: state.pageKey,
                    child: HistoryEntryDetailScreen(entryId: entryId),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'settings',
            name: SettingsScreen.routeName,
            pageBuilder: (context, state) => MaterialPage(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _RouterErrorScreen(error: state.error),
  );
});

class _RouterErrorScreen extends StatelessWidget {
  const _RouterErrorScreen({this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation error')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(error?.toString() ?? 'Unknown error'),
      ),
    );
  }
}
