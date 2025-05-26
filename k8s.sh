#!/bin/bash

# ufw 서비스 중지
echo "**************************************************************"
echo "ufw service stop"
echo "**************************************************************"
sudo systemctl stop ufw

# ufw 서비스 자동 실행 중지
echo "**************************************************************"
echo "disable ufw"
echo "**************************************************************"
sudo systemctl disable ufw

# 부팅 시 swap이 다시 활성화되지 않도록 설정
echo "**************************************************************"
echo "disable swap"
echo "**************************************************************"
sudo swapoff -a
sudo sed -i '/^[^#]*swap/ s/^/#/' /etc/fstab

echo "**************************************************************"
echo "sudo apt update"
echo "**************************************************************"
sudo apt update

# 필수 패키지 설치
echo "**************************************************************"
echo "sudo apt-get install -y apt-transport-https ca-certificates curl gpg vim"
echo "**************************************************************"
sudo apt-get install -y apt-transport-https ca-certificates curl gpg vim

# GPG 키 저장 디렉터리 생성
echo "**************************************************************"
echo "sudo mkdir -p -m 755 /etc/apt/keyrings"
echo "**************************************************************"
sudo mkdir -p -m 755 /etc/apt/keyrings

# Kubernetes GPG 키 등록
echo "**************************************************************"
echo "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg"
echo "**************************************************************"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Kubernetes 공식 리포지토리 추가 1.29 기
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 패키지 목록 업데이트
echo "**************************************************************"
echo "sudo apt-get update"
echo "**************************************************************"
sudo apt-get update

# Kubernetes 주요 패키지 설치
echo "**************************************************************"
echo "sudo apt-get install -y kubelet kubeadm kubectl"
echo "**************************************************************"
sudo apt-get install -y kubelet kubeadm kubectl

# 설치 확인
echo "**************************************************************"
echo "kubectl version --client"
echo "**************************************************************"
kubectl version --client
echo "**************************************************************"
kubeadm version
echo "**************************************************************"
kubelet --version
echo "**************************************************************"

# 버전 고정 (자동 업데이트 방지)
echo "**************************************************************"
echo "sudo apt-mark hold kubelet kubeadm kubectl"
echo "**************************************************************"
sudo apt-mark hold kubelet kubeadm kubectl

# 1. containerd 설치
echo "**************************************************************"
echo "sudo apt install -y containerd"
echo "**************************************************************"
sudo apt install -y containerd

# 2. 기본 설정 파일 생성
echo "**************************************************************"
echo "sudo mkdir -p /etc/containerd"
echo "**************************************************************"
sudo mkdir -p /etc/containerd
echo "**************************************************************"
echo "containerd config default | sudo tee /etc/containerd/config.toml"
echo "**************************************************************"
containerd config default | sudo tee /etc/containerd/config.toml

# 3. Systemd cgroup 사용하도록 설정
echo "**************************************************************"
echo "sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml"
echo "**************************************************************"
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# 4. containerd 재시작 및 부팅 시 자동 실행
echo "**************************************************************"
echo "sudo systemctl restart containerd"
echo "**************************************************************"
sudo systemctl restart containerd
echo "**************************************************************"
echo "sudo systemctl enable containerd"
echo "**************************************************************"
sudo systemctl enable containerd

# 5. br_netfilter 모듈 로드
echo "**************************************************************"
echo "sudo modprobe br_netfilter"
echo "**************************************************************"
sudo modprobe br_netfilter

# 6. 필요한 커널 파라미터 설정
echo "**************************************************************"
echo "cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf"
echo "net.bridge.bridge-nf-call-iptables = 1"
echo "net.bridge.bridge-nf-call-ip6tables = 1"
echo "net.ipv4.ip_forward = 1"
echo "EOF"
echo "**************************************************************"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF


echo "**************************************************************"
echo "sudo sysctl --system"
echo "**************************************************************"
sudo sysctl --system

## config 복사
## master node에서 실행
## worker node에서는 $HOME/.kube/config 내용을 master node에서 복사
echo "**************************************************************"
echo "mkdir -p $HOME/.kube"
echo "**************************************************************"
mkdir -p $HOME/.kube
echo "**************************************************************"
echo "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config"
echo "**************************************************************"
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

## master node에서 실행
## worker node에서는 kubeadm join 명령어 실행
echo "**************************************************************"
echo "kubeadm init"
echo "**************************************************************"
kubeadm init


## buildkit 설치
wget https://github.com/moby/buildkit/releases/latest/download/buildkit-v0.22.0.linux-amd64.tar.gz
tar -xf buildkit-v0.22.0.linux-amd64.tar.gz
sudo mv bin/buildctl /usr/local/bin/
sudo mv bin/buildkitd /usr/local/bin/






## 화면에 나오는 아래 양식 복사
## or kubeadm token create --print-join-command 실행
## kubeadm join 192.168.23.240:6443 --token c4rif2.5ao3immwgxwfybbf --discovery-token-ca-cert-hash sha256:5aeab574791a9a104c2fe14707e7e93e3863e72dc0e9c3a7555fdb5bd2965080