class jetty-solr {
  # TODO update the service to support status
  service { "jetty-solr" :
    ensure    => running,
    enable    => true,
    require   => Package['jetty-solr'],
    hasstatus => false,
    status    => '/etc/init.d/jetty-solr check',
  }

  package { 'jetty-solr' :
    provider => "rpm",
    source => "http://uspto-jenkins-artifacts.s3-website-us-east-1.amazonaws.com/jetty-solr-4.1.0-9.noarch.rpm",
    ensure => present,
    require => Package['java-1.7.0-openjdk'],
  }

  package { 'java-1.7.0-openjdk' :
    ensure => present,
  }

}


