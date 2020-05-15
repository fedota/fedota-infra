# kubectl delete -f .\nfs-test-pod.yaml
# kubectl delete -f .\nfs-service.yaml
# kubectl delete -f .\nfs-pvc.yaml
# kubectl delete -f .\nfs-pv.yaml

kubectl create -f .\nfs-service.yaml
kubectl create -f .\nfs-pv.yaml
kubectl create -f .\nfs-pvc.yaml
kubectl create -f .\nfs-test-pod.yaml
