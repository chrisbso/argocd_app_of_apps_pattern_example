# minikube stop
# minikube delete

minikube start
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace --namespace argocd --version 7.*.* --wait --wait-for-jobs
kubectl apply -f app-of-apps.yml && argocd login --core 2>&1 1>/dev/null && kubectl config set-context --current --namespace=argocd 2>&1 1>/dev/null && argocd app wait app-of-apps --timeout 60 2>&1 1>/dev/null && kubectl config set-context --current --namespace=default 2>&1 1>/dev/null
echo "ArgoCD admin password: " && kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
kubectl port-forward service/argocd-server -n argocd 8080:80
