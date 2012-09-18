#!/usr/bin/ruby
# Simple class to add values to facter from lldp
# Inspiration from https://github.com/mfournier/puppet-lldp/blob/master/lib/facter/lldp.rb
# Benefit of this  class is that it's a class and has tests

require 'facter'

class LLDP
    @@lldp_keys = ['chassis.name', 'port.descr', 'vlan.vlan-id', 'vlan']

    attr_accessor :is_test

    def initialize(test=nil)
        if !test
            lldp_data_hash = self.build_response()
            if lldp_data_hash
                interfaces = self.get_interfaces()
                if interfaces
                    final_array = restrict_to_keys(lldp_data_hash, interfaces)
                    add_facts(final_array)
                end
            end
        else 
            self.is_test = true
        end
    end

    def get_interfaces
        # Iterate over the Facter value 'interface'
        # Facter.value('interface') returns a , separated
        # list of interfaces
        
        tmp = Array.new
        Facter.value('interfaces').split(/,/).each do |interface|
            tmp.push interface
        end
        return tmp
    end

    def build_response
        # Check if lldp is installed on the system
        # If so, we want to get the key/value pairs
        # of the response, create a hash and return it
        
        if File.exists?('/usr/sbin/lldpctl')
            lldp_response = `lldpctl -f keyvalue`
            return(lldp_string_to_hash(lldp_response))
        else
            return nil
        end
    end

    def lldp_string_to_hash(input_string)
        lldp = Hash.new
        input_string.split(/\n/).each do |line|
            key, value = line.split(/=/)
            lldp[key] ||= Array.new
            lldp[key] << value
            lldp[key].uniq!
        end
        return lldp

    end

    def restrict_to_keys(full_lldp_response, interfaces)
        # Iterate over the interfaces
        # For each interface iterate over the full lldp response
        # Calculate a fact string from the list
        # of facts we want to add to facter and
        # return a hash of what needs added to facter
        
        tmp_hash = Hash.new
        interfaces.each do |interface, value|
            @@lldp_keys.each do |key|
                fact_string = "lldp.#{interface}.#{key}"
                if full_lldp_response.has_key?(fact_string)
                    tmp_hash[fact_string] = full_lldp_response[fact_string]
                end
            end
        end
        return tmp_hash
    end

    def add_facts(input_hash)
        # Iterate over the hash of facts to add
        # The hash is a simple key/value store
        # of the information to be added to facter
        
        input_hash.each do |key, value|
            Facter.add(key) do
                setcode do
                    value
                end
            end
        end


    end
end

if __FILE__ == $0
    require 'lldp'
    _lldp = LLDP.new(test=false)
end

