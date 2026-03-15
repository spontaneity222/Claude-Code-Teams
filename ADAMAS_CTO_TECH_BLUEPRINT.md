# グループ統合デジタル・EC技術戦略
## CTOエージェント設計書 v1.0

> マスター戦略: ADAMAS_GROUP_MASTER_STRATEGY.md PART 8 参照

---

# 第1章: Shopifyアーキテクチャ設計

## 1.1 マルチストア戦略（推奨: ハイブリッド型）

```
┌─────────────────────────────────────────────────────────────┐
│                    Adamas Group Digital Hub                  │
│                   (統合管理レイヤー / Headless CMS)           │
└──────────────────────────┬──────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  Adamas Store │  │ Subscription  │  │  Fragrance +  │
│  (Jewelry)    │  │  Box Store    │  │  Flower Store │
│ adamas-       │  │ box.adamas-   │  │ lifestyle.    │
│ jewelry.com   │  │ group.com     │  │ adamas-       │
│               │  │               │  │ group.com     │
│ JP/US/EU/ASIA │  │ JP/US/EU/ASIA │  │  JP + Export  │
│ via Markets   │  │ via Markets   │  │  via Markets  │
└───────────────┘  └───────────────┘  └───────────────┘
        │                  │                  │
        └──────────────────┴──────────────────┘
                           │
              ┌────────────▼────────────┐
              │   統合 Customer CDP      │
              │   (Segment / Klaviyo)   │
              └─────────────────────────┘
```

## 1.2 ストア構成詳細

```
ストア1: adamas-jewelry.com (Adamas専用)
├── JP: /ja  (¥ + Paidy/PayPay)
├── US: /en-us  ($ + AfterPay/Klarna)
├── EU: /en-eu  (€ + Klarna/iDEAL)
├── UK: /en-gb  (£)
├── CN: /zh  (¥CNY + Alipay/WeChat Pay)
└── KR: /ko  (₩ + Kakao Pay)

ストア2: box.adamas-group.com (サブスクボックス専用)
├── JP: /ja  (¥ + Paidy/PayPay)
├── US: /en-us  ($ + AfterPay/Klarna)
└── EU: /en-eu  (€ + Klarna/iDEAL)

ストア3: lifestyle.adamas-group.com (フラワー + フレグランス)
├── JP: /ja  (国内配送最適化)
├── ASIA: /en-asia  (ドライフラワー輸出)
└── EU: /en-eu  (フレグランス特化)
```

## 1.3 Shopify Plus 移行タイミング

| フェーズ | タイミング | コスト | 取得機能 |
|---------|----------|--------|---------|
| Phase 1 (0-12ヶ月) | スタンダード × 3 | $237/月 | 基本機能 |
| Phase 2 (12-24ヶ月) | Adamas のみ Plus | $2,300/月 | カスタムチェックアウト・Flow・B2B |
| Phase 3 (24ヶ月+) | Plus Organization | $2,300~/月 | 3ストア統合管理 |

**Plus移行トリガー: Adamas 月商 $50K USD 超過時**

---

# 第2章: 必須アプリスタック

## 優先度マトリクス

```
影響度(高)
    │
    │  ★★★ MUST (即時)      ★★ SHOULD (Phase 2)
    │  ├ Shopify基盤設定    ├ AI推薦 (Nosto)
    │  ├ Klaviyo+フロー     ├ CDP (Segment)
    │  ├ 多通貨/Markets     ├ SMS (Attentive US)
    │  ├ Recharge           ├ Triple Whale
    │  └ GA4+GTM            └ AR試着 (Zakeke)
    │
    │  ★ NICE TO HAVE       ○ DEFER (Phase 3)
    │  ├ Hotjar             ├ Stay.ai
    │  ├ ReConvert          ├ Snap Camera AR
    │  └ AfterShip          └ BigQuery ML
    │
    └──────────────────────────── 実装難易度(低→高)
```

## 月次コスト見積もり

### Phase 1 (Month 3時点): ¥290,000/月

| ツール | USD | JPY |
|-------|-----|-----|
| Shopify スタンダード × 3 | $237 | ¥35,550 |
| Recharge Standard | $99 | ¥14,850 |
| Klaviyo 5K contacts | $100 | ¥15,000 |
| Weglot Pro | $49 | ¥7,350 |
| Triple Whale | $129 | ¥19,350 |
| Okendo Essential | $19 | ¥2,850 |
| ShipStation + AfterShip | $20 | ¥3,000 |
| Hotjar + GDPR | $48 | ¥7,200 |
| **アプリ小計** | **$701** | **¥105,150** |
| 翻訳者（日本語校正） | - | ¥50,000 |
| 開発・テーマカスタム | - | ¥150,000 |
| **合計** | | **≒¥290,000/月** |

### Phase 2 (Month 6時点): ¥830,000/月
- Shopify Plus (Adamas) 追加: +¥309,450
- Segment CDP: +¥18,000
- AI推薦 Nosto: +¥45,000
- Attentive SMS (US): +¥75,000

### Phase 3 (Month 12時点): ¥1,300,000/月
- Plus Organization: +¥345,000
- GTM Server-Side (GCP): +¥7,500
- BigQuery: +¥15,000
- AI API (OpenAI): +¥30,000

---

# 第3章: Klaviyo フロー設計（優先実装8本）

| フロー名 | トリガー | 想定ROI |
|---------|---------|---------|
| ウェルカムシリーズ (5通) | 会員登録 | LTV +34% |
| カート放棄 (3通) | 24h未購入 | 回収率 15〜20% |
| 購入後ケア (4通) | 購入完了 | リピート率 +18% |
| VIP昇格通知 | LTV閾値到達 | ロイヤリティ向上 |
| サブスク解約防止 | 解約ボタン押下 | チャーン -23% |
| 誕生日オファー | 誕生日-7日 | CVR +40% |
| 在庫補充通知 | 在庫復活 | 即時売上 |
| ブラウズ放棄 | 商品閲覧→離脱 | 回収率 8〜12% |

---

# 第4章: 多言語・多通貨・決済マトリクス

## 決済方法（地域別）

| 地域 | 必須決済 |
|------|---------|
| 日本 | Shopify Payments + Paidy + PayPay + コンビニ払い + 銀行振込 |
| 米国 | Shopify Payments + AfterPay + Klarna + Apple/Google Pay |
| 欧州 | Shopify Payments + Klarna + iDEAL + Bancontact |
| アジア | Alipay + WeChat Pay + GrabPay + Kakao Pay + LINE Pay |

## 翻訳優先順位

| 優先度 | 言語 | 品質 | 月次コスト |
|-------|------|------|----------|
| 1 | 日本語 | 専門翻訳者 | ¥50,000 |
| 2 | 英語 | ネイティブ校正 | $500 |
| 3 | 中国語(簡体) | 専門翻訳者 | ¥40,000 |
| 4 | フランス語 | AI+校正 | €300 |
| 5 | 韓国語 | AI+校正 | ₩300,000 |

---

# 第5章: データ基盤・CDP設計

## グループ横断 CDP アーキテクチャ

```
【収集】Shopify #1 + #2 + #3 + LINE/IG/TikTok
         ↓
【統合】Segment CDP (Single Customer View)
  ├── 購買履歴（全事業横断）
  ├── 行動データ
  ├── コミュニケーション履歴
  └── LTV/チャーンスコア (AI算出)
         ↓
【活用】Klaviyo | Meta/Google Ads Sync | BigQuery
```

## 統合顧客プロファイル設計

```json
{
  "customer_id": "ADM-2024-00001",
  "segments": {
    "tier": "VIP",
    "ltv_total": 1250000,
    "ltv_by_brand": { "adamas": 850000, "subscription": 300000, "lifestyle": 100000 },
    "churn_risk_score": 0.12,
    "next_purchase_prediction": "2026-04-15"
  },
  "consent": {
    "gdpr": true, "jp_pipa": true, "email_marketing": true, "line_marketing": true
  }
}
```

---

# 第6章: Shopify Flow 主要自動化

| Flow | トリガー | アクション |
|------|---------|----------|
| VIPタグ自動付与 | 注文完了 + LTV > ¥500,000 | タグ追加 + Klaviyo更新 + Slack通知 |
| 在庫切れ代替案内 | 在庫 = 0 + ウィッシュリスト > 10 | 代替案内メール送信 |
| サブスク解約阻止 | Recharge 解約押下 | スキップオファー + 10%割引コード自動発行 |
| 不正注文フラグ | 注文作成 + Signifyd < 500 | 保留 + Slack通知 |

---

# 第7章: AR試着実装ロードマップ

| フェーズ | 実装 | 費用 |
|---------|------|------|
| Phase 1 (即時) | Shopify AR (USDZ) | 撮影費¥50,000〜/点 |
| Phase 2 | Zakeke AR | $299/月 |
| Phase 3 | Snap Camera Kit | 初期$5,000〜 |

---

# 第8章: セキュリティ・コンプライアンス

## プライバシー規制対応

| 要件 | GDPR(EU) | 個情法(JP) | CCPA(CA) | PIPL(CN) |
|-----|---------|----------|---------|---------|
| 同意バナー | 必須 | 推奨 | 必須 | 必須 |
| データ削除権 | 必須 | 必須 | 必須 | 必須 |
| 越境移転規制 | SCCs必要 | 安全管理 | - | 厳格規制 |

**推奨ツール: Pandectes GDPR Compliance ($9/月)**

---

# ROI試算サマリー

```
【年商¥120M想定時の施策別ROI】

カート放棄メール (Klaviyo): +¥10,800,000/年
アップセル (ReConvert):     +¥14,400,000/年
AI推薦 (Nosto):             +¥9,600,000/年
サブスクチャーン削減:        +¥5,520,000/年
────────────────────────────────────────
年間合計効果:  +¥40,320,000
Phase 2 年間コスト: ¥9,960,000
純利益:       +¥30,360,000
ROI:           304%
```

---

## CTO推奨アクション TOP 10

| 順位 | アクション | 期限 |
|-----|----------|------|
| 1 | Shopify 3ストア契約 + Markets設定 | Week 1 |
| 2 | Klaviyo 連携 + 基本フロー設定 | Week 2 |
| 3 | Recharge サブスク設定 | Week 3 |
| 4 | GA4 + GTM 正確な計測設定 | Week 4 |
| 5 | Paidy/PayPay 日本決済統合 | Month 1 |
| 6 | Okendo レビュー設置 | Month 2 |
| 7 | GDPR/個情法 Cookie同意設定 | Month 2 |
| 8 | Segment CDP 統合開始 | Month 4 |
| 9 | Adamas Shopify Plus 移行 | Month 6 |
| 10 | サーバーサイドタグ移行 | Month 8 |

---

*本設計書は Claude Code Agent Teams CTO エージェントによる詳細技術設計書です。*
*マスター戦略書: ADAMAS_GROUP_MASTER_STRATEGY.md*
