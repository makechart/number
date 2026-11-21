# Change Logs

## v0.0.5

 - add `desc` ( en / zh-TW ) to the config items, shown under the label in the makechart style panel

## v0.0.4

 - fix bug: font size was fitted to the width only, so in a short container ( e.g. a KPI row in a dashboard )
   the number and unit overflowed and got clipped. when the stacked number + unit is taller than the chart,
   both now shrink together to fit the height too ( also with `enlarge` )
 - add `short`, `short:enlarge` test cases


## v0.0.3

 - fix bug: the rolling number never stopped its tick loop. it approaches the target asymptotically and
   never becomes exactly equal, so `stop` was never called and `requestAnimationFrame` kept running.
   it now snaps to the target and stops once within 0.5 ( the displayed integer is already the same )
 - rolling speed is time based ( 10% of the remaining distance per 1/60 s, using `dt` from `mod.tick` )
   instead of per frame, so it no longer runs faster on high refresh rate screens
 - add `tween` config ( default true ). the number shows the final value directly when `tween` is
   false or when `prefers-reduced-motion: reduce` is set
 - add `settle-stops` / `no-tween` test cases


## v0.0.2

 - extend the lite base ( `@makechart/base` `lite/index.html`, no d3 ): needs `@makechart/base` >= 0.2.0
   and `@plotdb/chart` >= 3.7.0.
   the number rolling in `mod.tick` follows `chart.anim` too, so it can be recorded frame by frame
 - fix bug: throws when `value` isn't bound; shows 0 when the value is missing
 - add test cases ( `test/index.ls`, run with `npm test` via `@makechart/viewer` )


## v0.0.1

init release
