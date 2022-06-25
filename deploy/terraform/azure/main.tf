variable "input_hello" {
  default = "Hello World!"
}

output "output_hello" {
  value = var.input_hello
}