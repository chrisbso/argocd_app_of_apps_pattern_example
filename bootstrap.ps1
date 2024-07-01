# minikube stop
# minikube delete

minikube start
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -n argocd --create-namespace --namespace argocd --version 7.3.2 --wait --wait-for-jobs; kubectl rollout status deployments -n argocd -l app.kubernetes.io/part-of=argocd --timeout 60s
kubectl apply -f app-of-apps.yml; argocd login --core | out-null; kubectl config set-context --current --namespace=argocd | out-null; argocd app wait app-of-apps --timeout 60 | out-null; kubectl config set-context --current --namespace=default | out-null
Write-Host -NoNewLine "ArgoCD admin password: "; kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | %{[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))} | Write-Host
kubectl port-forward service/argocd-server -n argocd 8080:80
