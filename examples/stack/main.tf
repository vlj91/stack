resource "random_pet" "name" {}

module "stack" {
  source = "../../"

  name = random_pet.name.id
}