lock '~> 3.11.0'

set :application, 'virtuatable-sessions'
set :deploy_to, '/var/www/sessions'
set :repo_url, 'git@github.com:jdr-tools/sessions.git'
set :branch, 'master'

append :linked_files, 'config/mongoid.yml'
append :linked_files, '.env'
append :linked_dirs, 'bundle'
append :linked_dirs, 'log'