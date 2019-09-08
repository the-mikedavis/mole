# Mole

[![Build Status](https://travis-ci.com/the-mikedavis/mole.svg?token=h2ecsdphjZp1AedKhwAq&branch=master)](https://travis-ci.com/the-mikedavis/mole)

Mole is a game like Tinder but for skin moles. You can swipe left and right on
images of moles depending on whether you think it's a good idea to have it be
checked out or whether you think it's fine.

## Technologies

* [Elixir](https://elixir-lang.org/): a dynamically typed functional language with great concurrency support and low latency. I use Elixir for all back-end logic.
* [Phoenix Framework](https://phoenixframework.org/): Rails is to Ruby as Phoenix is to Elixir. Phoenix makes it easy to write a web-app backend in Elixir.
* [PostgreSQL](https://www.postgresql.org/): An open-source and easy to use database. Postgres manages all long-term state like information in the tests. Testing with PostgreSQL is easier with elixir because of sand-box mode and rollbacks.
* [MySQL](https://www.mysql.com/): A production database. Software constraint for the target server.
* [Slime](https://slime-lang.com/): Slim HTML with support for templating in Elixir. All pages are rendered using compiled Slime.
* [Sass](http://sass-lang.com/documentation/file.INDENTED_SYNTAX.html) (indented style): a suped-up CSS with minimal syntax. Sass handles all stylization.
* [Webpack](https://webpack.js.org/): A build tool for front-end assets. Webpack automatically organizes and transpiles all front-end assets.

## How to Install It

You'll need an Ubuntu-based server with MySQL. The releases are designed
for Ubuntu 16.04 but other versions may work equally well. Go into the releases
tab of this repo on GitHub and download `mole.tag.gz` onto your server.
First, create the database under a name of your choice.
Then add these lines into your `/etc/environment`:

- [ ] `MOLE_PORT` - the port you wish to run on
  - if you want to use SSL, I recommend setting up a reverse proxy through [nginx](https://docs.nginx.com/nginx/admin-guide/web-server/reverse-proxy/) or [apache](https://httpd.apache.org/docs/2.4/howto/reverse_proxy.html)
- [ ] `MOLE_HOST` - the hostname of your server
- [ ] `MOLE_SECRET_KEYBASE` - a random secret string of (about 65) characters
  - any sort of password manager should be able to generate a good random string for this
- [ ] `MOLE_DB_DATABASE` - the database you created for the application
- [ ] `MOLE_DB_USERNAME` - the username of the MySQL user with permissions for that database
- [ ] `MOLE_DB_PASSWORD` - the password of the user who has permissions for that database
- [ ] `MOLE_DEFAULT_PASSWORD` - the default password for new admin users

#### Example

```
MOLE_PORT=4000
MOLE_HOST=example.org
MOLE_SECRET_KEYBASE=SKtholekarcoekhoe
MOLE_SIGNING_TOKEN=SKRCOEBKVtqjkseth6534$ENOu
MOLE_DB_DATABASE=mole_prod
MOLE_DB_USERNAME=user
MOLE_DB_PASSWORD=password
```

But replace these values as described above.

Now extract the application. Use `tar xzf mole.tar.gz` to extract it. You can
now run the app with `bin/mole start` (use `bin/mole stop` to stop it).
If you have your environment sourced, you should first run `bin/mole seed` to
setup the database. (Running it twice won't do anything bad.)

Once you have these in your `/etc/environment`, you can set up a service to run
the application. If your server's power goes out, you won't have to start up
the app manually. (If you don't want to do this, simply `source
/etc/environment`, `bin/mole seed`, and `bin/mole start`.) Here's a
service definition. Write this as `/etc/systemd/system/mole.service`. Now
you'll be able to run `service mole start` and never worry about it again.

```
[Unit]
Description=mole service

[Service]
WorkingDirectory=/path/to/extracted/tarball
ExecStart=mole start
ExecStop=mole stop
Restart=always
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=mole
User=root
RemainAfterExit=yes

EnvironmentFile=/etc/environment

[Install]
WantedBy=multi-user.target
```

## Building releases

To build a new release, you must compile the code for the environment you want
to release to. If you want to deploy to CentOS, you must compile the release
on a CentOS machine.

With this repository cloned, and [`asdf`](https://github.com/asdf-vm/asdf)
installed on your machine, run

```console
$ asdf plugin-add erlang
$ asdf plugin-add nodejs
$ bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring
$ asdf plugin-add elixir
$ asdf install
$ mix deps.get
$ cd assets
$ yarn install
$ ./node_modules/.bin/webpack -p
$ cd ..
$ mix phx.digest
$ MIX_ENV=prod mix release --env=prod
$ find _build -name mole.tar.gz
```

This will create a release tarball that can be extracted and installed as
detailed in the previous header.

## Developing

With this repository cloned and elixir, yarn, erlang, and mysql installed on
the development machine:

```console
$ cd assets && yarn install && cd -
$ mix deps.get
$ mix ecto.setup
$ iex -S mix phx.server
```

This will run the project locally at port 4004.
