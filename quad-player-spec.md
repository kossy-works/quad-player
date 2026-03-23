# YouTube QUAD PLAYER — 仕様書

**ファイル名:** `youtube-quad-player.html`  
**形式:** シングルファイル HTML（CSS・JS すべて同梱）  
**ホスティング:** GitHub Pages（`https://<username>.github.io/quad-player/`）  
**推奨ブラウザ:** Google Chrome  

---

## 概要

YouTube の動画・ライブ配信を **4画面同時表示** できる Web アプリ。  
YouTube Data API v3 を使ったチャンネル検索パネルを内蔵し、埋め込みコードの手動コピペなしで動画をロードできる。

---

## 画面構成

```
┌─────────────────────────────────────┐
│ HEADER（ロゴ / クリアボタン）         │
├─────────────────────────────────────┤
│ 検索パネル（折りたたみ可能）           │
│  └ APIキー入力 / チャンネル選択 / 検索 │
│  └ 検索結果リスト                     │
├──────────────┬──────────────────────┤
│  セル 01     │  セル 02              │
│  （動画）    │  （動画）              │
├──────────────┼──────────────────────┤
│  セル 03     │  セル 04              │
│  （動画）    │  （動画）              │
├─────────────────────────────────────┤
│ ステータスバー                        │
└─────────────────────────────────────┘
```

---

## 機能仕様

### 1. 4画面プレイヤー

| 項目 | 仕様 |
|------|------|
| 表示形式 | 2×2 グリッド、各セル等分 |
| 動画ロード方法 | ① 検索パネルから / ② 埋め込みコード手動ペースト |
| 入力形式 | YouTube 埋め込みコード `<iframe src="...">` または embed URL 直接入力 |
| autoplay | ロード時に自動付与（`?autoplay=1`） |
| ショートカット | `Ctrl+Enter`（Mac: `Cmd+Enter`）でロード実行 |
| LIVE 判定 | URL に `live_stream` または `?v=` を含む場合、赤枠＋LIVE バッジを表示 |
| クリア | ヘッダーの「クリア」ボタンで全セルをリセット |

### 2. 検索パネル

デフォルトは **折りたたみ状態**。ヘッダー行クリックで開閉。

#### 2-1. API キー管理

| 項目 | 仕様 |
|------|------|
| 入力形式 | パスワードフィールド（マスク表示） |
| 永続化 | `localStorage` に保存（キー: `yt_quad_api_key`） |
| 初期化 | ページロード時に自動復元 |
| 保存確認 | 保存済み時はボタンが「✓ 保存済」（緑）に変化 |

使用 API: **YouTube Data API v3**（Google Cloud Console で取得）  
1日あたりの無料クォータ: 10,000 ユニット

#### 2-2. チャンネル選択

プルダウンからチャンネルを選ぶと、チャンネル ID が自動でテキスト欄にセットされる。  
テキスト欄への直接入力も可能。

**対応入力形式:**

| 形式 | 例 |
|------|----|
| チャンネル ID 直接 | `UCxxxxxxxxxxxxxxxxxxxxxxxx` |
| @ハンドル URL | `https://www.youtube.com/@ChannelName` |
| `/c/` 形式 URL | `https://www.youtube.com/c/ChannelName` |

**チャンネル ID 解決フロー:**
1. `UC` から始まる 24 文字の ID → そのまま使用
2. `@ハンドル` 形式 → `channels?forHandle=` API で解決
3. 解決失敗時 → `search?type=channel` API でフォールバック

#### 2-3. 検索・結果表示

- チャンネルの**最新動画 10 件**を取得（`search?order=date&type=video`）
- ライブ中の動画は `videos?part=snippet` の `liveBroadcastContent=live` で判定し、赤い **LIVE バッジ** を付与
- 各結果行に **01〜04** スロットボタンを表示
- スロットボタンを押すと即ロード（コピペ不要）
- ロード済みのスロットボタンは**緑色**に変化
- 同じスロットに別の動画をロードした場合、前の動画のマークは自動クリア
- 「クリア」ボタン実行時にロード状態もリセット

---

## チャンネルリスト

### 公式

| 表示名 | チャンネル ID |
|--------|--------------|
| オートレース | `UCJAPqcMNYk3HMknRuPMNvKA` |
| ぺーちゃんねる | `UCr4eIfuNdlZWSDMjFwDTabA` |

### 競輪 LIVE

| 表示名 | チャンネル ID |
|--------|--------------|
| 函館 | `UC7Ehq9agmTeznt6XjZ5faLw` |
| 青森 | `UCosOaqq60s3QAenTONNxUuQ` |
| いわき平 | `UCTrT1fwMS9cOePzW_Z0TQfw` |
| 弥彦 | `UCYOGwSM8IwydT0VLUKv5qKg` |
| 前橋 | `UCtn0XkksabeXWF2Omyg6JEQ` |
| 取手 | `UCDeV-cyqnTnoCCjz2Dm7VNA` |
| 宇都宮 | `UCXKIA4ppNI_5lYFS3Eke39A` |
| 大宮 | `UCH1CtPd9P_DBK9xMzYH48lw` |
| 西武園 | `UCH1CtPd9P_DBK9xMzYH48lw` |
| 京王閣 | `UCHdHXMKeFSZ3PxSUtpp90ng` |
| 立川 | `UCOyQSsvzD9qQDgtkeu0n84Q` |
| 立川サブアカ | `UCvG1ViOoCDUqLrjbJsPhwzg` |
| 松戸 | `UCEYoRewzhZWzP9OHaAFE8gA` |
| 川崎 | `UCtU7gR5VCpvQjtVPykL4EUA` |
| 平塚 | `UCvfTQBD1nQ8kAqwdrnTN-_g` |
| 小田原 | `UCNgccovrnvwUqSBaqoqrtfA` |
| 伊東 | `UC3CT-xL9H2UW4PMA2Hg1FjA` |
| 静岡 | `UCoPaxOy8ch2ydfgL1cpwhvQ` |
| 名古屋 | `UCgf3cKAiLdTAset5YVGN4Rw` |
| 岐阜 | `UCs2ed7DZGQ-YKsCOX6NGyZQ` |
| 大垣 | `UCcDTb_mchV4oxxQ2CfGSHFA` |
| 豊橋 | `UC8mS4Ao44gjBbi8nFrP4fNg` |
| 富山 | `UCvVIZOHj843xo_QSnjY62Lg` |
| 松阪 | `UCOZRGa_L_saD0ObvDtzG22Q` |
| 四日市 | `UCPibXjT_mINGifM1gi7ja0g` |
| 福井 | `UCypKxtT2sGParvK54JMeWfw` |
| 奈良 | `UCAHgvI8-zib9yOA2suyjGcg` |
| 向日町 | `UCdBuL72WRnKDIvAekxS2NxQ` |
| 和歌山 | `UCu_WLHra6mfVBHj5qVz5Rbw` |
| 岸和田 | `UChHOZZ-KJgahUia5vxQnvNw` |
| 玉野 | `UCiKs6agRQVxz1RRPHSX-Oaw` |
| 広島 | `UCC-MHu8wH3xWu8M93nzszBQ` |
| 防府 | `UC42l0MgmrF_tIfaMAPVvUKA` |
| 高松 | `UCWFvocB4sfX4wVXWaB4-SBg` |
| 小松島 | `UCnfVl6Q_xov3Wf45NdWE1Eg` |
| 高知 | `UCcnE1XfjoFEDL5GeWRk2DgQ` |
| 松山 | `UCX3xb9FwC7jL_ZnVmoyzgDg` |
| 小倉 | `UCNOW-bJwHAbkNFQcmgtEuHQ` |
| 久留米 | `UCh7mcNayAkEXneLmnFZwzbQ` |
| 武雄 | `UClqmxHvzzOOWnpNdznfM28A` |
| 佐世保 | `UCHsrH9sBqz9uDKggEKGsOFw` |
| 別府 | `UCxUAWJYLRXK2GFl9Nz7lJXA` |
| 熊本 | `UCuhDz3wM73NDTg4IPMNlKhQ` |

---

## エラー処理

| エラー | 対応 |
|--------|------|
| 埋め込みコード認識不可 | セル内にエラーメッセージを表示 |
| API キー未設定で検索実行 | ステータスバーに警告、API キー欄にフォーカス |
| チャンネルが見つからない | 結果エリアにメッセージ表示 |
| API エラー（レート超過など） | エラーメッセージを結果エリアに表示 |
| YouTube 埋め込み制限（error 153） | YouTube 側の制限のため対応不可。別の動画を使用 |
| `file://` から開いた場合 | YouTube セキュリティ制限でブロック。必ず URL でアクセス |

---

## API キー設定（Google Cloud Console）

1. https://console.cloud.google.com/ にアクセス
2. プロジェクト作成 →「YouTube Data API v3」を有効化
3. 「認証情報」→「APIキーを作成」
4. HTTPリファラー制限を設定（推奨）:
   ```
   https://<username>.github.io/*
   ```

---

## デザイン仕様

| 項目 | 値 |
|------|----|
| テーマ | ダークモード固定 |
| 背景色 | `#0a0a0a` |
| アクセントカラー | `#ff3b3b`（赤） |
| フォント | DM Mono（等幅）/ DM Sans（本文） |
| LIVE バッジ色 | `#ff6666`（赤、点滅ドット付き） |
| ロード済みスロット色 | `#4ade80`（緑） |

---

## 今後の拡張候補

- チャンネルリストの UI 上での追加・削除・並び替え
- セッション間でのスロット状態の保存・復元
- IP アクセス制限（Cloudflare Access または独自サーバー）
