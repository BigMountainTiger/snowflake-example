import os
from dotenv import load_dotenv

path = os.path.dirname(os.path.abspath(__file__))
load_dotenv(f'{path}/.env')

DBUSER = os.getenv('DBUSER')
DBPASS = os.getenv('DBPASS')
ACCT = os.getenv('ACCT')
WAREHOUSE = os.getenv('WAREHOUSE')
DATABASE = os.getenv('DATABASE')
SCHEMA = os.getenv('SCHEMA')
ROLE = os.getenv('ROLE')

aws_access_key_id = os.getenv('aws_access_key_id')
aws_secret_access_key = os.getenv('aws_secret_access_key')
