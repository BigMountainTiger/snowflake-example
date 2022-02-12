import snow


def run():
    results = snow.db.execute_script('./database/__init__.sql')
    snow.util.print_list(results)


if __name__ == '__main__':
    run()
