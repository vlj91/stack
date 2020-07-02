# `stack`

This repository is a set of modules which can be used to configure Kubernetes clusters as well as some of the surrounding features such as ingress controllers and Prometheus.

## Quickstart

To get started, define a simple cluster module:

```hcl
module "stack" {
  source = "github.com/vlj91/stack"

  name = "mycluster"
}
```

You'll then need to:

```
terraform apply -target=module.stack
```

From the `stack` module, you will receive the following:

- A VPC with private, public and database subnets
- An AWS EKS cluster with compute nodes
- A private Route53 zone

You can then make use of the other modules available in this repository to form a more complete cluster. An example of this can be found in `examples/stack`.

**Note**: You'll need to run the apply against the `stack` module prior to working with any addon modules etc. in order to generate working `kubernetes` and `helm` provider configuration.

## Requirements

- `kubectl`
- `helm`
- `jq`
- `aws-okta` installed and configured *optional*