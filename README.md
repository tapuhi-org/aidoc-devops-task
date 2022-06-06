# aidoc-devops-task

## architecture  

1. AWS:
   1. VPC - 10.0.0.0/16
      1. peering with below HVN
   2. EKS 
      1. github action self hosted runner.
      2. consul agents and injector agents 
2. HCP:
   1. HVN - 172.25.32.0/20
   2. CONSUL 
   3. VAULT 
      1. Consul dynamic acl token
      2. k8s auth method 
      

## security considerations
In the task there was a request to expose the consul to public. Still I prefered to use the private endpoints for consul and vault to communicate between them and github actions . That's why I created a self hosted runner in the same VPC (and eks) so it can access the private endpoints.


## What else can be improved 
1. Disable all public HCP endpoints and access everything from the private network 
2. Using atlantis or terraform cloud to prevent the use of unencrypted tokens during terraform run or using ENV variables
3. Instead of using the public endpoints for HCP services using a k8s service with loadbalancer served from withing the VPC exosed through nat-gateway with specific IPs whitelist or leave it in private network and access it through VPN (preffarable)  



