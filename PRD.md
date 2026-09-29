# QuietFlip — Product Requirements Document

**Status:** Draft for product planning  
**Date:** 29 September 2026  
**Working name:** QuietFlip  
**Short description:** An ad-free flip clock, countdown timer, and stopwatch for phone, desktop, and web.

**Naming note:** QuietFlip is a working recommendation because it suggests both the flip display and the calm, ad-free experience. A preliminary web search did not surface a clock app with that exact name; this is not trademark or store-name clearance. "Flip Pilot" is already used by [an App Store app](https://apps.apple.com/gb/app/flip-pilot-ai/id6772052217) and appears in [a registered US software mark](https://trademarks.justia.com/888/48/flip-88848607.html), so it is a weaker launch choice.

## 1. Product summary

QuietFlip opens straight into a large, black flip clock. People can make it fill the screen, start a countdown, or use a stopwatch without creating an account. A few useful display settings live behind a small settings control. Preferences are saved locally. Optional account-based sync can follow after the core app is working well on every target platform.

### Product promise

**A beautiful clock that stays out of the way.** No ads, account gate, feed, or unrelated content.

### Target platforms

iPhone, Android, Windows, macOS, and modern browsers. Flutter provides a shared UI and core timekeeping code, with small platform-specific adapters for full-screen behavior, screen wake, storage, and notifications.

## 2. Problem and audience

Many flip clock apps are visually appealing but add ads, paywalls, or extra features around a simple task. QuietFlip serves people who want a desk clock, a focus timer, or a quick stopwatch on a device they already own.

Primary situations:

- A phone or tablet sits on a desk as a readable clock.
- A laptop or second monitor shows the time while someone works.
- Someone starts a countdown for a task and wants a clear completion alert.
- Someone measures elapsed time without leaving the clock app.

The first release assumes a single user and one active timer or stopwatch on each device. Account sync is only for preferences; running timers do not sync between devices.

## 3. Release scope

| Priority | Feature | First release behavior |
| --- | --- | --- |
| P0 | Flip clock | Local time, large flip digits, black default theme, 12/24-hour choice, optional seconds. |
| P0 | Full-screen display | One clear control to enter or leave the largest display each platform allows. Clock stays readable in portrait and landscape. |
| P0 | Countdown timer | Set hours/minutes/seconds; start, pause, resume, reset; see remaining time clearly. |
| P0 | Stopwatch | Start, pause, resume, reset; show elapsed time. |
| P0 | Completion alert | Visual and audible alert while the app is open; system notification where the platform permits it and the user grants permission. |
| P0 | Local settings | Save theme, time format, seconds, sound, and screen-awake choice on the device/browser. |
| P1 | Optional sign-in and sync | Later release: sign-in from Settings and sync display preferences across signed-in devices. App remains fully usable when signed out. |
| Later | Word of the day | Separate discovery and design task; no API dependency in the first release. |

No alarms, calendar, weather, widgets, Pomodoro cycles, lap tracking, social features, analytics, ads, or subscriptions are planned for the first release.

## 4. Core experience

### Home and navigation

1. Launch directly into **Clock**. No splash flow beyond normal loading and no login prompt.
2. Show three modes: **Clock**, **Timer**, **Stopwatch**. The active mode uses most of the screen.
3. Keep controls small and visible when needed. In full-screen mode, a tap/click reveals controls briefly; keyboard users can use a documented shortcut such as `F` to toggle full screen and `Esc` to leave it where supported.
4. Put display preferences and future account controls in **Settings**. Returning from Settings restores the prior mode and active timer state.

### Clock

- Default display: black background, high-contrast white flip cards, hours and minutes, local device time.
- Digits animate only when their value changes. Animation does not delay or change the displayed time.
- Settings: 12/24-hour format, seconds on/off, **Black** or **Light** theme, flip sound on/off (off by default).
- Respect the system's reduced-motion preference by using an instant digit change.
- When the device time zone or time changes, the display corrects on the next update.

### Timer

- Input accepts 1 second through 99 hours, 59 minutes, 59 seconds. Invalid or zero duration cannot start.
- Timer displays remaining time and start/pause/resume/reset controls.
- Switching modes or minimizing the native app does not silently reset the timer. On return, remaining time is recomputed from the intended end time, rather than counting UI frames.
- At zero, stop at `00:00:00`, show a clear completion state, and alert according to user settings and platform capability. Do not automatically repeat.
- Persist a running timer locally so reopening the app can show whether it finished while the app was away. Alert delivery after the app is killed is platform dependent and must be tested separately.

### Stopwatch

- Start, pause, resume, and reset; display hours, minutes, seconds, and tenths while running.
- Measure elapsed time with a monotonic source while the app process is active, so a system clock adjustment does not change the measurement.
- Preserve the current session when switching modes. A new launch may restore the session where reliable; no background alert is needed.

### Notifications and sound

- A timer completion is the only notification event in the first release. No marketing or engagement notifications.
- Ask for notification permission when the user enables system alerts or starts a timer that needs them, not on first launch. Explain the benefit in plain language.
- If permission is denied or unavailable, show the in-app completion state and keep the timer usable.
- On the web, show a browser notification only when supported and permitted. An ordinary browser tab cannot promise an alert after it is closed; describe this clearly in the UI if needed.

### Settings and account

- Save local preferences automatically, including in a browser on the same browser profile.
- First release Settings has **Display**, **Sound & alerts**, and **Keep screen awake** controls. A future **Account & sync** section appears only when sign-in actually works; no dead login button.
- Later, account sign-in is optional. A signed-out user retains all core features. Signing in uploads current preferences after an explicit merge choice if cloud and local values differ. Signing out leaves a local copy and stops syncing.
- Sync only preferences at first: theme, time format, seconds, sound, and screen-awake choice. Never require an account to start a timer.

## 5. Design requirements

- The clock is the hero: large numerals, generous spacing, and no persistent branding in full screen.
- Black is the default on every device, including first launch when the operating system uses light mode.
- Controls must be usable with touch, mouse, and keyboard; all controls have accessible labels and visible focus states.
- Layout supports small phones, tablets, desktop windows, and browser resizing without clipped digits.
- Keep the last selected mode and settings locally. On a fresh install, open Clock in Black theme.
- Prevent accidental screen sleep only when the user enables **Keep screen awake** and the platform allows it. Restore normal device behavior when the app leaves that display or the setting is disabled.

## 6. Platform behavior and constraints

| Platform | Full screen | Timer alert expectation |
| --- | --- | --- |
| iPhone / Android app | Immersive app display within system limits; retain a visible way to exit. | In-app alert; local system notification when permission and OS scheduling allow. |
| Windows / macOS app | Native full-screen window. | In-app alert; system notification where supported and permitted. |
| Browser | Use the Fullscreen API after a user action where available; otherwise fill the visible page. | In-app alert while open; browser notification where supported and permitted. No promise after tab closure. |

True browser full-screen support differs by browser and device. In particular, iPhone Safari may only allow a full-viewport page rather than an element-level full-screen experience. This must be checked on current devices before release. Background browser timers can be throttled, so display time must be derived from timestamps rather than repeated one-second callbacks.

## 7. Technical direction

- Use Flutter for the shared app. Build and test the five requested targets separately.
- Use **NonStop CLI** to generate the project. Choose its smallest practical template/module set for the first release; do not include Firebase Authentication, Firestore, push messaging, analytics, or dashboard modules until their features ship.
- Keep timekeeping logic independent of widgets: one clock service, one countdown state machine, and one stopwatch state machine. Use platform adapters for full-screen, screen-awake, persistence, and notifications.
- Store only preferences and limited timer state locally. No backend, account, or network request is required for first use.
- For later sync, evaluate Firebase Authentication plus a settings document. Firebase's current Flutter documentation says Windows support is for local development rather than production, so Windows sign-in/sync needs a feasibility decision before that feature is committed across all platforms.
- Do not use Firebase Cloud Messaging for a local countdown. It solves server-to-device messaging and adds complexity that this use case does not need.

## 8. Acceptance criteria for first release

1. Fresh install on each target opens directly to a black flip clock without sign-in, ads, or network access.
2. Clock displays the correct local time, flips at the proper boundary, and remains legible in phone portrait, phone landscape, and a resized desktop/browser window.
3. Full-screen control works within the platform's capability; unsupported browser full screen falls back to a full-viewport display without a broken control.
4. A 30-second timer can be started, paused, resumed, and reset. It reaches zero accurately after the app is backgrounded and reopened.
5. Timer completion gives an in-app alert; system notification behavior is verified per platform and permission state, with limitations documented in the app/store listing.
6. Stopwatch start/pause/resume/reset works and does not jump when the system clock changes.
7. Display settings survive app restart. Reduced-motion and keyboard accessibility work.
8. All five release builds pass platform smoke tests. No network dependency is required for the clock, timer, or stopwatch.

## 9. Delivery sequence

1. **Foundation:** Generate a minimal Flutter project with NonStop CLI; build the clock, Black/Light themes, local settings, and responsive layout.
2. **Time tools:** Add countdown and stopwatch with robust lifecycle handling.
3. **Platform polish:** Add full-screen, screen-awake, and completion alerts per platform; verify accessibility and release builds.
4. **Optional sync:** Test a production path for Windows, then add account sign-in and settings sync only when all target platforms have a supported solution.
5. **Word of the day:** Research licensing, API reliability, offline behavior, and whether it belongs on the clock screen or a separate optional panel.

## 10. Open decisions

- Final brand name, trademark clearance, domains, and store listing availability.
- Whether the first public launch should be simultaneous on all five targets or staged after the same core experience is ready on each.
- Exact local-notification implementation and reliability on each operating system, especially when the app has been force-closed.
- A supported production architecture for Windows account sync.
- Whether to add more themes after observing demand for Black and Light.

## Research notes

- [Flutter supported platforms](https://docs.flutter.dev/reference/supported-platforms) confirm the requested deployment targets.
- [NonStop CLI package](https://pub.dev/packages/nonstop_cli) documents project generation and optional modules.
- [Firebase Flutter setup](https://firebase.google.com/docs/flutter/setup) documents platform support and the Windows production caution.
- [MDN Fullscreen API](https://developer.mozilla.org/en-US/docs/Web/API/Element/requestFullscreen) and [WebKit's Fullscreen API notes](https://webkit.org/blog/13966/webkit-features-in-safari-16-4/) explain browser variation.
- [MDN Page Visibility API](https://developer.mozilla.org/en-US/docs/Web/API/Page_Visibility_API) documents background timer throttling.
- [MDN Notifications API](https://developer.mozilla.org/en-US/docs/Web/API/Notifications_API) documents web permission and lifecycle constraints.

