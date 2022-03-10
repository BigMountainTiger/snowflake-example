execute immediate $$
begin
    USE DATABASE MLG_SNOWFLAKE;
    USE SCHEMA UTILITY;
    USE ROLE SYSADMIN;

    return 'Initiated the context';
end;
$$;

SELECT CURRENT_ROLE(), CURRENT_WAREHOUSE(), CURRENT_DATABASE(), CURRENT_SCHEMA();

-- COMPARE_TABLE_TO_TABLE
CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.COMPARE_TABLE_TO_TABLE(
    TABLE_NAME_1 VARCHAR,
    TABLE_NAME_2 VARCHAR
)
RETURNS VARIANT NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;

    const parse_name = (table_name) => {
        const parts = ((table_name || '').toUpperCase()).split('.');

        if (parts.length != 3) {
            throw `Please provide a fully qualified table name for ${table_name}.`;
        }

        const rs = st({sqlText: `SELECT EXISTS ( SELECT * FROM ${parts[0]}.INFORMATION_SCHEMA.TABLES
            WHERE TABLE_CATALOG = '${parts[0]}' AND TABLE_SCHEMA = '${parts[1]}' AND TABLE_NAME = '${parts[2]}' );`}).execute();

        rs.next();
        if (!rs.getColumnValue(1)) {
            throw `The table ${table_name} does not exist or you do not have access to it`;
        }

        return parts;
    };

    const PARTS_1 = parse_name(TABLE_NAME_1);
    const PARTS_2 = parse_name(TABLE_NAME_2);

    const result = (() => {

        const subquery = (parts) => {

            return `SELECT ORDINAL_POSITION, UPPER(COLUMN_NAME) AS COLUMN_NAME
                FROM ${parts[0]}.INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_CATALOG = '${parts[0]}'
                    AND TABLE_SCHEMA = '${parts[1]}'
                    AND TABLE_NAME = '${parts[2]}'
                ORDER BY ORDINAL_POSITION`;
        };

        const query = `SELECT IFNULL(T1.ORDINAL_POSITION, T2.ORDINAL_POSITION) AS ORDINAL_POSITION,
                T1.COLUMN_NAME AS T1_COLUMN_NAME,
                T2.COLUMN_NAME AS T2_COLUMN_NAME,
                IFNULL(T1.COLUMN_NAME = T2.COLUMN_NAME, FALSE) AS MATCH
            FROM (${subquery(PARTS_1)}) T1
            FULL JOIN (${subquery(PARTS_2)}) T2
                ON T1.ORDINAL_POSITION = T2.ORDINAL_POSITION
            ORDER BY ORDINAL_POSITION;`;

        const result = [];
        const rs = st({sqlText: query}).execute();

        while(rs.next()) {
            result.push({
                ORDINAL_POSITION: rs.getColumnValue(1),
                T1_COLUMN_NAME: rs.getColumnValue(2),
                T2_COLUMN_NAME: rs.getColumnValue(3),
                MATCH: rs.getColumnValue(4)
            });
        }

        return result;

    })();

    return result;
$$;

-- COMPARE_TABLE_TO_TABLE_DIFF_ONLY
CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.COMPARE_TABLE_TO_TABLE_DIFF_ONLY(
    TABLE_NAME_1 VARCHAR,
    TABLE_NAME_2 VARCHAR
)
RETURNS VARIANT NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;
    const rs = st({sqlText: `CALL MLG_SNOWFLAKE.UTILITY.COMPARE_TABLE_TO_TABLE(
        '${TABLE_NAME_1}', '${TABLE_NAME_1}'
    );`}).execute();

    rs.next();
    const columns = rs.getColumnValue(1);

    return columns.filter(c => !c.MATCH);
$$;

-- COMPARE_TABLE_TO_S3_FILE_HEADER
CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.COMPARE_TABLE_TO_S3_FILE_HEADER(
    TABLE_NAME VARCHAR,
    FILE_PATH VARCHAR
)
RETURNS VARIANT NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;

    const parse_name = (table_name) => {
        const parts = ((table_name || '').toUpperCase()).split('.');

        if (parts.length != 3) {
            throw `Please provide a fully qualified table name for ${table_name}.`;
        }

        const rs = st({sqlText: `SELECT EXISTS ( SELECT * FROM ${parts[0]}.INFORMATION_SCHEMA.TABLES
            WHERE TABLE_CATALOG = '${parts[0]}' AND TABLE_SCHEMA = '${parts[1]}' AND TABLE_NAME = '${parts[2]}' );`}).execute();

        rs.next();
        if (!rs.getColumnValue(1)) {
            throw `The table ${table_name} does not exist or you do not have access to it`;
        }

        return parts;
    };

    const PARTS = parse_name(TABLE_NAME);
    const temp_table_name = `${TABLE_NAME}_TEMP_TABLE_2022_4_FILES_IN_S3_HEADER_COLUMNS_ORDERBY_SEQUENCE`;

    const drop_temp_table_if_exists = () => {
        st({sqlText: `DROP TABLE IF EXISTS ${temp_table_name};`}).execute();
    };

    (() => {
        drop_temp_table_if_exists();
        st({sqlText: `CREATE TEMP TABLE ${temp_table_name} (
            ORDINAL_POSITION INT,
            COLUMN_NAME VARCHAR
        );`}).execute();

        const rs = st({sqlText: `CALL MLG_SNOWFLAKE.UTILITY
            .CREATE_TABLE_FROM_S3_GET_FILE_HEADER_COLUMNS('${FILE_PATH}');`}).execute();
        
        rs.next()
        const columns = rs.getColumnValue(1);
        const tuples = [];
        for (let i = 0; i < columns.length; i++) {
            tuples.push(`(${(i + 1)}, '${columns[i]}')`);
        }

        st({sqlText: `INSERT INTO ${temp_table_name} VALUES ${tuples.join(',')};`}).execute();

    })();

    const result = (() => {

        const subquery = (parts) => {

            return `SELECT ORDINAL_POSITION, UPPER(COLUMN_NAME) AS COLUMN_NAME
                FROM ${parts[0]}.INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_CATALOG = '${parts[0]}'
                    AND TABLE_SCHEMA = '${parts[1]}'
                    AND TABLE_NAME = '${parts[2]}'
                ORDER BY ORDINAL_POSITION`;
        };

        const query = `SELECT IFNULL(T1.ORDINAL_POSITION, T2.ORDINAL_POSITION) AS ORDINAL_POSITION,
                T1.COLUMN_NAME AS T_COLUMN_NAME,
                T2.COLUMN_NAME AS F_COLUMN_NAME,
                IFNULL(T1.COLUMN_NAME = T2.COLUMN_NAME, FALSE) AS MATCH
            FROM (${subquery(PARTS)}) T1
            FULL JOIN ${temp_table_name} T2
                ON T1.ORDINAL_POSITION = T2.ORDINAL_POSITION
            ORDER BY ORDINAL_POSITION;`;

        const result = [];
        const rs = st({sqlText: query}).execute();

        while(rs.next()) {
            result.push({
                ORDINAL_POSITION: rs.getColumnValue(1),
                T_COLUMN_NAME: rs.getColumnValue(2),
                FILE_HEADER_COLUMN_NAME: rs.getColumnValue(3),
                MATCH: rs.getColumnValue(4)
            });
        }

        return result;

    })();

    drop_temp_table_if_exists();

    return result;
$$;

-- COMPARE_TABLE_TO_S3_FILE_HEADER_DIFF_ONLY
CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.COMPARE_TABLE_TO_S3_FILE_HEADER_DIFF_ONLY(
    TABLE_NAME VARCHAR,
    FILE_PATH VARCHAR
)
RETURNS VARIANT NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;
    const rs = st({sqlText: `CALL MLG_SNOWFLAKE.UTILITY.COMPARE_TABLE_TO_S3_FILE_HEADER(
        '${TABLE_NAME}', '${FILE_PATH}'
    );`}).execute();

    rs.next();
    const columns = rs.getColumnValue(1);

    return columns.filter(c => !c.MATCH);
$$;




