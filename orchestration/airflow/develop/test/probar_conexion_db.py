from sqlalchemy import create_engine

url = "postgresql+psycopg2://postgres:postgres@172.24.16.1:5432/geopos"
engine = create_engine(url)

try:
    connection = engine.connect()
    print("Conexión exitosa")
    connection.close()
except Exception as e:
    print(f"Error: {e}")
