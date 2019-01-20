
define tinc::host(
  $netname,
  $subnets=['169.254.0.0/16'],
  $publickey,
  $publicaddress=undef,
  $nodename=$name,
  $port=undef,
) {
  
  file { "/etc/tinc/${netname}/hosts/${nodename}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('tinc/host.erb'),
  }

}
