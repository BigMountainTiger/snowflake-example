from env import env
import snowflake.connector


def fetchall(sql, params=[]):
    return __execute__(sql, params, lambda cur: cur.fetchall())


def fetchone(sql, params=[]):
    return __execute__(sql, params, lambda cur: cur.fetchone())


def execute(sql, params=[]):
    return __execute__(sql, params, lambda cur: None)


def execute_script(sqlfile):

    results = []
    with open(sqlfile, 'r', encoding='utf-8') as f:
        try:
            conn = __connect__()
            for cur in conn.execute_stream(f, remove_comments=True):
                for retn in cur:
                    results.append(retn)

        finally:
            if conn is not None:
                conn.close()

    return results


def __connect__():
    return snowflake.connector.connect(
        user=env.DBUSER,
        password=env.DBPASS,
        account=env.ACCT,
        warehouse=env.WAREHOUSE,
        database=env.DATABASE,
        schema=env.SCHEMA,
        role=env.ROLE
    )


def __execute__(sql, params, fetch):

    try:
        conn = __connect__()

        try:
            cur = conn.cursor()
            cur.execute(sql, params)
            result = cur.fetchone()

        finally:
            if cur is not None:
                cur.close()

    finally:
        if conn is not None:
            conn.close()

    return result
