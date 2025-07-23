datacenter = "dc1"
node_name = "consul-server"                      
server = true                    
bootstrap_expect = 1  
data_dir = "/opt/consul"   
bind_addr = "0.0.0.0"            
advertise_addr = "{{ GetInterfaceIP \"enp0s8\" }}"  
client_addr = "0.0.0.0"          
ui = true                     

ports {
  grpc = 8502  # Обязательно для xDS API
}

connect {
  enabled = true  # Включаем Service Mesh
}

enable_central_service_config = true  # Для управления сервисами
