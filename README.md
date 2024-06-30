# ArgoCD App-of-apps Pattern Example

This repo constitutes a simple pattern of how to apply the app-of-apps pattern for ArgoCD. The app-of-apps (`appOfApps.yml`) in this repo manages three children apps:
* Bitnami Redis (Helm, `apps/redis.yml`, [oci://registry-1.docker.io/bitnamicharts/redis](https://github.com/bitnami/charts/tree/main/bitnami/redis))
* ArgoCD (Helm, `apps/argocd.yml`, https://argoproj.github.io/argo-helm)
* Nginx hello-world (Git, `apps/nginx.yml`, `./nginx/`)

# Getting started
To begin, you will need to have [kubectl](https://kubernetes.io/docs/reference/kubectl/) and [Helm](https://helm.sh/docs/intro/install/) installed on your box, and a cluster available. In this example, we'll be using [minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Fx86-64%2Fstable%2Fbinary+download) with the Docker driver (default driver - you will need the [Docker Engine](https://docs.docker.com/engine/) for this). After having installed prerequisites, start `minikube`, i.e. run `minikube start`. Your context should now be minikube, check e.g. `kubectl config current-context`.

## Installing ArgoCD
We will now start off by installing ArgoCD in our cluster using Helm,
```
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace --namespace argocd --version 7.3.2
```

Here, we chose version `7.3.2`, since it matches the `targetRevision` in `apps/argocd.yml`. *If these two don't match when we deploy our app-of-apps later, it will break our ArgoCD-install(!)*.

## Logging in to ArgoCD's web portal
*(This section can be skipped if you just want to follow the instructions which are prompted after the ArgoCD install mentioned above)*

Let's get the visual representation of our apps ready, by logging into the ArgoCD web portal. To access this, we'll need to forward one of the service ports of the `argocd-server`-service, which we'll open in our browser on our box, and get the `admin`-password. 
1. Open a new terminal and forward the service port 80 to local port 8080, `kubectl port-forward service/argocd-server -n argocd 8080:80` - the portal should be accessible at `localhost:8080` in your browser.
2. Log in with the `admin`-user, password can be retrieved by `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo`
3. You should now be greeted by an empty set of apps after logging in with `admin` at `localhost:8080`- let's create one (or many!).

## Creating our app-of-apps.
Now that we have ArgoCD running in our cluster, let's create our app-of-apps by applying the appropriate manifest. Run `kubectl apply -f bootstrap.yml` to deploy your app-of-apps. There should now be 4 apps appearing in your portal,
 * `appOfApps`
 * `redis-app`
 * `argocd-app`
 * `nginx-app`

`appOfApps`now manages its own children - try e.g. deleting `redis-app` from the portal view. It will quickly be re-synced by `appOfApps`, to the manifests under the `apps`-folder in this repo.

## Exploring our app-managed apps
  * `redis-app` doesn't really do anything, but if you have an appliction running locally on your box which makes use of Redis connections, you could try connecting to it by exposing it to localhost, `kubectl port-forward service/redis-app-master 6379:6379`. The default username should be `default`, and the password can be extracted to a env-variable by e.g. `export REDIS_PASSWORD=$(kubectl get secret --namespace default redis-app -o jsonpath="{.data.redis-password}" | base64 --decode)`. Have fun!
  * `argocd-app` is now controlling your instance of ArgoCD, which you installed in the first section using `helm install argocd (...)`. Note that these apps are controlled by what is in this remote repository(!). You can try forking this repo, and swap out all the `repoURL: https://github.com/chrisbso/argocd_app_of_apps_pattern_example.git`s in the `*.yml`-files with your own remote repository. *After* applying your updated `bootstrap.yml` to your cluster and ensuring that your `argocd-app` is healthy and synced, you can try to change the version of your ArgoCD instance by changing the `targetRevision` to e.g. `6.11.0` (make sure to push changes to remote) - in the ArgoCD dashboard for your `argocd-app`, you should see after sync it now is sync-ed to version 6.11.0. Strong emphasis on *after*. You just witnessed an ArgoCD app changing its own instance version. Remember that this will most likely kill the port-forwarding process we set up earlier for the portal frontend, you just need to restart it.
  * `nginx-app` is just a dummy "hello-world"-feature, which makes use of custom K8s manifests. You can reach it by exposing its service port to localhost, `kubectl port-forward service/nginx-service 8887:8888` - visit `localhost:8888/foo` in your browser. The `ngnix` will think it's serving its resource `/foo` from `localhost:80`, which is true for its Pod-environment - we are mapping this through a NodePort on port `8887`, which we again forward to `8888` on our box's loopback interface. 
