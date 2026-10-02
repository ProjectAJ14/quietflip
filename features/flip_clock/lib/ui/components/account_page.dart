import 'dart:async';

import 'package:cloud_sync/cloud_sync.dart';
import 'package:design_system/design_system.dart';
import 'package:flip_clock/ui/components/sync_card.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// How deleting the account ended, as the app reports it.
enum AccountDeletion {
  /// The synced documents and the account are gone.
  deleted,

  /// Firebase wants a recent sign-in first; the app has signed out.
  needsSignIn,

  /// Anything else; nothing was deleted, or only the synced documents.
  failed,
}

/// The Account page pinned to the bottom of Settings. Signed out it says
/// why an account is optional; signed in it holds the Sync settings switch,
/// the last sync, any failure (only ever shown here), sign-out and delete.
SettingsCategory accountCategory(
  BuildContext context, {
  required CloudSync sync,
  required DateTime Function() now,
  required bool use24h,
  required VoidCallback onSignIn,
  required Future<void> Function() onSignOut,
  required Future<AccountDeletion> Function() onDeleteAccount,
  required ValueChanged<bool> onSyncChanged,
}) {
  final s = strings.sync;
  final account = sync.account.value;
  final status = sync.status.value;
  return SettingsCategory(
    icon: Icons.cloud_outlined,
    label: s.account,
    groups: account == null
        ? [
            SettingsGroup(rows: [_SignedOut(onSignIn: onSignIn)]),
            SettingsGroup(
              header: s.what_syncs,
              rows: [
                SettingsNoteRow(text: s.what_syncs_body),
                SettingsNoteRow(text: s.stays_body),
              ],
            ),
          ]
        : [
            SettingsGroup(
              header: s.account,
              rows: [
                SettingsValueRow(
                  label: account.email,
                  value: switch (account.provider) {
                    SyncProvider.email => s.provider_email,
                    SyncProvider.google => s.provider_google,
                    SyncProvider.apple => s.provider_apple,
                  },
                ),
              ],
            ),
            SettingsGroup(
              header: s.sync_header,
              rows: [
                SettingsSwitchRow(
                  label: s.sync_settings,
                  subtitle: s.sync_settings_note,
                  value: sync.enabled,
                  onChanged: onSyncChanged,
                ),
                LastSyncedRow(at: sync.lastSynced, now: now, use24h: use24h),
                if (_statusLine(sync) case final line?)
                  _StatusRow(
                    text: line,
                    failed: status is SyncFailed,
                    onTap: switch (status) {
                      SyncFailed(reason: SyncFailure.denied) => onSignIn,
                      _ => null,
                    },
                    onRetry: switch (status) {
                      SyncFailed(reason: SyncFailure.unknown) =>
                        () => unawaited(sync.retry()),
                      _ => null,
                    },
                  ),
              ],
            ),
            SettingsGroup(
              rows: [
                SettingsValueRow(
                  label: strings.auth.sign_out,
                  onTap: () => unawaited(_signOut(context, onSignOut)),
                ),
                _DangerRow(
                  label: s.delete_account,
                  onTap: () =>
                      unawaited(_delete(context, onDeleteAccount, onSignIn)),
                ),
              ],
              footer: s.sign_out_note,
            ),
          ],
  );
}

/// The line under Last synced, or null when there is nothing to add.
String? _statusLine(CloudSync sync) {
  final s = strings.sync;
  if (!sync.enabled) return s.off_note;
  return switch (sync.status.value) {
    SyncPending() => s.syncing,
    SyncWaiting() => s.waiting,
    SyncFailed(:final reason) => failureText(reason),
    SyncOff() || SyncDone() => null,
  };
}

Future<void> _signOut(
  BuildContext context,
  Future<void> Function() onSignOut,
) async {
  final confirmed = await _confirm(
    context,
    body: strings.auth.sign_out_confirmation,
    action: strings.auth.sign_out,
  );
  if (confirmed) await onSignOut();
}

Future<void> _delete(
  BuildContext context,
  Future<AccountDeletion> Function() onDeleteAccount,
  VoidCallback onSignIn,
) async {
  final s = strings.sync;
  final confirmed = await _confirm(
    context,
    title: s.delete_title,
    body: s.delete_body,
    action: s.delete_account,
    danger: true,
  );
  if (!confirmed) return;
  final result = await onDeleteAccount();
  if (!context.mounted) return;
  switch (result) {
    case AccountDeletion.deleted:
      break;
    case AccountDeletion.needsSignIn:
      await _tell(context, s.delete_recent_login);
      onSignIn();
    case AccountDeletion.failed:
      await _tell(context, s.delete_failed);
  }
}

Future<bool> _confirm(
  BuildContext context, {
  String? title,
  required String body,
  required String action,
  bool danger = false,
}) async {
  final colors = DesignColors.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          style: danger
              ? TextButton.styleFrom(foregroundColor: colors.danger)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

Future<void> _tell(BuildContext context, String message) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(MaterialLocalizations.of(context).okButtonLabel),
      ),
    ],
  ),
);

/// Signed out: the headline, why an account is optional, Sign in to sync.
class _SignedOut extends StatelessWidget {
  const _SignedOut({required this.onSignIn});

  final VoidCallback onSignIn;

  /// The Sign in button is full width up to this.
  static const double buttonWidth = 320;

  @override
  Widget build(BuildContext context) {
    final s = strings.sync;
    final colors = DesignColors.of(context);
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(DesignSpace.s6),
      child: Column(
        spacing: DesignSpace.s3,
        children: [
          Icon(
            Icons.cloud_outlined,
            size: DesignSize.cornerButton,
            color: colors.ink,
          ),
          Text(
            s.headline,
            textAlign: TextAlign.center,
            style: text.titleLarge?.copyWith(color: colors.ink),
          ),
          Text(
            s.body,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: DesignSpace.s3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: buttonWidth),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(onPressed: onSignIn, child: Text(s.sign_in)),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Last synced  2 min ago", refreshed every 30 s while it is on screen.
class LastSyncedRow extends StatefulWidget {
  const LastSyncedRow({
    super.key,
    required this.at,
    required this.now,
    required this.use24h,
  });

  final DateTime? at;
  final DateTime Function() now;
  final bool use24h;

  /// How often the relative time is redrawn.
  static const Duration refresh = Duration(seconds: 30);

  @override
  State<LastSyncedRow> createState() => _LastSyncedRowState();
}

class _LastSyncedRowState extends State<LastSyncedRow> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(LastSyncedRow.refresh, (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SettingsValueRow(
    label: strings.sync.last_synced,
    value: syncedWhen(
      context,
      widget.at,
      now: widget.now(),
      use24h: widget.use24h,
    ),
  );
}

/// A status line (danger when failed), announced when it changes, with an
/// optional Try again button; [onTap] makes the line itself a button.
class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.text,
    required this.failed,
    this.onTap,
    this.onRetry,
  });

  final String text;
  final bool failed;
  final VoidCallback? onTap;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = DesignColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpace.s4,
          vertical: DesignSpace.s2,
        ),
        child: Row(
          spacing: DesignSpace.s3,
          children: [
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: failed ? colors.danger : colors.inkMuted,
                  ),
                ),
              ),
            ),
            if (onRetry case final retry?)
              TextButton(onPressed: retry, child: Text(strings.sync.try_again)),
          ],
        ),
      ),
    );
  }
}

/// A full-width action row in the danger ink.
class _DangerRow extends StatelessWidget {
  const _DangerRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: DesignSize.cornerButton),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpace.s4,
          vertical: DesignSpace.s2,
        ),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: DesignColors.of(context).danger,
            ),
          ),
        ),
      ),
    ),
  );
}
