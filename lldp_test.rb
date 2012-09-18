#!/usr/bin/ruby
require 'test/unit'
require 'lldp'

class TestLLDP < Test::Unit::TestCase
    @@lldp_ctl_output = "lldp.eth0.via=LLDP
lldp.eth0.rid=1
lldp.eth0.age=17 days, 09:36:51
lldp.eth0.chassis.mac=AA:AA:AA:AA:AA:AA
lldp.eth0.chassis.name=switch1.vlan.dc.mozilla.com
lldp.eth0.chassis.mgmt-ip=10.99.99.1
lldp.eth0.chassis.Bridge.enabled=on
lldp.eth0.chassis.Router.enabled=off
lldp.eth0.port.ifname=Gi3/0/9
lldp.eth0.port.descr=GigabitEthernet3/0/9
lldp.eth0.port.auto-negotiation.supported=no
lldp.eth0.port.auto-negotiation.enabled=yes
lldp.eth0.port.auto-negotiation.current=unknown
lldp.eth0.vlan.vlan-id=75
lldp.eth0.vlan.pvid=yes
lldp.eth1.via=LLDP
lldp.eth1.rid=1
lldp.eth1.age=17 days, 09:36:49
lldp.eth1.chassis.mac=AA:AA:AA:AA:AA:AA
lldp.eth1.chassis.name=switch1.vlan.dc.mozilla.com
lldp.eth1.chassis.mgmt-ip=10.99.99.1
lldp.eth1.chassis.Bridge.enabled=on
lldp.eth1.chassis.Router.enabled=off
lldp.eth1.port.ifname=Gi4/0/9
lldp.eth1.port.descr=GigabitEthernet4/0/9
lldp.eth1.port.auto-negotiation.supported=no
lldp.eth1.port.auto-negotiation.enabled=yes
lldp.eth1.port.auto-negotiation.current=unknown
lldp.eth1.vlan.vlan-id=75
lldp.eth1.vlan.pvid=yes"

    def test_is_test
        tmp = LLDP.new(test=true)
        assert_equal tmp.is_test, true
    end

    def test_build_response
        # Placeholder test. Not sure hot to replicate
        # the output of lldpctl

        assert_equal true, true
    end

    def test_get_interfaces
        # Placeholder test. Not sure hot to replicate
        # the output of Facter('interfaces')

        assert_equal true, true
    end

    def test_add_facts
        # Placeholder test. Not sure hot to replicate
        # the output of Facter.add

        assert_equal true, true
    end

    def test_lldp_string_to_hash
        # Test construction of hash from lldp key/value string

        tmp = LLDP.new(test=true)
        response_hash = tmp.lldp_string_to_hash(@@lldp_ctl_output)
        puts response_hash
        assert_equal response_hash.length, 30
        assert_equal response_hash["lldp.eth0.port.ifname"], Gi3/0/9

    end

    def test_LLDP_restrict_to_keys
        tmp = LLDP.new(test=true)
        lldp_hash = Hash.new
        # Create a hash from the mock response string
        # This gets handled by facter
        
        @@lldp_ctl_output.split(/\n/).each do |line|
            key, value = line.split(/=/)
            lldp_hash[key] ||= Array.new
            lldp_hash[key] << value
            lldp_hash[key].uniq!
        end
        # Statically assign an array of test interfaces
        interfaces = ["bond0","eth0","eth1","lo"]

        #Get our response of the mock hash
        final = tmp.restrict_to_keys(lldp_hash, interfaces)
        assert_equal final.length, 6
        assert_equal final["lldp.eth1.chassis.name"], ["switch1.vlan.dc.mozilla.com"]
        assert_equal final["lldp.eth1.port.descr"], ["GigabitEthernet4/0/9"]
        assert_equal final["lldp.eth1.vlan.vlan-id"], ["75"]
        assert_equal final["lldp.eth0.chassis.name"], ["switch1.vlan.dc.mozilla.com"]
        assert_equal final["lldp.eth0.port.descr"], ["GigabitEthernet3/0/9"]
        assert_equal final["lldp.eth0.vlan.vlan-id"], ["75"]
    end
end
