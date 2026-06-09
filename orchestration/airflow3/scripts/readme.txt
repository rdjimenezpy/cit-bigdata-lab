# Manual de Ayuda:
airflow --help
airflow webserver --help
airflow scheduler --help
airflow triggerer --help

# Permisos y formatos para los scripts
chmod +x start_airflow.sh
chmod +x status_airflow.sh
chmod +x stop_airflow.sh

sed -i 's/\r//' start_airflow.sh
sed -i 's/\r//' status_airflow.sh
sed -i 's/\r//' stop_airflow.sh