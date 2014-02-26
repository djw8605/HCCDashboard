# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '10m', :first_in => 0 do |job|
  
  require 'json'
  require 'net/http' 
  require 'filesize'

  capacity_url = "http://hcc-ganglia.unl.edu/graph.php?c=red-infrastructure&h=hadoop-name.red.hcc.unl.edu&r=hour&z=default&jr=&js=&event=show&ts=0&v=3338915.0&m=dfs.FSNamesystem.CapacityTotalGB&json=1"
  used_url = "http://hcc-ganglia.unl.edu/graph.php?c=red-infrastructure&h=hadoop-name.red.hcc.unl.edu&r=hour&z=default&jr=&js=&event=show&ts=0&v=2561634.0&m=dfs.FSNamesystem.CapacityUsedGB&json=1"

  uri = URI(capacity_url)
  response = Net::HTTP.get_response(uri) 
  capacity_json = JSON.parse(response.body)
 
  capacity = capacity_json[0]["datapoints"].last[0]
  i = 1
  while capacity == "NaN" and i < capacity_json[0]["datapoints"].length
    capacity = capacity_json[0]["datapoints"][capacity_json[0]["datapoints"].length - i][0]
    i += 1
  end

  capacity = (capacity / (1024)).round(1)
  
  uri = URI(used_url)
  response = Net::HTTP.get_response(uri)
  used_json = JSON.parse(response.body)
 
  used = used_json[0]["datapoints"].last[0]
  i = 1
  while used == "NaN" and i < used_json[0]["datapoints"].length
    used = used_json[0]["datapoints"][used_json[0]["datapoints"].length - i][0]
    i += 1
  end

  used = (used  / (1024)).round(1)
  send_event('RedStorage', { min: 0, max: capacity, value: used, moreinfo: 'Capacity: %{capacity}' % {:capacity => Filesize.from("#{capacity.to_s} TB").pretty} })
  send_event('HCCAmazonPrice', { redStorage: used } )
  
end
