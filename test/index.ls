# number 的 test case ( @makechart/viewer 的 mctest )
mk = (val, unit) ->
  raw: [{val, name: "票房", unit: \新臺幣}]
  binding: {name: {key: \name}, value: {key: \val} <<< (if unit => {unit} else {})}
# 數字每格往目標靠 10%, 約 400 格才完全停下. lite 版推 anim 的時鐘, d3 版等真實時間
settle = (c, ctx) ->
  if c.anim => for i from 0 til 600 => c.anim.step 16
  else ctx.wait 11000

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
    # 沒有綁 value 時不該丟錯, 顯示 0
    * name: "no-value", data: \novalue, steps: settle
    * name: "update", data: \small, steps: [settle, ((c) -> d = mk 9876; c.set-raw d.raw, d.binding), settle]

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
