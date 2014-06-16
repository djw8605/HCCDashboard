def getRRD(url)
  require 'tempfile'
  require 'net/http'
  
  # First, create a temporary file
  tmp_file = Tempfile.new('rrd') 
  uri = URI(url)
  req = req = Net::HTTP::Get.new(uri.path)
  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
    https.request(req)
  end

  tmp_file.write(response.body)

  return tmp_file

end


# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '6m', :first_in => 0 do |job|

  require 'rrd'
  
  # Download the RRD
  rrd_tmp = getRRD("https://red-mon.unl.edu/cacti/rra/hcc-schorr-mlxe_traffic_in_836.rrd")
  rrd2_tmp = getRRD("https://red-mon.unl.edu/cacti/rra/hcc-pki-mlxe_traffic_in_1004.rrd")
  rrd3_tmp = getRRD("https://red-mon.unl.edu/cacti/rra/hcc-schorr-mlxe_traffic_in_1162.rrd")
  
  # Read in the RRD, parse into points data structure
  rrd = RRD::Base.new(rrd_tmp.path)
  rrd2 = RRD::Base.new(rrd2_tmp.path)
  rrd3 = RRD::Base.new(rrd3_tmp.path)
 
  #network_debug = File.open("/tmp/networkdebug", 'w') 
  #network_debug.puts "Path = #{rrd3_tmp.path}"
  #network_debug.puts "RRD = #{rrd3}"

  points = []
  last_point = 0
  min_point = 0
  rrd.fetch(:average).each do |line| 
     if line[1].class != String && line[1].nan? != true
       if min_point == 0
         min_point = line[0].to_f
       end
       points << { x: line[0].to_f, y: (line[1].to_f + line[2].to_f)*8 }
       last_point = (line[1].to_f + line[2].to_f)*8
     end
  end

  counter = 0
  rrd2.fetch(:average).each do |line|
     if line[1].class != String && line[1].nan? != true
       if min_point == 0
         min_point = line[0].to_f
       end
       counter = 0
       while points[counter][:x] != line[0].to_f do
         #network_debug.puts "Incrementing counter #{points[counter][:x]} != #{line[0].to_f}" 
         counter += 1
       end
       if points[counter][:x] == line[0].to_f 
         #network_debug.puts "Found an equal: #{points[counter][:x]} = #{line[0].to_f}"
       else
         next
       end
       #network_debug.puts "Before add: #{points[counter][:y]}"
       points[counter][:y] += ( line[1].to_f + line[2].to_f)*8
       #network_debug.puts "After add: #{points[counter][:y]}"
       last_point = points[counter][:y]
     end
  end

  counter = 0
  rrd3.fetch(:average).each do |line|
     if line[1].class != String && line[1].nan? != true
       if min_point == 0
         min_point = line[0].to_f
       end
       counter = 0
       while points[counter][:x] != line[0].to_f do
         #network_debug.puts "Incrementing counter #{points[counter][:x]} != #{line[0].to_f}" 
         counter += 1
       end
       if points[counter][:x] == line[0].to_f 
         #network_debug.puts "Found an equal: #{points[counter][:x]} = #{line[0].to_f}"
       else
         next
       end
       #network_debug.puts "Before add: #{points[counter][:y]}"
       points[counter][:y] += ( line[1].to_f + line[2].to_f)*8
       #network_debug.puts "After add: #{points[counter][:y]}"
       last_point = points[counter][:y]
     end
  end

  
  #network_debug.close

  send_event('NetworkGraph', { points: points })
  send_event('HCCAmazonPrice', { network_bandwidth: last_point })
end
