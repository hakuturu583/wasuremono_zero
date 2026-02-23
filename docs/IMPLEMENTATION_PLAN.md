# 忘れ物防止 iOS アプリ 実装計画（Swift / Xcode）

## ゴール
- 移動（GPSの有意な変化/Visits）を検知したらバックグラウンドから起動し、ローカル通知で「け/ケータイ・さ/財布・キ/鍵・め/メガネ」を確認できるアクションボタンを提示する。
- バッテリーに優しい検知（Significant Location Change / CLVisit）と、過剰通知の抑制を行う。

## 開発ステップ（優先度順）
1. GitHub Actions でビルドテスト（最初に用意）
2. Xcode プロジェクト雛形の作成（iOS 15+ / Swift）
3. 通知カテゴリ・アクションの定義（UNUserNotificationCenter）
4. 位置情報検知レイヤ（SLC/Visits）の実装（CoreLocation）
5. バックグラウンドでのトリガー→ローカル通知発火
6. レート制限・サプレッション（時間・距離・ドウェル）
7. 初回オンボーディング（権限要求と説明）
8. 設定画面（対象項目のオン/オフ・頻度調整）
9. 永続化（UserDefaults で直近チェック・設定保存）
10. テスト追加（ユニット・スナップショット／一部UI）
11. 文言・ローカライズ（日本語）とアイコン整備
12. TestFlight 配布とストア審査ドキュメント準備

## CI（GitHub Actions）
- 目的: 毎プッシュ/PRでプロジェクトがクリーンビルドできることを自動検証。
- ランナー: `macos-14`（Xcode 15系）
- 主なステップ:
  - `actions/checkout@v4`
  - Xcode セットアップ（`xcodebuild -showsdks` で可視化）
  - 依存関係解決（SPM）
  - `xcodebuild -scheme WasuremonoZero -destination 'generic/platform=iOS' -configuration Debug -skipPackagePluginValidation build`
  - 成果物のアーティファクト保存（`DerivedData/Logs/Build`）
- ワークフロー例（後で `.github/workflows/ios-build.yml` として追加）:
  ```yaml
  name: iOS Build
  on: [push, pull_request]
  jobs:
    build:
      runs-on: macos-14
      steps:
        - uses: actions/checkout@v4
        - name: Show Xcode
          run: xcodebuild -version && xcodebuild -showsdks
        - name: Resolve packages
          run: xcodebuild -resolvePackageDependencies -project WasuremonoZero.xcodeproj || true
        - name: Build
          run: xcodebuild -scheme WasuremonoZero -destination 'generic/platform=iOS' -configuration Debug -skipPackagePluginValidation build
        - name: Archive logs
          if: always()
          uses: actions/upload-artifact@v4
          with:
            name: build-logs
            path: ~/Library/Logs/DiagnosticReports
  ```

## アーキテクチャ概要
- 層構造:
  - LocationLayer: `LocationService`（SLC/Visitsの購読、許可状態管理）
  - TriggerPolicy: `MovementPolicy`（距離/時間/訪問イベントから通知可否を決定）
  - NotificationLayer: `NotificationService`（カテゴリ/アクション登録、通知発火、反応処理）
  - App/UI: 設定（対象項目の選択、通知頻度、サイレント時間帯）
  - Persistence: `UserDefaults`（直近通知時刻・最終場所・項目設定）

## 主要機能の詳細
- 位置検知:
  - `startMonitoringSignificantLocationChanges()` を基本に使用。
  - 可能なら `CLLocationManagerDelegate` の `didVisit` で到着/出発を補助的に活用。
  - バックグラウンド起動: SLC/Visit はアプリを再起動・バックグラウンドで呼び出し可能。
- 通知:
  - カテゴリID: `CHECK_ITEMS`。
  - アクション: `CHECK_PHONE(け)`, `CHECK_WALLET(さ)`, `CHECK_KEYS(キ)`, `CHECK_GLASSES(め)`, `SNOOZE(後で)`。
  - 通知文: タイトル「持ち物チェック」、本文「け/さ/キ/め を確認してください」。
  - 反応時: 押した項目を直近チェックとして保存、履歴に記録（簡易）。
- レート制限/サプレッション:
  - 最短通知間隔（例: 30分）と最小移動距離（例: 200m）。
  - 同一場所での連続通知抑制（ジオハッシュや座標丸めで同一判定）。
- 権限とCapabilities:
  - Info.plist: `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`, `UIBackgroundModes`（`location`）。
  - 通知: `UNUserNotificationCenter` で許可ダイアログ、アクションカテゴリ登録。

## 画面（最小）
- メイン: 対象項目（け/さ/キ/め）のスイッチ、スヌーズ設定、最短通知間隔、最小距離。
- オンボーディング: 目的説明 → 通知許可 → 位置情報「常に許可」依頼。

## データモデル（軽量）
- `Settings`: enabledItems: Set<Item>, minIntervalMinutes: Int, minDistanceMeters: Int, quietHours: Range<Int>?
- `State`: lastNotifiedAt: Date?, lastLocation: CLLocation?, lastCheckedItems: Set<Item>

## テスト戦略
- Policyの単体テスト: 時間/距離しきい値の判定。
- Notification登録のテスト: カテゴリ・アクションIDが期待通り。
- Locationのモック: デリゲートをプロトコル化して擬似イベント注入。
- UI: スナップショット（設定画面のみ）。

## リスクと対策
- 常時位置許可の審査リスク: 目的の明確な説明、オンボーディング内の合理的な文言、`WhenInUse`→`Always` の段階的依頼。
- 通知の多さ: レート制限/場所抑制とユーザ設定の露出。
- 省電力: 標準の`startUpdatingLocation`は使わずSLC/Visit中心。

## 受け入れ基準
- バックグラウンドで移動検知→ローカル通知が安定して届く。
- 通知に「け/さ/キ/め」のアクションボタンが表示され、押下がアプリ状態に反映される。
- CI でクリーンビルドが通る。

