@testplan
Feature: nmcli - ethernet

    # Please do use tags as follows:
    # @bugzilla_link (rhbz123456)
    # @version_control (ver+/-=1.4.1)
    # @other_tags (see environment.py)
    # @test_name (compiled from scenario name)
    # Scenario:


    @ethernet
    @ethernet_create_with_editor
    Scenario: nmcli - ethernet - create with editor
    * Open editor for a type "ethernet"
    * Set a property named "ipv4.method" to "auto" in editor
    * Set a property named "connection.interface-name" to "eth1" in editor
    * Set a property named "connection.autoconnect" to "no" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Note the "connection.id" property from editor print output
    * Quit editor
     Then Check ifcfg-name file created with noted connection name


    @ethernet
    @ethernet_create_default_connection
    Scenario: nmcli - ethernet - create default connection
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet"
    Then Check ifcfg-name file created for connection "ethernet"


    @ethernet
    @veth
    @ethernet_create_ifname_generic_connection
    Scenario: nmcli - ethernet - create ifname generic connection
    * Add a new connection of type "ethernet" and options "ifname * con-name ethos autoconnect no"
    * Check ifcfg-name file created for connection "ethos"
    * Bring up connection "ethos"
    Then "ethernet\s+connected\s+ethos" is visible with command "nmcli device"


    @ethernet
    @ethernet_connection_up
    Scenario: nmcli - ethernet - up
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Check ifcfg-name file created for connection "ethernet"
    * "inet 192." is not visible with command "ifconfig eth1"
    * Bring up connection "ethernet"
    Then "inet 192." is visible with command "ifconfig eth1"


    @ethernet
    @ethernet_disconnect_device
    Scenario: nmcli - ethernet - disconnect device
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect yes"
    * Check ifcfg-name file created for connection "ethernet"
    * Bring up connection "ethernet"
    * "inet 192." is visible with command "ifconfig eth1"
    * Disconnect device "eth1"
    Then "inet 192." is not visible with command "ifconfig eth1"


    @ethernet
    @ethernet_describe_all
    Scenario: nmcli - ethernet - describe all
    * Open editor for a type "ethernet"
    Then Check "port|speed|duplex|auto-negotiate|mac-address|cloned-mac-address|mac-address-blacklist|mtu|s390-subchannels|s390-nettype|s390-options" are present in describe output for object "802-3-ethernet"


    @ethernet
    @ethernet_describe_separately
    Scenario: nmcli - ethernet - describe separately
    * Open editor for a type "ethernet"
    Then Check "\[port\]" are present in describe output for object "802-3-ethernet.port"
    Then Check "\[speed\]" are present in describe output for object "802-3-ethernet.speed"
    Then Check "\[duplex\]" are present in describe output for object "802-3-ethernet.duplex"
    Then Check "\[auto-negotiate\]" are present in describe output for object "802-3-ethernet.auto-negotiate"
    Then Check "\[mac-address\]" are present in describe output for object "802-3-ethernet.mac-address"
    Then Check "\[cloned-mac-address\]" are present in describe output for object "802-3-ethernet.cloned-mac-address"
    Then Check "\[mac-address-blacklist\]" are present in describe output for object "802-3-ethernet.mac-address-blacklist"
    Then Check "\[mtu\]" are present in describe output for object "802-3-ethernet.mtu"
    Then Check "\[s390-subchannels\]" are present in describe output for object "802-3-ethernet.s390-subchannels"
    Then Check "\[s390-nettype\]" are present in describe output for object "802-3-ethernet.s390-nettype"
    Then Check "\[s390-options\]" are present in describe output for object "802-3-ethernet.s390-options"


    @rhbz1264024
    @ethernet
    @ethernet_set_matching_mac
    Scenario: nmcli - ethernet - set matching mac adress
    * Add a new connection of type "ethernet" and options "ifname * con-name ethernet autoconnect no"
    * Note the "ether" property from ifconfig output for device "eth1"
    * Open editor for connection "ethernet"
    * Set a property named "802-3-ethernet.mac-address" to "noted-value" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "eth1:connected:ethernet" is visible with command "nmcli -t -f DEVICE,STATE,CONNECTION device" in "20" seconds
    Then "inet 192." is visible with command "ip a s eth1"


    @ethernet
    @teardown_testveth @restart
    @no_assumed_connection_for_veth
    Scenario: NM - ethernet - no assumed connection for veth
    * Prepare simulated test "testE" device
    * Add a new connection of type "ethernet" and options "ifname testE con-name ethernet autoconnect no"
    * Bring up connection "ethernet"
    * Restart NM
    Then "testE" is not visible with command "nmcli -f NAME c" in "50" seconds


    @ethernet
    @ethernet_set_invalid_mac
    Scenario: nmcli - ethernet - set non-existent mac adress
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "802-3-ethernet.mac-address" to "00:11:22:33:44:55" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    Then "No suitable device found for this connection" is visible with command "nmcli connection up ethernet"


    @rhbz1264024
    @ethernet
    @ethernet_set_blacklisted_mac
    Scenario: nmcli - ethernet - set blacklisted mac adress
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Note the "ether" property from ifconfig output for device "eth1"
    * Open editor for connection "ethernet"
    * Set a property named "802-3-ethernet.mac-address-blacklist" to "noted-value" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    Then "Error" is visible with command "nmcli connection up ethernet"


    @ethernet
    @ethernet_mac_spoofing
    Scenario: nmcli - ethernet - mac spoofing
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "802-3-ethernet.cloned-mac-address" to "f0:de:aa:fb:bb:cc" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "ether f0:de:aa:fb:bb:cc" is visible with command "ifconfig eth1"


    @rhbz1413312
    @ver+=1.6.0
    @ethernet @mac @restart
    @ethernet_mac_address_preserve
    Scenario: NM - ethernet - mac address preserve
    * Execute "echo -e '[connection]\nethernet.cloned-mac-address=preserve' > /etc/NetworkManager/conf.d/99-mac.conf"
    * Reboot
    * Execute "ip link set dev eth1 address f0:11:22:33:44:55"
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Bring "up" connection "ethernet"
    * Note the output of "nmcli -t --mode tabular --fields GENERAL.HWADDR device show eth1" as value "new_eth1"
    Then "ether f0:11:22:33:44:55" is visible with command "ip a s eth1"


    @rhbz1413312
    @ver+=1.6.0
    @ethernet @mac @restart
    @ethernet_mac_address_permanent
    Scenario: NM - ethernet - mac address permanent
    * Note the output of "nmcli -t --mode tabular --fields GENERAL.HWADDR device show eth1" as value "orig_eth1"
    * Execute "echo -e '[connection]\nethernet.cloned-mac-address=permanent' > /etc/NetworkManager/conf.d/99-mac.conf"
    * Reboot
    * Execute "ip link set dev eth1 address f0:11:22:33:44:55"
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Bring "up" connection "ethernet"
    * Note the output of "nmcli -t --mode tabular --fields GENERAL.HWADDR device show eth1" as value "new_eth1"
    Then Check noted values "orig_eth1" and "new_eth1" are the same


    @rhbz1413312
    @ver+=1.6.0
    @rhel7_only @ethernet @mac
    @ethernet_mac_address_rhel7_default
    Scenario: NM - ethernet - mac address rhel7 dafault
    * Note the output of "nmcli -t --mode tabular --fields GENERAL.HWADDR device show eth1" as value "orig_eth1"
    * Execute "ip link set dev eth1 address f0:11:22:33:44:55"
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Bring "up" connection "ethernet"
    * Note the output of "nmcli -t --mode tabular --fields GENERAL.HWADDR device show eth1" as value "new_eth1"
    Then Check noted values "orig_eth1" and "new_eth1" are the same


    @rhbz1353612
    @ver+=1.7.1
    @ethernet
    @ethernet_duplex_speed_auto_negotiation
    Scenario: nmcli - ethernet - duplex speed and auto-negotiation
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet"
    * Execute "nmcli connection modify ethernet 802-3-ethernet.duplex full 802-3-ethernet.speed 10"
    When "ETHTOOL_OPTS="autoneg off speed 10 duplex full"" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet"
    * Execute "nmcli connection modify ethernet 802-3-ethernet.auto-negotiate yes"
    When "ETHTOOL_OPTS="autoneg on"" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet"
    * Execute "nmcli connection modify ethernet 802-3-ethernet.auto-negotiate no"
    Then "ETHTOOL_OPTS" is not visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet"



    @ethernet
    @ethernet_set_mtu
    Scenario: nmcli - ethernet - set mtu
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "802-3-ethernet.mtu" to "64" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "MTU=64" is visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet"
    Then "inet 192." is visible with command "ifconfig eth1"


    @ethernet
    @mtu
    @nmcli_set_mtu_lower_limit
    Scenario: nmcli - ethernet - set lower limit mtu
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "802-3-ethernet.mtu" to "666" in editor
    * Save in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "1280" is visible with command "ip a s eth1"


    @ethernet
    @ethernet_set_static_configuration
    Scenario: nmcli - ethernet - static IPv4 configuration
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.10/24" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "inet 192.168.1.10\s+netmask 255.255.255.0" is visible with command "ifconfig eth1"


    @ethernet
    @ethernet_set_static_ipv6_configuration
    Scenario: nmcli - ethernet - static IPv6 configuration
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "ipv6.method" to "manual" in editor
    * Set a property named "ipv6.addresses" to "2607:f0d0:1002:51::4/64" in editor
    * Set a property named "ipv4.method" to "disabled" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "inet6 2607:f0d0:1002:51::4\s+prefixlen 64" is visible with command "ifconfig eth1"


    @ethernet
    @ethernet_set_both_ipv4_6_configuration
    Scenario: nmcli - ethernet - static IPv4 and IPv6 combined configuration
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "ipv6.method" to "manual" in editor
    * Set a property named "ipv6.addresses" to "2607:f0d0:1002:51::4/64" in editor
    * Set a property named "ipv4.method" to "manual" in editor
    * Set a property named "ipv4.addresses" to "192.168.1.10/24" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "inet 192.168.1.10\s+netmask 255.255.255.0" is visible with command "ifconfig eth1"
    Then "inet6 2607:f0d0:1002:51::4\s+prefixlen 64" is visible with command "ifconfig eth1"


    @ethernet
    @nmcli_ethernet_no_ip
    Scenario: nmcli - ethernet - no ip
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name ethernet autoconnect no"
    * Open editor for connection "ethernet"
    * Set a property named "ipv6.method" to "ignore" in editor
    * Set a property named "ipv4.method" to "disabled" in editor
    * Save in editor
    * Check value saved message showed in editor
    * Quit editor
    * Bring up connection "ethernet"
    Then "eth1\s+ethernet\s+connected" is visible with command "nmcli device"


    @rhbz1141417
    @ethernet
    @restart
    @nmcli_ethernet_wol_default
    Scenario: nmcli - ethernet - wake-on-lan default
    * Execute "systemctl stop NetworkManager"
    * Execute "modprobe -r ixgbe && modprobe ixgbe && sleep 5"
    * Note the output of "ethtool em2 |grep Wake-on |grep Supports | awk '{print $3}'" as value "wol_supports"
    * Note the output of "ethtool em2 |grep Wake-on |grep -v Supports | awk '{print $2}'" as value "wol_orig"
    * Restart NM
    * Add connection type "ethernet" named "ethernet" for device "em2"
    # Wake-on-lan 94 equals to (phy, unicast, multicast, broadcast, magic) alias pumbg
    * Execute "nmcli c modify ethernet 802-3-ethernet.wake-on-lan 92"
    * Bring up connection "ethernet"
    * Note the output of "ethtool em2 |grep Wake-on |grep -v Supports | awk '{print $2}'" as value "wol_now"
    When Check noted values "wol_now" and "wol_supports" are the same
    * Execute "nmcli c modify ethernet 802-3-ethernet.wake-on-lan default"
    * Execute "modprobe -r ixgbe && modprobe ixgbe && sleep 5"
    * Restart NM
    * Bring up connection "ethernet"
    * Note the output of "ethtool em2 |grep Wake-on |grep -v Supports | awk '{print $2}'" as value "wol_now"
    Then Check noted values "wol_now" and "wol_orig" are the same


    @rhbz1141417
    @ethernet
    @nmcli_ethernet_wol_enable_magic
    Scenario: nmcli - ethernet - wake-on-lan magic
    * Add connection type "ethernet" named "ethernet" for device "em2"
    * Execute "nmcli c modify ethernet 802-3-ethernet.wake-on-lan magic"
    * Bring up connection "ethernet"
    Then "Wake-on: g" is visible with command "ethtool em2"


    @rhbz1141417
    @ethernet
    @nmcli_ethernet_wol_disable
    Scenario: nmcli - ethernet - wake-on-lan disable
    * Add connection type "ethernet" named "ethernet" for device "em2"
    * Execute "nmcli c modify ethernet 802-3-ethernet.wake-on-lan none"
    * Bring up connection "ethernet"
    Then "Wake-on: d" is visible with command "ethtool em2"


    @rhbz1141417
    @ethernet
    @nmcli_ethernet_wol_from_file
    Scenario: nmcli - ethernet - wake-on-lan from file
    * Add connection type "ethernet" named "ethernet" for device "em2"
    * Append "ETHTOOL_OPTS=\"wol g\"" to ifcfg file "ethernet"
    * Execute "nmcli con reload"
    * Bring up connection "ethernet"
    Then "Wake-on: g" is visible with command "ethtool em2"
    Then "magic" is visible with command "nmcli con show ethernet |grep wake-on-lan"


    @rhbz1141417
    @ethernet
    @nmcli_ethernet_wol_from_file_to_default
    Scenario: nmcli - ethernet - wake-on-lan from file and back
    * Add connection type "ethernet" named "ethernet" for device "em2"
    * Note the output of "ethtool em2 |grep Wake-on |grep -v Supports | awk '{print $2}'" as value "wol_orig"
    * Append "ETHTOOL_OPTS=\"wol g\"" to ifcfg file "ethernet"
    * Execute "nmcli con reload"
    * Bring up connection "ethernet"
    Then "Wake-on: g" is visible with command "ethtool em2"
    Then "magic" is visible with command "nmcli con show ethernet |grep wake-on-lan"
    * Open editor for connection "ethernet"
    * Submit "set 802-3-ethernet.wake-on-lan default" in editor
    * Save in editor
    * Quit editor
    * Bring "down" connection "ethernet"
    * Execute "modprobe -r ixgbe && modprobe ixgbe && sleep 5"
    * Bring up connection "ethernet"
    Then "ETHTOOL_OPTS" is not visible with command "cat /etc/sysconfig/network-scripts/ifcfg-ethernet"
    * Note the output of "ethtool em2 |grep Wake-on |grep -v Supports | awk '{print $2}'" as value "wol_new"
    Then Check noted values "wol_new" and "wol_orig" are the same


    @ver+=1.4.0
    @con_ethernet_remove @8021x
    @8021x_with_credentials
    Scenario: nmcli - ethernet - connect to 8021x - md5
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap md5 802-1x.identity user 802-1x.password password"
    Then Bring "up" connection "con_ethernet"


    @ver+=1.6.0
    @con_ethernet_remove @8021x
    @8021x_tls
    Scenario: nmcli - ethernet - connect to 8021x - tls
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap tls 802-1x.identity test 802-1x.ca-cert /tmp/certs/test_user.ca.pem 802-1x.client-cert /tmp/certs/test_user.cert.pem 802-1x.private-key /tmp/certs/test_user.key.pem 802-1x.private-key-password redhat"
    Then Bring "up" connection "con_ethernet"


    @ver+=1.4.0
    @con_ethernet_remove @8021x
    @8021x_peap_md5
    Scenario: nmcli - ethernet - connect to 8021x - peap - md5
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap peap 802-1x.identity test_md5 802-1x.anonymous-identity test 802-1x.ca-cert /tmp/certs/test_user.ca.pem 802-1x.phase2-auth md5 802-1x.password password"
    Then Bring "up" connection "con_ethernet"


    @ver+=1.4.0
    @con_ethernet_remove @8021x
    @8021x_peap_mschapv2
    Scenario: nmcli - ethernet - connect to 8021x - peap - mschapv2
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap peap 802-1x.identity TESTERS\\test_mschapv2 802-1x.anonymous-identity test 802-1x.ca-cert /tmp/certs/test_user.ca.pem 802-1x.phase2-auth mschapv2 802-1x.password password"
    Then Bring "up" connection "con_ethernet"


    @ver+=1.4.0
    @con_ethernet_remove @8021x
    @8021x_peap_gtc
    Scenario: nmcli - ethernet - connect to 8021x - peap - gtc
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap peap 802-1x.identity test_gtc 802-1x.anonymous-identity test 802-1x.ca-cert /tmp/certs/test_user.ca.pem 802-1x.phase2-auth gtc 802-1x.password password"
    Then Bring "up" connection "con_ethernet"


    @ver+=1.4.0
    @con_ethernet_remove @8021x
    @8021x_ttls_pap
    Scenario: nmcli - ethernet - connect to 8021x -ttls - pap
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap ttls 802-1x.identity test_ttls 802-1x.anonymous-identity test 802-1x.ca-cert /tmp/certs/test_user.ca.pem 802-1x.phase2-auth pap 802-1x.password password"
    Then Bring "up" connection "con_ethernet"


    @ver+=1.4.0
    @con_ethernet_remove @8021x
    @8021x_ttls_chap
    Scenario: nmcli - ethernet - connect to 8021x -ttls - chap
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap ttls 802-1x.identity test_ttls 802-1x.anonymous-identity test 802-1x.ca-cert /tmp/certs/test_user.ca.pem 802-1x.phase2-auth chap 802-1x.password password"
    Then Bring "up" connection "con_ethernet"


    @ver+=1.4.0
    @con_ethernet_remove @8021x
    @8021x_ttls_mschap
    Scenario: nmcli - ethernet - connect to 8021x -ttls - mschap
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap ttls 802-1x.identity test_ttls 802-1x.anonymous-identity test 802-1x.ca-cert /tmp/certs/test_user.ca.pem 802-1x.phase2-auth mschap 802-1x.password password"
    Then Bring "up" connection "con_ethernet"


    @ver+=1.4.0
    @con_ethernet_remove @8021x
    @8021x_ttls_mschapv2
    Scenario: nmcli - ethernet - connect to 8021x -ttls - mschapv2
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap ttls 802-1x.identity test_ttls 802-1x.anonymous-identity test 802-1x.ca-cert /tmp/certs/test_user.ca.pem 802-1x.phase2-auth mschapv2 802-1x.password password"
    Then Bring "up" connection "con_ethernet"


    @ver+=1.4.0
    @con_ethernet_remove @8021x
    @8021x_ttls_mschapv2_eap
    Scenario: nmcli - ethernet - connect to 8021x -ttls - mschap - eap
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap ttls 802-1x.identity TESTERS\\test_mschapv2 802-1x.anonymous-identity test 802-1x.ca-cert /tmp/certs/test_user.ca.pem 802-1x.phase2-autheap mschapv2 802-1x.password password"
    Then Bring "up" connection "con_ethernet"


    @ver+=1.4.0
    @con_ethernet_remove @8021x
    @8021x_ttls_md5
    Scenario: nmcli - ethernet - connect to 8021x -ttls - md5
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap ttls 802-1x.identity test_md5 802-1x.anonymous-identity test 802-1x.ca-cert /tmp/certs/test_user.ca.pem 802-1x.phase2-autheap md5 802-1x.password password"
    Then Bring "up" connection "con_ethernet"


    @ver+=1.4.0
    @con_ethernet_remove @8021x
    @8021x_ttls_gtc
    Scenario: nmcli - ethernet - connect to 8021x -ttls - gtc
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap ttls 802-1x.identity test_gtc 802-1x.anonymous-identity test 802-1x.ca-cert /tmp/certs/test_user.ca.pem 802-1x.phase2-autheap gtc 802-1x.password password"
    Then Bring "up" connection "con_ethernet"


    @rhbz1456362
    @ver+=1.8.0
    @con_ethernet_remove @8021x
    @8021x_with_raw_credentials
    Scenario: nmcli - ethernet - connect to 8021x - md5 - raw
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet autoconnect no 802-1x.eap md5 802-1x.identity user 802-1x.password-raw '70 61 73 73 77 6f 72 64'"
    Then Bring "up" connection "con_ethernet"


    @rhbz1113941
    @ver+=1.4.0
    @ver-=1.10.0
    @con_ethernet_remove @8021x
    @8021x_without_password
    Scenario: nmcli - ethernet - connect to 8021x - md5 - ask for password
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet 802-1x.eap md5 802-1x.identity user autoconnect no"
    * Spawn "nmcli -a con up con_ethernet" command
    * Expect "identity.*user"
    * Enter in editor
    * Send "password" in editor
    * Enter in editor
    Then "test8X:connected:con_ethernet" is visible with command "nmcli -t -f DEVICE,STATE,CONNECTION device" in "20" seconds


    @rhbz1113941 @rhbz1438476
    @ver+=1.10.0
    @con_ethernet_remove @8021x
    @8021x_without_password
    Scenario: nmcli - ethernet - connect to 8021x - md5 - ask for password
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet 802-1x.eap md5 802-1x.identity user"
    * Spawn "nmcli -a con up con_ethernet" command
    * Expect "identity.*user"
    * Enter in editor
    * Send "password" in editor
    * Enter in editor
    Then "test8X:connected:con_ethernet" is visible with command "nmcli -t -f DEVICE,STATE,CONNECTION device" in "20" seconds


    @ver+=1.8.0
    @con_ethernet_remove @8021x
    @8021x_without_password_with_ask_at_the_end
    Scenario: nmcli - ethernet - connect to 8021x - md5 - ask for password at the end
    * Add a new connection of type "ethernet" and options "ifname test8X con-name con_ethernet 802-1x.eap md5 802-1x.identity user autoconnect no"
    * Spawn "nmcli con up con_ethernet -a" command
    * Expect "identity.*user"
    * Enter in editor
    * Send "password" in editor
    * Enter in editor
    Then "test8X:connected:con_ethernet" is visible with command "nmcli -t -f DEVICE,STATE,CONNECTION device" in "20" seconds


    @rhbz1391477
    @ver+=1.7.1
    @con_ethernet_remove
    @preserve_8021x_certs
    Scenario: nmcli - ethernet - preserve 8021x certs
    * Add a new connection of type "ethernet" and options "ifname \* con-name con_ethernet 802-1x.eap 'tls' 802-1x.client-cert /tmp/test2_ca_cert.pem 802-1x.private-key-password x 802-1x.private-key /tmp/test_key_and_cert.pem  802-1x.password pass1"
    * Execute "nmcli con reload"
    Then "con_ethernet" is visible with command "nmcli con"


    @rhbz1374660
    @ver+=1.10
    @con_ethernet_remove
    @preserve_8021x_leap_con
    Scenario: nmcli - ethernet - preserve 8021x leap connection
    * Add a new connection of type "ethernet" and options "ifname eth1 con-name con_ethernet 802-1x.identity jdoe 802-1x.eap leap"
    * Execute "nmcli con reload"
    Then "con_ethernet" is visible with command "nmcli con"
