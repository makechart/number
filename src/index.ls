module.exports =
  pkg:
    name: 'number', version: '0.0.1'
    extend: {name: "@makechart/base"}
    dependencies: []

  init: ({root, context, pubsub}) ->
    pubsub.fire \init, {mod: mod {context}} .then ~> it.0

mod = ({context}) ->
  {d3,ldcolor,repeatString$,infinite} = context
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
    @g = Object.fromEntries <[number unit]>.map ~> [it, d3.select(@layout.get-group it)]
    @g.number.append \text
    @g.unit.append \text
    @v = number: 0, unit: '', run: 0

  resize: ->
    [w,h] = [@box.width, @box.height]
    @size-rate = number: (@cfg.number-size-rate or 3), unit: (@cfg.unit-size-rate or 1)
    @v <<< do
      number: (@data.0 or {value: 0}).value
      unit: @binding.value.unit or (@data.0 or {unit: ''}).unit or ''
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
    @g.number.select \text .text ~>
      @v.run = (@v.number - @v.run) * 0.1 + @v.run
      if @v.run == @v.number => @stop!
      return Math.round(@v.run)

  render: ->
    @g.number.select \text
      .attr \x, (@n.number.getBoundingClientRect!width / 2)
      .attr \font-size, "#{@size-rate.number * @r.number}em"
      .attr \font-weight, \bold
      .attr \dominant-baseline, \hanging
      .attr \text-anchor, \middle
      .text Math.round(@v.run)
    @g.unit.select \text
      .attr \font-size, "#{@size-rate.unit * @r.unit}em"
      .attr \dominant-baseline, \hanging
      .text @v.unit
    @start!
