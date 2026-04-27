import duckdb

DB_PATH = "/opt/repo/cit-bigdata-lab/data/duckdb/mi_base.duckdb"

# Conexión a base en memoria (vacía)
con = duckdb.connect()

# Si quieres persistencia en disco:
# con = duckdb.connect(DB_PATH)

con.execute(
    """
    CREATE TABLE IF NOT EXISTS ventas_demo (
        id INTEGER,
        producto VARCHAR,
        importe DOUBLE
    )
    """
)

con.execute(
    """
    INSERT INTO ventas_demo VALUES
    (1, 'Notebook', 3500.00),
    (2, 'Monitor', 1200.00),
    (3, 'Mouse', 150.00)
    """
)

resultado = con.execute(
    """
    SELECT producto, importe
    FROM ventas_demo
    ORDER BY importe DESC
    """
).fetchall()

print("Resultado:", resultado)

con.close()