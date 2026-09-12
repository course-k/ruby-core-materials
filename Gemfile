# frozen_string_literal: true

source "https://rubygems.org"

# 教材リポの Gemfile は「教材側の道具」だけを持つ。
# 学習者コードのテストは成果リポの Gemfile で走る（根幹 §6）。
gem "minitest", "6.0.0"   # Ruby 4.0.6 同梱版に合わせる
gem "rubocop", "1.91.0"   # 書き写しの書式検査（根幹 §3.1）
# 原本の実行とアサーション数の実測に要る bundled gem（Ruby 4.0.6 同梱版に合わせる）
gem "csv", "3.3.5"
gem "logger", "1.7.0"
# rubocop が依存で json 3.x を引き込むと Ruby 4.0.6 同梱の json 2.18.0 と JSON.parse の引数仕様が変わる。
# 学習者環境（成果リポ、同梱 json）と同じ版に固定する。
gem "json", "2.18.0"
