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

1. Install docker and docker-compose

2. Launch dev environment
    ```bash
    $ make env-up
    ```

3. Run test(s)
    ```bash
    $ docker-compose run test
    ```
