# minikube stop
# minikube delete
minikube start
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace --namespace argocd --version 7.3.2 --wait --wait-for-jobs
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
kubectl apply -f app-of-apps.yml && argocd login --core && argocd app wait app-of-apps 2>&1 1>/dev/null
kubectl port-forward service/argocd-server -n argocd 8080:80
