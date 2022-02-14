Import-Module ActiveDirectory

# Cоздаем OU
New-ADOrganizationalUnit -Name "DemoOffice" -Path “DC=demo,DC=lab”
New-ADOrganizationalUnit -Name "Users" -Path “OU=DemoOffice,DC=demo,DC=lab”
New-ADOrganizationalUnit -Name "Computers" -Path “OU=DemoOffice,DC=demo,DC=lab”

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
Path = "OU=Users,OU=DemoOffice,DC=demo,DC=lab"
ChangePasswordAtLogon = $true
AccountPassword = "$pass" | ConvertTo-SecureString -AsPlainText -Force
Enabled = $true

}

New-ADUser @Username
Set-ADUser $user -PasswordNeverExpires:$True
if ($users.$user -eq "y")
{Add-ADGroupMember "Domain admins" $user}
}
