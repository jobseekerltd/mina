settings.release_path ||= lambda { "#{deploy_to}/releases/#{current_version}" }
settings.shared_path  ||= lambda { "#{deploy_to}/shared" }
settings.current_path ||= lambda { "#{deploy_to}/current" }
settings.lock_file    ||= lambda { "#{deploy_to}/deploy.lock" }

namespace :deploy do
  desc "Forces a deploy unlock."
  task :force_unlock do
    queue %{echo "-----> Unlocking"}
    queue %{rm -f "#{lock_file}"}
  end

  desc "Links paths set in :shared_paths."
  task :link_shared_paths do
    validate_set :shared_paths

    dirs = shared_paths.map { |file| File.dirname("#{release_path}/#{file}") }.uniq

    cmds = dirs.map do |dir|
      %{mkdir -p "#{dir}"}
    end

    cmds += shared_paths.map do |file|
      %{ln -s "#{shared_path}/#{file}" "#{release_path}/#{file}"}
    end

    queue %{
      echo "-----> Symlinking shared paths"
      #{cmds.join(" &&\n")}
    }
  end
end
