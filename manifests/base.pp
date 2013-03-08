#include 'lws'
class {'jetty-solr':  }

#class {'zookeeper':  
#	zookeeper_parent_dir => "/opt",
#	user                 => "zookeeper",
#	group                => "zookeeper",
#	zookeeper_version    => "3.4.5",
#	zookeeper_home       => "/opt/zookeeper",
#}