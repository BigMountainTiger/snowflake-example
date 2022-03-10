SELECT LEAD.ORDINAL_POSITION, LEAD_1.ORDINAL_POSITION, LEAD.COLUMN_NAME, LEAD_1.COLUMN_NAME
FROM (
	SELECT ORDINAL_POSITION, UPPER(COLUMN_NAME) AS COLUMN_NAME
	FROM INFORMATION_SCHEMA."COLUMNS"
	WHERE TABLE_NAME = 'LEAD'
		AND TABLE_CATALOG = 'MLG_SNOWFLAKE'
		AND TABLE_SCHEMA = 'UTILITY'
	ORDER BY ORDINAL_POSITION
) LEAD
FULL JOIN (
	SELECT ORDINAL_POSITION, UPPER(COLUMN_NAME) AS COLUMN_NAME
	FROM INFORMATION_SCHEMA."COLUMNS"
	WHERE TABLE_NAME = 'LEAD_1'
		AND TABLE_CATALOG = 'MLG_SNOWFLAKE'
		AND TABLE_SCHEMA = 'UTILITY'
	ORDER BY ORDINAL_POSITION
) LEAD_1 ON LEAD.ORDINAL_POSITION = LEAD_1.ORDINAL_POSITION
WHERE (LEAD.COLUMN_NAME != LEAD_1.COLUMN_NAME) OR (LEAD.COLUMN_NAME IS NULL) OR (LEAD_1.COLUMN_NAME IS NULL)
ORDER BY LEAD.ORDINAL_POSITION;


-- CREATE_TABLE_FROM_S3
CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.CREATE_TABLE_FROM_S3(TABLE_NAME VARCHAR, FILE_PATH VARCHAR)
RETURNS VARCHAR NOT NULL
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

    const query = (() => {
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

      for (let i = 0; i < columns.length; i++) {
        let column = columns[i];
        columns[i] = `\t${standardize_column(column, i+1)} VARCHAR`;
      }

      return `CREATE TABLE ${TABLE_NAME} (\n${columns.join(',\n')}\n);`;
    })();
    
    return (() => {
      const rs = st({sqlText: query}).execute();
      rs.next();

      return rs.getColumnValue(1);
    })();
$$;