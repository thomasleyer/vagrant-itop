node default {
  Package {
    allow_virtual => false,
  }

  augeas { "php.ini":
    notify  => Service[httpd],
    require => Package[php],
    context => "/files/etc/php.ini/PHP",
    changes => [
      "set post_max_size 32M",
    ],
  }
  package { "httpd":
    notify  => Service["httpd"],
    ensure => installed,
  }
  package { ["php","php-mysql","php-mcrypt","php-xml","php-cli","php-soap","php-ldap","graphviz","php-gd"]:
    notify  => Service["httpd"],
    ensure => installed,
    require => Exec["install EPEL"],
  }
  exec { "install EPEL":
    notify  => Service["httpd"],
    command => "/bin/rpm -if http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm",
    cwd     => "/",
    creates => "/etc/yum.repos.d/epel.repo",
  }
  service { "httpd": 
    ensure => running,
    enable => true,
  }
  service { "iptables":
    ensure => stopped,
    enable => false,
  }
  class { '::mysql::server':
    root_password           => 'strongpassword',
    remove_default_accounts => true,
    override_options        => $override_options
  }
  mysql::db { 'itop':
    user     => 'itop',
    password => 'itop',
    host     => 'localhost',
    grant    => [ 'SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE', 'ALTER', 'CREATE VIEW', 'TRIGGER'],
  }

}
