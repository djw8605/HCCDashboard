Number::formatMoney = (t=',', d='.', c='$') ->
  n = this
  s = if n < 0 then "-#{c}" else c
  i = Math.abs(n).toFixed(2)
  j = (if (j = i.length) > 5 then j % 3 else 0)
  s += i.substr(0, j) + t if j
  return s + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t)


calculate_storage = (total_tb) ->
  total_cost = 0.0

  if total_tb > 1
    total_cost += 0.085 * 1024
  else if total_tb > 0
    total_cost += 0.085 * (1024 * total_tb)
  total_tb -= 1

  if total_tb > 49
    total_cost += 0.075 * (1024 * 49)
  else if total_tb > 0
    total_cost += 0.075 * (1024 * total_tb)
  total_tb -= 49

  if total_tb > 450
    total_cost += 0.060 * (1024 * 450)
  else if total_tb > 0
    total_cost += 0.060 * (1024 * total_tb)
  total_tb -= 450
  
  if total_tb > 500
    total_cost += 0.055 * (1024 * 500)
  else if total_tb > 0
    total_cost += 0.055 * (1024 * total_tb)
  total_tb -= 500

  if total_tb > 4000
    total_cost += 0.051 * (1024 * 4000)
  else if total_tb > 0
    total_cost += 0.051 * (1024 * total_tb)
  total_tb -= 4000

  if total_tb > 0
    total_cost += 0.043 * (1024 * total_tb)

  total_cost

calculate_network = (total_bps) ->
  # Convert to gigabytes per second, then multiple to get per month
  # 60 * 60 * 24 * 30
  total_gbs = (total_bps * Number("1.16415322E-10")) * ( 60 * 60 * 24 * 30 )
  # total_gbs = (total_bps / 8589934592) * (30 * 24 * 60 * 60) 
  total_cost = 0.0

  if total_gbs > 1
    total_cost += 0
  else if total_gbs > 0
    total_cost += 0
  total_gbs -= 1

  if total_gbs > 10*1024
    total_cost += 0.12 * (10*1024)
  else if total_gbs > 0
    total_cost += 0.12 * (total_gbs)
  total_gbs -= 10*1024

  if total_gbs > 40*1024
    total_cost += 0.09 * (1024 * 40)
  else if total_gbs > 0
    total_cost += 0.09 * (total_gps)
  total_gbs -= 40*1024
  
  if total_gbs > 100*1024
    total_cost += 0.07 * (1024 * 100)
  else if total_gbs > 0
    total_cost += 0.07 * (total_gbs)
  total_gbs -= 100*1024

  if total_gbs > 0
    total_cost += 0.05 * (total_gbs)

  total_cost





class Dashing.AmazonPrice extends Dashing.Widget

  @accessor 'current', Dashing.AnimatedValue

  computing_cost: 0.0
  storage_cost: 0.0
  network_cost: 0.0
  red_storage: 0.0
  tusker_storage: 0.0
  crane_storage: 0.0
  sandhills_storage: 0.0
  total_storage: 0.0

  @accessor 'total_storage', ->
    if @get('redStorage')
       @red_storage = parseFloat(@get('redStorage'))

    if @get('tuskerStorage')
       @tusker_storage = parseFloat(@get('tuskerStorage'))

    if @get('craneStorage')
       @crane_storage = parseFloat(@get('craneStorage'))

    if @get('sandhillsStorage')
       @sandhills_storage = parseFloat(@get('sandhillsStorage'))


    @red_storage + @tusker_storage + @crane_storage + @sandhills_storage
 
  @accessor 'current_hourly', ->
    if @get('total_cores')
      @computing_cost = ((parseFloat(@get('total_cores')) / 4) * 0.3)

    if @get('total_storage')
      @storage_cost = calculate_storage(parseFloat(@get('total_storage'))) / (30 * 24)

    if @get('network_bandwidth')
      @network_cost = calculate_network(parseFloat(@get('network_bandwidth'))) / (30 * 24)

    if @get('total_cores') or @get('total_storage') or @get('network_bandwidth')
      new_current = (@computing_cost + @storage_cost + @network_cost).toFixed(2)
      "#{new_current}"

  @accessor 'yearly', ->
    if @get('current_hourly')
      current = parseFloat(@get('current_hourly'))
      current_yearly = current * 24 * 365
      formatted_yearly = current_yearly.formatMoney()
      "#{formatted_yearly}"

  @accessor 'formatted_computing_cost', ->
    if @get('current_hourly') and @computing_cost > 0
    	"#{@computing_cost.formatMoney()}"
    else
        "Loading..."

  @accessor 'formatted_storage_cost', ->
    if @get('current_hourly') and @storage_cost > 0
    	"#{@storage_cost.formatMoney()}"
    else
        "Loading..."

  @accessor 'formatted_network_cost', ->
    if @get('current_hourly') and @network_cost > 0
    	"#{@network_cost.formatMoney()}"
    else
        "Loading..."


  ready: ->
    # This is fired when the widget is done being rendered

  onData: (data) ->
    # Handle incoming data
    # You can access the html node of this widget with `@node`
    # Example: $(@node).fadeOut().fadeIn() will make the node flash each time data comes in.
    

    
