# Repository Guidelines

## Project Structure & Module Organization
- Source: `WasuremonoZero/` (iOS app target). Tests: `WasuremonoZeroTests/`; UI tests: `WasuremonoZeroUITests/`.
- Assets: `WasuremonoZero/Assets.xcassets`. Xcode project: `WasuremonoZero.xcodeproj`.
- CI workflows: `.github/workflows/` (e.g., `ios-build.yml`). Docs: `docs/` (see `docs/IMPLEMENTATION_PLAN.md`).
- Core modules follow the architecture plan: `LocationService`, `MovementPolicy`, `NotificationService`, app/UI, and `UserDefaults` persistence.

## Build, Test, and Development Commands
- Resolve SPM packages: `xcodebuild -resolvePackageDependencies -project WasuremonoZero.xcodeproj`.
- Build (generic iOS): `xcodebuild -scheme WasuremonoZero -destination 'generic/platform=iOS' -configuration Debug build`.
- Run unit tests (simulator): `xcodebuild -scheme WasuremonoZero -destination 'platform=iOS Simulator,name=iPhone 15' test`.
- Open in Xcode: `open WasuremonoZero.xcodeproj`.
- CI: GitHub Actions on `macos-14` with Xcode 15; artifacts uploaded from build logs (see docs plan).

## Coding Style & Naming Conventions
- Swift 5+, 4-space indentation, ~120-char soft wrap.
- Names: Types `PascalCase`; functions/vars `lowerCamelCase`. File names match primary type.
- Prefer protocol-oriented design and dependency injection; avoid force unwraps.
- Use `SwiftLint`/`SwiftFormat` if configured; otherwise follow Swift API Design Guidelines.

## Testing Guidelines
- Framework: XCTest. Focus on `MovementPolicy` thresholds, notification categories/IDs, and basic settings UI.
- Naming: test target `WasuremonoZeroTests`; files `XxxTests.swift`; methods `test_condition_expectedBehavior()`.
- Mock `CLLocationManager` via protocols for determinism.
- Run unit tests with the command above.

## Commit & Pull Request Guidelines
- Commits: imperative mood, concise subject. Conventional Commits welcome (e.g., `feat: add MovementPolicy thresholds`).
- PRs: small, focused; include description, linked issues, and screenshots for UI changes.
- Ensure CI builds succeed and tests pass before requesting review.

## CI Screenshots & Artifacts
- UI tests on GitHub Actions must capture simulator screenshots and upload them as run artifacts.
- Add screenshots in `WasuremonoZeroUITests/` using `XCTAttachment(screenshot:)` and set `attachment.lifetime = .keepAlways`.
- When new UI screens/states are added, extend UI tests to capture additional screenshots accordingly.
- Verify artifacts in the workflow run summary; see `.github/workflows/ios-build.yml` and `docs/IMPLEMENTATION_PLAN.md` for details.

## Security & Configuration Tips
- Do not commit signing certificates or secrets; configure signing locally per developer.
- Include Info.plist keys: `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`.
- Enable `UIBackgroundModes` → `location`.
- Keep bundle IDs, scheme name `WasuremonoZero`, and notification category/action IDs consistent with the plan.
