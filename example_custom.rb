# Set logging level
# $default_opts[:log_level] = Logger::DEBUG

# Remove the temporary working directory on exit
# $default_opts[:clear_tmp] = true

# Configure git repository
#
# Configure a remote repository (which will be cloned to a temporary directory when needed)
# On ManageIQ appliances, only HTTPS URLs are allowed, because SSH support must be enabled in rugged at complile time
# $git_url  = 'https://github.com/ThomasBuchinger/automate-example.git'
# Authentication for remote repositories
# $git_user = someone
# $git_password = TOKEN
# Configure a local git repository (relative to the current working direcory). 
# The local repository is not updated automatically
# WARNING: The script may change the checked out branch and create new branches
# $git_path     = 'path/to/your/automate-repository'

# Configure ManageIQ parameters
# 
# MIQ Filesystem Domain
# This specifies the name of the automate domain on disk. 
# $export_name = 'foo'
