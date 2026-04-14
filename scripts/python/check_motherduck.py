import duckdb

# Reemplaza con tu token de MotherDuck
MOTHERDUCK_TOKEN = "TU_TOKEN"

# URL de conexión JDBC/SQL para MotherDuck
# Nota: 'md:' indica que es una conexión a MotherDuck
conn_str = f"md:?motherduck_token={MOTHERDUCK_TOKEN}"

# Crear conexión
try:
    conn = duckdb.connect(conn_str)
    print("✅ Conexión establecida con MotherDuck")

    # Ejecutar una consulta de prueba
    result = conn.execute("SELECT 42 AS test_value").fetchall()
    print("Resultado de prueba:", result)

    # Cerrar conexión
    conn.close()
    print("🔒 Conexión cerrada correctamente")

except Exception as e:
    print("❌ Error al conectar:", e)
