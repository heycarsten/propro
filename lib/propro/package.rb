module Propro
  module Package
    EXTRACT_NAME_RE = %r{/ext/bash/([a-z0-9_\-/]+)\.sh}
    SORTED_NAMES = %w[
      lib/propro
      lib/ubuntu
      lib/system
      lib/pg
      lib/rvm
      lib/nginx
      lib/node
      lib/redis
      vps/system
      app
      app/rvm
      app/pg
      app/nginx
      app/sidekiq
      app/puma
      app/puma/nginx
      app/node
      db/pg
      db/redis
      vagrant
      vagrant/system
      vagrant/pg
      vagrant/redis
      vagrant/rvm
      vagrant/node
      vagrant/nginx
      lib/extras
    ]

    module_function

    def root
      File.join(Propro.root, 'ext/bash')
    end

    def source_files
      @source_files ||= Dir[File.join(root, '**/*.sh')]
    end

    def sources
      @sources ||= begin
        names = SORTED_NAMES.dup
        source_files.each do |file|
          name = EXTRACT_NAME_RE.match(file)[1]
          names.push(name) unless names.include?(name)
        end
        names.map { |name| Source.new(name) }
      end
    end

    def sources_for_path(path)
      resort! sources.select { |source| /\A#{path}/ =~ source.name }
    end

    def sources_for_paths(*paths)
      resort! paths.flatten.map { |path| sources_for_path(path) }.flatten
    end

    def resort!(ary)
      ary.sort_by! { |source| SORTED_NAMES.index(source.name) }
      ary
    end
  end
end
