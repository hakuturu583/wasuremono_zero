#!/usr/bin/env python3
"""Create GitHub Issues for WasuremonoZero issue breakdown.

Usage:
  python scripts/create_github_issues.py --repo owner/name --token $GITHUB_TOKEN --create
  python scripts/create_github_issues.py --repo owner/name --dry-run
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from dataclasses import dataclass
from typing import Dict, List


@dataclass(frozen=True)
class IssueSpec:
    key: str
    title: str
    purpose: str
    tasks: List[str]
    dod: List[str]
    deps: List[str]


ISSUES: List[IssueSpec] = [
    IssueSpec("1", "CI: GitHub ActionsでiOSビルド検証を追加する", "Push/PR時にWasuremonoZeroがクリーンビルドできることを自動検証する。", ["`.github/workflows/ios-build.yml` を作成する", "`macos-14` + Xcode 15系で `xcodebuild` を実行する", "Buildログのアーティファクト保存を設定する"], ["ワークフローがPush/PRで起動し、Debugビルドが成功する", "失敗時にログをダウンロードできる"], []),
    IssueSpec("2", "プロジェクト雛形: iOS 15+ / Swiftで基本構成を整備する", "実装を進めるための最小アプリ構成を整える。", ["ターゲット/スキーム `WasuremonoZero` の整合性を確認する", "`Info.plist` に位置情報利用文言とBackground Modes（location）を追加する", "最小画面とアプリエントリを安定化する"], ["ローカルでDebugビルドが通る", "必須のInfo.plistキーが設定済み"], ["1"]),
    IssueSpec("3", "通知基盤: カテゴリ/アクション定義と権限要求を実装する", "通知アクション（け/さ/キ/め/後で）をOSへ登録し、通知許可を取得する。", ["`NotificationService` を実装する", "カテゴリID `CHECK_ITEMS` と各アクションIDを定義する", "初期化時のカテゴリ登録と権限要求フローを追加する"], ["通知カテゴリが登録され、通知にアクションボタンが表示される", "許可状態に応じた処理分岐が確認できる"], ["2"]),
    IssueSpec("4", "位置検知基盤: SLC/Visit監視レイヤを実装する", "バッテリー効率を保ちながら移動イベントを取得できる状態を作る。", ["`LocationService` を実装する", "`startMonitoringSignificantLocationChanges()` と `didVisit` の受信実装を行う", "位置情報権限状態の管理APIを整備する"], ["位置イベント受信時にコールバック/イベント通知が発火する", "バックグラウンド起動シナリオを考慮した実装になっている"], ["2"]),
    IssueSpec("5", "トリガー連携: 移動検知からローカル通知発火までを接続する", "「移動を検知したら通知する」最短の縦断フローを成立させる。", ["Appライフサイクル層で `LocationService` と `NotificationService` を接続する", "移動イベント受信時に通知作成/スケジュールを実行する", "最低限のログ/計測ポイントを追加する"], ["実機で移動イベント後に通知が届く", "通知アクション押下がアプリ状態へ伝播する"], ["3", "4"]),
    IssueSpec("6", "判定ロジック: レート制限・サプレッションを実装する", "通知過多を防ぎ、同一場所/短時間連続の通知を抑制する。", ["`MovementPolicy` を実装する", "最短通知間隔（例: 30分）と最小移動距離（例: 200m）を判定する", "同一場所判定（座標丸め等）を導入する"], ["ポリシー判定のユニットテストが通る", "実機挙動で短時間連打通知が抑制される"], ["4", "5"]),
    IssueSpec("7", "オンボーディング: 権限説明と段階的許可導線を実装する", "通知/位置情報の許可理由を明示し、許可率と審査適合性を高める。", ["目的説明画面を追加する", "通知許可→位置情報許可（必要に応じて段階的）を案内する", "拒否時の再案内/設定遷移導線を用意する"], ["初回起動時に一連の導線が破綻なく動作する", "審査説明として合理的な文言が用意されている"], ["3", "4"]),
    IssueSpec("8", "設定画面: 対象項目・通知頻度・距離しきい値を編集可能にする", "ユーザーが通知挙動を調整できるUIを提供する。", ["対象項目（け/さ/キ/め）のオンオフUIを実装する", "最短通知間隔/最小距離/スヌーズ等の設定UIを追加する", "バリデーションと初期値表示を整備する"], ["設定変更がアプリ再起動後も保持される（#9と連携）", "設定値が通知判定に反映される（#6と連携）"], ["6", "9"]),
    IssueSpec("9", "永続化: Settings/StateをUserDefaultsへ保存する", "設定値と直近状態（最終通知時刻など）を継続利用可能にする。", ["`Settings` / `State` の保存・読込レイヤを実装する", "互換性を考慮したキー設計とデフォルト値を定義する", "主要状態更新ポイント（通知発火時、アクション押下時）で保存する"], ["再起動後に設定/状態が復元される", "不正値/欠損値でもクラッシュしない"], ["5"]),
    IssueSpec("10", "テスト整備: Policy/Notification/UIの自動テストを追加する", "回帰防止のため、重要ロジックを自動テストで担保する。", ["`MovementPolicy` の時間/距離しきい値テストを追加する", "通知カテゴリ/アクションIDの登録テストを追加する", "設定画面の最小UIテスト（またはスナップショット）を追加する"], ["CIでテストが安定実行できる", "主要分岐がテストでカバーされる"], ["3", "6", "8"]),
    IssueSpec("11", "文言・ローカライズ・アイコン整備", "日本語UXを磨き、通知や画面文言の一貫性を確保する。", ["主要画面/通知文言を日本語で統一する", "必要に応じて `Localizable.strings` を導入する", "アプリアイコン/必要アセットを整備する"], ["主要導線の文言が日本語で自然", "通知文言とアクション名称が仕様と一致"], ["7", "8"]),
    IssueSpec("12", "リリース準備: TestFlight配布と審査向け情報整理", "外部テストとストア審査に必要な準備を完了する。", ["TestFlight配布フロー（ビルド番号運用含む）を確立する", "審査メモ（常時位置許可の必要性説明）を作成する", "既知制限・問い合わせ導線を整理する"], ["TestFlightでインストール〜基本導線確認ができる", "審査提出に必要な説明文が揃っている"], ["10", "11"]),
]


def to_body(issue: IssueSpec, issue_number_map: Dict[str, int]) -> str:
    deps = [f"#{issue_number_map[d]}" if d in issue_number_map else f"(未作成: #{d})" for d in issue.deps]
    deps_md = "\n".join([f"- {d}" for d in deps]) if deps else "- なし"
    tasks_md = "\n".join([f"- [ ] {task}" for task in issue.tasks])
    dod_md = "\n".join([f"- [ ] {item}" for item in issue.dod])
    return (
        "## 背景\n"
        f"{issue.purpose}\n\n"
        "## 作業内容\n"
        f"{tasks_md}\n\n"
        "## 完了条件（DoD）\n"
        f"{dod_md}\n\n"
        "## 依存Issue\n"
        f"{deps_md}\n\n"
        "## 備考\n"
        "- docs/ISSUE_BREAKDOWN_JA.md から自動起票。\n"
    )


def github_request(repo: str, token: str, method: str, path: str, payload: dict | None = None) -> dict:
    url = f"https://api.github.com/repos/{repo}{path}"
    data = json.dumps(payload).encode("utf-8") if payload is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header("Authorization", f"Bearer {token}")
    req.add_header("Accept", "application/vnd.github+json")
    req.add_header("X-GitHub-Api-Version", "2022-11-28")
    if payload is not None:
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req, timeout=30) as resp:
        return json.loads(resp.read().decode("utf-8"))


def parse_args() -> argparse.Namespace:
    token = (
        os.getenv("GITHUB_TOKEN")
        or os.getenv("GH_TOKEN")
        or os.getenv("SECRT")
        or os.getenv("SECRET")
    )
    p = argparse.ArgumentParser()
    p.add_argument("--repo", default=os.getenv("GITHUB_REPO"), help="owner/repo")
    p.add_argument("--token", default=token, help="GitHub token")
    p.add_argument("--create", action="store_true", help="Actually create issues")
    p.add_argument("--dry-run", action="store_true", help="Print planned issues")
    return p.parse_args()


def main() -> int:
    args = parse_args()
    dry_run = args.dry_run or not args.create

    if not args.repo:
        print("ERROR: --repo または GITHUB_REPO が必要です", file=sys.stderr)
        return 2

    created_map: Dict[str, int] = {}

    if dry_run:
        for issue in ISSUES:
            print(f"[DRY-RUN] {issue.key}. {issue.title}")
            print(to_body(issue, created_map))
            print("-" * 60)
        return 0

    if not args.token:
        print("ERROR: --token または GITHUB_TOKEN/GH_TOKEN/SECRT/SECRET が必要です", file=sys.stderr)
        return 2

    try:
        for issue in ISSUES:
            body = to_body(issue, created_map)
            payload = {"title": issue.title, "body": body}
            created = github_request(args.repo, args.token, "POST", "/issues", payload)
            number = created["number"]
            created_map[issue.key] = number
            print(f"Created #{number}: {issue.title}")

        # second pass: add concrete dependency links comment where needed
        for issue in ISSUES:
            if not issue.deps:
                continue
            issue_number = created_map[issue.key]
            links = ", ".join([f"#{created_map[d]}" for d in issue.deps])
            github_request(
                args.repo,
                args.token,
                "POST",
                f"/issues/{issue_number}/comments",
                {"body": f"依存Issue: {links}"},
            )
            print(f"Commented deps on #{issue_number}: {links}")
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", errors="ignore")
        print(f"GitHub API ERROR: HTTP {e.code}\n{detail}", file=sys.stderr)
        return 1
    except Exception as e:
        print(f"Unexpected ERROR: {e}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
