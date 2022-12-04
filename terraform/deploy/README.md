# Спринт 1
**Развертывание в Яндекс Облаке**
___
Требования:
- Аккаунт в Яндекс Облаке
- Установленный Terraform
- Установленный Ansible
___
Как развернуть:
- загрузить содержимое из удаленного репозитория
- перейти в каталог: _HW-03-3/deploy/_
- в файле **main.tf** внести свои значения:  
  - _token     = "***Specify OAuth token***"_
  - _cloud_id  = "***Specify Cloud ID***"_
  - _folder_id = "***Specify Folder ID***"_
- в файле **variables.tf** прописать свой приватный и публичный ключ:
  - _private_key = "~/.ssh/id_***"
  - _pub_key     = "~/.ssh/id_***.pub"
- выполнить _terraform init_
- выполнить _terraform apply_
___
**Результат развертывания**
- терминал
- ![terraform_deploy](./images/terraform_deploy.PNG)
- Яндекс Облако
- ![yandex_result](./images/yandex_result.PNG)
- веб браузер
- ![web_result](./images/web_result.PNG)
- управляющая нода
- ![manager_node](./images/manager_node.PNG)
