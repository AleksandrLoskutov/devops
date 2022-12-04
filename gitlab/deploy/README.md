# Спринт 2
**GitLab деплой приложения**
___
Как развернуть:
- создать _Personal Access Token_, указать области - api, read_registry, write_registry
- импортировать содержимое _/gitlab/deploy/_ в созданный ранее проект (final_sprint) на gitlab.com
- указать логин вашей учётной записи gitlab.com в соответствующем поле файла _templates/deployment.yml_
  - _image: "registry.gitlab.com/<Указать логин аккаунта GitLab>/final_sprint:latest"_
- указать внешний ip-адрес worker-ноды соответствующем поле файла _app/app/settings.py_, ip-адрес необходимо указывать в одинарных ковычках
  - ALLOWED_HOSTS = ['ip-адрес worker-ноды']
- вручную запустить исполнение пайплайна CI/CD, ввести при запуске логин и пароль вашей учётной записи gitlab.com
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
