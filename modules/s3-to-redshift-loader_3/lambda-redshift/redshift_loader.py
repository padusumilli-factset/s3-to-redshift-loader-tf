import json
import logging
import os

import psycopg2

from redshift_auto_schema_generator import RedshiftAutoSchemaGenerator

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    host = os.getenv("host")
    dbname = os.getenv("database_name")
    user_name = os.getenv("user_name")
    iam_role = os.getenv("iam_role")
    password = os.getenv("password")
    schema_name = os.getenv("schema")
    aws_region = os.getenv("aws_region")

    logger.info(f'host: {host},'
                f' dbname: {dbname},'
                f' user_name: {user_name}'
                f' iam_role: {iam_role}'
                f' schema_name: {schema_name}'
                f' aws_region: {aws_region}')

    logger.info(f"event collected is {event}")

    for record in event['Records']:
        try:
            (table_name, src_path) = _get_file_info(record)
            logger.info("Bucket key name is {}".format(src_path))
            from_path = "s3://{}".format(src_path)
            logger.info("from path {}".format(from_path))
        except Exception as e:
            logger.error(e)

        try:
            conn = psycopg2.connect(
                dbname=dbname, host=host, port="5439", user=user_name, password=password
            )
            conn.autocommit = True
        except Exception as e:
            logger.error(f"Unable to establish connection to Redshift cluster {e}")

        # creates a table schema for a new file
        _create_schema(
            file_location=from_path, schema=schema_name, table=table_name, redshift_conn=conn
        )

        with conn.cursor() as cursor:
            copy_query = f"""
                COPY {schema_name}.{table_name} FROM '{from_path}'
                IAM_ROLE '{iam_role}'
                IGNOREHEADER AS 1
                FORMAT AS DELIMITER AS '|' 
                TRUNCATECOLUMNS
                REGION AS '{aws_region}';
                """

            logger.info("query is {}".format(copy_query))
            cursor.execute(copy_query)

        # commit and close
        conn.close()


def _get_file_info(record):
    table_name = ""
    src_path = ""
    try:
        body = json.loads(record['body'].replace("'", "\""))
        src_path = body['src_path']
        file_name = os.path.basename(src_path)
        table_name, ext = os.path.splitext(file_name)
        logger.info(f'table_name: {table_name}, src_path: {src_path}')
    except Exception as e:
        logger.error(f'Unable to parse the event for table_name and src_path \n {e} \n {record} ')
    # ex: returns "pap_extract_characteristics",
    # "fdss3-aci-data-bucket-1/pa-analytics-demo/PAP_EXTRACT_CHARACTERISTICS.txt"
    return table_name.lower(), src_path


def _create_schema(file_location, schema, table, redshift_conn):
    new_table = RedshiftAutoSchemaGenerator(
        file=file_location,
        schema=schema,
        table=table,
        conn=redshift_conn,
        column_name_sanitizers=[(".", "_"),
                                (" ", "_"),
                                ("/", "_"),
                                ("-", "_"),
                                (":", "_"),
                                ("%", "PCT"),
                                ("(", ""),
                                (")", "")]
    )
    if not new_table.check_table_existence():
        ddl = new_table.generate_table_ddl()
        logger.info(ddl)

        with redshift_conn.cursor() as cur:
            cur.execute(ddl)
