

# CREATION DU GROUPE DE RESSOURCES, DU LOAD BALANCER ET DES MACHINES VIRTUELLES AINSI QUE CE DONT ILS ONT BESOIN (Réseau, sous réseau, pool d'adresses, etc.)


# Créer un groupe de ressources dans la zone canada central
az group create -n TP1Deploiement -l canadacentral

# Créer un réseau virtuel sur le groupe de ressources précédent avec l'adresse réseau 10.0.0.0 et un masque de 16 bits
az network vnet create -g TP1Deploiement -n ReseauVirtuelTP1 -l canadacentral --address-prefixes 10.0.0.0/16

# Créer un sous-réseau de notre réseau virtuel avec les adresses 10.0.1.0 combinées au masque /24
az network vnet subnet create -g myResourceGroup -n SousReseauTP1 -vnet-name ReseauVirtuelTP1 --address-prefixes 10.0.1.0/24

# Créer un load balancer avec allocation dynamique des adresses ip
az network lb create -g TP1Deploiement -n LoadBalancerTP1 -l canadacentral --frontend-ip-configs name=FrontendIPConfigTP1 --public-ip-address-allocation Dynamic

# Créer un pool d'adresses back-end sur notre LB
az network lb backend-address-pool create -g TP1Deploiement -n BackendPoolTP1 -lb-name LoadBalancerTP1

# Créer une sonde d'intégrité ou Probe pour notre LB
az network lb probe create -g TP1Deploiement -n ProbeTP1 -lb-name LoadBalancerTP1 --protocol Tcp --port 80 --interval 15 --timeout 5 --unhealthy-threshold 2 --healthy-threshold 2

# Créer une règle de load balancing sur notre LB
az network lb rule create -g TP1Deploiement -n LBRuleTP1 -lb-name LoadBalancerTP1 --frontend-ip-config-name FrontendIPConfigTP1 --backend-address-pool-name BackendPoolTP1 --protocol Tcp --port 80 --probe-name ProbeTP1

# Créer la première machine virtuelle
az vm create -g TP1Deploiement -n VM1TP1 --location canadacentral --size Standard_B2s --image UbuntuLTS --public-ip-address 10.0.1.1 --network-interface-name NetInc1TP1 --subnet SousReseauTP1 --admin-username admin --admin-password admin

# Créer la deuxième machine virtuelle
az vm create -g TP1Deploiement -n VM2TP2 --location canadacentral --size Standard_B2s --image UbuntuLTS --public-ip-address 10.0.1.2 --network-interface-name NetInc2TP1 --subnet SousReseauTP1 --admin-username admin --admin-password admin

# Ajouter les machines virtuelles au pool d'adresses back-end créé précédemment
az network lb backend-address-pool address add -g TP1Deploiement -n BackendPoolTP1 -lb-name LoadBalancerTP1 --ip-address VM1TP1 --ip-config-name NetInc1TP1
az network lb backend-address-pool address add -g TP1Deploiement -n BackendPoolTP1 -lb-name LoadBalancerTP1 --ip-address VM2TP2 --ip-config-name NetInc2TP1

# Créer un groupe de machines virtuelles avec des zones de déploiement
az vmss create -g TP1Deploiement -n ScaleSetTP1 --location canadacentral --sku Standard_B2s --image UbuntuLTS --zones 1 2 3 --upgrade-policy Automatic --admin-username admin --admin-password admin --network-interface-name NetIncTP1 --subnet SousReseauTP1 --autoscale-setting-name AutoscaleSettingTP1

# Créer un profil d'autoscaling
az monitor autoscale-setting create -g TP1Deploiement -n AutoscaleSettingTP1 --resource-type virtualMachineScaleSets --target-resource-id /subscriptions/77cf95a5-2236-4e63-be8d-d407dfbc714e/resourcegroups/TP1Deploiement/providers/microsoft.compute/virtualmachinescalesets/ScaleSetTP1 --location canadacentral --min-count 1 --max-count 10 --scale-rule-name ScaleRuleTP1 --profile-name AutoScalingProfileTP1 --time-grain 5 --cooldown 15 --enabled true

# Créer une règle sur notre profil pour la mise à l'échelle des VM
az monitor autoscale-setting rule create -g TP1Deploiement -n ScaleRuleTP1 --autoscale-setting-name AutoscaleSettingTP1 --metric-name PercentProcessorTime --metric-namespace Microsoft.Compute/virtualMachines --metric-resource-uri /subscriptions/77cf95a5-2236-4e63-be8d-d407dfbc714e/resourcegroups/TP1Deploiement/providers/microsoft.compute/virtualmachinescalesets/ScaleSetTP1 --time-aggregation Average --operator GreaterThan --threshold 50 --cooldown 15 --direction Increase --scale-action-type ChangeCount --scale-action-value 1
