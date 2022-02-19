# Переменные
$ip = '192.168.0.30'
$mask = '255.255.255.0'
$gw = '192.168.0.1'
$dns = '192.168.0.1'
$eth = 'Ethernet0'

# Отключение IPv6
Get-NetAdapterBinding -InterfaceAlias $eth | Set-NetAdapterBinding -Enabled:$false -ComponentID ms_tcpip6

# сеть
netsh interface ip set address name="$eth" static $ip $mask $gw
netsh interface ip set dns "$eth" static $dns >$null
