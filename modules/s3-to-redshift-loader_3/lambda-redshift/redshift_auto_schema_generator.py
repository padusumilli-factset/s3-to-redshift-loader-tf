from datetime import datetime
from typing import List
from typing import Tuple

import pandas as pd
import psycopg2 as pg
from dateutil import parser
from redshift_auto_schema import RedshiftAutoSchema


class RedshiftAutoSchemaGenerator(RedshiftAutoSchema):
    def __init__(self,
                 schema: str,
                 table: str,
                 file: str = None,
                 export_field_name: str = None,
                 export_field_type: str = None,
                 primary_key: str = None,
                 dist_key: str = None,
                 sort_key: str = None,
                 delimiter: str = '|',
                 quote_char: str = '"',
                 encoding: str = None,
                 conn: pg.extensions.connection = None,
                 default_group: str = 'dbreader',
                 file_df: pd.core.frame.DataFrame = None,
                 columns: List[str] = None,
                 column_name_sanitizers: Tuple[(str, str)] = None) -> None:

        super().__init__(schema=schema,
                         table=table,
                         file=file,
                         export_field_name=export_field_name,
                         export_field_type=export_field_type,
                         primary_key=primary_key,
                         dist_key=dist_key,
                         sort_key=sort_key,
                         delimiter=delimiter,
                         quotechar=quote_char,
                         encoding=encoding,
                         conn=conn,
                         default_group=default_group,
                         file_df=file_df,
                         columns=columns
                         )
        self.column_name_sanitizers = column_name_sanitizers

    def _replace_all(self, input_str: str):
        for r in self.column_name_sanitizers:
            input_str = input_str.replace(*r)

        return input_str

    def _load_file(self, path: str, low_memory: bool = False) -> None:
        if 'parquet' in self.file.lower():
            self.file_df = pd.read_parquet(self.file)
        else:
            chunks = pd.read_csv(self.file, sep=self.delimiter, quotechar=self.quotechar, encoding=self.encoding,
                                 low_memory=low_memory, chunksize=10_000)
            self.file_df = next(chunks)

        if self.column_name_sanitizers:
            self.file_df.columns = [self._replace_all(col) for col in self.file_df.columns]

    def _evaluate_type(self, metadata: pd.core.series.Series, identifier: bool = False) -> str:
        """Takes table column metadata as input and infers a Redshift data type from the data.

        Args:
            metadata (pd.core.series.Series): Core

        Returns:
            str: Redshift data type
        """
        name = str(metadata[0])
        column = self.file_df[name]

        if column.isnull().all():
            return 'notype'
        else:
            column = column[column.notnull()]

            if all(str(x).lower() in ["true", "false", "t", "f", "0", "1"] for x in
                   column.unique()) and identifier is False:
                return 'bool'
            else:
                try:
                    column.astype(float)
                    return 'float8'
                except (TypeError, ValueError, OverflowError):
                    try:
                        date_parse = pd.to_datetime(column, infer_datetime_format=True)
                        if not all(parser.parse(str(x), default=datetime(1900, 1, 1)) == parser.parse(str(x)) for x in
                                   column.unique()):
                            return 'varchar(256)'
                        elif all(date_parse == date_parse.dt.normalize()):
                            return 'date'
                        else:
                            return 'timestamp'
                    except (TypeError, ValueError, OverflowError):
                        if column.astype(str).map(len).max() <= 240:
                            return 'varchar(256)'
                        else:
                            return 'varchar(65535)'
