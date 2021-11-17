# Wordpress with PHP 7.4 Open Litespeed

## Environmental Configuration Options

_Note: These only apply during initial installation. Once there are files in the volume, changing these values will have no effect._

<table>
  <thead>
    <tr>
      <th>Name</th>
      <th>Value</th>
      <th>Default</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>WORDPRESS_DB_HOST</td>
      <td>IP or Hostname of MySQL Database</td>
      <td><pre>null</pre></td>
    </tr>
    <tr>
      <td>WORDPRESS_DB_NAME</td>
      <td>Name of database</td>
      <td><pre>null</pre></td>
    </tr>
    <tr>
      <td>WORDPRESS_DB_USER</td>
      <td>Database username</td>
      <td><pre>root</pre></td>
    </tr>
    <tr>
      <td>WORDPRESS_DB_PASSWORD</td>
      <td>Database User password</td>
      <td><pre>null</pre></td>
    </tr>
    <tr>
      <td>WORDPRESS_PLUGINLIST</td>
      <td>comma separated list of plugins to install</td>
      <td><pre>litespeed-cache,wp-mail-smtp</pre></td>
    </tr>
    <tr>
      <td>WORDPRESS_TIMEZONE</td>
      <td>Timezone</td>
      <td><pre>UTC</pre></td>
    </tr>
    <tr>
      <td>WORDPRESS_LANGUAGE</td>
      <td>Language pack to install</td>
      <td><pre>en_US</pre></td>
    </tr>
    <tr>
      <td>SMTP_SERVER</td>
      <td>IP or Hostname of the SMTP server</td>
      <td><pre>null</pre></td>
    </tr>
    <tr>
      <td>SMTP_PASSWORD</td>
      <td>SMTP Password</td>
      <td><pre>null</pre></td>
    </tr>
    <tr>
      <td>SMTP_USERNAME</td>
      <td>Username</td>
      <td><pre>null</pre></td>
    </tr>
    <tr>
      <td>SMTP_PORT</td>
      <td>smtp port</td>
      <td><pre>null</pre></td>
    </tr>
  </tbody>
</table>

## Monarx Support

The php7.4 variant of this image includes support for [Monarx](https://www.monarx.com). By default it's _**disabled**_ unless you include the following environmental variables at boot (_can be enabled after initial install_):

* `MONARX_ID`
* `MONARX_SECRET`
