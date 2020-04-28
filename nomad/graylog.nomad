job "graylog" {
  datacenters = ["dc1"]
  type        = "service"

  group "graylog" {
    count = 1

    task "mongo" {
      driver = "docker"
      config {
        image = "mongo:3"
        port_map { db = 27017 }
      }
      resources {
        network {
          port "db" { static = 27017 }
        }
      }
      service {
        name = "graylog-db"
        tags = ["db", "mongo"]
        port = "db"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    task "elastic" {
      driver = "docker"
      config {
        image = "docker.elastic.co/elasticsearch/elasticsearch-oss:6.8.5"
        port_map { es_http = 9200 }
      }
      env {
        "http.host" = "0.0.0.0"
        "ES_JAVA_OPTS" = "-Xmx512m -Xms512m"
      }
      resources {
        memory = 1024
        network {
          port "es_http" { static = 9200 }
        }
      }
      service {
        name = "graylog-es"
        tags = ["elasticsearch"]
        port = "es_http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    task "graylog" {
      driver = "docker"
      config {
        image = "graylog/graylog:3.2"
        port_map { graylog_http = 9000 }
      }
      env {
        "ES_JAVA_OPTS" = "-Xmx512m -Xms512m"
        "GRAYLOG_HTTP_EXTERNAL_URI" = "http://${NOMAD_ADDR_graylog_http}/"
        "GRAYLOG_HTTP_PUBLISH_URI" = "http://${NOMAD_ADDR_graylog_http}/"
        "GRAYLOG_ELASTICSEARCH_HOSTS" = "http://${NOMAD_ADDR_elastic_es_http}"
        "GRAYLOG_MONGODB_URI" = "mongodb://${NOMAD_ADDR_mongo_db}/graylog"
        "GRAYLOG_IS_MASTER" = "true"
      }
      resources {
        memory = 1024
        network {
          port "graylog_http" { static = 9000 }
        }
      }
      service {
        name = "graylog-app"
        tags = ["graylog"]
        port = "graylog_http"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
