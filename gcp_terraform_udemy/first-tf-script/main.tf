resource "local_file" "name" {
  filename = "sample.txt"
  content  = "I Love Terraasdasdasform"

  lifecycle {
    #prevent_destroy = true
  }

}

resource "random_string" "name1" {
  length = 10

}
