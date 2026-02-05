import pandas as pd
from sqlalchemy import create_engine

engine = create_engine('postgresql://postgres:@localhost:5432/db_name')

xls = pd.ExcelFile('Portfolio_Data.xlsx')
for sheet in xls.sheet_names:
    df = pd.read_excel(xls, sheet_name=sheet)
    df.columns = df.columns.str.strip().str.replace(' ', '_').str.replace(r'[^A-Za-z0-9_]', '', regex=True)
    df.to_sql(sheet, engine, if_exists='replace', index=False, method='multi')
    print(f"Loaded sheet '{sheet}' ({len(df)} rows) to table '{sheet}'")
