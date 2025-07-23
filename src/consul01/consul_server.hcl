datacenter = "dc1"
node_name = "consul-server"                      
server = true                    
bootstrap_expect = 1     
bind_addr = "0.0.0.0"            
advertise_addr = "{{ GetInterfaceIP \"eth1\" }}"  
client_addr = "0.0.0.0"          
ui = true                     