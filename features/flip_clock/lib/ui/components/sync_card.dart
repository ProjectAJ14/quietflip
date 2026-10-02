import 'package:cloud_sync/cloud_sync.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';
import 'package:timekeeping/timekeeping.dart';

/// When [at] was, for "Last synced": "Just now" under a minute, "N min ago"
/// under an hour, "Today at 14:05" today (24 h or 12 h by [use24h]), else
/// the date. Null reads "Not yet".
String syncedWhen(
  BuildContext context,
  DateTime? at, {
  required DateTime now,
  required bool use24h,
}) {
  final s = strings.sync;
  if (at == null) return s.never;
  final ago = now.difference(at);
  if (ago < const Duration(minutes: 1)) return s.just_now;
  if (ago < const Duration(hours: 1)) return s.minutes_ago(ago.inMinutes);
  if (DateUtils.isSameDay(at, now)) {
    return s.today_at(formatClock(at, use24h: use24h, showSeconds: false));
  }
  return MaterialLocalizations.of(context).formatMediumDate(at);
}

/// The Account card at the bottom of Settings: why signing in is optional
/// when signed out; whether sync is on and how it went when signed in.
class SyncCard extends StatelessWidget {
  const SyncCard({
    super.key,
    required this.sync,
    required this.now,
    required this.use24h,
  });

  final CloudSync sync;
  final DateTime Function() now;
  final bool use24h;

  @override
  Widget build(BuildContext context) {
    final s = strings.sync;
    final colors = DesignColors.of(context);
    final text = Theme.of(context).textTheme;
    final status = sync.status.value;
    final (
      IconData icon,
      String title,
      String? subtitle,
    ) = switch (sync.account.value) {
      null => (
        Icons.cloud_outlined,
        s.card_title_signed_out,
        s.card_body_signed_out,
      ),
      _ when !sync.enabled => (
        Icons.cloud_off_outlined,
        s.card_title_off,
        null,
      ),
      _ => (
        switch (status) {
          SyncFailed() => Icons.error_outline,
          SyncPending() || SyncWaiting() => Icons.cloud_sync_outlined,
          SyncOff() => Icons.cloud_off_outlined,
          SyncDone() => Icons.cloud_done_outlined,
        },
        s.card_title_on,
        switch (status) {
          SyncPending() => s.syncing,
          SyncWaiting() => s.waiting,
          SyncFailed(:final reason) => failureText(reason),
          SyncOff() || SyncDone() => s.card_last_synced(
            syncedWhen(context, sync.lastSynced, now: now(), use24h: use24h),
          ),
        },
      ),
    };
    final failed = sync.account.value != null && status is SyncFailed;
    final tint = failed ? colors.danger : colors.ink;
    return MergeSemantics(
      child: Row(
        spacing: DesignSpace.s3,
        children: [
          Icon(icon, color: tint),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: text.bodyLarge?.copyWith(
                    color: colors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: text.bodyMedium?.copyWith(
                      color: failed ? colors.danger : colors.inkSubtle,
                    ),
                  ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: colors.inkSubtle),
        ],
      ),
    );
  }
}

/// What a failed sync says, inside Settings only.
String failureText(SyncFailure reason) => switch (reason) {
  SyncFailure.offline => strings.sync.failed_offline,
  SyncFailure.denied => strings.sync.failed_denied,
  SyncFailure.unknown => strings.sync.failed_unknown,
};
