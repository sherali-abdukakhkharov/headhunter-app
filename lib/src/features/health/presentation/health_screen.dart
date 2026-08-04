import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:headhunter_app/src/core/config/app_config.dart';
import 'package:headhunter_app/src/core/design/design.dart';
import 'package:headhunter_app/src/core/network/api_exception.dart';
import 'package:headhunter_app/src/core/router/app_router.dart';
import 'package:headhunter_app/src/features/health/data/health_repository.dart';
import 'package:headhunter_app/src/features/health/domain/health_status.dart';

/// Proves the app -> backend -> Postgres chain works end to end.
///
/// This is scaffolding, not a product screen: replace it with the real first
/// feature once the backend exposes domain endpoints.
class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(healthStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend health'),
        actions: [
          // Debug-only entry point to the design-system catalogue. Never
          // reachable in a release build, and never part of the product shell.
          if (kDebugMode)
            IconButton(
              icon: const HhIcon(
                HhIconPath.filters,
                semanticLabel: 'Design system',
              ),
              tooltip: 'Design system',
              onPressed: () => context.go(Routes.designGallery),
            ),
          IconButton(
            icon: const HhIcon(
              HhIconPath.refresh,
              semanticLabel: 'Re-check',
            ),
            tooltip: 'Re-check',
            onPressed: () => ref.invalidate(healthStatusProvider),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(healthStatusProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Error is matched FIRST, and via hasError rather than the
            // AsyncError subtype. Riverpod represents a retrying provider as
            // AsyncLoading that carries the error, so matching AsyncLoading
            // first would hide a real failure behind a spinner forever.
            switch (health) {
              AsyncValue(hasError: true, :final error?) => _ErrorCard(
                error: error,
              ),
              AsyncValue(:final value?) => _HealthCard(status: value),
              _ => const _LoadingCard(),
            },
            const SizedBox(height: 16),
            _BaseUrlFooter(),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 16),
          Text('Contacting backend...'),
        ],
      ),
    ),
  );
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.status});

  final HealthStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final healthy = status.isHealthy;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  healthy ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: healthy
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Text(
                  healthy ? 'Backend healthy' : 'Backend degraded',
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(height: 28),
            _Row(label: 'Status', value: status.status),
            _Row(label: 'Database', value: status.database),
            _Row(label: 'Version', value: status.version),
            _Row(
              label: 'Checked at',
              value: status.timestamp.toIso8601String(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = error is ApiException
        ? (error as ApiException).message
        : 'Something went wrong: $error';

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_off,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cannot reach backend',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _BaseUrlFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      'API base URL: ${AppConfig.apiBaseUrl}\n'
      'Override with --dart-define=API_BASE_URL=...',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }
}
