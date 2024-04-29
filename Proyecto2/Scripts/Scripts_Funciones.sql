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
IN id INTEGER
IN nombre VARCHAR(50),
IN descripcion VARCHAR(100)
)
proc_tiCli:BEGIN
	IF existe_tipo_cliente(id) THEN
		SELECT 'Error: El tipo cliente ya existe' as Error;
		LEAVE proc_tiCli;
	END IF;
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
IN telefono VARCHAR(200),
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
proc_tipC:BEGIN
	IF nombre or descripcion is  THEN
		SELECT 'Error: El nombre o la descripcion estan vacios' as Error;
		LEAVE proc_tipC;
	END IF;
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




#Funcion para ingresar la cuenta
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
	ELSEIF NOT monto_apertura = saldo_cuenta THEN
		SELECT 'Error: El saldo de la cuenta debe ser igual al monto de apertura' as Error;
        LEAVE proc_cuenta;
	ELSE
		IF length(fecha_apertura) > 0 THEN
			INSERT INTO cuenta (id_cuenta,monto_apertura,saldo_cuenta,descripcion,fecha_apertura,otros_detalles,tipo_cuenta,id_cliente)
            VALUES (id_cuenta,monto_apertura,saldo_cuenta,descripcion,STR_TO_DATE(fecha_apertura, '%d/%m/%Y %H:%i:%s'),otros_detalles,tipo_cuenta,id_cliente);
            SELECT 'Se han ingresado datos en  la tabla cuenta.';
		ELSE
			INSERT INTO cuenta (id_cuenta,monto_apertura,saldo_cuenta,descripcion,fecha_apertura,otros_detalles,tipo_cuenta,id_cliente)
            VALUES (id_cuenta,monto_apertura,saldo_cuenta,descripcion,CURDATE(),otros_detalles,tipo_cuenta,id_cliente);
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
	IF costo <0 THEN
		SELECT 'Error: El saldo debe ser mayor a 0';
		LEAVE proc_prod_serv;
	END IF;
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
						VALUES (id_compra,STR_TO_DATE(fecha, '%d/%m/%Y'),retornar_monto_servicio(codigo_prod_serv),otros_detalles,codigo_prod_serv,id_cliente);
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


#Trigger del historial de transaccion

DELIMITER //
CREATE TRIGGER historial_transaccion AFTER INSERT ON transaccion
FOR EACH ROW
BEGIN
	SELECT NOW() INTO @fecha;
    INSERT INTO historial (fecha,descripcion,tipo)
    VALUES (@fecha,'Se ha realizado una accion en la tabla transaccion','INSERT');
END //
DELIMITER ;




#Existe tipo_transaccion
DELIMITER //
CREATE FUNCTION existe_tipo_transaccion(id INTEGER) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE existe BOOLEAN;
    SELECT EXISTS (SELECT 1 FROM tipo_transaccion WHERE codigo_transaccion = id) INTO existe;
    RETURN existe;
END //
DELIMITER ;


#Existe compra_debito_deposito
DELIMITER //
CREATE FUNCTION existe_c_d_d(id INTEGER) RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE existe BOOLEAN;
    SELECT EXISTS (SELECT 1 FROM compra WHERE id_compra = id) INTO existe;
    IF existe THEN
		RETURN existe;
	ELSE
		SELECT EXISTS (SELECT 1 FROM debito WHERE id_debito = id) INTO existe;
        IF existe THEN
			RETURN existe;
		ELSE
			SELECT EXISTS (SELECT 1 FROM deposito WHERE id_deposito = id) INTO existe;
            RETURN existe;
		END IF;
	END IF;
END //
DELIMITER ;


#funcion para devolver saldo de cuenta
DELIMITER //
CREATE FUNCTION retornar_saldo_cuenta(id BIGINT) RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE saldo_c INTEGER;
    SELECT saldo_cuenta INTO saldo_c FROM cuenta WHERE id_cuenta = id;
    RETURN saldo_c;
END //
DELIMITER ;


#funcion para devolver monto compra
DELIMITER //
CREATE FUNCTION retornar_monto_compra(id INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE monto INTEGER;
    SELECT importe_compra INTO monto FROM compra WHERE id_compra = id;
    RETURN monto;
END //
DELIMITER ;


#funcion para devolver monto debito
DELIMITER //
CREATE FUNCTION retornar_monto_debito(id INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE monto_d INTEGER;
    SELECT monto INTO monto_d FROM debito WHERE id_debito = id;
    RETURN monto_d;
END //
DELIMITER ;


#funcion para devolver monto deposito
DELIMITER //
CREATE FUNCTION retornar_monto_deposito(id INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE monto_d INTEGER;
    SELECT monto INTO monto_d FROM deposito WHERE id_deposito = id;
    RETURN monto_d;
END //
DELIMITER ;

#funcion para historial de actualizacion
DELIMITER //
CREATE PROCEDURE actualizar_historial(nombre_t VARCHAR(200))
BEGIN
    SELECT NOW() INTO @fecha;
    INSERT INTO historial (fecha,descripcion,tipo)
    VALUES (@fecha,CONCAT('Se ha realizado una accion en la tabla ',nombre_t),'UPDATE');
END //
DELIMITER ;



#Funcion almacenada para la transaccion

DELIMITER //

CREATE PROCEDURE asignarTransaccion(
IN id_transaccion INTEGER,
IN fecha VARCHAR(100),
IN otros_detalles VARCHAR(40),
IN id_tipo_transaccion INTEGER,
IN id_c_d_d INTEGER,
IN no_cuenta BIGINT
)
prod_transa:BEGIN
	IF NOT existe_tipo_transaccion(id_tipo_transaccion) THEN
		SELECT 'Error: El tipo de transaccion no esta definido' as Error;
        LEAVE prod_transa;
	ELSEIF NOT existe_c_d_d(id_c_d_d) THEN
		SELECT 'Error: El id_compra,id_debito o id_deposito no existe' as Error;
        LEAVE prod_transa;
	ELSEIF NOT existe_cuenta(no_cuenta) THEN
		SELECT 'Error: El numero de cuenta no existe' as Error;
        LEAVE prod_transa;
	ELSE
		CASE id_tipo_transaccion
			WHEN 1 THEN
				IF retornar_saldo_cuenta(no_cuenta) >= retornar_monto_compra(id_c_d_d) THEN
					INSERT INTO transaccion (id_transaccion,fecha,otros_detalles,id_tipo_transaccion,id_compra,id_deposito,id_debito,no_cuenta)
                    VALUES (id_transaccion,STR_TO_DATE(fecha, '%d/%m/%Y'),otros_detalles,id_tipo_transaccion,id_c_d_d,0,0,no_cuenta);
                    UPDATE cuenta
                    SET saldo_cuenta = saldo_cuenta - retornar_monto_compra(id_c_d_d)
                    WHERE id_cuenta = no_cuenta;
                    call actualizar_historial('cuenta');
                    SELECT 'Datos almacenados en la tabla transaccion';
                    LEAVE prod_transa;
				ELSE
                    SELECT 'Error: el monto de compra es mayor al saldo de la cuenta' as Error;
                    LEAVE prod_transa;
				END IF;
			WHEN 2 THEN
				INSERT INTO transaccion (id_transaccion,fecha,otros_detalles,id_tipo_transaccion,id_compra,id_deposito,id_debito,no_cuenta)
				VALUES (id_transaccion,STR_TO_DATE(fecha, '%d/%m/%Y'),otros_detalles,id_tipo_transaccion,0,id_c_d_d,0,no_cuenta);
				UPDATE cuenta
				SET saldo_cuenta = saldo_cuenta + retornar_monto_deposito(id_c_d_d)
				WHERE id_cuenta = no_cuenta;
				call actualizar_historial('cuenta');
				SELECT 'Datos almacenados en la tabla transaccion';
				LEAVE prod_transa;
			WHEN 3 THEN
				IF retornar_saldo_cuenta(no_cuenta) >= retornar_monto_debito(id_c_d_d) THEN
					INSERT INTO transaccion (id_transaccion,fecha,otros_detalles,id_tipo_transaccion,id_compra,id_deposito,id_debito,no_cuenta)
                    VALUES (id_transaccion,STR_TO_DATE(fecha, '%d/%m/%Y'),otros_detalles,id_tipo_transaccion,0,0,id_c_d_d,no_cuenta);
                    UPDATE cuenta
                    SET saldo_cuenta = saldo_cuenta - retornar_monto_debito(id_c_d_d)
                    WHERE id_cuenta = no_cuenta;
                    call actualizar_historial('cuenta');
                    SELECT 'Datos almacenados en la tabla transaccion';
                    LEAVE prod_transa;
				ELSE
                    SELECT 'Error: el monto de debito es mayor al saldo de la cuenta' as Error;
                    LEAVE prod_transa;
				END IF;
        END CASE;
    END IF;
END //
DELIMITER ;



#funcion para devolver monto del servicio
DELIMITER //
CREATE FUNCTION retornar_monto_servicio(id INTEGER) RETURNS INTEGER
DETERMINISTIC
BEGIN
    DECLARE monto INTEGER;
    SELECT costo INTO monto FROM producto_servicio WHERE codigo_prod_serv = id;
    RETURN monto;
END //
DELIMITER ;




#**********************************************Procedimientos almacenados de las consultas******************************************************************

#Consulta de saldo de cliente
DELIMITER //
CREATE PROCEDURE consultarSaldoCliente(
IN no_cuenta BIGINT
)
BEGIN
	IF NOT EXISTS (SELECT * FROM cuenta WHERE id_cuenta = no_cuenta) THEN
        SELECT 'Error: La cuenta no existe' as Error;
    ELSE
		SELECT cli.nombre,cli.tipo_cliente,ticli.nombre,cuen.tipo_cuenta,ticuen.nombre,cuen.saldo_cuenta,cuen.monto_apertura
		FROM cliente cli
		INNER JOIN cuenta cuen
        ON cli.id_cliente = cuen.id_cliente
        INNER JOIN tipo_cliente ticli
        ON cli.tipo_cliente = ticli.id_tipo
        INNER JOIN tipo_cuenta ticuen
        ON cuen.tipo_cuenta = ticuen.codigo
        WHERE cuen.id_cuenta = no_cuenta;
	END IF;
END //
DELIMITER ;
call consultarSaldoCliente(3030206081);



#Consulta de cliente
DELIMITER //
CREATE PROCEDURE consultarCliente(
IN id_c INTEGER
)
BEGIN
	IF NOT EXISTS (SELECT * FROM cliente WHERE id_cliente = id_c) THEN
        SELECT 'Error: el cliente no existe' as Error;
    ELSE
		SELECT cli.id_cliente,CONCAT(cli.nombre,' ',cli.apellidos) AS NombreCompleto,cli.fecha_creacion,cli.usuario,cli.telefono,cli.correo,
        COUNT(cuen.id_cuenta) as no_cuentas,
        cuen.tipo_cuenta,ticuen.nombre
        FROM cliente cli
        LEFT JOIN cuenta cuen
        ON cli.id_cliente = cuen.id_cliente
        LEFT JOIN tipo_cuenta ticuen
        ON cuen.tipo_cuenta = ticuen.codigo
		WHERE cli.id_cliente = id_c
        GROUP BY cli.id_cliente, cli.nombre, cli.apellidos, cli.fecha_creacion, cli.usuario,cuen.tipo_cuenta;
	END IF;
END //
DELIMITER ;

call consultarCliente(1001);


#Consulta de movimientos de cliente
DELIMITER //
CREATE PROCEDURE consultarMovsCliente(
IN id_c INTEGER
)
BEGIN
	IF NOT EXISTS (SELECT * FROM cliente WHERE id_cliente = id_c) THEN
        SELECT 'Error: el cliente no existe' as Error;
    ELSE
		SELECT tran.id_transaccion,tran.id_tipo_transaccion,titran.nombre,tran.no_cuenta,cuen.tipo_cuenta,
        CASE
			WHEN tran.id_compra IS NOT NULL THEN compra.importe_compra
			WHEN tran.id_debito IS NOT NULL THEN debito.monto
			WHEN tran.id_deposito IS NOT NULL THEN deposito.monto
            ELSE NULL
        END AS monto
        FROM transaccion tran
        INNER JOIN tipo_transaccion titran
        ON tran.id_tipo_transaccion = titran.codigo_transaccion
        INNER JOIN cuenta cuen
        ON tran.no_cuenta = cuen.id_cuenta
        LEFT JOIN 
            compra 
            ON tran.id_compra = compra.id_compra
        LEFT JOIN 
            debito 
            ON tran.id_debito = debito.id_debito
        LEFT JOIN 
            deposito 
            ON tran.id_deposito = deposito.id_deposito;
	END IF;
END //
DELIMITER ;
call consultarMovsCliente(1001);



#Consultar clientes por tipo de cuenta
DELIMITER //
CREATE PROCEDURE consultarTipoCuentas(
IN id_tipo_c INTEGER
)
BEGIN
	IF NOT EXISTS (SELECT * FROM tipo_cuenta WHERE codigo = id_tipo_c) THEN
        SELECT 'Error: el tipo de cuenta no existe' as Error;
    ELSE
		SELECT ticuen.codigo,ticuen.nombre,
        COUNT(cuen.id_cuenta) as cantidad_clientes_del_mismo_tipo
        FROM tipo_cuenta ticuen
        LEFT JOIN cuenta cuen
		ON ticuen.codigo = cuen.tipo_cuenta
        WHERE ticuen.codigo = id_tipo_c
        GROUP BY ticuen.codigo;
    END IF;
	
END //
DELIMITER ;
call consultarTipoCuentas(3);




#Consultar movimientos generales por rango de fechas
DELIMITER //
CREATE PROCEDURE consultarMovsGenFech(
IN fechaInicio VARCHAR(100),
IN fechaFin VARCHAR(100)
)
BEGIN
	DECLARE fechaI DATE;
    DECLARE fechaF DATE;
    SET fechaI = STR_TO_DATE(fechaInicio,'%d/%m/%Y');
    SET fechaF = STR_TO_DATE(fechaFin,'%d/%m/%Y');
	IF fechaI IS NOT NULL AND fechaF IS NOT NULL THEN
		SELECT tran.id_transaccion,tran.id_tipo_transaccion,titran.nombre,cli.nombre,cuen.id_cuenta,cuen.tipo_cuenta,tran.fecha,
        CASE
			WHEN tran.id_compra IS NOT NULL THEN compra.importe_compra
			WHEN tran.id_debito IS NOT NULL THEN debito.monto
			WHEN tran.id_deposito IS NOT NULL THEN deposito.monto
            ELSE NULL
        END AS monto,
        tran.otros_detalles
        FROM transaccion tran
        INNER JOIN tipo_transaccion titran
		ON tran.id_tipo_transaccion = titran.codigo_transaccion
        INNER JOIN cuenta cuen
        ON tran.no_cuenta = cuen.id_cuenta
        INNER JOIN cliente cli
        ON cuen.id_cliente = cli.id_cliente
        LEFT JOIN 
            compra 
            ON tran.id_compra = compra.id_compra
        LEFT JOIN 
            debito 
            ON tran.id_debito = debito.id_debito
        LEFT JOIN 
            deposito 
            ON tran.id_deposito = deposito.id_deposito
		WHERE tran.fecha >= fechaI AND tran.fecha<=fechaF;
    ELSE
		SELECT 'Fechas incorrectas';
    END IF;
END //
DELIMITER ;
call consultarMovsGenFech('08/04/2024','15/04/2024');

#Consulta de Movimientos por Rango de Fechas para un Cliente Específico
DELIMITER //
CREATE PROCEDURE consultarMovsFechClien(
IN cliente_ INTEGER,
IN fechaInicio VARCHAR(100),
IN fechaFin VARCHAR(100)
)
proc_con_cli:BEGIN
	DECLARE fechaI DATE;
    DECLARE fechaF DATE;
    SET fechaI = STR_TO_DATE(fechaInicio,'%d/%m/%Y');
    SET fechaF = STR_TO_DATE(fechaFin,'%d/%m/%Y');
    IF NOT EXISTS (SELECT * FROM cliente WHERE id_cliente = cliente_) THEN
        SELECT 'Error: el cliente no existe' as Error;
        LEAVE proc_con_cli;
	END IF;
	IF fechaI IS NOT NULL AND fechaF IS NOT NULL THEN
		SELECT tran.id_transaccion,tran.id_tipo_transaccion,titran.nombre,cli.nombre,cuen.id_cuenta,cuen.tipo_cuenta,tran.fecha,
        CASE
			WHEN tran.id_compra IS NOT NULL THEN compra.importe_compra
			WHEN tran.id_debito IS NOT NULL THEN debito.monto
			WHEN tran.id_deposito IS NOT NULL THEN deposito.monto
            ELSE NULL
        END AS monto,
        tran.otros_detalles
        FROM transaccion tran
        INNER JOIN tipo_transaccion titran
		ON tran.id_tipo_transaccion = titran.codigo_transaccion
        INNER JOIN cuenta cuen
        ON tran.no_cuenta = cuen.id_cuenta
        INNER JOIN cliente cli
        ON cuen.id_cliente = cli.id_cliente
        LEFT JOIN 
            compra 
            ON tran.id_compra = compra.id_compra
        LEFT JOIN 
            debito 
            ON tran.id_debito = debito.id_debito
        LEFT JOIN 
            deposito 
            ON tran.id_deposito = deposito.id_deposito
		WHERE tran.fecha >= fechaI AND tran.fecha<=fechaF AND cli.id_cliente = cliente_;
    ELSE
		SELECT 'Fechas incorrectas';
    END IF;
END //
DELIMITER ;
call consultarMovsFechClien(1001,'08/04/2024','15/04/2024');


#Consultar productos y servicios
DELIMITER //
CREATE PROCEDURE consultarDesasignacion(
)
BEGIN
	SELECT *
    FROM producto_servicio;
END //
DELIMITER ;
call consultarDesasignacion();


call crearProductoServicio(1,1,10.00,'Servicio de tarjeta de debito');
call crearProductoServicio(2,1,10.00,'Servicio de chequera');
call crearProductoServicio(3,1,400.00,'Servicio de asesoramiento financiero');
call crearProductoServicio(4,1,5.00,'Servicio de banca personal');
call crearProductoServicio(5,1,30.00,'Seguro de vida');
call crearProductoServicio(6,1,100.00,'Seguro de vida plus');
call crearProductoServicio(7,1,300.00,'Seguro de automóvil');
call crearProductoServicio(8,1,500.00,'Seguro de automóvil plus');
call crearProductoServicio(9,1,0.05,'Servicio de deposito');
call crearProductoServicio(10,1,0.10,'Servicio de Debito');


call crearProductoServicio(11,2,0,'Pago de energía Eléctrica (EEGSA)');
call crearProductoServicio(12,2,0,'Pago de agua potable (Empagua)');
call crearProductoServicio(13,2,0,'Pago de Matricula USAC');
call crearProductoServicio(14,2,0,'Pago de curso vacaciones USAC');
call crearProductoServicio(15,2,0,'Pago de servicio de internet');
call crearProductoServicio(16,2,0,'Servicio de suscripción plataformas streaming');
call crearProductoServicio(17,2,0,'Servicios Cloud');


DELETE FROM producto_servicio WHERE codigo_prod_serv = 18;
DELETE FROM producto_servicio WHERE codigo_prod_serv = 19;


DELETE FROM tipo_cliente WHERE id_tipo = 5;
DELETE FROM tipo_cliente WHERE id_tipo = 6;
ALTER TABLE tipo_cliente AUTO_INCREMENT 4;

DELETE FROM tipo_cuenta WHERE codigo = 7;
DELETE FROM tipo_cuenta WHERE codigo = 8;
ALTER TABLE tipo_cuenta AUTO_INCREMENT 6;