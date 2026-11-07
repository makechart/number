# Change Logs

## v0.0.2

 - extend the lite base ( `@makechart/base` `lite/index.html`, no d3 ): needs `@makechart/base` >= 0.2.0
   and `@plotdb/chart` >= 3.7.0.
   the number rolling in `mod.tick` follows `chart.anim` too, so it can be recorded frame by frame
 - fix bug: throws when `value` isn't bound; shows 0 when the value is missing
 - add test cases ( `test/index.ls`, run with `npm test` via `@makechart/viewer` )


## v0.0.1

init release
