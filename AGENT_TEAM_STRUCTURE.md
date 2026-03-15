# Claude Code Agent Teams — 現状構造マップ
*最終更新: 2026-03-15*

---

## 1. リポジトリ全体構成

```
Claude-Code-Teams/
│
├── .claude/
│   └── settings.json          ← エージェントチーム有効化設定
│       CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
│       teammateMode: "in-process"
│
├── CLAUDE.md                  ← 全エージェント共通コンテキスト
│
├── 戦略ドキュメント群（エージェントが生成）
│   ├── ADAMAS_GROUP_MASTER_STRATEGY.md   （統合マスター戦略）
│   ├── ADAMAS_CTO_TECH_BLUEPRINT.md      （Shopify技術設計）
│   ├── ADAMAS_ASIA_STRATEGY.md           （アジア展開戦略）
│   ├── REVENUE_TEAM_ANNUAL_PLAN.md       （収益化チーム年間計画）
│   └── FUTURE_BUSINESS_MEMO.md           （将来事業メモ）
│
├── examples/
│   ├── parallel-review/       ← PRを複数視点で同時レビュー
│   ├── competing-hypotheses/  ← バグを複数仮説で並列調査
│   └── feature-parallel/      ← フィーチャーを並列実装
│
└── scripts/
    ├── team-prompts.md        ← チームプロンプトテンプレート集
    └── check-teammate-quality.sh
```

---

## 2. エージェントチームの基本アーキテクチャ

```
┌──────────────────────────────────────────────────────────────┐
│                        USER（あなた）                         │
└────────────────────────────┬─────────────────────────────────┘
                             │ タスク指示
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                    TEAM LEAD（リード）                        │
│                   （このClaude Codeセッション）               │
│                                                              │
│  役割:                                                        │
│  ・タスクを分解してサブタスクに変換                            │
│  ・Teammate を生成・割り当て                                   │
│  ・全体の進捗管理・成果の統合                                  │
│  ・最終アウトプットをユーザーへ報告                            │
└───────┬──────────────┬──────────────┬───────────────┬────────┘
        │              │              │               │
        │ spawn        │ spawn        │ spawn         │ spawn
        ▼              ▼              ▼               ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Teammate A   │ │ Teammate B   │ │ Teammate C   │ │ Teammate D   │
│              │ │              │ │              │ │              │
│ 独自の       │ │ 独自の       │ │ 独自の       │ │ 独自の       │
│ コンテキスト  │ │ コンテキスト  │ │ コンテキスト  │ │ コンテキスト  │
│ ウィンドウ   │ │ ウィンドウ   │ │ ウィンドウ   │ │ ウィンドウ   │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │                │
       └────────────────┴────────────────┴────────────────┘
                  直接メッセージ可能（Mailbox経由）
                  タスクリスト共有（~/.claude/tasks/）
```

---

## 3. このセッションで実際に動いたチーム

```
TEAM LEAD（現セッション）
│
├── Teammate 1: Asia strategy: China, Korea, SEA luxury markets
│   ├── 担当: 中国・韓国・東南アジアのラグジュアリー市場分析
│   ├── 出力: ADAMAS_ASIA_STRATEGY.md（364行）
│   └── ステータス: ✅ completed
│
├── （他のTeammateたちも並列で動作）
│   └── 出力: ADAMAS_GROUP_MASTER_STRATEGY.md
│           ADAMAS_CTO_TECH_BLUEPRINT.md
│           その他部門別戦略
│
└── Team Lead（このセッション）
    ├── 各Teammateの成果を統合
    ├── REVENUE_TEAM_ANNUAL_PLAN.md 生成
    └── FUTURE_BUSINESS_MEMO.md 生成
```

---

## 4. エージェント間の通信フロー

```
Task Notification（タスク完了通知）の例:

Teammate "Asia strategy"
        │
        │  task-notification を送信
        ▼
Team Lead（このセッション）
        │
        │  result を受け取り
        │  → 内容を解析・保存
        │  → ADAMAS_ASIA_STRATEGY.md として整形
        │  → git commit & push
        ▼
      完了
```

**通信経路:**

| 方向 | 手段 |
|------|------|
| Lead → Teammate | `spawn`（タスク割り当て） |
| Teammate → Lead | `task-notification`（完了報告） |
| Teammate ↔ Teammate | `Mailbox`（直接メッセージ） |
| 全員 | `~/.claude/tasks/{team-name}/`（共有タスクリスト） |

---

## 5. 利用可能なチームパターン（テンプレート）

### パターン A: 並列レビュー（parallel-review）
```
Lead
├── Teammate: セキュリティレビュー担当
├── Teammate: パフォーマンスレビュー担当
└── Teammate: テストカバレッジ担当
         ↓ 全員同時並列実行
Lead が結果を統合 → 優先度付き課題リスト
```
**最適用途:** PRレビュー・コード监査・ドキュメントレビュー

---

### パターン B: 競合仮説（competing-hypotheses）
```
Lead
├── Teammate 1: 仮説Aを検証
├── Teammate 2: 仮説Bを検証
├── Teammate 3: 仮説Cを検証
├── Teammate 4: 仮説Dを検証
└── Teammate 5: 仮説Eを検証
         ↓ 互いの仮説を反証し合う
Lead が証拠を統合 → 最有力根本原因を特定
```
**最適用途:** 原因不明のバグ・複雑な障害調査

---

### パターン C: 並列実装（feature-parallel）
```
Lead
├── Teammate A: バックエンドAPI実装
│              （src/api/ を担当）
├── Teammate B: フロントエンドUI実装
│              （src/components/ を担当）
└── Teammate C: テスト作成
               （A・Bの完了を待ってから開始）
```
**最適用途:** 独立したモジュール・レイヤーをまたぐ大機能

---

### パターン D: 多角的リサーチ（今回使用）
```
Lead
├── Teammate: 市場戦略担当（今回のアジア戦略等）
├── Teammate: 技術設計担当（CTO Blueprint）
├── Teammate: 財務・全体戦略担当（Master Strategy）
└── Teammate: 地域戦略担当（各市場）
         ↓ 独立して調査・作成
Lead が統合 → マスター戦略書
```
**最適用途:** 複数視点のリサーチ・大規模な設計書作成

---

## 6. Subagent との違い

```
┌─────────────────┬──────────────────┬──────────────────┐
│                 │   Subagent       │   Agent Team     │
├─────────────────┼──────────────────┼──────────────────┤
│ コンテキスト    │ 独自ウィンドウ    │ 独自ウィンドウ    │
│ 完了後の扱い    │ 結果をLeadに返す  │ 完全に独立継続    │
│ Teammate間通信 │ なし             │ 直接メッセージ可  │
│ 協調方法       │ Leadが全管理      │ 共有タスクリスト  │
│ 最適用途       │ 結果だけほしい    │ 複雑な協調作業    │
│ トークンコスト  │ 低い             │ 高い（人数×）    │
└─────────────────┴──────────────────┴──────────────────┘
```

---

## 7. 生成ドキュメントと担当エージェントのマッピング

```
ADAMAS_GROUP_MASTER_STRATEGY.md
  └── 担当: 複数Teammate の成果を Lead が統合
      内容: グループ全体戦略・財務目標・組織構造

ADAMAS_CTO_TECH_BLUEPRINT.md
  └── 担当: CTO/技術担当 Teammate
      内容: Shopify設計・決済・物流・自動化技術仕様

ADAMAS_ASIA_STRATEGY.md
  └── 担当: "Asia strategy" Teammate（task-id: a4f67c60e014b1842）
      内容: 中国/韓国/東南アジア 市場別詳細戦略

REVENUE_TEAM_ANNUAL_PLAN.md
  └── 担当: Team Lead（このセッション）
      内容: 4部署×12ヶ月の週次・月次作戦計画

FUTURE_BUSINESS_MEMO.md
  └── 担当: Team Lead（このセッション）
      内容: 不動産・投資塾・コーヒーアプリ・データ企業 構想メモ
```

---

## 8. 設定ファイル詳細

```json
// .claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"  // チーム機能の有効化
  },
  "teammateMode": "in-process"  // Teammateを同一プロセス内で実行
}
```

**teammateMode の選択肢:**

| モード | 挙動 | 適用場面 |
|--------|------|---------|
| `in-process` | 同一プロセス内で実行（高速・低オーバーヘッド） | 開発・テスト |
| `subprocess` | 別プロセスとして起動（完全な独立性） | 本番・大規模 |

---

*このマップは現在のリポジトリ状態を反映しています。*
*エージェントチームの追加・変更があれば随時更新してください。*
