# Fedota Infrastructure

This contains detailed instructions and explanation to setup and run the Fedota infrastructure.

## Contents

- [Overview](#overview)
- [Setup](#setup)
	- [NFS](#nfs)
	- [FL Webserver](#fl-webserver)
- [Resources](#resources)


## Overview

```<Diagram here>```

```Brief Overview```


## Setup
Instruction to setup the fedota infrastructure

### NFS
NFS service need to be exposed to the k8s cluster. 
- This can be in a [manual way](https://blog.exxactcorp.com/deploying-dynamic-nfs-provisioning-in-kubernetes/), provisioned by a cloud provider, OR
- Use the `nfs-serive.yaml` manifest to run a nfs server as a container (by [erichough/nfs-server](https://github.com/ehough/docker-nfs-server)) on a pod which requires the following:

<image src="diagrams/nfs.png">

1. On the node where the pod would be running, create a directory `data`
2. Make sure that the node has `nfs`, `nfsd` kernel modules available. Manually enable them using `modprobe {nfs,nfsd}`
3. The manifest mounts this directory to the nfs container and also requires the an argument to the docker image to let the nfs server know we are sharing this directory (passed as NFS_EXPORT_0)
4.
	```
	kubectl create -f nfs-service.yaml
	
	# check status to be running and svc to be up
	kubectl get pod nfs-server-pod
	kubectl get svc nfs-service
	```

Next, create the Persistent Volume(PV) using NFS and the Persistent Volume Claim (PVC)
```
kubectl create -f nfs-pv.yaml
kubectl get pv nfs-pv # should be available

kubectl create -f nfs-pvc.yaml

# check; should be bound
kubectl get pv nfs-pv
kubectl get pvc nfs-pvc 
```

[Optional] Run a test nfs pod to check if NFS service, pv and pvc work
```
kubectl create -f nfs-test-pod.yaml

# check
kubectl get pod nfs-test-pod # should be running

# Both should print the same values
kubectl exec -it nfs-test-pod sh
	> cat /nfs/dates.txt
kubectl exec -it nfs-server-pod sh
	> cat /data/dates.txt
```
### Troubleshooting

If `nfs-test-pod` fails with nfs-service dns resolution issue check, this could be due to problems with the distribution 
- https://github.com/kubernetes/minikube/issues/2218#issuecomment-436821733
- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/#known-issues

### Debugging

Use the following to get logs and to describe the objects create
```
kubectl logs <pod-name>
kubectl describe <pod/svc/pv..> <name>

# for a running pod
kubectl logs nfs-server-pod
# generally
kubectl describe pod nfs-test-pod
```

### FL Webserver



## Resources

### Shared File storage structure
For each FL problem, FL coordinator and selectors use the `<fl_problem_id>` directory
```
\data
	\<fl_problem_id> 
		\initFiles
			fl_checkpoint <- RW 
			model.h5 <- R
		\<selector-id>
			fl_agg_checkpoint <- R
			fl_agg_checkpoint_weight <- R
			.
			.
		.
		.
		.
```

