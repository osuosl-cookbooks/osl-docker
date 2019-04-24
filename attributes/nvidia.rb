default['osl-docker']['nvidia']['version_lock'].tap do |p|
  p['nvidia-driver']['version'] = '410.104'
  p['nvidia-driver']['release'] = '1.el7'
  p['nvidia-docker2']['version'] = '2.0.3'
  p['nvidia-docker2']['release'] = '1.docker18.09.2.ce'
  p['cuda-drivers']['version'] = '410.104'
  p['cuda-drivers']['release'] = '1'
  p['cuda']['version'] = '10.0.130'
  p['cuda']['release'] = '1'
end
