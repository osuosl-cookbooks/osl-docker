package 'curl'

iface = node['network']['default_interface']

# Kitchen VMs run RA in NetworkManager; hand it to the kernel so osl-docker's accept_ra path runs.
execute "sysctl -w net/ipv6/conf/#{iface}/accept_ra=1" do
  only_if { ::File.exist?("/proc/sys/net/ipv6/conf/#{iface}/accept_ra") }
  not_if { ::File.exist?("/etc/sysctl.d/99-chef-net.ipv6.conf.#{iface}.accept_ra.conf") }
end if iface
