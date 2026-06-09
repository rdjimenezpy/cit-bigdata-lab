DO $$
BEGIN

set search_path to samples;

INSERT INTO ventas_farmacia (fecha, id_medicamento, cantidad, precio_unitario, id_cliente, metodo_pago, notas) VALUES
        ('2024-08-17', 1, 2, 5.00, 1, 'Tarjeta', 'Compra de rutina'),
        ('2024-08-17', 2, 1, 8.00, 2, 'Efectivo', 'Venta urgente');
END $$;
