# RuboCop Config Gem化計画

## 概要

現在submoduleとして運用されているRuboCop設定ファイル集をgemとして配布し、CLIツールを提供することで利便性を向上させる。

## 目標

- submodule更新の煩雑さを解消
- 簡単なセットアップとメンテナンス
- 既存の設定管理フロー（Rakeタスク）を維持
- バージョン管理による設定の統一

## Gem設計

### 命名戦略

- **Gem名**: `sakuro-rubocop-config` (RubyGems登録名)
- **実行ファイル**: `rubocop-config` (ユーザーが使うコマンド)
- **モジュール名**: `RubocopConfig` (独立ツールのためシンプルに)

### プロジェクト構造

```
sakuro-rubocop-config/
├── sakuro-rubocop-config.gemspec
├── lib/
│   ├── rubocop_config.rb              # エントリポイント
│   └── rubocop_config/
│       ├── version.rb
│       ├── cli.rb                     # CLI レジストリ
│       ├── cli/                       # サブコマンド群
│       │   ├── base.rb               # 共通機能
│       │   ├── init.rb               # 初期化コマンド
│       │   └── regenerate_todo.rb    # TODO再生成コマンド
│       ├── generators/               # ファイル生成機能
│       │   └── rubocop_yml_generator.rb
│       ├── config/                   # 設定ファイル群
│       │   ├── base.yml             # メイン設定（プラグイン設定含む）
│       │   ├── cops/                # カスタマイズ設定
│       │   │   ├── bundler.yml
│       │   │   ├── style.yml
│       │   │   ├── layout.yml
│       │   │   ├── rspec.yml
│       │   │   └── ...
│       │   └── defaults/            # RuboCopデフォルト設定
│       │       ├── bundler.yml
│       │       ├── style.yml
│       │       └── ...
│       ├── config.rb                # 設定管理クラス
│       └── templates/
│           └── rubocop.yml.erb      # プロジェクト用テンプレート
├── exe/
│   └── rubocop-config              # CLI実行ファイル
└── spec/                           # テスト
```

## CLI設計

### フレームワーク

- **dry-cli**: 軽量で依存関係が少ない

### コマンド構成

#### `rubocop-config init`
- プロジェクトの初期化
- `.rubocop.yml`生成
- `.rubocop_todo.yml`自動生成（`--auto-gen-config --no-exclude-limit --no-offense-counts --no-auto-gen-timestamp`）

**オプション:**
- `--departments`: 特定部門のみ指定
- `--force`: 既存ファイル上書き
- `--skip-todo`: TODO生成をスキップ

#### `rubocop-config regenerate-todo`
- `.rubocop_todo.yml`の再生成
- シンプルに `rubocop --regenerate-todo` を実行

### 使用フロー

```bash
# 1. インストール
gem install sakuro-rubocop-config

# 2. 初期セットアップ
cd my_project
rubocop-config init

# 3. 違反修正後のTODO更新
rubocop-config regenerate-todo
```

## 設定ファイル管理

### 継承構造

```
base.yml
├── cops/style.yml (inherit_from: ../defaults/style.yml)
├── cops/layout.yml (inherit_from: ../defaults/layout.yml)
└── ...
```

### ファイル役割

1. **`config/base.yml`**: 
   - AllCops設定
   - プラグイン設定
   - cops/以下の全ファイルを継承

2. **`config/cops/`**: 
   - defaults/を継承してカスタマイズ
   - ユーザーが実際に使用する設定
   - 必要な箇所のみ上書き

3. **`config/defaults/`**: 
   - RuboCopから自動生成されたベース設定
   - 開発・更新時の参照用

### プロジェクトでの使用

```yaml
# 基本使用
inherit_gem:
  sakuro-rubocop-config: config/base.yml

# 部分使用
inherit_gem:
  sakuro-rubocop-config:
    - config/cops/style.yml
    - config/cops/layout.yml
```

## 開発・保守フロー

### Gem開発側（設定メンテナンス）

```bash
# 1. RuboCopバージョンアップ時
bundle update rubocop rubocop-*

# 2. デフォルト設定更新（既存Rakeタスク活用）
bundle exec rake clobber
bundle exec rake build:all

# 3. gem内設定ファイルに反映
cp default/*.yml lib/rubocop_config/config/defaults/

# 4. カスタマイズ設定の差分確認・調整
# 必要に応じてcops/以下を手動調整

# 5. gemバージョンアップ・リリース
gem build sakuro-rubocop-config.gemspec
gem push sakuro-rubocop-config-x.x.x.gem
```

### ビルドタスク修正方針

#### 現在のタスク構成
- **`rake build:all`**: 全デフォルト設定生成の統括タスク
- **生成フロー**:
  1. `build/all.yml`生成（全cop情報を一括取得）
  2. 各部門別ファイルに分割（`default/bundler.yml`等）

#### 効率化の発見
RuboCopの`--show-cops`は部門別指定に対応：
```bash
# 部門全体指定（ワイルドカード必須）
bundle exec rubocop --show-cops 'Style/*' --force-default-config
bundle exec rubocop --show-cops 'Layout/*' --force-default-config

# 個別cop指定
bundle exec rubocop --show-cops Style/AccessModifierDeclarations --force-default-config
```

#### 改善された修正計画
1. **部門別直接生成**: 全体ファイル経由せず各部門を個別生成
   ```ruby
   # 改善案
   file "lib/rubocop_config/config/defaults/#{base}.yml" do |t|
     sh "bin/rubocop",
       "--show-cops", "'#{department}/*'",  # 部門指定
       "--force-default-config",
       # その他オプション...
       out: t.name
   end
   ```

2. **出力先をgem構造に変更**: `lib/rubocop_config/config/defaults/`
3. **カスタマイズ設定の継承関係を維持**
4. **既存copsファイルの保護機能追加**  
5. **差分レポート機能**

#### 利点
- **効率性**: 中間ファイル不要、メモリ使用量削減
- **並列処理**: 部門別独立生成が可能
- **保守性**: 各部門が独立、デバッグが容易

## gemspec設定

```ruby
Gem::Specification.new do |spec|
  spec.name          = "sakuro-rubocop-config"
  spec.version       = RubocopConfig::VERSION
  spec.authors       = ["OZAWA Sakuro"]
  
  spec.executables   = ["rubocop-config"]
  
  spec.add_dependency "rubocop", ">= 1.0"
  spec.add_dependency "dry-cli", "~> 1.0"
  spec.add_dependency "erb"
end
```

## 実装段階

### Phase 1: 基盤構築
- gem骨格作成
- CLI基盤実装
- 設定ファイル移行

### Phase 2: 機能実装
- initコマンド実装
- regenerate-todoコマンド実装
- テスト整備

### Phase 3: 移行・公開
- 既存プロジェクトでのテスト
- ドキュメント整備
- gem公開

## 利点

1. **利便性**: ワンコマンドでのセットアップ
2. **保守性**: gem更新による設定の最新化
3. **配布**: submodule管理不要
4. **互換性**: 段階的移行が可能
5. **既存資産活用**: Rakeタスクによる設定管理を継続

## 注意事項

- 既存submodule利用者への影響を最小限に抑制
- 設定の後方互換性維持
- 継承関係の整合性チェック機能が重要