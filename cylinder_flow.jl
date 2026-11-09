"""
WaterLily.jlを用いた円柱後流の数値解析

課題条件:
- Reynolds数: Re_D = 100 (直径基準)
- 格子: 96×64セル
- 直径あたりのセル数: D/Δx = 16

参考文献:
- 公式例: WaterLily-Examples/examples/TwoD_Circle.jl
- 理論: Weymouth & Font (2025), DOI: 10.1016/j.cpc.2025.109748
"""

using WaterLily
using Plots
using StaticArrays

"""
    cylinder_flow(n, m; Re_D=100, U=1, mem=Array)

円柱周りの流れのシミュレーションを初期化

# 引数
- `n`: x方向のセル数
- `m`: y方向のセル数
- `Re_D`: Reynolds数（直径基準）
- `U`: 一様流速
- `mem`: メモリバックエンド（CPU: Array, GPU: CuArray）

# 返り値
- `Simulation`: WaterLilyシミュレーションオブジェクト

# 物理的意味
Reynolds数 Re_D = U*D/ν は慣性力と粘性力の比を表します。
Re_D=100では、カルマン渦による周期的な渦放出が明瞭に観察されます。
"""
function cylinder_flow(n, m; Re_D=100, U=1, mem=Array)
    # 円柱の直径を定義（直径あたり16セル）
    D = 16  # 直径 [セル]
    radius = D / 2  # 半径 [セル]

    # 円柱の中心位置（上流側に配置）
    center = SA[n/4, m/2]  # (x, y)

    # 動粘性係数を直径基準Reynoldsから計算
    # Re_D = U*D/ν より ν = U*D/Re_D
    ν = U * D / Re_D

    println("=== 円柱流れシミュレーション設定 ===")
    println("格子サイズ: $(n)×$(m) セル")
    println("円柱直径: $D セル")
    println("円柱中心: $(center)")
    println("一様流速: $U")
    println("Reynolds数（直径基準）: Re_D = $Re_D")
    println("動粘性係数: ν = $ν")
    println("=====================================")

    # 円柱の形状を定義（符号付き距離関数）
    body = AutoBody((x,t) -> √sum(abs2, x .- center) - radius)

    # シミュレーションを初期化
    # dims: 格子サイズ
    # u_BC: 境界速度条件 (U, 0) = 左から右へ一様流
    # L: 基準長さ（直径を使用）
    # ν: 動粘性係数
    # body: 物体形状
    Simulation((n, m), (U, 0), D; ν=ν, body=body, mem=mem)
end

# シミュレーションを初期化（96×64セル、Re_D=100）
sim = cylinder_flow(96, 64; Re_D=100)

println("\nシミュレーションを開始します...")
println("初期時刻: t = $(WaterLily.sim_time(sim))")

# 時間発展（t=0から10まで）
t_end = 10.0
println("目標時刻: t = $t_end")

sim_step!(sim, t_end)

println("シミュレーション完了！")
println("最終時刻: t = $(WaterLily.sim_time(sim))")

# 渦度場を計算してPNG出力
println("\n渦度場を計算中...")
@inside sim.flow.σ[I] = WaterLily.curl(3, I, sim.flow.u)

# プロット
println("PNG画像を生成中...")
p = contourf(
    sim.flow.σ' |> Array,
    title="円柱後流の渦度場 (Re_D=100, t=$(round(WaterLily.sim_time(sim), digits=2)))",
    xlabel="x [セル]",
    ylabel="y [セル]",
    c=:RdBu,
    clims=(-0.5, 0.5),
    aspect_ratio=:equal,
    size=(800, 400)
)

# PNG保存
output_file = "vorticity_ReD100.png"
savefig(p, output_file)
println("渦度場を保存しました: $output_file")

println("\n=== 実行完了 ===")
