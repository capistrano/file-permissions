module Capistrano
  class FileNotFound < StandardError
  end
end

def absolute_writable_paths
  linked_dirs = fetch(:linked_dirs)
  fetch(:file_permissions_paths).map do |d|
    Array(linked_dirs).include?(d) ? shared_path.join(d) : release_path.join(d)
  end
end

def acl_entries(items, type = 'u', permissions = 'rwx')
  items.map { |item| [item, "#{type}:#{item}:#{permissions}"] }.to_h
end

namespace :deploy do
  namespace :set_permissions do
    task :check do
      on roles fetch(:file_permissions_roles) do
        absolute_writable_paths.each do |path|
          unless test "[ -d #{path} ]" or test "[ -e #{path} ]"
            msg = "Cannot change permissions: #{path} is not a file or directory"
            error msg
            fail Capistrano::FileNotFound, msg
          end
        end
      end
    end

    desc "Set user/group permissions on configured paths with setfacl"
    task :acl => [:check] do
      next unless any? :file_permissions_paths
      on roles fetch(:file_permissions_roles) do |host|
        users = fetch(:file_permissions_users).push(host.user)
        entries = acl_entries(users);
        paths = absolute_writable_paths

        if any? :file_permissions_groups
          groups = fetch(:file_permissions_groups);
          entries = entries.merge(acl_entries(groups, 'g'));
        end

        paths.each do |path|
          entries.each do |user, entry|
            #checks if path already has ACL set, to determine if the -n option should be used or not
            has_facl = (capture "getfacl --absolute-names --tabular #{path} | grep #{user}.*rwx | wc -l").chomp != "0"
            
            if (has_facl)
              execute :setfacl, "-Rn", "-m #{entry}", path
              execute :setfacl, "-dRn", "-m #{entry}", path
            else
              execute :setfacl, "-R", "-m #{entry}", path
              execute :setfacl, "-dR", "-m #{entry}", path
            end
          end
        end
      end
    end

    desc "Recursively set mode (from \"file_permissions_chmod_mode\") on configured paths with chmod"
    task :chmod => [:check] do
      next unless any? :file_permissions_paths
      on roles fetch(:file_permissions_roles) do |host|
        execute :chmod, "-R", fetch(:file_permissions_chmod_mode), *absolute_writable_paths
      end
    end

    desc "Recursively change user ownership for configured paths, and make them user writable"
    task :chown => [:check] do
      next unless any? :file_permissions_paths
      next unless any? :file_permissions_users

      users = fetch(:file_permissions_users)
      if users.length > 1
        warn "More than one user configured, using the first user only"
      end

      on roles fetch(:file_permissions_roles) do |host|
        paths = absolute_writable_paths
        execute :sudo, :chown, "-R", users.first, *paths
      end
    end

    desc "Recursively change group ownership for configured paths, and make them group writable"
    task :chgrp => [:check] do
      next unless any? :file_permissions_paths
      next unless any? :file_permissions_groups

      groups = fetch(:file_permissions_groups)
      if groups.length > 1
        warn "More than one group configured, using the first group only"
      end

      on roles fetch(:file_permissions_roles) do |host|
        paths = absolute_writable_paths
        execute :sudo, :chgrp, "-R", groups.first, *paths
        # make sure all child directories inherit group writable
        execute :sudo, :chmod, "-R", "g+rws", *paths
      end
    end
  end
end

namespace :load do
  task :defaults do
    set :file_permissions_roles, :all
    set :file_permissions_paths, []
    set :file_permissions_users, []
    set :file_permissions_groups, []
    set :file_permissions_chmod_mode, "0777"
  end
end
