import json
import psycopg2
import os
from redshift_auto_schema_generator import RedshiftAutoSchemaGenerator


def lambda_handler(event, context):
    
    # copy from s3 using the access point
    src_bucket = os.getenv('src_bucket')
    dst_bucket = os.getenv('dst_bucket')
    s3_key = _get_file_location(event)
    print("Bucket key name is {}".format(s3_key))
    table_name = s3_key.split
    from_path = "s3://{}/{}".format(dst_bucket, s3_key)
    print("from path {}".format(from_path))
    
    dbname = os.getenv("database_name")
    host = os.getenv("host")
    user = os.getenv("user")
    password = os.getenv("password")
    schema_name = os.getenv("schema")
    aws_region = os.getenv("aws_region")

    print("event collected is {}".format(event))
    try:
        s3_key = _get_file_location(event)
    except Exception as e:
        print(e)

    try:
        conn = psycopg2.connect(
            dbname=dbname, host=host, port="5439", user=user, password=password
        )
    except Exception as ERROR:
        print("Unable to establish connection to Redshift cluster: " + ERROR)
    
    # creates a table schema for a new file
    create_schema(
        file_location=from_path, schema=schema_name, table=table_name, redshift_conn=conn
    )

    with conn.cursor() as cursor:
        querry = f"""
            COPY {schema_name}.{table_name} FROM '{from_path}'
            IGNOREHEADER AS 1
            FORMAT AS DELIMITER AS '|' 
            TRUNCATECOLUMNS
            REGION AS {aws_region};
            """

        print("query is {}".format(querry))
        cursor.execute(querry)

    # commit and close
    conn.close()

def _get_file_location(event):
    body = json.loads(event['Records'][0]["body"])
    message = body["Message"]
    location = message.split(',')[0]
    return location.split('=')[1]

def create_schema(file_location, schema, table, redshift_conn):
    new_table = RedshiftAutoSchemaGenerator(
        file=file_location,
         schema=schema,
          table=table,
           conn=redshift_conn,
           column_name_sanitizers = [(".", "_"), (" ", "_"), ("/", "_"), ("-", "_"), ("%", "PCT"), (":", "_"), ("(", ""), (")", "")]
    )

    if not new_table.check_table_existence():
        ddl = new_table.generate_table_ddl()
        print(ddl)

        with redshift_conn as conn:
            with conn.cursor() as cur:
                cur.execute(ddl)
