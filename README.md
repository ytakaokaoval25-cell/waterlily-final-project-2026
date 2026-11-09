# WaterLily.jlを用いた円柱後流の数値解析

東京理科大学 熱流体力学演習2026 最終プロジェクト

## 研究目的

WaterLily.jlを用いた円柱後流の数値解析により、渦放出周波数と流体力を評価する。

## 実行環境

- **Julia**: 1.13.0
- **WaterLily.jl**: 1.8.0
- **OS**: macOS (Darwin 24.6.0)

## 依存パッケージ

```toml
[deps]
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
WaterLily = "ed894a53-0139-4a2c-9b31-8a8a0756f0ab"
```

バージョンの詳細は `Manifest.toml` を参照。

## 計算条件

### Re_D = 100の基準条件

| 項目 | 値 | 備考 |
|------|-----|------|
| Reynolds数（直径基準） | Re_D = 100 | Re_D = U_∞D/ν |
| 格子サイズ | 96×64 セル | 基準格子 |
| 円柱直径 | D = 16 セル | D/Δx = 16 |
| 一様流速 | U_∞ = 1 | 無次元 |
| 動粘性係数 | ν = 0.16 | ν = U_∞D/Re_D |
| 円柱中心位置 | (24, 32) セル | x方向は上流側 |
| 計算時間 | t = 0 → 10 | 無次元時間 |

### 物理的意味

**Reynolds数 Re_D = 100**は、慣性力と粘性力の比を表す無次元数です。

- Re_D ~ 40-150: 周期的な渦放出（カルマン渦）が発生
- Re_D = 100: カルマン渦が明瞭に観察される
- 期待される Strouhal数: St ≈ 0.16-0.17（文献値）

## 実行方法

### 1. 環境構築

```bash
# リポジトリに移動
cd ~/waterlily-final-project

# Juliaパッケージをインストール（初回のみ）
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

### 2. シミュレーション実行

```bash
# マルチスレッドで実行（推奨）
JULIA_NUM_THREADS=auto julia --project=. cylinder_flow.jl
```

**実行時間**: 約10-30秒（CPUの性能による）

### 3. 出力結果

実行後、以下のファイルが生成されます：

- `vorticity_ReD100.png`: 渦度場の可視化（t=10時点）

## 結果の例

![渦度場](vorticity_ReD100.png)

**観察される現象**:
- 円柱後方に**カルマン渦列**が形成される
- 赤い渦（負の渦度、時計回り）と青い渦（正の渦度、反時計回り）が交互に放出される
- これはRe_D=100の典型的な流れパターン

## ファイル構成

```
.
├── README.md                # このファイル
├── cylinder_flow.jl         # メインシミュレーションコード
├── Project.toml             # Juliaプロジェクト設定
├── Manifest.toml            # パッケージバージョン記録
├── docs/
│   └── AI_DECISIONS.md      # AI判断の記録
└── vorticity_ReD100.png     # 渦度場の出力（実行後）
```

## 参考文献

### 公式ドキュメント
- [WaterLily.jl 公式リポジトリ](https://github.com/WaterLily-jl/WaterLily.jl)
- [WaterLily-Examples](https://github.com/WaterLily-jl/WaterLily-Examples)
  - 参考にしたサンプル: `examples/TwoD_Circle.jl`

### 学術文献
- Weymouth, G.D. & Font, B. (2025). "WaterLily.jl: A differentiable and backend-agnostic Julia solver for incompressible viscous flow around dynamic bodies". *Computer Physics Communications*, 315, 109748. [DOI: 10.1016/j.cpc.2025.109748](https://doi.org/10.1016/j.cpc.2025.109748)
- Posdzich, P. & Grundmann, R. (2006). "Numerical simulation of flow past a cylinder". *Journal of Fluids and Structures*, DOI: 10.1016/j.jfluidstructs.2006.09.004

### 授業資料
- [東京理科大学 熱流体力学演習2026 最終プロジェクト課題](https://t2lab-it.github.io/thermofluid-exercise-2026/projects/final-project-topics/waterlily-cylinder-flow.html)

## 今後の研究計画

### 次のステップ（Re=100での詳細解析）

1. **Strouhal数の測定**
   - 揚力係数C_Lの時系列データを取得
   - FFTで渦放出周波数f_sを解析
   - St = f_s·D/U_∞ を計算
   - 文献値（St ≈ 0.16-0.17）と比較

2. **流体力係数の測定**
   - 抗力係数C_D（時間平均）
   - 揚力係数C_L（時系列）
   - C_L,rms（揚力変動の標準偏差）
   - 圧力成分と粘性成分の分離

3. **格子依存性の検証**
   - D/Δx = 8, 16, 32 で計算
   - 結果の収束性を確認

4. **外側境界の影響評価**
   - 計算領域を段階的に拡大
   - 上流・下流・側方距離の影響を調査

## 検証状況

### ✓ 検証済み（2026-11-09時点）

- [x] Julia 1.13.0での動作確認
- [x] WaterLily.jl v1.8.0のインストール
- [x] Re_D=100での計算実行（t=0→10）
- [x] カルマン渦列の定性的な観察
- [x] 渦度場のPNG出力

### ⚠️ 未検証・今後の課題

- [ ] **Strouhal数の定量測定** - 揚力係数の時系列データとFFT解析
- [ ] **流体力係数の測定** - C_D（時間平均）、C_L（時系列）、C_L,rms
- [ ] **初期過渡状態の確認** - t=10は十分な周期状態か？
- [ ] **文献値との定量比較** - Posdzich & Grundmann (2006) との数値比較
- [ ] **格子依存性** - D/Δx = 8, 16, 32での収束性
- [ ] **計算領域依存性** - 上流・下流・側方距離の影響
- [ ] **Reynolds数定義の再確認** - 半径基準と直径基準の混同がないか
- [ ] **境界条件の詳細** - 具体的な境界条件の設定値
- [ ] **第三者による再現確認** - 別環境でのclone→実行テスト
- [ ] **小さなCPUテスト** - CI/CD用の軽量テストケース

### 重要な注意事項

**現在の実装は基本動作確認のみです。**

- カルマン渦の「見た目」は確認できましたが、定量的な検証は未実施です
- 文献値との比較、格子依存性、計算領域の妥当性は今後の課題です
- この段階で「再現成功」と断定することはできません

## ライセンス

### このプロジェクトのライセンス

**GNU General Public License v3.0 (GPL-3.0)**

Copyright (C) 2026 東京理科大学 熱流体力学演習2026 受講生

詳細は [LICENSE](LICENSE) ファイルを参照してください。

### 使用パッケージとライセンス

| パッケージ | ライセンス | 著作権者 |
|-----------|-----------|---------|
| **WaterLily.jl** | MIT License | Copyright (c) 2020 Gabriel Weymouth |
| **WaterLily-Examples** | GPL-3.0 | Free Software Foundation |
| **Plots.jl** | MIT License | - |
| **StaticArrays.jl** | MIT License | - |

### 参考コードと著作権表示

本プロジェクトは以下を参考にしています：
- **WaterLily-Examples/examples/TwoD_Circle.jl** (GPL-3.0)

GPL-3.0のコピーレフト要件に従い、本プロジェクトもGPL-3.0でライセンスされています。

## 作成者

東京理科大学 熱流体力学演習2026 受講生

## 変更履歴

- 2026-11-09: 初版作成（Re_D=100の基本実装）
