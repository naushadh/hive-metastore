#!/usr/bin/env bash

set -euxo pipefail

generate_database_config(){
  cat << XML
<property>
  <name>javax.jdo.option.ConnectionDriverName</name>
  <value>${DATABASE_DRIVER}</value>
</property>
<property>
  <name>javax.jdo.option.ConnectionURL</name>
  <value>jdbc:${DATABASE_TYPE_JDBC}://${DATABASE_HOST}:${DATABASE_PORT}/${DATABASE_DB}</value>
</property>
<property>
  <name>javax.jdo.option.ConnectionUserName</name>
  <value>${DATABASE_USER}</value>
</property>
<property>
  <name>javax.jdo.option.ConnectionPassword</name>
  <value>${DATABASE_PASSWORD}</value>
</property>
XML
}

generate_hive_site_config(){
  database_config=$(generate_database_config)
  cat << XML > "$1"
<configuration>
$database_config
</configuration>
XML
}

generate_metastore_site_config(){
  database_config=$(generate_database_config)
  cat << XML > "$1"
<configuration>
  <property>
    <name>metastore.task.threads.always</name>
    <value>org.apache.hadoop.hive.metastore.events.EventCleanerTask</value>
  </property>
  <property>
    <name>metastore.expression.proxy</name>
    <value>org.apache.hadoop.hive.metastore.DefaultPartitionExpressionProxy</value>
  </property>
  $database_config
  <property>
    <name>metastore.warehouse.dir</name>
    <value>s3a://${S3_BUCKET}/${S3_PREFIX}/</value>
  </property>
  <property>
    <name>metastore.thrift.port</name>
    <value>9083</value>
  </property>
</configuration>
XML
}

generate_s3_custom_endpoint(){
  if [ -z "$S3_ENDPOINT_URL" ]; then
    echo ""
    return 0
  fi

  cat << XML
<property>
  <name>fs.s3a.endpoint</name>
  <value>${S3_ENDPOINT_URL}</value>
</property>
<property>
  <name>fs.s3a.access.key</name>
  <value>${AWS_ACCESS_KEY_ID:-}</value>
</property>
<property>
  <name>fs.s3a.secret.key</name>
  <value>${AWS_SECRET_ACCESS_KEY:-}</value>
</property>
<property>
  <name>fs.s3a.connection.ssl.enabled</name>
  <value>false</value>
</property>
<property>
  <name>fs.s3a.path.style.access</name>
  <value>true</value>
</property>
XML
}

generate_core_site_config(){
  custom_endpoint_configs=$(generate_s3_custom_endpoint)
  cat << XML > "$1"
<configuration>
  <property>
      <name>fs.defaultFS</name>
      <value>s3a://${S3_BUCKET}</value>
  </property>
  <property>
      <name>fs.s3a.impl</name>
      <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>
  </property>
  <property>
      <name>fs.s3a.fast.upload</name>
      <value>true</value>
  </property>
  $custom_endpoint_configs
</configuration>
XML
}

run_migrations(){
  if /opt/hive-metastore/bin/schematool -dbType "$DATABASE_TYPE" -validate | grep 'Done with metastore validation' | grep '[SUCCESS]'; then
    echo 'Database OK'
    return 0
  else
    # TODO: how to apply new version migrations or repair validation issues
    /opt/hive-metastore/bin/schematool --verbose -dbType "$DATABASE_TYPE" -initSchema
  fi
}

# configure & run schematool
generate_hive_site_config /opt/hadoop/etc/hadoop/hive-site.xml
run_migrations

# configure & start metastore (in foreground)
generate_metastore_site_config /opt/hive-metastore/conf/metastore-site.xml
generate_core_site_config /opt/hadoop/etc/hadoop/core-site.xml
/opt/hive-metastore/bin/start-metastore
