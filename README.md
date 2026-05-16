# YouTube QUAD PLAYER — 仕様書

**形式:** シングルファイルHTML + 静的JSON  
**ホスティング:** GitHub Pages  
**推奨ブラウザ:** Google Chrome

---

## 概要

YouTube の動画・ライブ配信を **4画面同時表示** できる Web アプリ。  
YouTube Data API v3 や API キーは使わず、GitHub Actions が YouTube RSS を定期取得して `data/latest-videos.json` を生成し、GitHub Pages は静的ファイルだけを配信する。

```
data/channels.json
  -> scripts/fetch_youtube_feeds.rb
  -> data/latest-videos.json
  -> index.html
```

---

## 機能仕様

### 1. 4画面プレイヤー

| 項目 | 仕様 |
|------|------|
| 表示形式 | 2×2 グリッド、各セル等分 |
| 動画ロード方法 | ① RSS最新動画リストから / ② 埋め込みコード手動ペースト |
| 入力形式 | YouTube 埋め込みコード `<iframe src="...">` または embed URL 直接入力 |
| autoplay | ロード時に自動付与（`?autoplay=1`） |
| ショートカット | `Ctrl+Enter`（Mac: `Cmd+Enter`）でロード実行 |
| LIVE 判定 | なし。タイトルと公開日時で運用判断する |
| クリア | ヘッダーの「クリア」ボタンで全セルをリセット |

### 2. RSS最新動画パネル

デフォルトは **折りたたみ状態**。ヘッダー行クリックで開閉。

| 項目 | 仕様 |
|------|------|
| チャンネル一覧 | `data/channels.json` から読み込み |
| 最新動画 | `data/latest-videos.json` から読み込み |
| 表示件数 | チャンネルごとに最大10件 |
| 表示情報 | サムネイル、タイトル、チャンネル名、公開日時 |
| ロード操作 | 各結果行の **01〜04** ボタンで該当スロットへロード |
| ロード済み表示 | ロード済みのスロットボタンを緑色に表示 |

### 3. チャンネル入力

プルダウンからチャンネルを選ぶと、チャンネル ID が自動でテキスト欄にセットされる。  
直接入力は `UC...` 形式の登録済みチャンネル ID のみ対応。

APIキーを廃止したため、`@handle` URL や `/c/` URL からのチャンネルID解決は非対応。新しいチャンネルを追加する場合は `data/channels.json` に `UC...` ID を追加する。

---

## データ更新

`.github/workflows/deploy-pages.yml` が以下のタイミングで実行される。

- `main` ブランチへの push
- 15分ごとのスケジュール実行
- GitHub Actions 画面からの手動実行

ワークフローは `scripts/fetch_youtube_feeds.rb` を実行し、YouTube RSS を取得して `data/latest-videos.json` を生成したうえで、GitHub Pages artifact として `index.html` と `data/` をデプロイする。

GitHub Pages の公開元は **GitHub Actions** に設定する。

---

## チャンネルリスト

チャンネル一覧の編集元は `data/channels.json`。

現在のグループ:

- 公式
- 競輪LIVE

同じチャンネル ID を複数名義で登録することも可能。例: 大宮 / 西武園。

---

## エラー処理

| エラー | 対応 |
|--------|------|
| 最新動画JSON未生成 | チャンネル一覧のみ表示し、GitHub Actions実行後に動画を表示 |
| RSS取得失敗 | 該当チャンネルの結果エリアにエラーを表示 |
| 登録外チャンネルID | `data/channels.json` への追加を促す |
| 埋め込みコード認識不可 | セル内にエラーメッセージを表示 |
| YouTube 埋め込み制限（error 153） | YouTube 側の制限のため対応不可。別の動画を使用 |
| iframe内で再生不可 | YouTube 側の埋め込み制限のためアプリ側では対応不可。別の動画を使用 |
| `file://` から開いた場合 | 静的JSON取得やYouTube埋め込みがブロックされる場合があるため、必ずURLでアクセス |

---

## デザイン仕様

| 項目 | 値 |
|------|----|
| テーマ | ダークモード固定 |
| 背景色 | `#0a0a0a` |
| アクセントカラー | `#ff3b3b`（赤） |
| フォント | DM Mono（等幅）/ DM Sans（本文） |
| ロード済みスロット色 | `#4ade80`（緑） |

---

## 今後の拡張候補

- チャンネルリストの UI 上での追加・削除・並び替え
- セッション間でのスロット状態の保存・復元
- RSS取得失敗時に前回成功データを保持する仕組み
