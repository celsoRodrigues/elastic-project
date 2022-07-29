#! /bin/env bash
set -x
DIR=$(dirname "${BASH_SOURCE[0]}")

install_all() {
    kubectl apply /home/celso/Documents/k8s/elastic/airflow/secrets/dags-repo-airflow-secret.yaml
    for program in logstash filebeat elasticsearch kibana airflow; do pushd ${program}; helm upgrade --create-namespace --namespace elastic-system --install ${program} . ; popd; done
}

install_core() {

    #ingress
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

    echo "waiting for ingress..."
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s

    # Add repos

    #add pkgs
    for program in metrics-server; do pushd ${program}; helm upgrade --create-namespace --namespace kube-monitoring --install ${program} .; popd; done 

    #add others:

    # Prometheus
    helm upgrade --install kube-prometheus-stack kube-prometheus-stack \
    --namespace kube-monitoring --create-namespace \
    --repo https://prometheus-community.github.io/helm-charts

    # Grafana ingress
    printf "\nInstalling grafana ingress...\n"
    kubectl apply -f ${DIR}/grafana_ing.yaml
    printf "\n"

    # Cert manager
    helm upgrade --install cert-manager cert-manager \
    --namespace kube-system --create-namespace \
    --repo https://charts.jetstack.io \
    --set installCRDs=true
   
}

install_elastic() {
    for program in logstash filebeat elasticsearch kibana; do pushd ${program}; helm upgrade --create-namespace --namespace elastic-system --install ${program} . | grep -E "(Happy\ Helming|NAME\: |LAST DEPLOYED\: |NAMESPACE\: |STATUS\: |REVISION\: | TEST SUITE\: )" \
    --color=never || true ; popd; printf "\n"; done

}

install_airflow() {
    kubectl apply /home/celso/Documents/k8s/elastic/airflow/secrets/dags-repo-airflow-secret.yaml
    for program in airflow; do pushd ${program}; helm upgrade --create-namespace --namespace airflow --install ${program} .; popd; done

}

install_csi_s3() {
    echo "test" 
}

install_ingress() {
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
        --selector=app.kubernetes.io/component=controller \
	  --timeout=90s
}

uninstall_all() {
    kubectl delete /home/celso/Documents/k8s/elastic/airflow/secrets/dags-repo-airflow-secret.yaml
    for program in logstash filebeat elasticsearch kibana airflow; do pushd ${program}; helm uninstall ${program}; popd; done
}

