def getRRD(url)
  require 'tempfile'
  require 'net/http'
  require 'openssl'
  require 'httpclient'

  #ssl_context = OpenSSL::SSL::SSLContext.new()
  #ssl_context.ssl_version = :TLSv1_client
  #print ssl_context.ciphers()
  #print "\n"
  #print OpenSSL::SSL::SSLContext::METHODS
  #print "\n"
  
  # First, create a temporary file
  print "\n"
  tmp_file = Tempfile.new('rrd') 
  #uri = URI(url)
  #req = Net::HTTP::Get.new(uri.path)
  #sock = Net::HTTP.new(uri.host, uri.port)
  #sock.use_ssl = true
  #sock.ssl_version = "TLSv1"
  #sock.start do |https|
  #  response = https.request(req)
  #end  
  c = HTTPClient.new
  #c.ssl_config.ssl_version = :SSLv23
  #c.ssl_config.ssl_version = :TLSv1
  #c.ssl_config.options |= OpenSSL::SSL::OP_NO_SSLv3
  c.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
  response = c.get(url)
  #response = 
  
  #response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE, :ssl_version => "TLSv1") do |https|
  #  https.request(req)
  #end

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
 
  network_debug = File.open("/tmp/networkdebug", 'w') 
  network_debug.puts "Path = #{rrd3_tmp.path}"
  network_debug.puts "RRD = #{rrd2.info.to_yaml}"
  network_debug.close

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


  #network_debug.puts points
  counter = 0
  rrd2.fetch(:average).each do |line|
     if line[1].class != String && line[1].nan? != true
       if min_point == 0
         min_point = line[0].to_f
       end
       # The RRD's no longer line up on timestamps.
       #network_debug.puts "Points = #{points}"
       #network_debug.puts "counter = #{counter}"
       #network_debug.puts "line[0] = #{line[0]}"
       #while points[counter][:x] != line[0].to_f do
       #  network_debug.puts "Incrementing counter #{points[counter][:x]} != #{line[0].to_f}"
       #  if 
       #  counter += 1
       #end
       #if points[counter][:x] == line[0].to_f 
       #  network_debug.puts "Found an equal: #{points[counter][:x]} = #{line[0].to_f}"
       #else
       #  next
       #end
       #network_debug.puts "Before add: #{points[counter][:y]}"
       points[counter][:y] += ( line[1].to_f + line[2].to_f)*8
       #network_debug.puts "After add: #{points[counter][:y]}"
       last_point = points[counter][:y]
       counter += 1
     end
  end

  counter = 0
  rrd3.fetch(:average).each do |line|
     if line[1].class != String && line[1].nan? != true
       if min_point == 0
         min_point = line[0].to_f
       end
       #while points[counter][:x] != line[0].to_f do
       #  #network_debug.puts "Incrementing counter #{points[counter][:x]} != #{line[0].to_f}" 
       #  counter += 1
       #end
       #if points[counter][:x] == line[0].to_f 
         #network_debug.puts "Found an equal: #{points[counter][:x]} = #{line[0].to_f}"
       #else
       #  next
       #end
       #network_debug.puts "Before add: #{points[counter][:y]}"
       points[counter][:y] += ( line[1].to_f + line[2].to_f)*8
       #network_debug.puts "After add: #{points[counter][:y]}"
       last_point = points[counter][:y]
       counter += 1
     end
  end
  
  #network_debug.close

  send_event('NetworkGraph', { points: points })
  send_event('HCCAmazonPrice', { network_bandwidth: last_point })
end
