execute immediate $$
begin
    USE DATABASE MLG_SNOWFLAKE;
    USE SCHEMA UTILITY;
    USE ROLE SYSADMIN;

    return 'Initiated the context';
end;
$$;

-- CSV_WHOLE_LINE
CREATE OR REPLACE FILE FORMAT MLG_SNOWFLAKE.UTILITY.CSV_WHOLE_LINE TYPE = 'csv';

-- CREATE_TABLE_FROM_S3_GET_FILE_HEADER_COLUMNS
CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.CREATE_TABLE_FROM_S3_GET_FILE_HEADER_COLUMNS(FILE_PATH VARCHAR)
RETURNS VARIANT NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;

    const columns = (()=> {
      const header_line = (() => {
        const rs = st({sqlText: `SELECT T.$1 FROM ${FILE_PATH}
          (FILE_FORMAT => MLG_SNOWFLAKE.UTILITY.CSV_WHOLE_LINE) T LIMIT 1;`}).execute();
        rs.next();

        return rs.getColumnValue(1);
      })();

      return (() => {
        return header_line.split('|');
      })();

    })();

    const standardize_column = (s, i) => {
      s = s.replace(/[^a-zA-Z0-9]/g, '_');
      s = s.replace(/_+/g, '_');
      s = s.replace(/^_/, '');
      s = s.replace(/_$/, '');

      if (/^[0-9]/.test(s)) {
        s = `C_${s}`;
      }

      s = s || `COLUMN_NO_${i}`;

      return s.toUpperCase();
    };

    (() => {

      for (let i = 0; i < columns.length; i++) {

        let column = columns[i];
        columns[i] = standardize_column(column, i + 1);
      }
    })();

    return columns;

$$;

-- CREATE_TABLE_FROM_S3
CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.CREATE_TABLE_FROM_S3(TABLE_NAME VARCHAR, FILE_PATH VARCHAR)
RETURNS VARCHAR NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;

    const columns = (()=> {
      const rs = st({sqlText: `CALL MLG_SNOWFLAKE.UTILITY
        .CREATE_TABLE_FROM_S3_GET_FILE_HEADER_COLUMNS('${FILE_PATH}')`}).execute();
      rs.next();

      return rs.getColumnValue(1);

    })();

    const query = (() => {
      for (let i = 0; i < columns.length; i++) {
        columns[i] = `\t${columns[i]} VARCHAR`;
      }

      return `CREATE TABLE ${TABLE_NAME} (\n${columns.join(',\n')}\n);`;
    })();
    
    return (() => {
      const rs = st({sqlText: query}).execute();
      rs.next();

      return rs.getColumnValue(1);
    })();
$$;

