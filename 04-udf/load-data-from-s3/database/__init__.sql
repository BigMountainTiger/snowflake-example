-- https://docs.snowflake.com/en/developer-guide/snowflake-scripting/

USE ROLE SYSADMIN;
SELECT CURRENT_ROLE(), CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_WAREHOUSE();

CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.LOAD_UTIL_LIST_FILES_FROM_S3(FILE_DIR VARCHAR)
RETURNS VARIANT NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;

    const files = (() => {
        const files = [];
        const rs = st({sqlText: `LIST ${FILE_DIR};`}).execute();

        while (rs.next()) {
            files.push(rs.getColumnValue(1));
        }

        return files;
    })();

    (() => {
        const stage = (() => {
            return FILE_DIR.split('/')[0];
        })();

        const get_stage_path = (s3_path) => {
            s3_path = s3_path.replace(/^s3:\/\//, '');
            const sections = s3_path.split('/');
            sections[0] = stage

            return sections.join('/');
        }

        for (let i = 0; i < files.length; i++) {
            files[i] = get_stage_path(files[i]);
        }

        files.sort();
        
    })();

    return files;
    
$$;


CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.LOAD_SIMPLE_COPY_INTO_FROM_S3(TABLE_NAME VARCHAR, FILE_PATH VARCHAR)
RETURNS VARCHAR NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;

    const skip = 1;
    st({sqlText: `COPY INTO ${TABLE_NAME} FROM ${FILE_PATH}
	          FILE_FORMAT = (TYPE = csv FIELD_DELIMITER = '|' SKIP_HEADER = ${skip} VALIDATE_UTF8 = FALSE)
	          ON_ERROR = CONTINUE;`}).execute();

    return 'SUCCESS';
$$;

CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.LOAD_FULL_REPLACE_FROM_S3(TABLE_NAME VARCHAR, FILE_PATH VARCHAR)
RETURNS VARCHAR NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;

    const temp_tb = (() => {
        return `${TABLE_NAME}_temp`;
    })();

    const drop_temp_table_if_exists = () => {
        st({sqlText: `DROP TABLE IF EXISTS ${temp_tb};`}).execute();
    };

    (() => {
        drop_temp_table_if_exists();
        st({sqlText: `CREATE TABLE ${temp_tb} LIKE ${TABLE_NAME};`}).execute();
    })();

    (() => {
        const cmds = [];
        cmds.push(`CALL MLG_SNOWFLAKE.UTILITY.LOAD_SIMPLE_COPY_INTO_FROM_S3('${temp_tb}', '${FILE_PATH}');`);
        cmds.push(`CREATE TABLE IF NOT EXISTS ${TABLE_NAME} LIKE ${temp_tb};`);
        cmds.push(`ALTER TABLE ${temp_tb} SWAP WITH ${TABLE_NAME}`);        

        for (const cmd of cmds) {
            st({sqlText: cmd}).execute();
        }
    })();

    drop_temp_table_if_exists();

    return 'SUCCESS';

$$;


CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.LOAD_INCREMENTAL_FROM_S3(TABLE_NAME VARCHAR, FILE_PATH VARCHAR, KEYS VARCHAR)
RETURNS VARCHAR NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;

    const temp_tb = (() => {
        return `${TABLE_NAME}_temp`;
    })();

    const drop_temp_table_if_exists = () => {
        st({sqlText: `DROP TABLE IF EXISTS ${temp_tb};`}).execute();
    };

    (() => {
        drop_temp_table_if_exists();
        st({sqlText: `CREATE TEMP TABLE ${temp_tb} LIKE ${TABLE_NAME};`}).execute();
    })();

    (() => {
        const cmds = [];
        cmds.push(`CALL MLG_SNOWFLAKE.UTILITY.LOAD_SIMPLE_COPY_INTO_FROM_S3('${temp_tb}', '${FILE_PATH}');`);

        const delete_query = (() => {
            const keys = KEYS.split('|');

            const match_keys = [];
            for (let key of keys) {
                key = key.trim();
                match_keys.push(`T.${key} = D.${key}`);
            }

            const query = `DELETE FROM ${TABLE_NAME} T 
                USING ${temp_tb} D
                WHERE ${match_keys.join(' AND ')}`;

            return query;
        })();

        cmds.push(delete_query);
        cmds.push(`INSERT INTO ${TABLE_NAME} SELECT * FROM ${temp_tb}`);

        for (const cmd of cmds) {
            st({sqlText: cmd}).execute();
        }
    })();

    drop_temp_table_if_exists();

    return 'SUCCESS';

$$;

CREATE or REPLACE PROCEDURE MLG_SNOWFLAKE.UTILITY.LOAD_APPEND_FROM_S3(TABLE_NAME VARCHAR, FILE_PATH VARCHAR)
RETURNS VARCHAR NOT NULL
LANGUAGE javascript
EXECUTE AS CALLER
AS
$$
    const st = snowflake.createStatement;

    const temp_tb = (() => {
        return `${TABLE_NAME}_temp`;
    })();

    const drop_temp_table_if_exists = () => {
        st({sqlText: `DROP TABLE IF EXISTS ${temp_tb};`}).execute();
    };

    (() => {
        drop_temp_table_if_exists();
        st({sqlText: `CREATE TEMP TABLE ${temp_tb} LIKE ${TABLE_NAME};`}).execute();
    })();

    (() => {
        const cmds = [];
        cmds.push(`CALL MLG_SNOWFLAKE.UTILITY.LOAD_SIMPLE_COPY_INTO_FROM_S3('${temp_tb}', '${FILE_PATH}');`);
        cmds.push(`INSERT INTO ${TABLE_NAME} SELECT * FROM ${temp_tb}`);

        for (const cmd of cmds) {
            st({sqlText: cmd}).execute();
        }
    })();

    drop_temp_table_if_exists();

    return 'SUCCESS';

$$;
