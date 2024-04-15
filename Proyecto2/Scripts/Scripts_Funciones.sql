CREATE TABLE tu_tabla (
    fecha DATETIME,
    descripcion VARCHAR(200),
    tipo VARCHAR(30)
);


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









