import boto3
from hive_metastore_client.builders import (  # type: ignore
    ColumnBuilder,
    DatabaseBuilder,
    SerDeInfoBuilder,
    StorageDescriptorBuilder,
    TableBuilder,
)
from hive_metastore_client import HiveMetastoreClient  # type: ignore
from thrift_files.libraries.thrift_hive_metastore_client.ttypes import Database, Table  # type: ignore
import psycopg2
import os
import typing as t
import unittest


DATABASE_NAME = 'test_database'
Env = t.Dict[str, str]


def get_test_table(db_location: str) -> Table:
    """ Inspired from: https://github.com/quintoandar/hive-metastore-client/blob/6743fb7a383f4fa00cf5235f599c239f8af2a92c/examples/create_table.py """
    # You must create a list with the columns
    columns = [
        ColumnBuilder("id", "string", "col comment").build(),
        ColumnBuilder("client_name", "string").build(),
        ColumnBuilder("amount", "string").build(),
        ColumnBuilder("year", "string").build(),
        ColumnBuilder("month", "string").build(),
        ColumnBuilder("day", "string").build(),
    ]

    # If you table has partitions create a list with the partition columns
    # This list is similar to the columns list, and the year, month and day
    # columns are the same.
    partition_keys = [
        ColumnBuilder("year", "string").build(),
        ColumnBuilder("month", "string").build(),
        ColumnBuilder("day", "string").build(),
    ]

    serde_info = SerDeInfoBuilder(
        serialization_lib="org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    ).build()

    storage_descriptor = StorageDescriptorBuilder(
        columns=columns,
        location=f"{db_location}/orders",
        input_format="org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat",
        output_format="org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat",
        serde_info=serde_info,
    ).build()

    table = TableBuilder(
        table_name="orders",
        db_name=DATABASE_NAME,
        storage_descriptor=storage_descriptor,
        partition_keys=partition_keys,
    ).build()

    return table


def put_database(db_location: str) -> Database:
    database_name = DATABASE_NAME
    database = DatabaseBuilder(name=database_name).build()
    with HiveMetastoreClient(os.environ['HIVE_HOST'], int(os.environ['HIVE_PORT'])) as client:
        client.create_database(database)
        client.create_table(get_test_table(db_location))
        return client.get_database(database_name)


class TestCRUD(unittest.TestCase):
    env: Env

    def setUp(self) -> None:
        self.env = os.environ.copy()

    def tearDown(self) -> None:
        with HiveMetastoreClient(self.env['HIVE_HOST'], int(self.env['HIVE_PORT'])) as client:
            client.drop_database(DATABASE_NAME, deleteData=True, cascade=True)

    def validate_postgres(self) -> None:
        conn = psycopg2.connect(
            host=self.env["POSTGRES_HOST"],
            dbname=self.env["POSTGRES_DB"],
            user=self.env["POSTGRES_USER"],
            password=self.env["POSTGRES_PASSWORD"],
        )
        # Lifted from: https://stackoverflow.com/a/28668161
        sql = """
            SELECT
                pgClass.relname   AS tableName,
                pgClass.reltuples AS rowCount
            FROM
                pg_class pgClass
                    INNER JOIN
                pg_namespace pgNamespace ON (pgNamespace.oid = pgClass.relnamespace)
            WHERE
                pgNamespace.nspname NOT IN ('pg_catalog', 'information_schema')
                AND pgClass.relkind='r'
        """
        with conn.cursor() as cur:
            cur.execute(sql)
            records = cur.fetchall()
        self.assertGreater(len(records), 0)

    def gen_s3_location(self) -> str:
        return f's3a://{self.env["S3_BUCKET"]}/{self.env["S3_PREFIX"]}/{DATABASE_NAME}.db'

    def validate_s3(self) -> None:
        client = boto3.client("s3", endpoint_url=self.env['S3_ENDPOINT_URL'])
        response = client.list_objects_v2(Bucket=self.env["S3_BUCKET"], Prefix=self.env["S3_PREFIX"])
        object_keys = [o["Key"] for o in response["Contents"]]
        self.assertGreater(len(object_keys), 0)

    def test_backend(self) -> None:
        db_location = self.gen_s3_location()
        database = put_database(db_location)
        self.validate_postgres()
        self.validate_s3()
        expected_database = Database(name=DATABASE_NAME, locationUri=db_location, parameters={}, ownerType=1, catalogName='hive')
        self.assertEqual(expected_database, database)
