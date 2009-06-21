

module Rudy; module CLI;
  class Routines < Rudy::CLI::CommandBase
    
    def routines_valid?
      raise Rudy::NoRoutinesConfig unless @@config.routines
      true
    end
    
    def routines
      if @@config.nil? || @@config.empty?
        return if @@global.quiet
        raise Rudy::NoConfig
      end
      
      if @option.all
        routine = @@config.routines
      else
        routine = {}
        routine.merge! @@config.routines.find_deferred(@@global.environment, @@global.role) || {}
        routine.merge! @@config.routines.find(@@global.role) || {}
      end
      
      outform = @@global.format == :json ? :to_json : :to_yaml
      
      puts routine.to_hash.send(outform)
    end
    
    def startup_valid?
      @rr = Rudy::Routines::Startup.new(@alias, @option, @argv)
      @rr.raise_early_exceptions
      true
    end
    def startup
      machines = @rr.execute || []
      puts $/, "The following machines are now available:" unless machines.empty?
      machines.each do |machine|
        puts machine
      end
    end
    
    def reboot_valid?
      @rr = Rudy::Routines::Reboot.new(@alias, @option, @argv)
      @rr.raise_early_exceptions
      true
    end
    def reboot
      machines = @rr.execute
      puts $/, "The following machines have been restarted:"
      machines.each do |machine|
        puts machine
      end
    end
    
    def passthrough_valid?
      @rr = Rudy::Routines::Passthrough.new(@alias, @option, @argv)
      @rr.raise_early_exceptions
      true
    end
    
    # All unknown commands are sent here (using Drydock's trawler). 
    # By default, the generic passthrough routine is executed which
    # does nothing other than execute the routine config block that
    # matches +@alias+ (the name used on the command-line). Calling
    #
    #     $ rudy unknown
    #
    # would end up here because it's an unknown command. Passthrough
    # then looks for a routine config in the current environment and
    # role called "unknown". If found, it's executed otherwise it'll
    # raise an exception.
    #
    def passthrough
            
      machines = @rr.execute
      
      
      unless machines.empty?
        puts $/, "The following machines were processed:"
        machines.each do |machine|
          puts machine
        end
      end
      
    end
    
    def shutdown_valid?
      @rr = Rudy::Routines::Shutdown.new(@alias, @option, @argv)
      @rr.raise_early_exceptions
      true
    end
    def shutdown
      routine = fetch_routine_config(:shutdown)
      
      puts "All machines in #{current_machine_group} will be shutdown".bright
      if routine && routine.disks
        if routine.disks.destroy
          puts "The following filesystems will be destroyed:".bright
          puts routine.disks.destroy.keys.join($/).bright
        end
      end
      
      #execute_check :medium
      
      machines = @rr.execute
      
      puts $/, "The following instances have been destroyed:"
      machines.each do |machine|
        puts '%s %s ' % [machine.name.bright, machine.awsid]
      end
      
      
    end
    

  end
end; end

