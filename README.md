# Smart Proxy DNS F5 provider

*Introduction*

This plugin adds a new DNS provider for managing records in an array of F5 GTMs using an account with ssh access and zrsh(ZoneRunner) commands.

## Installation

See [How_to_Install_a_Smart-Proxy_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Smart-Proxy_Plugin)
for how to install Smart Proxy plugins

This plugin is compatible with Smart Proxy 1.10 or higher.

## Configuration

To enable this DNS provider, edit `/etc/foreman-proxy/settings.d/dns.yml` and set:

    :use_provider: dns_f5

Configuration options for this plugin are in `/etc/foreman-proxy/settings.d/dns_f5.yml` and include:

* gtms: A hash object containing one or more addresses for GTMs. Each has contains the following:
* username: The username to connect to the GTM with. This user needs the advanced shell access setup when created. It has only been tested as admin on all partitions but more restrictive will likely work.
* password: The password to connect to the GTM with.
* view: The view to create the A records and PTR records. We also support deletion on host removal.
* query_server: This is the server to query in case you need to proxy your request out somewhere. IE you are modifying a view you would not get normally.

Example
```
 :gtms:
   "10.0.0.10":
     password: password
     query_server: "10.0.0.10"
     username: foreman_proxy
     view: Default
```

## Contributing

Fork and send a Pull Request. Thanks!

## Copyright

Copyright (c) 2017 Doug Forster

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
