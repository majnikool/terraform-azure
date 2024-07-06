# Rancher Setup on Azure Kubernetes Service (AKS)

This guide outlines the process of setting up Rancher on an Azure Kubernetes Service (AKS) cluster using Terraform, Nginx Ingress, TLS, and OIDC Workload Identity.

## Prerequisites

- Azure CLI
- Terraform
- Helm
- kubectl
- Certbot
- A domain name you control

## 1. Create AKS Cluster using Terraform

```bash
az login
az account list
az account set --subscription <id>
terraform init
terraform apply
az aks get-credentials --resource-group tutorial --name dev-demo
```

## 2. Obtain a Wildcard SSL Certificate

### Install Certbot

On macOS:

```bash
brew install certbot
```

### Obtain the Certificate

#### Automated DNS Challenge (Cloudflare Example)

1. Install Certbot DNS plugin for Cloudflare:

   ```bash
   pip3 install certbot certbot-dns-cloudflare
   ```

2. Create a Cloudflare API token with `Zone.DNS` edit permissions.

3. Save Cloudflare API Token:

   ```bash
   mkdir -p ~/.secrets/certbot
   echo "dns_cloudflare_api_token = YOUR_CLOUDFLARE_API_TOKEN" > ~/.secrets/certbot/cloudflare.ini
   chmod 600 ~/.secrets/certbot/cloudflare.ini
   ```

4. Run Certbot:

   ```bash
   sudo certbot certonly \
     --dns-cloudflare \
     --dns-cloudflare-credentials ~/.secrets/certbot/cloudflare.ini \
     -d "*.yourdomain.com" -d yourdomain.com
   ```

#### Manual DNS Challenge

1. Run Certbot:

   ```bash
   sudo certbot certonly --manual --preferred-challenges dns -d "*.yourdomain.com" -d yourdomain.com
   ```

2. Follow instructions to add the DNS TXT record.
3. Complete the verification process.

## 3. Create Kubernetes Secrets

```bash
# Create namespace for Rancher
kubectl create namespace cattle-system

# Create TLS secret for Rancher ingress
sudo kubectl -n cattle-system create secret tls tls-rancher-ingress \
  --cert=/etc/letsencrypt/live/yourdomain.com/fullchain.pem \
  --key=/etc/letsencrypt/live/yourdomain.com/privkey.pem

# Create wildcard TLS secret
sudo kubectl -n ingress create secret tls tls-wildcard \
  --cert=/etc/letsencrypt/live/yourdomain.com/fullchain.pem \
  --key=/etc/letsencrypt/live/yourdomain.com/privkey.pem
```

## 4. Configure DNS

1. Get the ingress service's public IP:

   ```bash
   kubectl get svc -n ingress
   ```

2. Copy the EXTERNAL-IP for `external-ingress-nginx-controller`.
3. Update your DNS record for `yourdomain.com` with this IP.
4. Verify DNS mapping:

   ```bash
   nslookup yourdomain.com
   ```

5. Test without changing DNS (replace IP with your ingress IP):

   ```bash
   curl --resolve "yourdomain.com:443:4.152.199.255" https://yourdomain.com/
   ```

## 5. Install Rancher

```bash
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update

helm install rancher rancher-stable/rancher \
  --namespace cattle-system \
  --set ingress.tls.source=secret \
  --set hostname=yourdomain.com \
  --set replicas=1 \
  --set bootstrapPassword="yourrancherpassword"
```

### Troubleshooting Kubernetes Version Compatibility

If your Kubernetes version is too recent for the Rancher version:

1. Download the chart locally:

   ```bash
   helm fetch rancher-stable/rancher --version=v2.8.5
   tar -xvf rancher-2.8.5.tgz
   ```

2. Edit `Chart.yaml`:

   ```bash
   vi Chart.yaml
   ```

3. Change `kubeVersion` to match your Kubernetes version (e.g., `kubeVersion: 1.29.5`).

4. Install the locally updated version:

   ```bash
   helm install rancher ./rancher \
     --namespace cattle-system \
     --set ingress.tls.source=secret \
     --set hostname=yourdomain.com \
     --set replicas=1 \
     --set bootstrapPassword="yourrancherpassword"
   ```

## 6. Examples

The `k8s` directory contains examples for various Kubernetes features. Here's how to use them:

### Create Public and Private Load Balancers

```bash
kubectl apply -f k8s/1-example
kubectl get svc
curl http://<ip>/
```

### Auto-Scaling

```bash
kubectl get nodes
kubectl apply -f k8s/2-example
kubectl get pods
kubectl describe pods nginx-v2-788b5579fd-dmbg8
kubectl get pods
kubectl get nodes
```

### Create an Ingress using Nginx Ingress

```bash
kubectl get svc -n ingress
kubectl apply -f k8s/3-example
kubectl get pods
kubectl get ing
curl --resolve "echo.antonputra.pvt:80:20.96.71.30" http://echo.antonputra.pvt/
```

### Secure the Ingress with TLS & Cert-manager

```bash
kubectl apply -f k8s/4-example
kubectl get pods
kubectl get ing
kubectl get Certificate
kubectl describe Certificate
kubectl describe CertificateRequest
kubectl describe Order
kubectl describe Challenge
kubectl get ing
kubectl get Certificate
dig echo.devopsbyexample.com
kubectl get ing
```

### Test Workload Identity

```bash
kubectl apply -f k8s/5-example
kubectl get pods -n dev
kubectl exec -it azure-cli-c97fd4f7c-rp2mc -n dev -- sh
az login --federated-token "$(cat $AZURE_FEDERATED_TOKEN_FILE)" --service-principal -u $AZURE_CLIENT_ID -t $AZURE_TENANT_ID
az storage blob list -c test --account-name devtest2392919
kubectl delete -f k8s/5-example
```

