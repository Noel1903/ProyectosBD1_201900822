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