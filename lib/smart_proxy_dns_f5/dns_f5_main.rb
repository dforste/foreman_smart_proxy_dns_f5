module Proxy::Dns::F5
  class Record < ::Proxy::Dns::Record

    attr_reader :gtms

    def initialize(gtm, username, password, dns_ttl)
      @gtm = gtm # Address of the bigIP GTM running zonerunner.
      @username = username # Username to ssh with. 
      @password = password # Password for user. 
      @view = view # View to manage reccord in. 
      @zones = get_zones()

      # Common settings can be defined by the main plugin, it's ok to use them locally.
      # Please note that providers must not rely on settings defined by other providers or plugins they are not related to.
      super('localhost', dns_ttl)
    end

    def do_create(name, value, type)
      logger.debug("Called do_create with name: #{name}, value: #{value}, type: #{type}.")

      name = name + '.'
      value = value + '.' if ['PTR'].include?(type)

      create_record(name, value, type)
    end

    def do_remove(name, type)
      name += '.'

      remove_all_records(name)
    end

    private
    def zrsh_exec(command)
      # Connect to a gtm via ssh and run an zrsh command. 
      # Returns the stdout of the command.
      require 'net/ssh'
      logger.info("Running this command on the GTM: #{command}.")
      Net::SSH.start( @gtm, @username, :password => @password ) do|ssh|
        ssh.exec!("echo '" + command + "' | /usr/local/bin/zrsh")
      end
    end

    def get_zones()
      # Get all the zones in the current view. 
      # Returns an array of the view. 
      view_info = zrsh_exec("displayview " + @view)
      view_info.match(/  \s+(.+)$\nOptions/m)[1].split(/\n\s+/)
    end

    def get_zone_by_address(address)
      # Get a zone to operate on given an address. 
      @zones.each do |zone| 
        return zone if address.include? (zone) 
      end
    end

    def get_records_from_zone(zone)
      # Get all the records from a zone returned in a list. 
      zone_info = zrsh_exec('displayzone ' + @view + ' ' + zone)
      zone_info.match(/\n\n(.+)/m)[1].split(/\n/)
    end 

    def get_record(address)
      # Get records in case it already exists. 
      # Return either nil, hash of 
      return_results = []
      get_records_from_zone(get_zone_by_address(address)).each do |record|
        if record.include? (address)
          return_results.append({ :type => record.split(/\s+/)[-2], :response => record.split(/\s+/)[-1], :ttl => record.split(/\s+/)[-4] }  )
        end 
      end
      return nil if return_results.length == 0
      return return_results 
    end

    def create_record(fqdn, address, type)
      # Create a record of a given type if it doesn't already exist. 
      existing = get_record(fqdn)
      if existing.is_a? Array
        # Verify existing record is correct. If not delete it. 
        existing.each do |record|
          if record[:type] == type and record[:response] == address
            logger.debug("Found correct existing record.")
          else
            logger.warn("Found incorrect record #{fqdn}, value: #{record[:response]}, type: #{record[:type]} deleting.")
            remove_record(fqdn, record[:response], record[:type], record[:ttl])
          end
        end
      else
        logger.info("Creating record for #{fqdn}, value: #{address}, type: #{type}, ttl: #{@dns_ttl}.")
        zrsh_exec("addrr " + @view + " " + get_zone_by_address(fqdn) + " " + fqdn + " " + @dns_ttl.to_s + " " + type + " " + address)
      end 
    end 

    def remove_record(fqdn, address, type, ttl)
      # Remove a given record. 
      logger.info("Deleting DNS record #{fqdn}, value: #{address}, type: #{type}, ttl: #{ttl}.")
      zrsh_exec('delrr ' + @view + " " + get_zone_by_address(fqdn) + " " + fqdn + " " + ttl.to_s + " " + type + " " + address)
    end 

    def remove_all_records(fqdn)
      # Remove all records to a given address. 
      existing = get_record(fqdn)
      if existing.is_a? Array
        existing.each do |record|
          remove_record(fqdn, record[:response], record[:type], record[:ttl])
        end
      end
    end
  end
end
