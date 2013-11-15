require 'singleton'
require 'fileutils'
require 'logger'
module Shotshare
  class Shots
    L = Logger.new STDERR

    include Singleton

    RC = "#{ENV['HOME']}/.shotsrc"

    attr_reader :config

    def run(options, args)
      @config = Config.instance().current
      @options = options

      if @options[:register]
        @config[:email] = @options[:email] if @options[:email]
        @config[:username] = @options[:username] if @options[:username]

        register
        exit
      end

      init_config

      # Assign explicit api_key
      @config[:api_key] = options[:api_key] if options[:api_key]
      raise Exception.new 'No API KEY' unless @config[:api_key]

      init_tmp_dir

      L.debug @config.to_yaml if @options[:debug]
      # Run scripts
      system(ENV['SHOTSHARE_SCRIPT']) if ENV['SHOTSHARE_SCRIPT']

      # Take the screenshot
      take_screenshot

      # Process RC file
      eval(File.open(RC).read) if File.exists?(RC)

      # Gather configuration file rules
      conf_rules = ConfigRuleContainer.instance.rules
      # Gather process rules
      proc_rules = ProcessRuleContainer.instance.rules

      uploadable_procs = evaluate_running_processes(proc_rules)
      L.info "Uploadable Procs: \n#{uploadable_procs.to_yaml}" if @options[:info]

      uploadable_configs = evaluate_configuration_files(conf_rules)
      L.info "Uploadable Configs: \n#{uploadable_configs.to_yaml}" if @options[:info]

      # Allow user to edit procs and configs
      uploadable_configs = ask_user_edit_configs(uploadable_configs) unless @options[:ignore_configs]
      uploadable_procs = ask_user_edit_procs(uploadable_procs) unless @options[:ignore_procs]

      # Prepare submission
      @publisher = Publisher.new(@config[:api_key])
      @publisher.prepare_submission

      # Upload the screenshot
      @publisher.upload_screenshot "#{@config[:tmp_dir]}/screenshot.png"
      # Upload configs
      upload_configs(uploadable_configs)
      # Upload programs
      upload_procs(uploadable_procs)

      @publisher.publish_submission

      # Cleanup files
      FileUtils.rm(Dir.glob("#{@config[:tmp_dir]}/*")) unless @options[:nocleanup]
    end

    private
    def init_config
      Config.load_config(@options[:config]) if @options[:config]
    end

    def init_tmp_dir
      FileUtils.mkdir_p(@config[:tmp_dir]) unless Dir.exists?(@config[:tmp_dir])
    end

    def register
      username = @config[:username]
      email = @config[:email]

      while !(username and email) do

        print "First, "
        while !email do
          e = get_email
          email = e if validate_email(e)
        end

        puts
        puts

        print "Lastly, "
        while !username do
          u = get_username
          username = u if validate_username(u)
        end

      end
      # END WHILE

      p = Publisher.new(nil)
      response = p.register email, username
      puts response
    end

    def get_email
      print "I'll need an email to send your api_key to.\n\nEmail: "
      gets.chomp
    end

    def get_username
      print "I need a username to associate with your work. \n
It can be anything you want as long as it's unique.\n\nUsername: "
      gets.chomp
    end

    def validate_username username
      return false unless username

      print "Username is #{username}, correct? [Y/n]: "
      validate_yes_no(gets)
    end

    def validate_email email
      return false unless email and email != ""

      print "Email is #{email}, correct? [Y/n]: "
      validate_yes_no(gets)
    end

    def validate_yes_no response
      answer = response[0].chomp
      return true if answer == ""
      return true if answer =~ /[Y|y]/
      false
    end

    def take_screenshot
      `scrot #{@config[:tmp_dir]}/screenshot.png`
    end

    def evaluate_rules(rules, list)
      L.debug "List undergoing evaluation: \n#{list.to_yaml}" if @options[:debug]
      final = []
      rules.sort_by! { | r | r.allow ? 0 : 1 }

      list.map do | l |
        if rules.length == 0
          final << l
        else
          rules.map do | rule |
            res = rule.process(l)
            final << res if res
          end
        end
      end

      final
    end

    def evaluate_running_processes(proc_rules)
      cmd = ENV['SHOTSHARE_PROC_CMD'] 
      cmd ||= "ps -au $(whoami) | awk '{print $4}' | sort | uniq -u"
      L.debug "COMMAND: #{cmd}" if @options[:debug]
      procs = `#{cmd}`.split("\n")
      evaluate_rules(proc_rules, procs)
    end

    def evaluate_configuration_files(conf_rules)
      cmd = ENV['SHOTSHARE_CONF_CMD']
      cmd ||= "find $HOME -maxdepth 1 -type f | egrep '.*(rc|\.conf)$'; find $HOME/.config -maxdepth 2 -type f | egrep '.*(rc|\.conf)$'"
      L.debug "COMMAND: #{cmd}" if @options[:debug]
      cfgs = `#{cmd}`.split("\n")
      evaluate_rules(conf_rules, cfgs)
    end

    def ask_user_edit_configs configs
      print 'Config files gather. Would you like to edit the list before they are submitted? [Y|n]: '
      configs = user_edit(configs) if validate_yes_no(gets)
      configs
    end

    def ask_user_edit_procs procs
      print 'Running processes gathered. Would you like to edit the list before they are submitted? [Y|n]: '
      procs = user_edit(procs) if validate_yes_no(gets)
      procs
    end

    def user_edit(list)
      filename = "#{@config[:tmp_dir]}/#{rand(1..500)}"
      File.open(filename, 'wb') do | file |
        list.each do | l |
          file << l << "\n"
        end
      end

      system("$EDITOR #{filename}")
      f_contents = File.open(filename).read
      L.debug "UPDATED LIST: "
      f_contents.split("\n")
    end

    def upload_configs configs
      return unless configs
      configs.each do | config |
        L.debug "Uploading config: #{config}..." if @options[:info]
        @publisher.upload_configuration config
      end
    end

    def upload_procs procs
      return unless procs
      procs.each do | proc |
        L.debug "Uploading process: #{proc}..." if @options[:info]
        @publisher.upload_program proc
      end
    end

  end
end
