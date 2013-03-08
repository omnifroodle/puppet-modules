# Class: zookeeper
#
# This module manages zookeeper
#
# Parameters:
#   zookeeper_parent_dir
#   user
#   group
#   zookeeper_version
#   zookeeper_home
#   zookeeper_log_dir
#
# Actions:
#   deploy zookeeper
#   deploy zk coniguration
#
# Requires:
#   N/A
# Sample Usage:
#   $myid=1
#   include zookeeper
#
class zookeeper (
    $zookeeper_myid = 1,
    $zookeeper_parent_dir = "/opt",
    $user = "zookeeper",
    $group= "zookeeper",
    $zookeeper_version = "3.4.5",
    $zookeeper_home = "/opt/zookeeper",
    $zookeeper_datastore = "/var/lib/zookeeper",
    $zookeeper_datastore_log = "/var/log/zookeeper",
  ) {

  package { "wget":
    ensure => installed,
  }

  user { $user: 
    ensure => present,
  }
  
  file { "zookeeper_home":
    path => $zookeeper_home,
    ensure => directory, 
    owner   => "${user}",
    group  => $group,
    require => [User[$user]],
  }

  exec { "download zookeeper":
      path    => "/usr/bin",
      command => "wget -q http://www.trieuvan.com/apache/zookeeper/zookeeper-${zookeeper_version}/zookeeper-${zookeeper_version}.tar.gz -O zookeeper-${zookeeper_version}.tar.gz",
      creates => "${zookeeper_home}/zookeeper-${zookeeper_version}.tar.gz",
      cwd     => $zookeeper_home,
      require => [Package[ "wget" ], File[$zookeeper_home]],
      user    => $user,
  }

  exec { "zookeeper_untar":
    path => "/bin",
    command => "tar xzf zookeeper-${zookeeper_version}.tar.gz;",
    cwd => "${zookeeper_home}",
    require => Exec["download zookeeper"],
    creates => "${zookeeper_home}/zookeeper-${zookeeper_version}",
  }

  $log_path = $operatingsystem ? {
    Darwin   => "/Users/$user/Library/Logs/zookeeper/",
    default => "/var/log/zookeeper",
  }

  file { "log_path":
    path => $log_path, 
    owner => $user,
    group => $group,
    mode => 644,
    ensure => directory,
    backup => false, 
    require => [User[$user]],
  }

  file { "zookeeper_datastore":
    path => $zookeeper_datastore, 
    ensure => directory, 
    owner => $user,
    group => $group,
    mode => 644, 
    backup => false,
    require => [User[$user]],
  }

  file { "zookeeper_datastore_myid":
    path => "${zookeeper_datastore}/myid", 
    ensure => file, 
    content => template("zookeeper/conf/dev/myid.erb"), 
    owner => $user,
    group => $group,
    mode => 644, 
    backup => false,
    require => File[$zookeeper_datastore],
  }

  if $zookeeper_datastore_log != $log_path {
    file { "zookeeper_datastore_log":
      path => "${zookeeper_datastore_log}", 
      ensure => directory, 
      owner => $user,
      group => $group,
      mode => 644, 
      backup => false,
      require => [User[$user]],
    }
  }

  include zookeeper::copy_conf
  include zookeeper::copy_services

}

class zookeeper::copy_conf {
  
  file { "$zookeeper_home/conf":
    path => "$zookeeper_home/conf",
    owner => $user,
    group => $group,
    mode => 644,
    ensure => directory,
    require => File[$zookeeper_home], 
  }

  file { "conf/zoo.cfg":
    path => "${zookeeper_home}/zookeeper-${zookeeper_version}/conf/zoo.cfg",
    owner => $user,
    group => $group,
    mode => 644,
    ensure => present,
    content => template("zookeeper/conf/dev/zoo.cfg.erb"), 
    require => File[$zookeeper_home], 
  }

  file { "zookeeper_java.env":
    path => "${zookeeper_home}/zookeeper-${zookeeper_version}/conf/java.env",
    owner => $user,
    group => $group,
    mode => 644,
    ensure => present,
    content => template("zookeeper/conf/dev/java.env.erb"), 
    require => File[$zookeeper_home], 
  }

  file { "zookeeper_log4j":
    path => "${zookeeper_home}/zookeeper-${zookeeper_version}/conf/log4j.properties",
    owner => $user,
    group => $group,
    mode => 644,
    ensure => present,
    content => template("zookeeper/conf/dev/log4j.properties.erb"), 
    require => File[$zookeeper_home], 
  }
}

class zookeeper::copy_services {
  if $operatingsystem != Darwin {
    file { "zookeeper-server-service":
      path => "/etc/init.d/zookeeper-server",
      content => template("zookeeper/service/zookeeper-server.erb"),
      ensure => file,
      owner => "root",
      group => "root",
      mode => 755
    }
  }
}

class zookeeper::copy_dev_services {
  $init_d_path = $operatingsystem ?{
    Darwin => "/usr/bin/zookeeper_service",
    default => "/etc/init.d/zookeeper",
  }

  $init_d_template = $operatingsystem ?{
    Darwin => "zookeeper/service/zookeeper_service.erb",
    default => "zookeeper/service/zookeeper.erb",
  }

  file { "zookeeper-init-service":
    path => $init_d_path,
    content => template($init_d_template),
    ensure => file,
    owner => $user,
    group => $group,
    mode => 755
  }
}

