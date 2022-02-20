Import-Module ActiveDirectory

# Указываем директорию
$dir = "C:\out"
new-item -path "$dir" -ItemType Directory -force >$null

# Переменные DC
$dc_first = "demo"
$dc_second = "lab"

# Переменные OU
$ou_main = "DemoOffice"
$ou_users = "Users"
$ou_computers = "Computers"

# Переменные для настройки сети
$ip = '192.168.0.30'
$mask = '255.255.255.0'
$gw = '192.168.0.1'
$dns = '192.168.0.100'
$eth = 'Ethernet0'

# Переменные PATH
$dc_path = "DC=$dc_first,DC=$dc_second"
$main_path = "OU=$ou_main,DC=$dc_first,DC=$dc_second"
$users_path = "OU=$ou_users,OU=$ou_main,DC=$dc_first,DC=$dc_second"
$computers_path = "OU=$ou_computers,OU=$ou_main,DC=$dc_first,DC=$dc_second"

# Проверка OU
try
{
Get-ADOrganizationalUnit -SearchBase "$main_path" -Filter * >$null
Get-ADOrganizationalUnit -SearchBase "$users_path" -Filter * >$null
Get-ADOrganizationalUnit -SearchBase "$computers_path" -Filter * >$null
}
catch
{
New-ADOrganizationalUnit -Name "$ou_main" -Path $dc_path
New-ADOrganizationalUnit -Name "$ou_users" -Path $main_path
New-ADOrganizationalUnit -Name "$ou_computers" -Path $main_path
}

# Вводим переменные
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

# Создание пользователей
New-ADUser @Username
Set-ADUser $user -PasswordNeverExpires:$True
if ($users.$user -eq "y")
{Add-ADGroupMember "Domain admins" $user}

# Создание скрпитов для компьютеров "локально"
$securepassword = '$pass' + " | ConvertTo-SecureString -AsPlainText -Force"
$credential = "New-Object System.Management.Automation.PSCredential -ArgumentList" + ' $user, $securepassword'

$out = '$user = "' + "$user" + '"
' + '$pass = "' + "$pass" + '"
' + '$securepassword = ' + "$securepassword
" + '$credential = ' + "$credential
Get-NetAdapterBinding -InterfaceAlias $eth | Set-NetAdapterBinding -Enabled:$false -ComponentID ms_tcpip6
netsh interface ip set address name=$eth static $ip $mask $gw
netsh interface ip set dns $eth static $dns
Timeout /T 5
Add-Computer -DomainName $dc_first.$dc_second -NewName $user -OUPath " + '"' + "$computers_path" + '"' + " -Credential" + ' $credential
Restart-Computer -Force'

# Указываем директорию и записываем данные пользователя
write-output $out | out-file -append -encoding utf8 "$dir\$user.ps1"
}
