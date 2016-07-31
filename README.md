# docker-topbeat

The contents of this repository contain the artifacts used during the Atlanta, GA Elastic Meetup on July 26, 2016 (https://www.meetup.com/Atlanta-Elastic-Fantastics/events/232388156/).  The title of the event was **Using Elasticsearch to Help Monitor Docker Containers**.

The Meetup introduction read as follows:
___
Most often, when Elasticsearch and Docker are part of the same discussion, the topic focuses on running Elasticsearch as a Docker container.  This session will explore these two technologies in a manner that's a bit outside this typical Elasticsearch and Docker discussion and look at how Elasticsearch combined with Beats can be used to assist in monitoring and reporting Docker container activity.


Through examples and demonstrations, the presentation will walk through the configuration of an example Docker multi-container application with each container and Docker host reporting statistics to Elasticsearch via Beats.  Areas of discussion include:


1. A quick introduction to Docker; how to get and install it

2. Review of the Beats used to monitor a Docker container

3. Introducing Dockerfiles and how Docker images are built

4. Running a process in a Docker container and have statistics reported by the Beats to Elasticsearch

5. Introduce Docker Compose to build a multi-container application with each container reporting statistics to Elasticsearch

6. Discuss the configuration of Elasticsearch, Kibana and Beats as it relates to the Docker hosts and containers
---

During the presentation several artifacts were used when building images.  These were copied from the ```build/distribution``` sub-directory in each respective ```dockerfiles``` directory.  Due to size, and in some cases license considerations, these files are not include in this repository.  Rather a ```README.md``` is included in the ```build/distribution``` sub-directories indicating the files to include in the directory and the location from which the files can be downloaded.
___
## Quick Start
The following describes the build order and commands used during the presentation.  Building the images, and running ```docker-compose``` in the order below should ensure a successful startup of all containers and applications.  Documentation on Dockerfiles, Docker Compose YMLs, and Docker commands in general can be found at https://docs.docker.com/.

### Image Build Order

**Customized CentOS image:**  
```cd dockerfiles/centos```  
```docker build --tag esmeetup/centos:7.07262106 .```

**Elasticsearch image:**  
```cd dockerfiles/elasticsearch```  
```docker build --tag esmeetup/elasticsearch:1.7.1 .```

**Kibana image:**  
```cd dockerfiles/kibana```  
```docker build --tag esmeetup/kibana:4.1.6 .```

**Customized MySQL/MariaDB image:**  
```cd dockerfiles/mysql```  
```docker build --tag esmeetup/mysql:latest .```

**Customized Wordpress image:**  
```cd dockerfiles/wordpress```  
```docker build --tag esmeetup/wordpress:latest .```

### Docker Compositions

**Elastic stack**  
```cd compose/es-kibana```  
```docker-compose up -d```  
```docker-compose logs``` (to view startup logs)

```docker-compose stop``` (will stop the containers referenced in the current directory's ```docker-compose.yml```)  
```docker-compose rm``` (will remove the containers referenced in the current directory's ```docker-compose.yml```)

**Wordpress**  
```cd compose/wordpress```  
```docker-compose up -d```  
```docker-compose logs``` (to view startup logs)


```docker-compose stop``` (will stop the containers referenced in the current directory's ```docker-compose.yml```)  
```docker-compose rm``` (will remove the containers referenced in the current directory's ```docker-compose.yml```

### Expose URLs
After having start both the Elastic and Wordpress compositions, you will find the applications at the following URLs:
* Elasticsearch: `http://<IP address>:9200/`
* Marvel: `http://<IP address>:9200/_plugin/marvel/`
* Kibana: `http://<IP address>:5601/`
* Wordpress: `http://<IP address>/`

*Note: The IP address is the IP address of the virtual machine on which the Docker Engine is running.*

### Topbeat on the Host VM
The containers built in the demonstration report process statistics to Kibana.  This is automatically configured as part of the container instantiation process.  During the demonstration, the host virtual machine running the Docker Engine was reporting system-wide data.  This requires that Topbeat be installed and configured on the host virtual machine.  The following describes a basic process to install and configure Topbeat to work in conjunction with the demonstration Docker containers.

1. Download Topbeat: https://download.elastic.co/beats/topbeat/topbeat-1.2.3-x86_64.tar.gz
1. Untar the file. The directory created will be named ```topbeat-1.2.3-x86_64```
1. Change into the newly create directory and open the file ```topbeat.yml``` for editing
1. Change ```process: true``` to ```process: false```
1. Under the ```output -> elasticsearch```, edit the ```hosts``` array. The entry should point to the Elasticsearch API port exposed through Docker.  The IP address will be that of the host virtual machine.  The port will be 9200.  A sample entry looks as follows: ```hosts: ['172.16.120.110:9200']```
1. Topbeat can then be started using the following command: ```./topbeat -e -c topbeat.yml``` *Do not start this process until Elasticsearch and Kibana have been initialized.  Doing so will create problems in the Topbeat mapping.*
