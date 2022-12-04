# Спринт 1
**Развертывание в Яндекс Облаке**
___
Требования:
- Аккаунт в Яндекс Облаке
- Аккаунте в gitlab.com
- Установленный Terraform
- Установленный Ansible
___
Как развернуть:
- загрузить содержимое из удаленного репозитория
- перейти в каталог: _/terraform/deploy/_
- в файле **main.tf** внести свои значения:  
  - _token     = "***Specify OAuth token***"_
  - _cloud_id  = "***Specify Cloud ID***"_
  - _folder_id = "***Specify Folder ID***"_
- в файле **variables.tf** прописать свой приватный и публичный ключ:
  - _private_key = "~/.ssh/id_*"
  - _pub_key     = "~/.ssh/id_*.pub"
- в файле **gitlab-token.yml** прописать регистрационный токен:
  - _gitlab_token: "***Specify GitLab runner registration token***"_
- сделать файл **provisioning.sh** исполняемым
- выполнить _terraform init_
- выполнить _terraform apply_
___
**Результат развертывания**
- Терминал
- ![k8s_terraform_deploy](./images/k8s_deploy_term.PNG)
- Яндекс Облако
- ![k8s_cloud_deploy](./images/k8s_deploy_cloud.PNG)
- Мастер-нода
- ![k8s_term_master](./images/k8s_term_master.PNG)
- GitLab runner
- ![gitlab_runner](./images/gitlab_runner.PNG)
