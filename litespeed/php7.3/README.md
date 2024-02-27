# Wordpress with PHP 7.3 Open Litespeed

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
  </tbody>
</table>
