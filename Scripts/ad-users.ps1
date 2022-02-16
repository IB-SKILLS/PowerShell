Import-Module ActiveDirectory

# Указываем директории
$dir = "C:\out"

# Переменные DC
$dc_first = "demo"
$dc_second = "lab"

# Переменные OU
$ou_main = "DemoOffice"
$ou_users = "Users"
$ou_computers = "Computers"

# Переменные PATH
$dc_path = "DC=$dc_first,DC=$dc_second"
$main_path = "OU=$ou_main,DC=$dc_first,DC=$dc_second"
$users_path = "OU=$ou_users,OU=$ou_main,DC=$dc_first,DC=$dc_second"
$computers_path = "OU=$ou_computers,OU=$ou_main,DC=$dc_first,DC=$dc_second"

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

$spass = '$pass' + " | ConvertTo-SecureString -AsPlainText -Force"
$credential = "New-Object System.Management.Automation.PSCredential -ArgumentList" + ' $user, $spass'

$out = '$user = "' + "$user" + '"
' + '$pass = "' + "$pass" + '"
' + '$spass = ' + "$spass
" + '$credential = ' + "$credential
Add-Computer -DomainName demo.lab -NewName $user -OUPath " + '"' + "$computers_path" + '"' + " -Credential" + ' $credential'

}

# Запись в директорию
new-item -path "$dir" -ItemType Directory -force
write-output $out | out-file -append -encoding utf8 "$dir\out.ps1"
