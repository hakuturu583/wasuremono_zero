# Repository Guidelines

## Project Structure & Module Organization
- Source: `WasuremonoZero/` (Swift iOS app target). Tests: `WasuremonoZeroTests/`, UI tests: `WasuremonoZeroUITests/`. Assets: `WasuremonoZero/Assets.xcassets`.
- Xcode project: `WasuremonoZero.xcodeproj`. CI workflows live in `.github/workflows/` (e.g., `ios-build.yml`).
- Docs: `docs/` (see `IMPLEMENTATION_PLAN.md` for architecture and CI details).

## Build, Test, and Development Commands
- Build (generic iOS): `xcodebuild -scheme WasuremonoZero -destination 'generic/platform=iOS' -configuration Debug build`
- Resolve SPM packages: `xcodebuild -resolvePackageDependencies -project WasuremonoZero.xcodeproj`
- Run unit tests (simulator): `xcodebuild -scheme WasuremonoZero -destination 'platform=iOS Simulator,name=iPhone 15' test`
- Open project in Xcode: `open WasuremonoZero.xcodeproj`
- CI runner: `macos-14` with Xcode 15; artifacts uploaded from build logs (see docs plan).

## Coding Style & Naming Conventions
- Language: Swift 5+. Indentation: 4 spaces, 120-char soft wrap.
- Names: Types `PascalCase`, functions/vars `lowerCamelCase`. Files match primary type name.
- Modules/services follow the plan: `LocationService`, `MovementPolicy`, `NotificationService`, plus app/UI and `UserDefaults` persistence.
- Prefer protocol-oriented design and dependency injection; avoid force unwraps. Use `SwiftLint`/`SwiftFormat` if configured; otherwise follow standard Swift API Design Guidelines.

## Testing Guidelines
- Framework: XCTest. Focus on policy logic (time/distance thresholds), notification category/IDs, and basic UI snapshot for settings.
- Naming: test target `WasuremonoZeroTests`; files `XxxTests.swift`; methods `test_condition_expectedBehavior()`.
- Run locally with the command above. Aim for meaningful coverage of `MovementPolicy` and notification registration; mock `CLLocationManager` via protocols for determinism.

## Commit & Pull Request Guidelines
- Commits: imperative mood, concise subject, scope in body when useful. Conventional Commits are welcome (e.g., `feat: add MovementPolicy thresholds`).
- PRs: small, focused; include description, linked issues, and screenshots for UI changes. Ensure CI builds succeed and tests pass.

## Security & Configuration Tips
- Do not commit signing certificates or secrets. Configure signing locally per developer.
- Include required Info.plist keys: `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`; enable `UIBackgroundModes` → `location`.
- Keep bundle IDs, scheme name `WasuremonoZero`, and notification category/action IDs consistent with the plan.
