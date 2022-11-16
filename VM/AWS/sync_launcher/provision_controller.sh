sudo apt update
sudo apt upgrade -y
sudo apt install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt update
sudo apt install ansible -y
sudo apt install sshpass -y
sudo apt install tree -y
sudo rm /etc/ansible/hosts && sudo cp sync_controller/hosts /etc/ansible/hosts
sudo cp sync_controller/main.yml /etc/ansible/main.yml
