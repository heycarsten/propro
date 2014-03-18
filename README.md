# Propro

_**Provision servers with Bash :trollface:**_

### Warning

_**Propro is pre-release software, it works for me but it might not work for you.**_

Propro was developed against Ubuntu Server 12.04 LTS 32bit and 64bit. It's been
tested on Vagrant with VMware Fusion and Virtual Box, and on Linode. It _could_
(and might) work with other distributions and providers, but right now it only
supports my personal use-cases.

### Creating A .propro Script

```sh
propro init -t vagrant
```

This will create a file in the current directory called `provision.propro` this
file looks a lot like:

```ruby
source :vagrant

# lib/system
set :system_shmall_percent, 0.75
set :system_shmmax_percent, 0.5
set :system_locale, "en_US.UTF-8"
set :system_timezone, "Etc/UTC"

# lib/pg
set :pg_version, 9.3
set :pg_extensions, [
  "btree_gin",
  "btree_gist",
  "fuzzystrmatch",
  "hstore",
  "intarray",
  "ltree",
  "pg_trgm",
  "tsearch2",
  "unaccent"
] # see: http://www.postgresql.org/docs/9.3/static/contrib.html

# lib/nginx
set :nginx_version, "1.4.4"
set :nginx_configure_opts, [
  "--with-http_ssl_module",
  "--with-http_gzip_static_module"
]
set :nginx_client_max_body_size, "5m"
set :nginx_worker_connections, 2000

# lib/node
set :node_version, "0.10.25"

# lib/redis
set :redis_version, "2.8.4"
set :redis_force_64bit, false # Force 64bit build even if available memory is lte 4GiB

# vagrant/system
provision "vagrant/system"

# vagrant/pg
provision "vagrant/pg"

# vagrant/redis
provision "vagrant/redis"

# vagrant/rvm
set :vagrant_rvm_ruby_version, "2.0.0"
provision "vagrant/rvm"

# vagrant/node
provision "vagrant/node"

# vagrant/nginx
provision "vagrant/nginx"

# lib/extras
set :extra_packages, []
provision "extras"
```

This generated file contains all of the available provisioners with their
default options listed above them. The `provision` directives tell Propro that
you want to run the provisioner for that given module. Seems overly complicated?
It probably is, and my next goal for Propro is to massively simplify it's
organization and the `.propro` syntax.

### Building a .propro script

Once your `.propro` is the way you want, you can tell Propro to build it into a
Bash script:

```sh
$ propro build provision.propro
```

This will output the shell script to standard output, if you'd like you can
specify a filename to output to with the `-o` option.

```sh
$ propro build -o myapp/lib/provision_vagrant.sh provision.propro
```

Now you can tell Vagrant to use this file with the `:shell` provisioner type.

### Deploying a provisioning script

If you're building a VPS, not just a development VM, you might find the `deploy`
task handy. Assume `0.0.0.0` is the public IP of a freshly built Linode, use
it like this:

```sh
$ propro deploy -s 0.0.0.0 web_server.propro
```

Propro will ask you for the root password, and then build and run the
provisioning script remotely while showing you output. Part of the built in
VPS provisioner is to disable root login access.

### More

- Check out the [`examples`](/examples) directory for examples of `.propro`
  scripts
- Check out the [`ext/bash`](/ext/bash) directory to see the actual Bash scripts
  that are used for provisioning.

### Thanks

- Existing tools that made me so crazy I ended up doing this.
- My coworkers and friends [@elucid](https://github.com/elucid) [@ghedamat](https://github.com/ghedamat) [@drteeth](https://github.com/drteeth) [@minusfive](https://github.com/minusfive) for reviewing, fiddling with, and using Propro during it's initial development.
