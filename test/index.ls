# number 的 test case ( @makechart/viewer 的 mctest )
mk = (val, unit) ->
  raw: [{val, name: "票房", unit: \新臺幣}]
  binding: {name: {key: \name}, value: {key: \val} <<< (if unit => {unit} else {})}
# 數字每 1/60 秒往目標靠 10%, 差不到 0.5 就停 ( 12777216 約 170 格 ). lite 版推 anim 的時鐘, d3 版等真實時間
settle = (c, ctx) ->
  if c.anim => for i from 0 til 600 => c.anim.step 16
  else ctx.wait 11000

# 數字與單位 ( 疊起來 ) 都在圖的範圍內
fits = (c, ctx) ->
  b = ctx.root.getBoundingClientRect!
  h = <[number unit]>.reduce ((a, k) -> a + c.n[k].getBoundingClientRect!height), 0
  if h > b.height + 0.5 => throw new Error "數字加單位高 #{h}px, 超過圖的 #{b.height}px"
  <[number unit]>.map (k) ->
    r = c.n[k].getBoundingClientRect!
    if r.width > b.width + 0.5 => throw new Error "#k 寬 #{r.width}px, 超過圖的 #{b.width}px"

mctest.suite do
  size: [400, 240]
  data:
    big: mk 12777216, \百萬元新臺幣
    small: mk 42
    nounit: mk 3.14159
    novalue: raw: [{name: "票房"}], binding: {name: {key: \name}}
  cases:
    * name: "big", data: \big, steps: settle
    * name: "small", data: \small, steps: settle
    * name: "unit-from-data", data: \nounit, steps: settle
    * name: "enlarge", data: \small, config: {enlarge: true}, steps: settle
    * name: "narrow", data: \big, size: [160, 120], steps: settle
    # 矮的容器 ( 儀表板的 KPI 列 ): 數字加單位要放得進高度, 不能只看寬度
    * name: "short", data: \big, size: [400, 50], steps: [settle, fits]
    * name: "short:enlarge", data: \small, size: [400, 40], config: {enlarge: true}, steps: [settle, fits]
    # 沒有綁 value 時不該丟錯, 顯示 0
    * name: "no-value", data: \novalue, steps: settle
    * name: "update", data: \small, steps: [settle, ((c) -> d = mk 9876; c.set-raw d.raw, d.binding), settle]
    # 逼近到位後要停掉 tick 的迴圈 ( 以前用 == 判斷, 永遠停不下來 )
    * name: "settle-stops", data: \nounit
      steps:
        * settle
        * (c) -> if c._aniloop.is-running! or c.v.run != c.v.number => throw new Error "tick loop still running"
    # 不滾動: 一開始就是終值, 不跑 tick
    * name: "no-tween", data: \big, config: {tween: false}
      steps: (c) -> if c._aniloop.is-running! => throw new Error "tick loop running with tween off"

# lite 版才有: 數字滾動的中間格
mctest.suite do
  size: [400, 240]
  data: big: mk 12777216, \百萬元新臺幣
  cases:
    * name: "anim:roll-frames", data: \big
      # 切到 manual 前已用真實時間跑過幾格, 先從 0 重來
      steps: (c, ctx) ->
        c.v.run = 0
        c.render!
        for i from 1 to 3
          for j from 0 til 5 => c.anim.step 16
          ctx.capture "f#{i * 5}"
