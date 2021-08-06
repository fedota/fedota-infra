# Setup
Instructions to setup the fedota infrastructure

## Requirements
The easiest way to run fedota is by setting up [Kubernetes](https://kubernetes.io/) and following the instruction mentions below. For a local setup, there are instruction in the repositories of individual components each having requirements and usage instructions. 

For setting up Kubernetes, [several options](https://kubernetes.io/docs/setup/) exists. We have used [minikube](https://kubernetes.io/docs/setup/learning-environment/minikube/) during development and testing.


## Webserver and the Client

Setup the webserver as mentioned (https://github.com/fedota/fl-coordinator)

It spawns the containers for coordinator and selector when the FL problem is created
Information about FL infrastructure components can be found here 
- [Coordinator](https://github.com/fedota/fl-coordinator)
- [Selector](https://github.com/fedota/fl-selector)

Currently we have to pass the selector's address as a config to the [fl-client](https://github.com/fedota/fl-client) for it to connect and then begin training. The plan is the allow the webserver to create the docker image for the client (with the selector address configured) allowing the data holders to use it directly and run the image passing in the data file location as the argument.

Here is a [video](https://drive.google.com/file/d/1-wbu21gmvTVgxNgRRSCbIKNCVj43fOek/view?usp=sharing) of a single round of federated learning that we captured during our testing. This is not using the webserver to spawn the infra, the coordinator and selected are deployed in Azure and the client is simulated using Google Colab.

## Miscellaneous

### Shared File storage structure
For each FL problem, coordinator and selectors use the `<fl_problem_id>` directory
```
\data
	\<fl_problem_id> 
		\initFiles
			fl_checkpoint
			model.h5
			.
			.
		\<selector-id>
			fl_agg_checkpoint
			fl_agg_checkpoint_weight
			\roundFiles
				checkpoint_<client-no>
				checkpoint_weight_<client-no>
		.
		.
		.
```

### NFS
NFS service need to be exposed to the k8s cluster. 
- This can be in a [manual way](https://blog.exxactcorp.com/deploying-dynamic-nfs-provisioning-in-kubernetes/), provisioned by a cloud provider, OR
- Use the `k8s-manifests/nfs-service.yaml` manifest to run a nfs server as a container (by [erichough/nfs-server](https://github.com/ehough/docker-nfs-server)) on a pod which requires the following:

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

[Optional] For testing

Create the Persistent Volume(PV) using NFS and the Persistent Volume Claim (PVC)
```
kubectl create -f nfs-pv.yaml
kubectl get pv nfs-pv # should be available

kubectl create -f nfs-pvc.yaml

# check; should be bound
kubectl get pv nfs-pv
kubectl get pvc nfs-pvc 
```
Run a test nfs pod to check if NFS service, pv and pvc work
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
#### Troubleshooting

If `nfs-test-pod` fails with nfs-service dns resolution issue check, this could be due to problems with the distribution 
- https://github.com/kubernetes/minikube/issues/2218#issuecomment-436821733
- https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/#known-issues

#### Debugging

Use the following to get logs and to describe the objects create
```
kubectl logs <pod-name>
kubectl describe <pod/svc/pv..> <name>

# for a running pod
kubectl logs nfs-server-pod
# generally
kubectl describe pod nfs-test-pod
```
