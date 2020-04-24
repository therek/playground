# Prometheus playgroud

## Usage

This playground is prepared to be run in Docker containers
with `docker-compose` command. There are two steps to start
up this environment. 

First, you need to start Cassadra. It takes a while before
it becomes accessible, and without Cassandra running Cortex
will fail on startup.

    docker-compose up -d cassandra; docker-compose logs -f cassandra

Check logs for similar entry

    MigrationManager.java:495 - Drop Keyspace 'cortex'
    MigrationManager.java:338 - Create new Keyspace: KeyspaceMetadata{name=cortex, params=KeyspaceParams(...)}

Then you can start the remaining containers:

    docker-compose up -d

## Links

* Blackbox Exporter - http://localhost:9115/
* Cassandra Exporteer - http://localhost:8080/
* Cortex - http://localhost:9009/
* Grafana - http://localhost:3000/
* Prometheus - http://localhost:9090/
