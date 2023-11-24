resource "null_resource" "vscode-config" {
  depends_on = [time_sleep.wait_for_instance]


  connection {
    type        = "ssh"
    host        = aws_instance.ubuntu.public_ip
    user        = "ubuntu"
    password    = ""
    private_key = file("C:/Users/nahbu/OneDrive/Documents/ansible-key.pem")
  }

  #provisioner "remote-exec" {
    #script = "script.sh"
  #}

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }
  provisioner "remote-exec" {

     inline = [
    "chmod +x /tmp/script.sh",
    "sudo sed -i -e 's/\r$//' /tmp/script.sh", # Remove the spurious CR characters.
    "sudo /tmp/script.sh"
  ]
   
  }

  provisioner "local-exec" {
    command = templatefile("${var.os}-ssh-script.tpl", {
      hostname     = aws_instance.ubuntu.public_ip
      user         = "ansible",
      IdentityFile = "C:/Users/nahbu/OneDrive/Documents/ansible-key.pem"
    })
    interpreter = var.os == "windows" ? ["powershell", "-Command"] : ["bash", "-c"]
  }
}

resource "time_sleep" "wait_for_instance" {
  create_duration = "180s"

  depends_on = [aws_instance.ubuntu]
}
