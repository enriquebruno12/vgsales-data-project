print('>>> Script has begun')

from pathlib import Path
import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

def get_engine():
    load_dotenv()
    
    host = os.getenv('POSTGRES_HOST','localhost')
    port = os.getenv('POSTGRES_PORT', '5432')
    db = os.getenv('POSTGRES_DB')
    user = os.getenv('POSTGRES_USER')
    pwd = os.getenv('POSTGRES_PASSWORD')

    if not all([db, user, pwd]):
        raise ValueError('Missing variables in .env (DB/USER/PASSWORD).')
    url = f'postgresql+psycopg2://{user}:{pwd}@{host}:{port}/{db}'

    return create_engine(url)

def main():
    print('>>> Got into main()')

    project_root = Path(__file__).resolve().parents[1]
    csv_path = project_root / 'data' / 'raw' / 'vgsales.csv'

    if not csv_path.exists():s
        raise FileNotFoundError(f'CSV not found in {csv_path}')
    
    print(f'Reading CSV: {csv_path}')
    df = pd.read_csv(csv_path)

    df.columns = [c.strip().lower() for c in df.columns]

    """
    rename_map = {
        'na_sales':'na_sales',
        'eu_sales':'eu_sales',
        'jp_sales':'jp_sales',
        'other_sales':'other_sales',
        'global_sales':'global_sales'
    }

    df = df.rename(columns=rename_map)
    """

    df['rank'] = pd.to_numeric(df['rank'],errors = 'coerce')
    df['year'] = pd.to_numeric(df['year'],errors = 'coerce').astype('Int64')

    sales_cols = ['na_sales','eu_sales','jp_sales','other_sales','global_sales']
    for col in sales_cols:
        df[col]= pd.to_numeric(df[col],errors = 'coerce')

    print(f'Linhas no csv: {len(df)}')

    engine = get_engine()

    with engine.begin() as conn:
        conn.execute(text('TRUNCATE TABLE stg_vgsales_raw;'))

    print('Inserting stg_vgsales_raw into Postgres...')
    df.to_sql(
        'stg_vgsales_raw',
        con=engine,
        if_exists='append',
        index=False,
        method='multi',
        chunksize=5000,
    )

    with engine.connect() as conn:
        db_count = conn.execute(text('SELECT COUNT(*) FROM stg_vgsales_raw')).scalar()
    print(f'Inserted lines in Postgres: {db_count}')

if __name__ == '__main__':
    main()