# This runs all the snowflake script files
# It requires the virtualenv and the PYTHONPATH
# 1. source .python/.env-3.9/bin/activate
# 2. source .python/PYTHONPATH
# 3. Pass the script file path as the argumner

import sys
import snow

def run():
    if len(sys.argv) != 2:
        print('Please provide the script file name')
        return

    results = snow.db.execute_script(sys.argv[1])
    snow.util.print_list(results)


if __name__ == '__main__':
    run()
