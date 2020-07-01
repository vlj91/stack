## Getting started

The example assumes the use of aws-okta for AWS authentication. It also assumes the `jq` tool is installed.

```
aws_okta_profile=<your aws-okta profile>
aws-okta exec $aws_okta_profile -- terraform apply -target=module.stack -auto-approve
aws-okta exec $aws_okta_profile -- terraform apply -target=local_file.providers -auto-approve
aws-okta exec $aws_okta_profile -- terraform apply -auto-approve

aws-okta exec $aws_okta_profile -- kubectl --kubeconfig kubeconfig get deployments -A

# go to our hello service
open "http://$(aws-okta exec $aws_okta_profile -- kubectl --kubeconfig kubeconfig get service -n default -o json | jq -r '.items[0].status.loadBalancer.ingress[0].hostname')"
```