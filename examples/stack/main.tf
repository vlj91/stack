resource "random_pet" "name" {}

module "stack" {
  source = "../../"

  name = random_pet.name.id
}

resource "local_file" "providers" {
  filename        = "${path.module}/tf-providers.tf"
  content         = module.stack.providers
  file_permission = 0644
}

module "addons" {
  source = "../../addons"

  stack_name  = module.stack.name
  oidc_issuer = module.stack.oidc_issuer
}

module "hello" {
  source = "../../external-service"

  cluster        = module.stack.name
  name           = "hello"
  image          = "paulbouwer/hello-kubernetes:1.8"
  container_port = 8080
}