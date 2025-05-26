# k8s-rebellions

Ubuntu 22.04 기반의 Kubernetes 환경 구축 가이드입니다.

## 1. 이미지 빌드

Ubuntu 22.04 기반의 컨테이너 이미지를 빌드합니다.

```bash
buildctl build --frontend=dockerfile.v0 --local context=. --local dockerfile=. --output type=oci,dest=image.tar,name=k8s-rebel:22.04
```

## 2. containerd 이미지 관리

### 이미지 가져오기

빌드된 이미지를 containerd에 가져옵니다.

```bash
sudo ctr -n k8s.io images import image.tar --debug
```

### 이미지 목록 확인

현재 containerd에 등록된 이미지 목록을 확인합니다.

```bash
sudo ctr -n k8s.io images ls
```

### 네임스페이스 목록 확인

containerd의 네임스페이스 목록을 확인합니다.

```bash
sudo ctr namespace list
```

## 3. Kubernetes 배포

### 컨테이너 배포

모든 노드에 rebellions.ai/ATOM 리소스를 사용하는 컨테이너를 배포합니다.

```bash
kubectl apply -f rebel-device-k8s.yaml
```

### 컨테이너 삭제

배포된 컨테이너를 삭제합니다.

```bash
kubectl delete -f rebel-device-k8s.yaml
```

### Pod 목록 확인

배포된 Pod 목록을 확인합니다.

```bash
kubectl get pods
```

### 컨테이너 접속

특정 Pod의 컨테이너에 접속합니다.

```bash
kubectl exec -it [pod_name] -- bash
```

## 4. 노드별 컨테이너 확인

각 노드(master/worker)에서 실행 중인 컨테이너를 확인합니다.

```bash
kubectl get pods
```
