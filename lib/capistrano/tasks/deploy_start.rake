namespace :deploy do
  desc 'Start the server'
  after :finishing, :start do
    on roles(:all) do
      within current_path do
        pid_file = "/tmp/#{fetch(:application)}.pid"

        if test("[ -f #{pid_file} ]")
          puts 'Le fichier du PID a bien été trouvé et va être supprimé.'
          execute :kill, "-9 `cat #{pid_file}`"
        else
          puts "Le fichier du PID n'a pas été trouvé et ne peux pas être supprimé."
        end
        execute :bundle, "exec rackup -p #{fetch(:app_port)} --env production -o 0.0.0.0 -P #{pid_file} --daemonize"
      end
    end
  end
end