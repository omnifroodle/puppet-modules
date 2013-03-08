class lws {

  package { 'java-1.7.0-openjdk' :
    ensure => present,
  }

  package { 'jetty-solr' :
    provider => "rpm",
    source => "http://uspto-jenkins-artifacts.s3-website-us-east-1.amazonaws.com/jetty-solr-4.1.0-9.noarch.rpm",
    ensure => present,
    require => Package['java-1.7.0-openjdk'],
  }

  file { "/mnt/data1" :
    ensure => directory,
  }

  #mount { 'index-mount' :
    #name => "/mnt/data1",
    #device => "/dev/xvdm",
    #fstype => "ext4",
    #options => "rw,noexec,nodev,noatime,nodiratime",
    #ensure => "mounted",
    #require => File['/mnt/data1'],
  #}

  #file { "/var/lib/solr/solr.xml" :
    #source => "puppet:///modules/lws/solr.xml",
    #recurse => true,
    #ensure => present,
    #require => File['/mnt/data1'],
  #}

  #file { "/var/lib/solr/ingestion_logs" :
    #source => "puppet:///modules/lws/ingestion_logs",
    #recurse => true,
    #ensure => present,
    #require => File['/mnt/data1'],
  #}

  #file { "/var/lib/solr/cn_patent" :
    #source => "puppet:///modules/lws/cn_patent",
    #recurse => true,
    #ensure => present,
    #require => File['/mnt/data1'],
  #}

  service { "jetty-solr" :
    ensure => running,
    enable => true,
    #   require => File['/var/lib/solr/cn_patent'],
  }

  file { "/var/lib/solr/data" :
    ensure => link,
    target => "/mnt/data1",
    force => true,
    recurse => true,
    owner => "solr",
    group => "solr",
    require => Package['jetty-solr'],
  }
}
