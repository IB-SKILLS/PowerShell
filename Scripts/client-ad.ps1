# Разрешаем использование испольняемого файла для всех пользователей
# Set-ExecutionPolicy RemoteSigned
# -A

# Вводим переменные
$Username = 'user-agent'
$Password = 'xxXX1234'
$ldap_path = 'OU=Computers,OU=DemoOffice,DC=demo,DC=lab'

# Настройка -credential
$Securepassword = $Password | ConvertTo-SecureString -AsPlainText -Force 
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $Securepassword

# Добавляем пользователя в домен и перезагружаем комьютер
Add-Computer -DomainName demo.lab -NewName $Username -OUPath $ldap_path -Credential $credential
Restart-Computer -Force
