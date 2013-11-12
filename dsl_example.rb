processes do

  allow(/pianobar/) do | psname |
    psname.upcase
  end

  deny(/gvfs/)

end

config_files do

  allow('/path/to/file') do | tmp_file |
    # Operate on file before upload

  end

  deny('/path/to/file')

end

shots_config(DATA)

__END__
username: itechjunkie
key: <%= ENV['SHOTSHARE_API_KEY'] %>
editor: <%= ENV['EDITOR'] %>
