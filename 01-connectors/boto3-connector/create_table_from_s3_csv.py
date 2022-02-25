import sys
from aws import s3


def create_sql(file_name):

    def get_sql():

        def get_columns():
            header_line = s3.get_file_headers(file_name)
            headers = header_line.split('|')
            columns = []

            for h in headers:
                h = h.strip().replace(' ', '_').replace('-', '_')
                columns.append(f"\t{h} VARCHAR")

            return ",\n".join(columns)

        columns = get_columns()
        table_name = file_name.split('.')[0].replace('-', '_').upper()
        sql = f'CREATE OR REPLACE TABLE {table_name} (\n{columns}\n);'

        return sql

    return get_sql()


if __name__ == '__main__':
    try:
        sql = create_sql('aaaa.txt')
    except Exception as e:
        print(e)
        sys.exit()

    print(sql)
