minikube stop
minikube delete
minikube start
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace --namespace argocd --version 7.3.2
sleep 5
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | %{[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))} | Write-Output
kubectl apply -f appOfApps.yml
sleep 5
kubectl port-forward service/argocd-server -n argocd 8080:80
