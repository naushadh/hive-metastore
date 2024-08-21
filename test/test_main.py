#!/usr/bin/env python

from hive_metastore_client.builders import DatabaseBuilder
from hive_metastore_client import HiveMetastoreClient
import os


def main() -> None:
    database_name = 'test_database'
    database = DatabaseBuilder(name=database_name).build()
    with HiveMetastoreClient(os.environ['HIVE_HOST'], int(os.environ['HIVE_PORT'])) as client:
        client.create_database(database)
        print(client.get_database(database_name))
        client.drop_database(database_name, deleteData=True, cascade=True)


if __name__ == "__main__":
    main()
