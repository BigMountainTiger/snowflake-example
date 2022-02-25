from snow import db

def run():
    row = db.fetchall('SELECT CURRENT_ROLE(), CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_WAREHOUSE()')
    print(row)


if __name__ == '__main__':
    run()
