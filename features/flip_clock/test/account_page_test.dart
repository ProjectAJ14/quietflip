import 'package:cloud_sync/cloud_sync.dart';
import 'package:core/core.dart' as core;
import 'package:core/core.dart' show Logger;
import 'package:design_system/design_system.dart';
import 'package:di/di.dart';
import 'package:flip_clock/data/repositories/settings_repository_imp.dart';
import 'package:flip_clock/state/settings_controller.dart';
import 'package:flip_clock/ui/components/account_page.dart';
import 'package:flip_clock/ui/components/sync_card.dart';
import 'package:flip_clock/ui/screens/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localization/localization.dart';

import 'fakes.dart';

const _ada = SyncAccount(
  uid: 'u1',
  email: 'ada@example.com',
  provider: SyncProvider.google,
);

void main() {
  late SettingsController settings;
  late FakeCloudSync sync;
  late DateTime now;
  var signIns = 0;
  var signOuts = 0;
  var deletes = 0;
  var deletion = AccountDeletion.deleted;

  setUp(() async {
    await core.init();
    settings = SettingsController(
      repository: SettingsRepositoryImp(
        store: FakeStore(),
        logger: di.get<Logger>(),
      ),
      alerts: FakeAlerts(),
    );
    sync = FakeCloudSync();
    now = DateTime(2026, 10, 2, 14, 30);
    signIns = signOuts = deletes = 0;
    deletion = AccountDeletion.deleted;
  });
  tearDown(di.reset);

  Future<void> open(
    WidgetTester tester, {
    Size size = const Size(375, 900),
    double textScale = 1,
    String? category,
    bool withSync = true,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    // A fresh tree, so each open starts where its arguments say.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      DesignSystemWrapper(
        mode: AppearanceMode.black,
        builder: (context, theme) => MaterialApp(
          theme: theme,
          home: SettingsScreen(
            settings: settings,
            sound: FakeSound(),
            desktop: size.width >= 600,
            category: category,
            now: () => now,
            sync: withSync ? sync : null,
            onSignIn: () => signIns++,
            onSignOut: () async => signOuts++,
            onDeleteAccount: () async {
              deletes++;
              return deletion;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(GoogleFonts.pendingFonts);
    await tester.pumpAndSettle();
  }

  void signIn({SyncStatus? status, DateTime? last}) {
    sync
      ..lastSyncedValue = last
      ..accountValue.value = _ada
      ..statusValue.value = status ?? SyncDone(last ?? DateTime(2026));
  }

  Future<void> openAccount(WidgetTester tester) async {
    await tester.tap(find.byType(SyncCard));
    await tester.pumpAndSettle();
  }

  final s = strings.sync;

  testWidgets('no card and no account page without a sync', (tester) async {
    await open(tester, withSync: false);
    expect(find.text(s.card_title_signed_out), findsNothing);
    expect(find.byType(SyncCard), findsNothing);
  });

  testWidgets('signed out: the card sits below every category and opens the '
      'account page; Sign in to sync calls back', (tester) async {
    await open(tester);
    final card = tester.getRect(find.text(s.card_title_signed_out));
    final about = tester.getRect(find.text(strings.clock.settings_about));
    expect(card.top, greaterThan(about.bottom));
    expect(find.text(s.card_body_signed_out), findsOneWidget);
    expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
    await openAccount(tester);
    expect(find.text(s.headline), findsOneWidget);
    expect(find.text(s.body), findsOneWidget);
    expect(find.text(s.what_syncs.toUpperCase()), findsOneWidget);
    expect(find.text(s.what_syncs_body), findsOneWidget);
    expect(find.text(s.stays_body), findsOneWidget);
    final button = find.widgetWithText(AppButton, s.sign_in);
    expect(tester.getSize(button).width, lessThanOrEqualTo(320));
    await tester.tap(button);
    expect(signIns, 1);
  });

  testWidgets('desktop: the card is at the bottom of the sidebar', (
    tester,
  ) async {
    await open(tester, size: const Size(1280, 900));
    final card = tester.getRect(find.text(s.card_title_signed_out));
    expect(card.bottom, greaterThan(900 - 120));
    expect(card.right, lessThan(SettingsShell.desktopSidebarWidth));
  });

  testWidgets(
    'signed in: account, provider, switch, last sync, sign-out note',
    (tester) async {
      signIn(last: now.subtract(const Duration(minutes: 5)));
      await open(tester);
      expect(find.text(s.card_title_on), findsOneWidget);
      expect(find.text(s.card_last_synced('5 min ago')), findsOneWidget);
      expect(find.byIcon(Icons.cloud_done_outlined), findsOneWidget);
      await openAccount(tester);
      expect(find.text(_ada.email), findsOneWidget);
      expect(find.text(s.provider_google), findsOneWidget);
      expect(find.text(s.sync_settings), findsOneWidget);
      expect(find.text(s.sync_settings_note), findsOneWidget);
      expect(find.text(s.last_synced), findsOneWidget);
      expect(find.text('5 min ago'), findsOneWidget);
      expect(find.text(s.sign_out_note), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      await tester.tap(find.text(s.sync_settings));
      await tester.pumpAndSettle();
      expect(sync.switches, [false]);
      expect(find.text(s.off_note), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.text(s.card_title_off), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
    },
  );

  testWidgets('providers are labelled', (tester) async {
    for (final (provider, label) in [
      (SyncProvider.email, s.provider_email),
      (SyncProvider.apple, s.provider_apple),
    ]) {
      sync.accountValue.value = SyncAccount(
        uid: 'u',
        email: 'e@x.io',
        provider: provider,
      );
      sync.statusValue.value = const SyncOff();
      await open(tester, category: 'account');
      expect(find.text(label), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('every status has its line, on the page and the card, and '
      'none raises a toast or snackbar', (tester) async {
    signIn(status: const SyncPending());
    await open(tester, category: 'account');
    final cases = <(SyncStatus, String, IconData)>[
      (const SyncPending(), s.syncing, Icons.cloud_sync_outlined),
      (const SyncWaiting(), s.waiting, Icons.cloud_sync_outlined),
      (
        SyncFailed(now, SyncFailure.offline),
        s.failed_offline,
        Icons.error_outline,
      ),
      (
        SyncFailed(now, SyncFailure.denied),
        s.failed_denied,
        Icons.error_outline,
      ),
      (
        SyncFailed(now, SyncFailure.unknown),
        s.failed_unknown,
        Icons.error_outline,
      ),
    ];
    for (final (status, line, _) in cases) {
      sync.statusValue.value = status;
      await tester.pumpAndSettle();
      // The page line, and the card's subtitle (phone page shows the page;
      // the card is checked on desktop below).
      expect(find.text(line), findsOneWidget, reason: line);
      final failed = status is SyncFailed;
      expect(
        tester.widget<Text>(find.text(line)).style?.color,
        failed ? DesignColors.dark.danger : DesignColors.dark.inkMuted,
      );
      expect(find.byType(SnackBar), findsNothing);
    }
    // Signed in but the switch is off.
    sync.enabledValue = false;
    sync.statusValue.value = const SyncOff();
    await tester.pumpAndSettle();
    expect(find.text(s.off_note), findsOneWidget);

    // The card shows the same, with an icon per status.
    sync.enabledValue = true;
    await open(tester, size: const Size(1280, 900));
    for (final (status, line, icon) in cases) {
      sync.statusValue.value = status;
      await tester.pumpAndSettle();
      expect(find.text(line), findsOneWidget, reason: 'card $line');
      expect(find.byIcon(icon), findsOneWidget, reason: 'card $line');
    }
    sync.statusValue.value = const SyncOff();
    await tester.pumpAndSettle();
    expect(find.text(s.card_last_synced(s.never)), findsOneWidget);
  });

  testWidgets('denied taps to sign in; unknown offers Try again', (
    tester,
  ) async {
    signIn(status: SyncFailed(now, SyncFailure.denied));
    await open(tester, category: 'account');
    expect(find.text(s.try_again), findsNothing);
    await tester.tap(find.text(s.failed_denied));
    expect(signIns, 1);
    sync.statusValue.value = SyncFailed(now, SyncFailure.unknown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.try_again));
    expect(sync.retries, 1);
    // Offline: no button, it retries by itself on reconnect.
    sync.statusValue.value = SyncFailed(now, SyncFailure.offline);
    await tester.pumpAndSettle();
    expect(find.text(s.try_again), findsNothing);
    await tester.tap(find.text(s.failed_offline));
    expect(signIns, 1);
  });

  testWidgets('last synced: just now, minutes, today, an earlier date, never', (
    tester,
  ) async {
    signIn(last: now.subtract(const Duration(seconds: 30)));
    await open(tester, category: 'account');
    expect(find.text(s.just_now), findsOneWidget);
    for (final (last, text) in [
      (now.subtract(const Duration(minutes: 5)), '5 min ago'),
      (DateTime(2026, 10, 2, 9, 5), s.today_at('09:05')),
      (
        DateTime(2026, 10, 1, 23, 50),
        const DefaultMaterialLocalizations().formatMediumDate(
          DateTime(2026, 10, 1),
        ),
      ),
      (null, s.never),
    ]) {
      sync.lastSyncedValue = last;
      sync.statusValue.value = SyncDone(DateTime(2000 + text.length));
      await tester.pumpAndSettle();
      expect(find.text(text), findsOneWidget, reason: text);
    }
    // 12-hour time follows the clock's setting.
    await settings.update(settings.state.copyWith(use24h: false));
    sync.lastSyncedValue = DateTime(2026, 10, 2, 13, 5);
    sync.statusValue.value = SyncDone(DateTime(1999));
    await tester.pumpAndSettle();
    expect(find.text(s.today_at('1:05 PM')), findsOneWidget);
  });

  testWidgets('the relative time refreshes every 30 s and the timer stops '
      'with the page', (tester) async {
    signIn(last: now);
    await open(tester, category: 'account');
    expect(find.text(s.just_now), findsOneWidget);
    now = now.add(const Duration(minutes: 2));
    await tester.pump(const Duration(seconds: 29));
    expect(find.text(s.just_now), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2 min ago'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    // A periodic timer left running would fail the test here.
  });

  testWidgets('sign out asks first, then calls back; the page follows the '
      'account', (tester) async {
    signIn();
    await open(tester, category: 'account');
    await tester.tap(find.text(strings.auth.sign_out));
    await tester.pumpAndSettle();
    expect(find.text(strings.auth.sign_out_confirmation), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(signOuts, 0);
    await tester.tap(find.text(strings.auth.sign_out));
    await tester.pumpAndSettle();
    await tester.tap(find.text(strings.auth.sign_out).last);
    await tester.pumpAndSettle();
    expect(signOuts, 1);
    sync.accountValue.value = null;
    sync.statusValue.value = const SyncOff();
    await tester.pumpAndSettle();
    expect(find.text(s.headline), findsOneWidget);
  });

  testWidgets('delete asks first and calls back', (tester) async {
    signIn();
    await open(tester, category: 'account');
    await tester.tap(find.text(s.delete_account));
    await tester.pumpAndSettle();
    expect(find.text(s.delete_title), findsOneWidget);
    expect(find.text(s.delete_body), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(deletes, 0);
    await tester.tap(find.text(s.delete_account));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.delete_account).last);
    await tester.pumpAndSettle();
    expect(deletes, 1);
    expect(find.byType(AlertDialog), findsNothing);
    expect(signIns, 0);
  });

  testWidgets('delete needing a recent sign-in says so, then opens sign-in; '
      'other failures say so', (tester) async {
    signIn();
    deletion = AccountDeletion.needsSignIn;
    await open(tester, category: 'account');
    await tester.tap(find.text(s.delete_account));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.delete_account).last);
    await tester.pumpAndSettle();
    expect(find.text(s.delete_recent_login), findsOneWidget);
    expect(signIns, 0);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(signIns, 1);

    deletion = AccountDeletion.failed;
    await tester.tap(find.text(s.delete_account));
    await tester.pumpAndSettle();
    await tester.tap(find.text(s.delete_account).last);
    await tester.pumpAndSettle();
    expect(find.text(s.delete_failed), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(signIns, 1);
  });

  testWidgets('category=account opens the page; without a sync it is ignored', (
    tester,
  ) async {
    await open(tester, category: 'account');
    expect(find.text(s.headline), findsOneWidget);
    await open(tester, category: 'account', size: const Size(1280, 900));
    expect(find.text(s.body), findsOneWidget);
    await open(tester, category: 'account', withSync: false);
    expect(find.text(strings.clock.settings), findsOneWidget);
    expect(find.text(s.headline), findsNothing);
  });

  testWidgets('fits at text scale 2, signed out and signed in', (tester) async {
    await open(tester, textScale: 2, category: 'account');
    expect(tester.takeException(), isNull);
    signIn(status: SyncFailed(now, SyncFailure.unknown));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await open(tester, textScale: 2);
    await tester.scrollUntilVisible(
      find.text(s.card_title_on),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the card announces its title and status as one', (tester) async {
    final handle = tester.ensureSemantics();
    signIn(last: now);
    await open(tester, size: const Size(1280, 900));
    expect(
      find.bySemanticsLabel(
        RegExp('${s.card_title_on}\n${s.card_last_synced(s.just_now)}'),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });
}
