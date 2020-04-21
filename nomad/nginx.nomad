job "web" {
  datacenters = ["dc1"]
  type        = "service"

  update {
    max_parallel = 2
    stagger      = "30s"
  }

  group "frontend" {
    count = 3

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:1.16"

        port_map {
          http = 80
        }

        mounts = [{
          type     = "bind"
          target   = "/etc/nginx/conf.d"
          source   = "/data/nginx"
          readonly = false
        }]
      }

      resources {
        network {
          port "http" {
            static = 80
          }
        }
      }

      service {
        name = "nginx"
        tags = ["http"]
        port = "http"

        check {
          type     = "http"
          path     = "/status"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
