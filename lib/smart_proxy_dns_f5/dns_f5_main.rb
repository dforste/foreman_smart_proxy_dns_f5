require 'dns_common/dns_common'

module Proxy::Dns::F5
  class Record < ::Proxy::Dns::Record
    include Proxy::Log

    attr_reader :gtms

    def initialize(gtms, dns_ttl)
      @gtms = gtms

      super('localhost', dns_ttl)
    end

    def do_create(name, value, type)
      name += '.'
      value += '.' if ['PTR', 'CNAME'].include?(type)

      @gtms.each do |gtm,meta|
        host_entry = test_reccord(meta['query_server'], name)
        if ! host_entry
          zrsh_exec(gtm, meta, "addrr " + meta['view'] + " " + get_zone(gtm, meta, meta['view'], name) + " " + name + " 3600 A " + value)
        end
      end
    end

    def do_remove(name, type)
      name += '.'
      @gtms.each do |gtm,meta|
        host_entry = test_reccord(meta['query_server'], name)
        if host_entry
          zrsh_exec(gtm, meta, "delrr " + meta['view'] + " " + get_zone(gtm, meta, meta['view'], name) + " " + name + " 3600 A " + host_entry)
          zrsh_exec(gtm, meta, "delrr " + meta['view'] + " " + get_zone(gtm, meta, meta['view'], host_entry) + " " + host_entry + " 3600 A " + name)
        end
      end
    end

    private

    # A method to simply do a dns lookup with the provided nameserver and
    # request. It will return the response as a string or nil.
    def test_reccord(nameserver, query)
      require 'resolv'
      resolver = Resolv::DNS.new(:nameserver => [nameserver],
                :search => [''],
                :ndots => 1)

      if query.match(/^[0-9\.]+$/)
        resolver.getname(query).to_s
      else
        resolver.getaddress(query).to_s
      end
      rescue Resolv::ResolvError => e
    end

    def zrsh_exec(gtm, meta, command)
      require 'rubygems'
      require 'net/ssh'
      Net::SSH.start( gtm, meta['username'], :password => meta['password'] ) do|ssh|
        ssh.exec!("echo '" + command + "' | /usr/local/bin/zrsh")
      end
    end

    def get_zones(gtm, meta, view)
      view_info = zrsh_exec(gtm, meta, "displayview " + view)
      view_info.match(/  \s+(.+)$\nO/m)[1].split(/\n\s+/)
    end

    def get_zone(gtm, meta, view, address)
      if address.match(/^[0-9\.]+$/)
        reverse_zone = "in-addr.arpa."
        zones = get_zones(gtm, meta, view)
        return_zone = ""
        address.split(".").each do |octet|
          reverse_zone = octet + "." + reverse_zone
          if zones.include?(reverse_zone)
            return_zone =  reverse_zone
          end
        end
        return_zone
      else
        get_zones(gtm, meta, view).select do |zone|
          address.include? (zone)
        end [0]
      end
    end

  end
end
