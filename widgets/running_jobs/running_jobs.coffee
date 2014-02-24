class Dashing.RunningJobs extends Dashing.Widget
  @accessor 'current', Dashing.AnimatedValue

  ready: ->
    # This is fired when the widget is done being rendered


  @accessor 'difference', ->
      if @get('last')
        last = parseInt(@get('last'))
        current = parseInt(@get('current'))
        if last != 0
          diff = Math.abs(Math.round((current - last) / last * 100))
          "#{diff}%"
      else
        ""

   @accessor 'arrow', ->
      if @get('last')
        if parseInt(@get('current')) > parseInt(@get('last')) then 'icon-arrow-up' else 'icon-arrow-down'

  onData: (data) ->
    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.
    $(@node).fadeOut().fadeIn()
    # Calculates the % difference between current & last values.
    #@accessor 'difference', ->
    #  if @get('last')
    #    last = parseInt(@get('last'))
    #    current = parseInt(@get('current'))
    #    if last != 0
    #      diff = Math.abs(Math.round((current - last) / last * 100))
    #      "#{diff}%"
    #  else
    #    ""
    # Picks the direction of the arrow based on whether the current value is higher or lower than the last
    #@accessor 'arrow', ->
    #  if @get('last')
    #    if parseInt(@get('current')) > parseInt(@get('last')) then 'icon-arrow-up' else 'icon-arrow-down'
      
