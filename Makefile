SHELL := /bin/bash

VERSION := 0.0.1

all_terraform: init plan apply

all_ghr: clean_helm image helm deploy

.PHONY: init
init:
	@ARM_SUBSCRIPTION_ID=$(shell az account show --query id --out tsv)
	@ARM_TENANT_ID=$(shell az account show --query tenantId --out tsv)
	@cd ./terraform && terraform init --upgrade -input=false -migrate-state \
	-backend-config="resource_group_name=${RESOURCE_GROUP_NAME}" \
	-backend-config="storage_account_name=${STORAGE_ACCOUNT_NAME}" \
	-backend-config="key=${RESOURCE_GROUP_NAME}.tfstate" \
	-backend-config="container_name=${STORAGE_CONTAINER_NAME}"

.PHONY: plan
plan:
	cd ./terraform && terraform plan \
	-var="resource_group_name=$(RESOURCE_GROUP_NAME)" \
	-var="cluster_name=${CLUSTER_NAME}" \
	--out=tf.plan

.PHONY: apply
apply:
	cd ./terraform && \
    terraform apply -refresh-only tf.plan && \
	rm tf.plan && \
	az aks update -n ${CLUSTER_NAME} -g ${RESOURCE_GROUP_NAME} --attach-acr ${CLUSTER_NAME} 

.PHONY: image
image:
	az configure --defaults acr=${RESOURCE_GROUP_NAME} \
	&& az acr build -t ghrunner:${VERSION} ./ghrdocker

.PHONY: helm
helm:
	export HELM_EXPERIMENTAL_OCI=1 && \
	az configure --defaults acr=${RESOURCE_GROUP_NAME} && \
	az acr login -n ${RESOURCE_GROUP_NAME} && \
	cd ./ghrhelm && \
	helm package . && \
	helm push ghr-${VERSION}.tgz oci://${RESOURCE_GROUP_NAME}.azurecr.io/ghrunner && \
	az acr repository show --name ${RESOURCE_GROUP_NAME} --repository ghrunner && \
	rm ghr-${VERSION}.tgz

.PHONY: deploy
deploy:
	export HELM_EXPERIMENTAL_OCI=1 && \
	az configure --defaults acr=${RESOURCE_GROUP_NAME} && \
	az acr login -n ${RESOURCE_GROUP_NAME} && \
	az aks get-credentials --name ${CLUSTER_NAME} --resource-group ${RESOURCE_GROUP_NAME} && \
	az configure --defaults acr=${RESOURCE_GROUP_NAME} && \
	helm pull oci://${RESOURCE_GROUP_NAME}.azurecr.io/ghrunner/ghr --version ${VERSION} && \
	helm install ghrunner ghr-${VERSION}.tgz \
	--set image.repository=${RESOURCE_GROUP_NAME}.azurecr.io/ghrunner \
	--set ghr.github_token=${GH_TOKEN} && \
	--set ghr.repo_name=${GITHUB_REPO_NAME} && \
	--set ghr.repo_url=${GITHUB_REPO_URL} && \
	--set ghr.repo_owner=${GITHUB_REPO_OWNER} && \
	rm ghr-${VERSION}.tgz

.PHONY: clean_helm
clean_helm: 
	-helm uninstall ghrunner

setup_command:
	echo ". ./setup.sh -c clusterName -g resourceGroupName -s subscriptionID -r region 2>&1"
