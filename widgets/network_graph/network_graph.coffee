formatAxis = `function(y) {
    var abs_y = Math.abs(y);
    if (abs_y >= 1125899906842624)  { return (y / 1125899906842624).toFixed(0) + "P" }
    else if (abs_y >= 1099511627776){ return (y / 1099511627776).toFixed(0) + "T" }
    else if (abs_y >= 1073741824)   { return (y / 1073741824).toFixed(0) + "G" }
    else if (abs_y >= 1048576)      { return (y / 1048576).toFixed(0) + "M" }
    else if (abs_y >= 1024)         { return (y / 1024).toFixed(0) + "K" }
    else if (abs_y < 1 && y > 0)    { return y.toFixed(0) }
    else if (abs_y === 0)           { return '' }
    else                        { return y }
}`

class Dashing.NetworkGraph extends Dashing.Widget

  bytesToSize: (bytes) ->
    sizes = ['B', 'Kb', 'Mb', 'Gb', 'Tb'];
    if bytes == 0 
      return 'n/a';
    i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
    Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];

  @accessor 'current', ->
    return @get('displayedValue') if @get('displayedValue')
    points = @get('points')[-20..]
    if points
      this.bytesToSize(points[points.length - 1].y)


  ready: ->
    container = $(@node).parent()
    # Gross hacks. Let's fix this.
    width = (Dashing.widget_base_dimensions[0] * container.data("sizex")) + Dashing.widget_margins[0] * 2 * (container.data("sizex") - 1)
    height = (Dashing.widget_base_dimensions[1] * container.data("sizey"))
    @graph = new Rickshaw.Graph(
      element: @node
      width: width
      height: height
      renderer: @get("graphtype")
      series: [
        {
        color: "#fff",
        data: [{x:0, y:0}]
        }
      ]
    )

    @graph.series[0].data = @get('points')[-20..] if @get('points')

    x_axis = new Rickshaw.Graph.Axis.Time(graph: @graph)
    # y_axis = new Rickshaw.Graph.Axis.Y(graph: @graph, tickFormat: Rickshaw.Fixtures.Number.formatBase1024KMGTP)
    y_axis = new Rickshaw.Graph.Axis.Y(graph: @graph, tickFormat: formatAxis)
    @graph.render()

  onData: (data) ->
    if @graph
      @graph.series[0].data = data.points[-20..]
      @graph.render()
    $(@node).fadeOut().fadeIn()
