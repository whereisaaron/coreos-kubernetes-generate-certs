# coreos-kubernetes-generate-certs
Script to generate certificates for a kube-aws deployment that last longer than 90 days.

Tested with kube-aws 0.8.1 and OpenSSL 1.0.1f

To use this script, place the files in a folder somewhere, and configure the `OUTFOLDER` to the 'credentials' folder for kube-aws. 
You mush delete or move any existing folder as the script SHOULD not overwrite an existing folder. 
Configure the domain name and IP addresses to match your deployment.
Run the script from the folder were the .cnf files are. 

```
# Org to use in all certs
ORG=kube-aws

# Target folder to copy certs
OUTFOLDER="../credentials/"

# Create configuration api cert -- UPDATE THESE FOR YOUR ENVIRONMENT
export API_DNS_NAME=your.domain.name
export K8S_SERVICE_IP=172.16.0.50
export MASTER_HOST=10.31.0.1
```
