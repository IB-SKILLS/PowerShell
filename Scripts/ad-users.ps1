Import-Module ActiveDirectory

# Переменные OU
$ou_main = "DemoOffice"
$ou_users = "Users"
$ou_computers = "Computers"

# Переменные PATH
$dc_path = "DC=demo,DC=lab"
$main_path = "OU=DemoOffice,DC=demo,DC=lab"
$users_path = "OU=Users,OU=DemoOffice,DC=demo,DC=lab"
$computers_path = "OU=Computers,OU=DemoOffice,DC=demo,DC=lab"

# Cоздаем OU
New-ADOrganizationalUnit -Name "$ou_main" -Path $dc_path
New-ADOrganizationalUnit -Name "$ou_users" -Path $main_path
New-ADOrganizationalUnit -Name "$ou_computers" -Path $main_path

$number = Read-Host "Введите количество пользователей"
$count=1..$number
$users = @{}

foreach ($i in $count)
{
$username = Read-Host "Введите имя пользователя номер $i"
$usergroup = Read-Host "Должен ли пользователь $i иметь права администратора? (Y - да, N - нет)"
$users.Add($username,$usergroup)
}
$pass = Read-Host 'Enter the password'

# Цикл с пользователями
foreach ($user in $users.keys) {
$Username = @{

Name = "$user"
GivenName = "$user"
UserPrincipalName = "$user@demo.lab"
Path = $users_path
ChangePasswordAtLogon = $true
AccountPassword = "$pass" | ConvertTo-SecureString -AsPlainText -Force
Enabled = $true

}

New-ADUser @Username
Set-ADUser $user -PasswordNeverExpires:$True
if ($users.$user -eq "y")
{Add-ADGroupMember "Domain admins" $user}
}

