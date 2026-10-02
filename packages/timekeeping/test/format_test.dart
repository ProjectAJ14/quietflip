import 'package:flutter_test/flutter_test.dart';
import 'package:timekeeping/timekeeping.dart';

/// English markers, as `MaterialLocalizations` gives them in English.
const en = (am: 'AM', pm: 'PM');

void main() {
  group('formatClock', () {
    final cases = <(DateTime, bool, bool, String)>[
      (DateTime(2026, 1, 1, 9, 41, 7), true, false, '09:41'),
      (DateTime(2026, 1, 1, 9, 41, 7), true, true, '09:41:07'),
      (DateTime(2026, 1, 1, 0, 5), true, false, '00:05'),
      (DateTime(2026, 1, 1, 23, 59, 59), true, true, '23:59:59'),
      (DateTime(2026, 1, 1, 9, 41, 7), false, false, '9:41 AM'),
      (DateTime(2026, 1, 1, 9, 41, 7), false, true, '9:41:07 AM'),
      (DateTime(2026, 1, 1, 0, 5), false, false, '12:05 AM'),
      (DateTime(2026, 1, 1, 12, 30), false, false, '12:30 PM'),
      (DateTime(2026, 1, 1, 11, 59, 59), false, true, '11:59:59 AM'),
      (DateTime(2026, 1, 1, 13, 0), false, false, '1:00 PM'),
      (DateTime(2026, 1, 1, 23, 59), false, false, '11:59 PM'),
    ];
    for (final (t, use24h, showSeconds, expected) in cases) {
      test('$t 24h=$use24h seconds=$showSeconds -> $expected', () {
        expect(
          formatClock(
            t,
            use24h: use24h,
            showSeconds: showSeconds,
            meridiem: en,
          ),
          expected,
        );
      });
    }
  });

  test('12-hour time takes the language\'s markers', () {
    const ja = (am: '午前', pm: '午後');
    expect(
      formatClock(
        DateTime(2026, 1, 1, 9, 41),
        use24h: false,
        showSeconds: false,
        meridiem: ja,
      ),
      '9:41 午前',
    );
    expect(meridiemFor(DateTime(2026, 1, 1, 11, 59), ja), '午前');
    expect(meridiemFor(DateTime(2026, 1, 1, 12), ja), '午後');
    // 24-hour time never shows one.
    expect(
      formatClock(
        DateTime(2026, 1, 1, 21, 5),
        use24h: true,
        showSeconds: false,
        meridiem: ja,
      ),
      '21:05',
    );
  });

  test('formatHms pads every field and clamps negatives', () {
    expect(formatHms(Duration.zero), '00:00:00');
    expect(formatHms(const Duration(seconds: 61)), '00:01:01');
    expect(formatHms(Countdown.max), '99:59:59');
    expect(formatHms(const Duration(seconds: -5)), '00:00:00');
  });

  test('ceilToSecond rounds up to whole seconds', () {
    expect(ceilToSecond(Duration.zero), Duration.zero);
    expect(ceilToSecond(const Duration(milliseconds: -400)), Duration.zero);
    expect(
      ceilToSecond(const Duration(microseconds: 1)),
      const Duration(seconds: 1),
    );
    expect(
      ceilToSecond(const Duration(milliseconds: 400)),
      const Duration(seconds: 1),
    );
    expect(
      ceilToSecond(const Duration(seconds: 2)),
      const Duration(seconds: 2),
    );
    expect(
      ceilToSecond(const Duration(milliseconds: 2001)),
      const Duration(seconds: 3),
    );
    expect(
      formatHms(ceilToSecond(const Duration(milliseconds: 400))),
      '00:00:01',
    );
  });

  test('formatStopwatch shows truncated tenths and unbounded hours', () {
    expect(formatStopwatch(Duration.zero), '0:00:00.0');
    expect(formatStopwatch(const Duration(milliseconds: 1299)), '0:00:01.2');
    expect(
      formatStopwatch(
        const Duration(minutes: 59, seconds: 59, milliseconds: 999),
      ),
      '0:59:59.9',
    );
    expect(
      formatStopwatch(const Duration(hours: 123, minutes: 4)),
      '123:04:00.0',
    );
    expect(formatStopwatch(const Duration(seconds: -1)), '0:00:00.0');
  });
}
