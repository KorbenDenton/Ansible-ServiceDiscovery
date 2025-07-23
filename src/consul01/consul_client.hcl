datacenter = "dc1"
server = false
bind_addr = "0.0.0.0"
advertise_addr = "{{ GetInterfaceIP \"eth1\" }}"
retry_join = ["192.168.56.12"]  #IP consul_server
client_addr = "0.0.0.0"