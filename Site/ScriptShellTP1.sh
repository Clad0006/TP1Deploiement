

# CREATION DU GROUPE DE RESSOURCES, DU LOAD BALANCER ET DES MACHINES VIRTUELLES AINSI QUE CE DONT ILS ONT BESOIN (Réseau, sous réseau, pool d'adresses, etc.)


# Créer un groupe de ressources dans la zone canada central
az group create -n TP1Deploiement -l canadacentral

# Créer un réseau virtuel sur le groupe de ressources précédent avec l'adresse réseau 10.0.0.0 et un masque de 16 bits
az network vnet create -g TP1Deploiement -n ReseauVirtuelTP1 -l canadacentral --address-prefixes 10.0.0.0/16

# Créer un sous-réseau de notre réseau virtuel avec les adresses 10.0.1.0 combinées au masque /24
az network vnet subnet create -g TP1Deploiement -n SousReseauTP1 --vnet-name ReseauVirtuelTP1 --address-prefixes 10.0.1.0/24

# Créer un load balancer avec allocation dynamique des adresses ip
az network lb create -g TP1Deploiement -n LoadBalancerTP1 -l canadacentral --public-ip-address-allocation Static

# Créer un pool d'adresses back-end sur notre LB
az network lb address-pool create -g TP1Deploiement -n BackendPoolTP1 --lb-name LoadBalancerTP1

# Créer une sonde d'intégrité ou Probe pour notre LB
az network lb probe create -g TP1Deploiement -n ProbeTP1 --lb-name LoadBalancerTP1 --protocol Tcp --port 80 --interval 15

# Créer une règle de load balancing sur notre LB
az network lb rule create -g TP1Deploiement -n LBRuleTP1 --lb-name LoadBalancerTP1 --backend-pool-name BackendPoolTP1 --protocol Tcp --frontend-port 80 --backend-port 80 --probe-name ProbeTP1

# Créer un groupe de machines virtuelles avec des zones de déploiement
az vmss create -g TP1Deploiement -n ScaleSetTP1 --location canadacentral --image ubuntu2204 --zones 1 2 3 --upgrade-policy Automatic --admin-username adminuser --admin-password adminuser_password1 --vnet-name NetIncTP1 --subnet SousReseauTP1

# Créer un profil d'autoscaling
az monitor autoscale create -g TP1Deploiement -n AutoscaleSettingTP1 --resource /subscriptions/167fcb55-1d31-4096-90a8-f9e0a30d3853/resourcegroups/TP1Deploiement/providers/microsoft.compute/virtualmachinescalesets/ScaleSetTP1 --location canadacentral --min-count 1 --max-count 10 --count 2

# Créer une règle sur notre profil pour la mise à l'échelle des VM
az monitor autoscale rule create -g TP1Deploiement --autoscale-name AutoscaleSettingTP1 --condition "Percentage CPU > 50 avg 10m" --cooldown 15 --scale out 1
