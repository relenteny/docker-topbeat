# docker-topbeat

The contents of this repository contain the artifacts used during the Atlanta, GA Docker Meetup on October 19, 2016 (http://www.meetup.com/Docker-Atlanta/events/234505891/).  The title of the event was **Using Elasticsearch to Help Monitor Docker Containers**.

The Meetup introduction read as follows:
___

Docker and Elasticsearch are two of the hottest technologies in our industry.  Most often, when Elasticsearch and Docker are part of the same discussion, the topic focuses on running Elasticsearch in a Docker container.  This session will explore these two technologies in a manner that's a bit outside this typical Elasticsearch and Docker discussion and look at how Elasticsearch combined with Beats can be used to assist in monitoring and reporting Docker container activity. 

Through examples and demonstrations, the presentation will walk through the configuration of an example Docker multi-service application with each container and Docker host reporting statistics to Elasticsearch via Beats.  Areas of discussion include: 

1. A quick introduction to Elastic Beats 

2. Review of how an Elastic Beat can be used to monitor a Docker container 

3. Discuss the configuration of Elasticsearch, Kibana and Beats 

4. Building Docker images ready to report container statistics to Elastic search 

5. Introduce Docker Swarm 1.12 to deploy a multi-service application with each container reporting statistics to Elasticsearch 

If you know little about Docker or Elasticsearch, don't hesitate to join the group for this interesting discussion.  You'll be certain to walk away with enough samples and information to give it a try.  If you're very comfortable with these technologies, sharing your insights, experiences and guidance will certainly benefit the entire group. 

For those who may have attended this presentation when given at a recent Elasticsearch Meetup, this updated presentation refines the topics discussed in that presentation and adds a discussion of Docker Swarm and Docker services now available in Docker 1.12.

---

During the presentation several artifacts were used when building images.  These were copied from the ```build/distribution``` sub-directory in each respective ```dockerfiles``` directory.  Due to size, and in some cases license considerations, these files are not include in this repository.  Rather a ```README.md``` is included in the ```build/distribution``` sub-directories indicating the files to include in the directory and the location from which the files can be downloaded.
___
## Quick Start
The following describes the build order and commands used during the presentation.  Building the images, and following the subsequent Docker commands in the order below should ensure a successful startup of all containers and applications.  Documentation on Dockerfiles, Docker Swarm, and Docker commands in general can be found at https://docs.docker.com/.  These examples were built and run on Docker version 1.12.2.

### Image Build Order

#### Customized Ubuntu image:  
```cd dockerfiles/ubuntu```  
```docker build --tag meetup/ubuntu:16.04 .```

#### Java 8 server runtime image:  
```cd dockerfiles/jre```  
```docker build --tag meetup/jre:8 .```

#### Elasticsearch image:  
```cd dockerfiles/elasticsearch```  
```docker build --tag meetup/elasticsearch:2.4.1 .```

#### Kibana image:  
```cd dockerfiles/kibana```  
```docker build --tag meetup/kibana:4.6.1 .```

#### Customized MySQL/MariaDB image:  
```cd dockerfiles/mysql```  
```docker build --tag meetup/mysql:5.7 .```

#### Customized Wordpress image:  
```cd dockerfiles/wordpress```  
```docker build --tag meetup/wordpress:php5.6 .```

### Copying Images to Multiple Engines

The example application will function on a single node Swarm cluster.  However, if you will be working through this example with more than 
one Docker Engine (node) participating in the Swarm, you will need to load the above created images on each Docker Engine.  This can be done 
without a registry using the `docker save` and `docker load` commands.

To save the created images for loading on to additional Docker Engines, the following command is used:

`docker save -o images.tar meetup/wordpress:php5.6 meetup/kibana:4.6.1 meetup/elasticsearch:2.4.1 meetup/jre:8 meetup/mysql:5.7 meetup/ubuntu:16.04 ubuntu:16.04 wordpress:php5.6`

This will create a file named `images.tar` in the current directory.  To load the saved images on to another Docker Engine, update the
`DOCKER_HOST` environment variable to point to the Docker Engine on which the images are to be loaded and use the following command:

`docker load -i images.tar`    

## Docker Swarm

The commands described below used to create the sample application's containers only work when a Docker Engine has Swarm mode enabled.  Regardless
of the number of nodes in a Swarm, there must be at least one Swarm master node.  The following command 
defines and initializes a Swarm cluster and establishes the Docker Engine on which the command is executed (identified by the `DOCKER_HOST` environment variable) as a master 
node in the Swarm:

`docker swarm init`

The output of the command will look similar to the following:

```
Swarm initialized: current node (4g8gsbtavitr8a1iweizk1cax) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-5sh2zijpx8etoy1pjxbqq5dshfrrb5yvjl3v4vptngarvgs4wg-8lm4vb6ouo38mlyj9u4bx1ncp \
    192.168.31.110:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

For each additional Docker Engine that will be participating in the Swarm, enter the `docker swarm join` command
displayed in the output of the `docker swarm init` command.

With the Swarm initailized, the example application makes use of two networks.  The following commands create
the sample networks.

`docker network create -d overlay --subnet 10.10.1.0/24 elastic`  
`docker network create -d overlay database`

*Note: The `docker network` command must be executed on the Docker Engine designated
as the master node.* 

## Deploying the Docker Swarm Services

### The Elastic Stack Services

The demonstration consists of two groupings of containers; the Elastic stack grouping, which utilizes the 
`elastic` network created above, and the sample application grouping containing MySQL and Worpress, which utilizes
the database network.

Before the MySQL and Wordpress services are started, the Elastic stack needs to be started.  Upon startup of the
Elastic stack, Elasticsearch and Kibana are configured and initialized to support the Topbeat data
that will be sent to it from the containers and host VMs.

#### Elasticsearch Master Node Service
`docker service create --replicas 3 --publish 9200:9200 --name esmaster --network elastic --mount type=bind,source=/opt/esdata,destination=/home/elastic/data meetup/elasticsearch:2.4.1 /home/elastic/bin/start-elasticsearch.sh -m 2`

*Note: The `--mount` option is not required to run the test application.  It's used to demonstrate externalizing the Elasticsearch data 
directories.  If it is used, the directory `/opt/esdata` must be created on **all** Docker Engine hosts prior to
deploying the service.*

#### Kibana Service
`docker service create --publish 5601:5601 --name kibana --network elastic meetup/kibana:4.6.1 /home/kibana/bin/start-kibana.sh -s esmaster`

*Note: To ensure proper logging of topbeat information, Kibana must be fully initialized before topbeat data is sent to 
Elasticsearch The following is a snippet of a log generated by Kibana upon a successful start.*

```
{"_index":".kibana","_type":"index-pattern","_id":"winlogbeat-*","_version":1,"_shards":{"total":2,"successful":2,"failed":0},"created":true}
{"type":"log","@timestamp":"2016-10-24T18:50:12Z","tags":["status","plugin:kibana@1.0.0","info"],"pid":349,"state":"green","message":"Status changed from uninitialized to green - Ready","prevState":"uninitialized","prevMsg":"uninitialized"}
{"type":"log","@timestamp":"2016-10-24T18:50:12Z","tags":["status","plugin:elasticsearch@1.0.0","info"],"pid":349,"state":"yellow","message":"Status changed from uninitialized to yellow - Waiting for Elasticsearch","prevState":"uninitialized","prevMsg":"uninitialized"}
{"type":"log","@timestamp":"2016-10-24T18:50:12Z","tags":["status","plugin:marvel@2.4.0","info"],"pid":349,"state":"yellow","message":"Status changed from uninitialized to yellow - Waiting for Elasticsearch","prevState":"uninitialized","prevMsg":"uninitialized"}
{"type":"log","@timestamp":"2016-10-24T18:50:12Z","tags":["status","plugin:kbn_vislib_vis_types@1.0.0","info"],"pid":349,"state":"green","message":"Status changed from uninitialized to green - Ready","prevState":"uninitialized","prevMsg":"uninitialized"}
{"type":"log","@timestamp":"2016-10-24T18:50:12Z","tags":["status","plugin:markdown_vis@1.0.0","info"],"pid":349,"state":"green","message":"Status changed from uninitialized to green - Ready","prevState":"uninitialized","prevMsg":"uninitialized"}
{"type":"log","@timestamp":"2016-10-24T18:50:12Z","tags":["status","plugin:metric_vis@1.0.0","info"],"pid":349,"state":"green","message":"Status changed from uninitialized to green - Ready","prevState":"uninitialized","prevMsg":"uninitialized"}
{"type":"log","@timestamp":"2016-10-24T18:50:13Z","tags":["status","plugin:spyModes@1.0.0","info"],"pid":349,"state":"green","message":"Status changed from uninitialized to green - Ready","prevState":"uninitialized","prevMsg":"uninitialized"}
{"type":"log","@timestamp":"2016-10-24T18:50:13Z","tags":["status","plugin:statusPage@1.0.0","info"],"pid":349,"state":"green","message":"Status changed from uninitialized to green - Ready","prevState":"uninitialized","prevMsg":"uninitialized"}
{"type":"log","@timestamp":"2016-10-24T18:50:13Z","tags":["status","plugin:table_vis@1.0.0","info"],"pid":349,"state":"green","message":"Status changed from uninitialized to green - Ready","prevState":"uninitialized","prevMsg":"uninitialized"}
{"type":"log","@timestamp":"2016-10-24T18:50:13Z","tags":["status","plugin:marvel@2.4.0","info"],"pid":349,"state":"green","message":"Status changed from yellow to green - Marvel ready","prevState":"yellow","prevMsg":"Waiting for Elasticsearch"}
{"type":"log","@timestamp":"2016-10-24T18:50:13Z","tags":["status","plugin:elasticsearch@1.0.0","info"],"pid":349,"state":"green","message":"Status changed from yellow to green - Kibana index ready","prevState":"yellow","prevMsg":"Waiting for Elasticsearch"}
{"type":"log","@timestamp":"2016-10-24T18:50:13Z","tags":["listening","info"],"pid":349,"message":"Server running at http://0.0.0.0:5601"}
```  

The log is retrieved through the use of the `docker logs` command:

`docker logs -f <container id>`

where container id is the id of the Kibana container.

#### Elasticsearch Worker Node Service
The Elasticsearch worker node service demonstrates adding supplemental nodes to the Elasticsearch cluster.  Unlike
the master node service, the worker node container deployments do not publish a port through the Docker Swarm Routing Mesh.  This
is simply for providing an example as to how containers can interoperate with each other and yet have a level of
restricted access to an eternal network.  

`docker service create --replicas 2 --name esnode --network elastic --mount type=bind,source=/opt/esdata,destination=/home/elastic/data meetup/elasticsearch:2.4.1 /home/elastic/bin/start-elasticsearch.sh -m 2`

The Elasticsearch worker node service can also be used to try out scaling Docker services via the `docker service scale` command.  In the
above example, the Elasticsearch worker node service is started with 2 replicas (container instances).  To have the Swarm scale that out to 4, the
following command can be used:

`docker service scale esnode=4`

### The Sample Application Services

In order to effectively demonstrate the use of Topbeat to report a combination of data from containers and host VMs, constraints
are specified in the two `docker service create` commands displayed below.  The constraints are used to ensure that the
service containers are instantiated on nodes that meet the criteria.  The containts used in this example are based on Docker Engine
labels.  Documentation on assigning labels to Docker Engines and other Docker components can be found on the Docker documentation site (https://docs.docker.com/).
If you are running in a single node Swarm, you can either remove the `constraint` parameter from the `docker service create` command or
add both Docker Engine labels to the single instance of the Docker Engine on which you are running these examples.     

#### MySQL Service
`docker service create --name mysql --network database --env ES_SERVER=<IP address> --env MYSQL_ROOT_PASSWORD=mysqlroot --constraint engine.labels.meetup.node==mysql meetup/mysql:5.7`

*Note: The IP address is the IP address of the virtual machine on which the any of the Docker Engines participating in the Swarm is running.*

#### Wordpress Service
`docker service create --name wordpress --network database --publish 80:80 --env ES_SERVER=<IP address> --env WORDPRESS_DB_PASSWORD=mysqlroot --mount type=bind,source=/opt/wordpress,destination=/var/www/html --constraint engine.labels.meetup.node==wordpress meetup/wordpress:php5.6`

*Note: The IP address is the IP address of the virtual machine on which the any of the Docker Engines participating in the Swarm is running.*  

Similar to Elasticsearch service creation, the Wordpress service creation specifies a `mount` parameter.  This is used as another example for storing
application data external to a container.  However, for the Wordpress service, there is a caveat.  Using this confoguration, the Wordpress service
can be scaled using the `docker service scale` command similar to the Elasticsearch worker node service described above.  Due to the simplicity of this sample
configuration, all running Wordpress containers must point to the same data directory.  Therefore, either the mount point used in the sample
command `/opt/wordpress` must be a shared (e.g. NFS or Samba) mounted directory across all Docker Engine host VMs, or the Docker Engine label used
as a constraint in starting the Wordpress service must be assigned to only one Docker Engine.  Once again, this would not be done in a production environment.  It's used
solely to demonstrate container scaling and externalizing application data. 

## Exposed URLs
After having deployed the services, you will find the applications at the following URLs:
* Elasticsearch: `http://<IP address>:9200/`
* Kibana: `http://<IP address>:5601/`
* Wordpress: `http://<IP address>/`

*Note: The IP address is the IP address of the virtual machine on which the any of the Docker Engines participating in the Swarm is running.*

## Topbeat on the Host VMs
The containers built in the demonstration report process statistics to Elasticsearch, which are then displayed through Kibana.  This is automatically configured as part of the container instantiation process.  During the demonstration, the host virtual machines running the Docker Engine were reporting system-wide data.  This requires that Topbeat be installed and configured on the host virtual machine.  The following describes a basic process to install and configure Topbeat to work in conjunction with the demonstration Docker containers.

1. Download Topbeat: https://download.elastic.co/beats/topbeat/topbeat-1.3.1-x86_64.tar.gz
1. Untar the file. The directory created will be named ```topbeat-1.3.1-x86_64```
1. Change into the newly created directory and open the file ```topbeat.yml``` for editing
1. Change ```process: true``` to ```process: false```
1. Under the ```output -> elasticsearch```, edit the ```hosts``` array. The entry should point to the Elasticsearch port (9200) exposed through the Docker Swarm.  The IP address will be that of a system hosting a Docker Engine participating in the Swarm.  A sample entry looks as follows: ```hosts: ['192.168.31.110:9200']```
1. Topbeat can then be started using the following command: ```./topbeat -e -c topbeat.yml``` *Do not start this process until Elasticsearch and Kibana have been initialized.  Doing so will create problems in the Topbeat mapping.*
