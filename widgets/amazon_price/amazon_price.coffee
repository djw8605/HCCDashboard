Number::formatMoney = (t=',', d='.', c='$') ->
  n = this
  s = if n < 0 then "-#{c}" else c
  i = Math.abs(n).toFixed(2)
  j = (if (j = i.length) > 3 then j % 3 else 0)
  s += i.substr(0, j) + t if j
  return s + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t)


class Dashing.AmazonPrice extends Dashing.Widget

  @accessor 'current', Dashing.AnimatedValue
  
  @accessor 'current_hourly', ->
    if @get('current')
      new_current = parseFloat(@get('current')).toFixed(2)
      "#{new_current}"

  @accessor 'yearly', ->
    if @get('current')
      current = parseFloat(@get('current'))
      current_yearly = current * 24 * 365
      formatted_yearly = current_yearly.formatMoney()
      "#{formatted_yearly}"


  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.
    

    
