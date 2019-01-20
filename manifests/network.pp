
define tinc::network(
  $vpnaddress='169.254.0.0/16',
  $vpnprefix='24',
  $vpnroute=[],
  $netname=$name,
  $autostart=true,
  $addressfamily='ipv4',
  $interface='vpn0',
  $connectto=[],
  $nodename=$::hostname,
  $keysize='4096',
  $devicetype='tap',
  $mode='switch',
  $purge=false,
)
{

  validate_array($vpnroute)
  validate_array($connectto)

  if ($autostart == true) {
    concat::fragment { "nets.boot-${netname}":
      content => "${netname}\n",
      target  => '/etc/tinc/nets.boot',
      order   => '02'
    }
  }
  if ($tinc::autoip == false) {
    $vpnaddress=undef
  }

  file { "/etc/tinc/${netname}":
    ensure => directory
  }
  -> file { "/etc/tinc/${netname}/hosts/":
    ensure => directory,
    purge  => $purge
  }

  exec { "tinc-keygen-${netname}":
    command => "/usr/sbin/tincd -c /etc/tinc/${netname} -K ${keysize} -n ${netname}",
    creates => "/etc/tinc/${netname}/rsa_key.priv",
    require => File["/etc/tinc/${netname}/tinc.conf"]
  }
  -> exec { "tinc-pubkey-${netname}":
    command => "/usr/bin/openssl rsa -in /etc/tinc/${netname}/rsa_key.priv -out /etc/tinc/${netname}/rsa_key.pub -pubout",
    creates => "/etc/tinc/${netname}/rsa_key.pub",
  }

  file { "/etc/tinc/${netname}/tinc.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('tinc/tinc.conf.erb'),
    notify  => Service['tinc'],
    require => File["/etc/tinc/${netname}"]
  }

  file { "/etc/tinc/${netname}/tinc-up":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0544',
    content => template('tinc/tinc-up.erb'),
    require => File["/etc/tinc/${netname}"]
  }

  file { "/etc/tinc/${netname}/tinc-down":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0544',
    content => template('tinc/tinc-down.erb'),
    require => File["/etc/tinc/${netname}"]
  }

  Tinc::Host <<| netname == $netname |>>

}
