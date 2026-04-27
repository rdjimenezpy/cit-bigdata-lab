import duckdb
import pandas as pd

# Crear conexión en memoria
con = duckdb.connect()

# Ejecutar consulta simple
print(con.execute("SELECT 42 AS respuesta").fetchall())

# Usar con pandas
df = pd.DataFrame({"valores": [1, 2, 3]})
print(con.execute("SELECT avg(valores) FROM df").fetchall())