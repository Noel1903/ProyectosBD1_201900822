CREATE TABLE tu_tabla (
    fecha DATETIME,
    descripcion VARCHAR(200),
    tipo VARCHAR(30)
);

ALTER TABLE cliente
ADD COLUMN fecha_creacion DATETIME;	


#funcion para verificar texto sin numeros

DELIMITER //
CREATE FUNCTION validar_texto(texto VARCHAR(255)) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE contiene BOOLEAN;
    SET contiene = texto REGEXP '[0-9]';
    RETURN contiene;
END //
DELIMITER ;


#Funcion para verificar correo
DELIMITER //
CREATE FUNCTION validar_correo(correo VARCHAR(255)) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE es_valido BOOLEAN;
    SET es_valido = correo REGEXP '^([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:\|)?)+$';
    RETURN es_valido;
END //
DELIMITER ;

#funcion para ver si existe  el cliente
DELIMITER //
CREATE FUNCTION existe_cliente(user_ VARCHAR(255)) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE existe BOOLEAN;
    SELECT EXISTS (SELECT 1 FROM cliente WHERE usuario = user_) INTO existe;
    RETURN existe;
END //
DELIMITER ;


#Funcion para verificar si existe tipo cliente
DELIMITER //
CREATE FUNCTION existe_tipo_cliente(tipo VARCHAR(255)) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE existe BOOLEAN;
    SELECT EXISTS (SELECT 1 FROM tipo_cliente WHERE id_tipo = tipo) INTO existe;
    RETURN existe;
END //
DELIMITER ;


#Trigger para llenar historial tipo_cliente
DELIMITER //
CREATE TRIGGER historial_tipo_cliente AFTER INSERT ON tipo_cliente
FOR EACH ROW
BEGIN
	SELECT NOW() INTO @fecha;
    INSERT INTO historial (fecha,descripcion,tipo)
    VALUES (@fecha,'Se ha realizado una accion en la tabla tipo_cliente','INSERT');
END //
DELIMITER ; 

#Procedimiento almacenado para guardar el tipo_cliente
DELIMITER //

CREATE PROCEDURE registrarTipoCliente(
IN nombre VARCHAR(50),
IN descripcion VARCHAR(100)
)
BEGIN
	DECLARE contiene_numeros BOOLEAN;
    SET contiene_numeros = validar_texto(descripcion);
    
    IF contiene_numeros THEN
		SELECT 'Error: La descripcion solo debe contener texto' as Error;
	ELSE 
		INSERT INTO tipo_cliente (nombre,descripcion)
        VALUES (nombre,descripcion);
        SELECT ('Se han agregado datos a tabla tipo_cliente');
	END IF;

END //
DELIMITER ;

call registrarTipoCliente('Individual Extranjero','Este tipo de cliente es una persona individual de nacionalidad extranjera.');









#trigger para historial de tabla cliente
DELIMITER //
CREATE TRIGGER historial_cliente AFTER INSERT ON cliente
FOR EACH ROW
BEGIN
	SELECT NOW() INTO @fecha;
    INSERT INTO historial (fecha,descripcion,tipo)
    VALUES (@fecha,'Se ha realizado una accion en la tabla cliente','INSERT');
END //
DELIMITER ; 



#Procedimiento almacenado para el cliente
DELIMITER //
CREATE PROCEDURE registrarCliente(
IN id_cliente INTEGER,
IN nombre VARCHAR(40),
IN apellidos VARCHAR(40),
IN telefono VARCHAR(26),
IN correo VARCHAR(40),
IN usuario VARCHAR(40),
IN contraseña VARCHAR(200),
IN tipo_cliente INTEGER
)
proc_cliente:BEGIN
	IF validar_texto(nombre) THEN
		SELECT 'Error: El nombre o nombres debe contener solo letras' as Error;
        LEAVE proc_cliente;
	ELSEIF validar_texto(apellidos) THEN
		SELECT 'Error: El apellido o apellidos debe contener solo letras' as Error;
        LEAVE proc_cliente;
	ELSEIF NOT validar_correo(correo) THEN
		SELECT 'Error: El correo o correos tienen formato erroneo' as Error;
        LEAVE proc_cliente;
	ELSEIF existe_cliente(usuario) THEN
		SELECT 'Error: El nombre de usuario ya existe' as Error;
        LEAVE proc_cliente;
	ELSEIF NOT existe_tipo_cliente(tipo_cliente) THEN
		SELECT 'Error: El tipo de cliente no existe' as Error;
        LEAVE proc_cliente;
	ELSE
		INSERT INTO cliente (id_cliente,nombre,apellidos,telefono,correo,usuario,contraseña,tipo_cliente,fecha_creacion)
        VALUES (id_cliente,nombre,apellidos,telefono,correo,usuario,AES_ENCRYPT(contraseña, 'key-secret'),tipo_cliente,NOW());
		SELECT 'Se ingresaron datos a la tabla cliente';
    END IF;
END //
DELIMITER ;


#Trigger para llenar historial tipo_cuenta
DELIMITER //
CREATE TRIGGER historial_tipo_cuenta AFTER INSERT ON tipo_cuenta
FOR EACH ROW
BEGIN
	SELECT NOW() INTO @fecha;
    INSERT INTO historial (fecha,descripcion,tipo)
    VALUES (@fecha,'Se ha realizado una accion en la tabla tipo_cuenta','INSERT');
END //
DELIMITER ;

#Funcion para llenar tipo_cuenta
DELIMITER //
CREATE PROCEDURE registrarTipoCuenta(
IN id INTEGER,
IN nombre VARCHAR(50),
IN descripcion VARCHAR(100)
)
BEGIN
	INSERT INTO tipo_cuenta (nombre,descripcion)
    VALUES (nombre,descripcion);
    SELECT('Se han ingresado datos a la tabla tipo_cuenta');
END //
DELIMITER ;
call registrarTipoCuenta(1,'Cuenta de Cheques','Este tipo de cuenta ofrece la facilidad de emitir cheques para realizar transacciones monetarias.');


#Funcion para verificar si existe tipo cuenta
DELIMITER //
CREATE FUNCTION existe_tipo_cuenta(tipo INTEGER) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE existe BOOLEAN;
    SELECT EXISTS (SELECT 1 FROM tipo_cuenta WHERE codigo = tipo) INTO existe;
    RETURN existe;
END //
DELIMITER ;


#Funcion para verificar si existe numero cuenta
DELIMITER //
CREATE PROCEDURE registrarCuenta(
IN id_cuenta BIGINT,
IN monto_apertura DECIMAL(12,2),
IN saldo_cuenta DECIMAL(12,2),
IN descripcion VARCHAR(50),
IN fecha_apertura VARCHAR(100),
IN otros_detalles VARCHAR(100),
IN tipo_cuenta INTEGER,
IN id_cliente INTEGER
)
proc_cuenta:BEGIN
	IF existe_cuenta(id_cuenta) THEN
		SELECT 'Error: La cuenta ya existe' as Error;
        LEAVE proc_cuenta;
	ELSEIF monto_apertura <0 THEN
		SELECT 'Error: El monto de apertura debe ser positivo' as Error;
        LEAVE proc_cuenta;
	ELSEIF saldo_cuenta < 0 THEN
		SELECT 'Error: El saldo de la cuenta debe ser de 0 en adelante' as Error;
        LEAVE proc_cuenta;
	ELSEIF NOT existe_tipo_cuenta(tipo_cuenta) THEN
		SELECT 'Error: El tipo de cuenta no existe' as Error;
        LEAVE proc_cuenta;
	ELSEIF NOT existe_id_cliente(id_cliente) THEN
		SELECT 'Error: El cliente no existe' as Error;
        LEAVE proc_cuenta;
	ELSE
		IF length(fecha_apertura) > 0 THEN
			INSERT INTO cuenta (id_cuenta,monto_apertura,saldo_cuenta,descripcion,fecha_apertura,otros_detalles,tipo_cuenta,id_cliente)
            VALUES (id_cuenta,monto_apertura,saldo_cuenta,descripcion,STR_TO_DATE(fecha_apertura, '%d/%m/%Y'),otros_detalles,tipo_cuenta,id_cliente);
            SELECT 'Se han ingresado datos en  la tabla cuenta.';
		ELSE
			INSERT INTO cuenta (id_cuenta,monto_apertura,saldo_cuenta,descripcion,fecha_apertura,otros_detalles,tipo_cuenta,id_cliente)
            VALUES (id_cuenta,monto_apertura,saldo_cuenta,descripcion,DATE_FORMAT(CURDATE(), '%d/%m/%Y'),otros_detalles,tipo_cuenta,id_cliente);
			SELECT 'Se han ingresado datos en  la tabla cuenta.';
		END IF;
	END IF;
END //
DELIMITER ;
call registrarCuenta(3030206081, 800.00, 1000.00, 'Apertura de cuenta con Q800','','',3,1002);
call registrarCuenta(3030206081, 600.00, 600.00, 'Apertura de cuenta con Q500','01/04/2024','esta apertura tiene fecha',5,1001);



#Funcion para verificar si existe el id_cliente
DELIMITER //
CREATE FUNCTION existe_id_cliente(id INTEGER) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE existe BOOLEAN;
    SELECT EXISTS (SELECT 1 FROM cliente WHERE id_cliente = id) INTO existe;
    RETURN existe;
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER historial_cuenta AFTER INSERT ON cuenta
FOR EACH ROW
BEGIN
	SELECT NOW() INTO @fecha;
    INSERT INTO historial (fecha,descripcion,tipo)
    VALUES (@fecha,'Se ha realizado una accion en la tabla cuenta','INSERT');
END //
DELIMITER ;



#Trigger para el historial del producto_servicio
DELIMITER //
CREATE TRIGGER historial_cuenta AFTER INSERT ON cuenta
FOR EACH ROW
BEGIN
	SELECT NOW() INTO @fecha;
    INSERT INTO historial (fecha,descripcion,tipo)
    VALUES (@fecha,'Se ha realizado una accion en la tabla cuenta','INSERT');
END //
DELIMITER ;



#Funcion para el llenado de producto_servicio
DELIMITER //
CREATE PROCEDURE crearProductoServicio(
IN codigo_prod_serv INTEGER,
IN tipo INTEGER,
IN costo DECIMAL(12,2),
IN descripcion_prod_serv varchar(100)
)
proc_prod_serv:BEGIN
	CASE tipo 
		WHEN  1 THEN
			IF costo>0 THEN
				INSERT INTO producto_servicio (codigo_prod_serv,tipo,costo,descripcion_prod_serv)
                VALUES (codigo_prod_serv,tipo,costo,descripcion_prod_serv);
                SELECT 'Datos ingresados en la tabla producto_servicio';
                LEAVE proc_prod_serv;
			ELSE 
				SELECT 'Error: El tipo 1 tiene que tener un valor definido' AS Error;
                LEAVE proc_prod_serv;
			END IF;
		WHEN 2 THEN
			INSERT INTO producto_servicio (codigo_prod_serv,tipo,costo,descripcion_prod_serv)
                VALUES (codigo_prod_serv,tipo,costo,descripcion_prod_serv);
                SELECT 'Datos ingresados en la tabla producto_servicio';
                LEAVE proc_prod_serv;
		ELSE 
			SELECT 'Tipo no definido, es erroneo' as Error;
			LEAVE proc_prod_serv;
	END CASE;			
END //
DELIMITER ;


#Existe Producto o Servicio
DELIMITER //
CREATE FUNCTION existe_producto_servicio(id INTEGER) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE existe BOOLEAN;
    SELECT EXISTS (SELECT 1 FROM producto_servicio WHERE codigo_prod_serv = id) INTO existe;
    RETURN existe;
END //
DELIMITER ;

#Trigger de historial de compra
DELIMITER //
CREATE TRIGGER historial_compra AFTER INSERT ON compra
FOR EACH ROW
BEGIN
	SELECT NOW() INTO @fecha;
    INSERT INTO historial (fecha,descripcion,tipo)
    VALUES (@fecha,'Se ha realizado una accion en la tabla compra','INSERT');
END //
DELIMITER ;

#funcion para devolver el tipo de producto
DELIMITER //
CREATE FUNCTION retornar_tipo_prod_serv(id INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE tipo_ INTEGER;
    SELECT tipo INTO tipo_ FROM producto_servicio WHERE codigo_prod_serv = id;
    RETURN tipo_;
END //
DELIMITER ;


#Procedimiento almacenado para llenar la tabla compra
DELIMITER //
CREATE PROCEDURE realizarCompra(
IN id_compra INTEGER,
IN fecha VARCHAR(100),
IN importe_compra DECIMAL(12,2),
IN otros_detalles varchar(100),
IN codigo_prod_serv INTEGER,
IN id_cliente INTEGER
)
proc_compra:BEGIN
	DECLARE tipo_prod_serv INTEGER;
    IF NOT existe_id_cliente(id_cliente) THEN
		SELECT 'Error: El id_cliente no existe' as Error;
        LEAVE proc_compra;
	ELSE
		IF NOT existe_producto_servicio(codigo_prod_serv) THEN
			SELECT 'Error: El codigo de producto o servicio no existe' as Error;
			LEAVE proc_compra;
		ELSE
			SET tipo_prod_serv = retornar_tipo_prod_serv(codigo_prod_serv);
			CASE tipo_prod_serv
				WHEN 1 THEN
					IF importe_compra > 0 THEN
						SELECT 'Error: Como es un servicio, el valor de importe_compra debe ser 0 por ya tener un precio establecido' as Error;
						LEAVE proc_compra;
					ELSE
						INSERT INTO compra (id_compra,fecha,importe_compra,otros_detalles,codigo_prod_serv,id_cliente)
						VALUES (id_compra,STR_TO_DATE(fecha, '%d/%m/%Y'),importe_compra,otros_detalles,codigo_prod_serv,id_cliente);
						SELECT 'Datos ingresados a la tabla compra';
						LEAVE proc_compra;
					END IF;
				WHEN 2 THEN
					IF importe_compra = 0 THEN
						SELECT 'Error: Como es un producto, el valor de importe_compra debe ser mayor a 0 por no tener un precio establecido' as Error;
						LEAVE proc_compra;
					ELSE
						INSERT INTO compra (id_compra,fecha,importe_compra,otros_detalles,codigo_prod_serv,id_cliente)
						VALUES (id_compra,STR_TO_DATE(fecha, '%d/%m/%Y'),importe_compra,otros_detalles,codigo_prod_serv,id_cliente);
						SELECT 'Datos ingresados a la tabla compra';
						LEAVE proc_compra;
					END IF;
				
			END CASE;
		END IF;
	END IF;
END //
DELIMITER ;
call realizarCompra(1111, '10/04/2024', 40, 'compra de servicio', 18, 1001); 
call realizarCompra(1112, '10/04/2024', 0, 'compra de producto', 19, 1001); 
call realizarCompra(1113, '10/04/2024', 50, 'compra de producto', 19, 1001);

#Trigger del historial de realizarDeposito

DELIMITER //
CREATE TRIGGER historial_deposito AFTER INSERT ON deposito
FOR EACH ROW
BEGIN
	SELECT NOW() INTO @fecha;
    INSERT INTO historial (fecha,descripcion,tipo)
    VALUES (@fecha,'Se ha realizado una accion en la tabla deposito','INSERT');
END //
DELIMITER ;

#Funcion almacenada para el realizarDeposito


DELIMITER //

CREATE PROCEDURE realizarDeposito(
IN id_deposito INTEGER,
IN fecha VARCHAR(100),
IN monto DECIMAL(12,2),
IN otros_detalles VARCHAR(40),
IN id_cliente INTEGER
)
proc_deposito:BEGIN
	IF existe_id_cliente(id_cliente) THEN
		IF monto > 0 THEN
			INSERT INTO deposito(id_deposito,fecha,monto,otros_detalles,id_cliente)
            VALUES (id_deposito,STR_TO_DATE(fecha, '%d/%m/%Y'),monto,otros_detalles,id_cliente);
            SELECT 'Datos ingresados a la tabla deposito';
			LEAVE proc_deposito;
		ELSE
			SELECT 'Error: El monto a depositar debe ser mayor a 0' as Error;
			LEAVE proc_deposito;
		END IF;
	ELSE
		SELECT 'Error: El id_cliente no existe' as Error;
		LEAVE proc_deposito;
	END IF;
END //
DELIMITER ;


realizarDeposito(1114, '10/04/2024', 100, 'deposito de dinero', 1001);
realizarDeposito(1115, '10/04/2024', 0, 'deposito de dinero', 1001);

#Trigger del historial de realizarDebito

DELIMITER //
CREATE TRIGGER historial_debito AFTER INSERT ON debito
FOR EACH ROW
BEGIN
	SELECT NOW() INTO @fecha;
    INSERT INTO historial (fecha,descripcion,tipo)
    VALUES (@fecha,'Se ha realizado una accion en la tabla debito','INSERT');
END //
DELIMITER ;

#Funcion almacenada para el realizarDebito


DELIMITER //

CREATE PROCEDURE realizarDebito(
IN id_debito INTEGER,
IN fecha VARCHAR(100),
IN monto DECIMAL(12,2),
IN otros_detalles VARCHAR(40),
IN id_cliente INTEGER
)
proc_debito:BEGIN
	IF existe_id_cliente(id_cliente) THEN
		IF monto > 0 THEN
			INSERT INTO debito(id_debito,fecha,monto,otros_detalles,id_cliente)
            VALUES (id_debito,STR_TO_DATE(fecha, '%d/%m/%Y'),monto,otros_detalles,id_cliente);
            SELECT 'Datos ingresados a la tabla debito';
			LEAVE proc_debito;
		ELSE
			SELECT 'Error: El monto a debitar debe ser mayor a 0' as Error;
			LEAVE proc_debito;
		END IF;
	ELSE
		SELECT 'Error: El id_cliente no existe' as Error;
		LEAVE proc_debito;
	END IF;
END //
DELIMITER ;

call realizarDebito(1116, '10/04/2024', 100, 'retiro de dinero', 1001);
call realizarDebito(1117, '10/04/2024', 0, 'retiro de dinero con error', 1001);


#Trigger del historial de tipo_transaccion

DELIMITER //
CREATE TRIGGER historial_tipo_transaccion AFTER INSERT ON tipo_transaccion
FOR EACH ROW
BEGIN
	SELECT NOW() INTO @fecha;
    INSERT INTO historial (fecha,descripcion,tipo)
    VALUES (@fecha,'Se ha realizado una accion en la tabla tipo_transaccion','INSERT');
END //
DELIMITER ;

#Funcion almacenada para el tipo_transaccion


DELIMITER //

CREATE PROCEDURE registrarTipoTransaccion(
IN codigo_transaccion INTEGER,
IN nombre VARCHAR(20),
IN descripcion VARCHAR(40)
)
BEGIN
	INSERT INTO tipo_transaccion (codigo_transaccion,nombre,descripcion)
    VALUES (codigo_transaccion,nombre,descripcion);
    SELECT 'Datos ingresados a la tabla tipo_transaccion';
END //
DELIMITER ;

call registrarTipoTransaccion(1, 'Compra', 'Transacción de compra');
call registrarTipoTransaccion(2, 'Deposito', 'Transacción de deposito');
call registrarTipoTransaccion(3, 'Debito', 'Transacción de debito');