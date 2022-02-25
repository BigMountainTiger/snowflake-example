CREATE or REPLACE PROCEDURE CREATE_TABLE(TABLE_NAME VARCHAR, STAGE VARCHAR, FILE_PATH VARCHAR)
RETURNS VARCHAR NOT NULL
LANGUAGE javascript
AS
$$
    const st = snowflake.createStatement;

    const columns = (()=> {
      const header_line = (() => {
        const rs = st({sqlText: `SELECT T.$1 FROM ${STAGE}/${FILE_PATH}
          (FILE_FORMAT => CSV_WHOLE_LINE) T LIMIT 1;`}).execute();
        rs.next();

        return rs.getColumnValue(1);
      })();

      return (() => {
        return header_line.split('|');
      })();

    })();

    const standardize_column = (column) => {
      return column;
    };

    const query = (() => {
      for (let i = 0; i < columns.length; i++) {
        let column = columns[i];
        columns[i] = `\t${standardize_column(column)} VARCHAR`;
      }

      return `CREATE OR REPLACE TABLE ${TABLE_NAME} (\n${columns.join(',\n')}\n);`;
    })();
    
    return (() => {
      const rs = st({sqlText: query}).execute();
      rs.next();

      return rs.getColumnValue(1);
    })();
$$;

CALL CREATE_TABLE('AAAA', '@S3_HUGE_HEAD_LI_2022_STAGE', 'aaaa.txt');