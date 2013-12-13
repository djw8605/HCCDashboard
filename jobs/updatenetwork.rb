# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '6m', :first_in => 0 do |job|

  require 'tempfile'
  require 'rrd'
  require 'net/http' 
 
  # First, create a temporary file
  tmp_file = Tempfile.new('networkrrd')

  # Download the RRD
  rrd_url = "https://red-mon.unl.edu/cacti/rra/hcc-schorr-mlxe_traffic_in_836.rrd"
  uri = URI(rrd_url)
  req = Net::HTTP::Get.new(uri.path)

  response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https', :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
    https.request(req)
  end

  tmp_file.write(response.body)
  
  # Read in the RRD, parse into points data structure
  rrd = RRD::Base.new(tmp_file.path)
  
  points = []
  min_point = 0
  rrd.fetch(:average).each do |line| 
     if line[1].class != String && line[1].nan? != true
       if min_point == 0
         min_point = line[0].to_f
       end
       points << { x: line[0].to_f, y: (line[1].to_f + line[2].to_f)*8 }
     end
  end
  tmp_file.close
  tmp_file.unlink

  send_event('NetworkGraph', { points: points })
end
