## Getting started

```
aws_okta_profile=blah-engineer
aws-okta exec $aws_okta_profile -- terraform apply -target=module.stack -auto-approve
aws-okta exec $aws_okta_profile -- terraform apply -target=local_file.providers -auto-approve
aws-okta exec $aws_okta_profile -- terraform apply -auto-approve

aws-okta exec $aws_okta_profile -- kubectl --kubeconfig kubeconfig get deployments -A
```