require_relative 'shotshare/publisher.rb'

module Shotshare

  DEFAULT_CONFIG = {
    'api_key' => nil,
    'whitelist' => [],
    'blacklist' => [],
    'theme_directory' => "#{ENV['PWD']}",
    'force_overwrite' => false
  }

  class Investigator
    class << self

      def gather_processes file
        # Gather desktop data
        ## Get running procs for user
        procs =  `ps -au $(whoami) | awk '{print $4}' | sort | uniq -u`
        ## Read proc whitelist/blacklist
        ## TODO: Apply WHITELIST / BLACKLIST

        # Save to file
        File.open("#{theme_dir}/procs", "w") do | f |
          f << procs
        end

      end

      def gather_xresources file
        `xrdb -edit #{file}`
        # Gather .Xresources colors
        if $?
        end
      end

      private
      def prep_file file
        dir = File.dirname(file)
        dir_exists = Dir.exists?(dir)
        file_exists = File.exists?(file)

        dir_exists and file_exists
      end

    end
  end

end
