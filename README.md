# hive-metastore

Apache Hive Metastore as a Standalone server in Docker. Can be used in a modular fashion with Presto, Trino, Spark, and many other BigData tools.

There are numerous Docker images that attempt to do this, but yet to see something actually work as advertised with minimal bloat.

## Setup

### Usage

The recommended way to get this Docker Image is to pull the prebuilt image from the [Docker Hub Registry](https://hub.docker.com/r/naushadh/hive-metastore).

```bash
$ docker pull naushadh/hive-metastore
```

If you wish, you can also build the image yourself by cloning the repository, and executing the docker build command.

```bash
$ git clone https://github.com/naushadh/hive-metastore
$ cd hive-metastore
$ make build
```

You can also use DockerCompose to launch the app with all of its dependencies using [docker-compose.yml](https://raw.githubusercontent.com/naushadh/hive-metastore/main/docker-compose.yml) file in the GitHub repository. Just replace the `build` with `image`

```diff
app:
-   build: .
+   image: naushadh/hive-metastore
```

And then run

```bash
$ docker compose up -d
[+] Running 4/4
 ✔ Container hive-metastore-localstack-1  Healthy                                                                   10.8s 
 ✔ Container hive-metastore-postgres-1    Healthy                                                                   30.8s 
 ✔ Container hive-metastore-s3_setup-1    Started                                                                   11.0s 
 ✔ Container hive-metastore-app-1         Started                                                                   31.0s 
$ docker compose ps
NAME                          IMAGE                       COMMAND                  SERVICE             CREATED              STATUS                    PORTS
hive-metastore-app-1          hive-metastore-app          "./run.sh"               app                 About a minute ago   Up 8 seconds              0.0.0.0:9083->9083/tcp
hive-metastore-localstack-1   localstack/localstack:1.1   "docker-entrypoint.sh"   localstack          About a minute ago   Up 39 seconds (healthy)   4510-4559/tcp, 5678/tcp, 0.0.0.0:4566->4566/tcp
hive-metastore-postgres-1     postgres:14-alpine          "docker-entrypoint.s…"   postgres            About a minute ago   Up 39 seconds (healthy)   0.0.0.0:5432->5432/tcp
```

You can now connect to the MetaStore Thrift server at `0.0.0.0:9083` from your host machine.

### Configuration

Controlled via ENVironment variables

Key                | Required?                             | Description
-------------------|---------------------------------------|-------------
DATABASE_TYPE_JDBC | No, defaults to postgresql            | Database type<sup>1</sup> for JDBC connection
DATABASE_TYPE      | No, defaults to postgres              | Database type<sup>1</sup> for migration tool
DATABASE_DRIVER    | No, defaults to org.postgresql.Driver | Database class used for JDBC connection
DATABASE_HOST      | Yes                                   | Database host
DATABASE_PORT      | No, defaults to 5432                  | Database port
DATABASE_DB        | Yes                                   | Database name
DATABASE_USER      | Yes                                   | Database user
DATABASE_PASSWORD  | Yes                                   | Database password
S3_ENDPOINT_URL    | No                                    | Custom S3 endpoint URL; useful for LocalStack integration
S3_BUCKET          | Yes                                   | S3 bucket name
S3_PREFIX          | Yes                                   | S3 bucket prefix

> **<sup>1</sup>** Though you have the ability to modify `DATABASE_TYPE_JDBC`/`DATABASE_TYPE`, we presently only install Postgres driver.
> You'd have to extend this image and install a non-Postgres driver to change the Database type.

### Development

This project has most of the batteries included to test and verify that the app works

1. Install docker (27+) with compose

2. Launch dev environment
    ```bash
    $ make build env-up
    ```

3. Run test(s)
    ```bash
    $ make test
    ```
