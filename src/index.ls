module.exports =
  pkg:
    name: 'number', version: '0.0.1'
    # lite: 不帶 d3 的 base ( 見 @plotdb/chart utils )
    extend: {name: "@makechart/base", path: "lite/index.html"}
    dependencies: []

  init: ({root, context, pubsub}) ->
    pubsub.fire \init, {mod: mod {context}} .then ~> it.0

mod = ({context}) ->
  {ldcolor} = context
  svgns = "http://www.w3.org/2000/svg"
  sample: ->
    raw: [{val: 12777216, name: "票房", unit: "新臺幣"}]
    binding:
      name: {key: \name}
      value: {key: \val, unit: '百萬元新臺幣'}
  config:
    enlarge: type: \boolean, default: false
  dimension:
    value: {type: \R, name: "value"}
    name: {type: \N, name: "name"}
    unit: {type: \N, name: "unit"}
  init: ->
    @n = Object.fromEntries <[number unit]>.map ~> [it, @layout.get-node(it)]
    @g = Object.fromEntries <[number unit]>.map ~> [it, @layout.get-group it]
    @t = Object.fromEntries <[number unit]>.map ~> [it, @g[it].appendChild document.createElementNS(svgns, \text)]
    @v = number: 0, unit: '', run: 0

  resize: ->
    [w,h] = [@box.width, @box.height]
    @size-rate = number: (@cfg.number-size-rate or 3), unit: (@cfg.unit-size-rate or 1)
    @v <<< do
      number: +((@data.0 or {}).value) or 0
      unit: (@binding.value or {}).unit or (@data.0 or {unit: ''}).unit or ''
    @n.number
      ..style.fontSize = "#{@size-rate.number}em"
      ..textContent = @v.number
    @n.unit
      ..style.fontSize = \1em
      ..textContent = @v.unit
    @r = r = Object.fromEntries <[number unit]>.map ~> [it, (w / (@n[it]getBoundingClientRect!width or 1))]
    (if !@cfg.enlarge => <[number unit]> else <[unit]>).map ~> @r[it] = (r[it] <? 1)
    @n.number.style.fontSize = "#{@size-rate.number * r.number}em"
    @n.unit.style.fontSize = "#{@size-rate.unit * r.unit}em"
    @layout.update false

  tick: ->
    # 每格往目標靠 10% ( 以格數計, 錄影時跟著 anim 的 step 走 )
    @v.run = (@v.number - @v.run) * 0.1 + @v.run
    if @v.run == @v.number => @stop!
    @t.number.textContent = Math.round(@v.run)

  render: ->
    @t.number
      ..setAttribute \x, (@n.number.getBoundingClientRect!width / 2)
      ..setAttribute \font-size, "#{@size-rate.number * @r.number}em"
      ..setAttribute \font-weight, \bold
      ..setAttribute \dominant-baseline, \hanging
      ..setAttribute \text-anchor, \middle
      ..textContent = Math.round(@v.run)
    @t.unit
      ..setAttribute \font-size, "#{@size-rate.unit * @r.unit}em"
      ..setAttribute \dominant-baseline, \hanging
      ..textContent = @v.unit
    @start!
