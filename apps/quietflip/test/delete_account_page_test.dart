import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Google Play needs a public URL that explains how to delete an account. The
// page is static HTML under web/, so Hosting serves it before the `**` rewrite
// that would otherwise show the clock. These checks keep its promises tied to
// the app and the hosting config.
void main() {
  const supportEmail = 'ajaymail2114@gmail.com';
  final page = File('web/delete-account/index.html').readAsStringSync();

  test('names the app and the page purpose', () {
    expect(page, contains('<title>Delete your QuietFlip account</title>'));
    expect(page, contains('QuietFlip is an ad-free flip clock'));
  });

  test('every mailto goes to the one support address', () {
    final targets = RegExp(
      r'mailto:([^?"]+)',
    ).allMatches(page).map((m) => m.group(1)).toSet();
    expect(targets, {supportEmail});
  });

  test('the request email carries a subject', () {
    expect(page, contains('subject=QuietFlip%20account%20deletion%20request'));
  });

  test('the in-app path uses the real labels', () {
    final strings = File(
      '../../packages/localization/lib/messages.i69n.yaml',
    ).readAsStringSync();
    expect(strings, contains('  settings: "Settings"'));
    expect(strings, contains('sync:\n  account: "Account"'));
    expect(strings, contains('  delete_account: "Delete account"'));
    expect(page, contains('Settings &gt; Account &gt; Delete account'));
  });

  test('asks for the sender address, never a password', () {
    expect(page, contains('from the email address of your QuietFlip account'));
    expect(page, contains('never ask for your password'));
    expect(page, isNot(contains('<form')));
    expect(page, isNot(contains('<input')));
  });

  test('states verification, timeframes, deletions and retention', () {
    for (final phrase in [
      'verif',
      'within 7 days',
      'within 30 days',
      'Firebase Authentication',
      'Firestore',
      'Google Analytics for Firebase',
      'Firebase Crashlytics',
      'does not remove them',
    ]) {
      expect(
        page.toLowerCase(),
        contains(phrase.toLowerCase()),
        reason: phrase,
      );
    }
  });

  test('is self-contained: no script, no external asset', () {
    expect(page, isNot(contains('<script')));
    expect(page, isNot(contains('src="http')));
    expect(page, isNot(contains('<link rel="stylesheet"')));
  });

  test('is readable on a phone and labelled for screen readers', () {
    expect(page, contains('<html lang="en">'));
    expect(page, contains('name="viewport" content="width=device-width'));
  });

  test('Hosting publishes build/web and does not ignore the page', () {
    final hosting =
        (jsonDecode(File('firebase.json').readAsStringSync())
                as Map<String, dynamic>)['hosting']
            as Map<String, dynamic>;
    expect(hosting['public'], 'build/web');
    final ignored = (hosting['ignore'] as List).cast<String>();
    expect(
      ignored.where((p) => p == '**' || p.contains('delete-account')),
      isEmpty,
    );
  });
}
