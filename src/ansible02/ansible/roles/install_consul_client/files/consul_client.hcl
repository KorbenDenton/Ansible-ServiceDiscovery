datacenter = "dc1"
data_dir = "/opt/consul"
server = false
bind_addr = "0.0.0.0"
advertise_addr = "{{ GetInterfaceIP \"enp0s8\" }}"
retry_join = ["192.168.56.12"]  #IP consul_server
client_addr = "0.0.0.0"

ports {
  grpc = 8502  # Обязательно для xDS API
}

connect {
  enabled = true  # Включаем Service Mesh
}

enable_central_service_config = true  # Для управления сервисами
