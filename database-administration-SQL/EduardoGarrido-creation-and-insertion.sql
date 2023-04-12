--------------------
-- CREACION SCHEMA
--------------------

create schema practica_eduardo_garrido authorization ekjwwzhp;

------------------------------
-- CREACION TABLA grupos_marca
------------------------------

-- Tabla grupos_marca
create table practica_eduardo_garrido.grupos_marca(
	ID_grupo_marca varchar(10) not null, -- PK
	nombre_grupo_marca varchar(100) not null,
	descripcion varchar(500) null
);

-- PK Tabla grupos_marca
alter table practica_eduardo_garrido.grupos_marca
add constraint grupos_marca_PK primary key (ID_grupo_marca);

------------------------
-- CREACION TABLA marcas
------------------------

-- Tabla marcas
create table practica_eduardo_garrido.marcas(
	ID_marca varchar(10) not null, -- PK
	ID_grupo_marca varchar(10) not null, -- FK grupos_marca
	nombre_marca varchar(100) not null,
	descripcion varchar(500) null
);

-- PK Tabla marcas
alter table practica_eduardo_garrido.marcas
add constraint marcas_PK primary key (ID_marca);

-- FK marcas - grupos_marca
alter table practica_eduardo_garrido.marcas
add constraint marcas_grupos_marca_FK foreign key (ID_grupo_marca)
references practica_eduardo_garrido.grupos_marca (ID_grupo_marca);

-------------------------
-- CREACION TABLA modelos
-------------------------

-- Tabla modelos
create table practica_eduardo_garrido.modelos(
	ID_modelo varchar(10) not null, -- PK
	ID_marca varchar(10) not null, -- FK marcas
	nombre_modelo varchar(100) not null,
	descripcion varchar(500) null
);

-- PK Tabla modelos
alter table practica_eduardo_garrido.modelos
add constraint modelos_PK primary key (ID_modelo);

-- FK modelos - marcas
alter table practica_eduardo_garrido.modelos
add constraint modelos_marcas_FK foreign key (ID_marca)
references practica_eduardo_garrido.marcas (ID_marca);

-------------------------
-- CREACION TABLA colores
-------------------------

-- Tabla colores
create table practica_eduardo_garrido.colores(
	ID_color varchar(10) not null, -- PK
	nombre_color varchar(100) not null,
	descripcion varchar(500) null
);

-- PK Tabla colores
alter table practica_eduardo_garrido.colores
add constraint colores_PK primary key (ID_color);

------------------------------
-- CREACION TABLA aseguradoras
------------------------------

-- Tabla aseguradoras
create table practica_eduardo_garrido.aseguradoras(
	ID_aseguradora varchar(10) not null, -- PK
	nombre_aseguradora varchar(100) not null,
	descripcion varchar(500) null
);

-- PK Tabla aseguradoras
alter table practica_eduardo_garrido.aseguradoras
add constraint aseguradoras_PK primary key (ID_aseguradora);

---------------------------
-- CREACION TABLA empleados
---------------------------

-- Tabla empleados
create table practica_eduardo_garrido.empleados(
	ID_empleado varchar(10) not null, -- PK
	nombre varchar(100) not null,
	apellido1 varchar(100) not null,
	apellido2 varchar(100) null,
	descripcion varchar(500) null
);

-- PK Tabla empleados
alter table practica_eduardo_garrido.empleados
add constraint empleados_PK primary key (ID_empleado);

------------------------
-- CREACION TABLA coches
------------------------

-- Tabla coches
create table practica_eduardo_garrido.coches(
	matricula varchar(50) not null, -- PK
	fecha_compra date not null,
	poliza varchar(50) not null,
	kilometraje int not null,
	ID_grupo_marca varchar(10) not null, -- FK grupos_marca
	ID_marca varchar(10) not null, -- FK marcas
	ID_modelo varchar(10) not null, -- FK modelos
	ID_color varchar(10) not null, -- FK colores
	ID_aseguradora varchar(10) not null, -- FK aseguradoras
	ID_empleado varchar(10) not null, -- FK empleados
	descripcion varchar(500) null
);

-- PK Tabla coches
alter table practica_eduardo_garrido.coches
add constraint coches_PK primary key (matricula);

-- FK coches - grupos_marca
alter table practica_eduardo_garrido.coches
add constraint coches_grupos_marca_FK foreign key (ID_grupo_marca)
references practica_eduardo_garrido.grupos_marca (ID_grupo_marca);

-- FK coches - marcas
alter table practica_eduardo_garrido.coches
add constraint coches_marcas_FK foreign key (ID_marca)
references practica_eduardo_garrido.marcas (ID_marca);

-- FK coches - modelos
alter table practica_eduardo_garrido.coches
add constraint coches_modelos_FK foreign key (ID_modelo)
references practica_eduardo_garrido.modelos (ID_modelo);

-- FK coches - colores
alter table practica_eduardo_garrido.coches
add constraint coches_colores_FK foreign key (ID_color)
references practica_eduardo_garrido.colores (ID_color);

-- FK coches - aseguradoras
alter table practica_eduardo_garrido.coches
add constraint coches_aseguradoras_FK foreign key (ID_aseguradora)
references practica_eduardo_garrido.aseguradoras (ID_aseguradora);

-- FK coches - empleados
alter table practica_eduardo_garrido.coches
add constraint coches_empleados_FK foreign key (ID_empleado)
references practica_eduardo_garrido.empleados (ID_empleado);

----------------------------
-- CREACION TABLA revisiones
----------------------------

-- Tabla revisiones
create table practica_eduardo_garrido.revisiones(
	ID_revision varchar(10) not null, -- PK
	categoria_revision varchar(100) not null,
	descripcion varchar(500) null
);

-- PK Tabla revisiones
alter table practica_eduardo_garrido.revisiones
add constraint revisiones_PK primary key (ID_revision);

-------------------------
-- CREACION TABLA monedas
-------------------------

-- Tabla monedas
create table practica_eduardo_garrido.monedas(
	tipo_moneda varchar(10) not null, -- PK
	nombre_moneda varchar(100) not null,
	descripcion varchar(500) null
);

-- PK Tabla monedas
alter table practica_eduardo_garrido.monedas
add constraint monedas_PK primary key (tipo_moneda);

----------------------------------------
-- CREACION TABLA hist_revisiones_coches
----------------------------------------

-- Tabla hist_revisiones_coches
create table practica_eduardo_garrido.hist_revisiones_coches(
	matricula varchar(50) not null, -- PK y FK coches
	ID_revision varchar(10) not null, -- PK y FK revisiones
	km_revision int not null,
	fecha_revision date not null,
	costo_revision int not null,
	tipo_moneda varchar(10) not null, -- FK monedas
	descripcion varchar(500) null
);

-- PK Tabla hist_revisiones_coches
alter table practica_eduardo_garrido.hist_revisiones_coches
add constraint hist_revisiones_coches_PK primary key (matricula, ID_revision);

-- FK hist_revisiones_coches - coches
alter table practica_eduardo_garrido.hist_revisiones_coches
add constraint hist_revisiones_coches_coches_FK foreign key (matricula)
references practica_eduardo_garrido.coches (matricula);

-- FK hist_revisiones_coches - revisiones
alter table practica_eduardo_garrido.hist_revisiones_coches
add constraint hist_revisiones_coches_revisiones_FK foreign key (ID_revision)
references practica_eduardo_garrido.revisiones (ID_revision);

-- FK hist_revisiones_coches - monedas
alter table practica_eduardo_garrido.hist_revisiones_coches
add constraint hist_revisiones_coches_monedas_FK foreign key (tipo_moneda)
references practica_eduardo_garrido.monedas (tipo_moneda);

-------------------------------
-- RELLENADO TABLA grupos_marca
-------------------------------

insert into practica_eduardo_garrido.grupos_marca
(id_grupo_marca, nombre_grupo_marca)
values ('GM1', 'Grupo Toyota');

insert into practica_eduardo_garrido.grupos_marca
(id_grupo_marca, nombre_grupo_marca)
values ('GM2', 'Grupo Honda');

insert into practica_eduardo_garrido.grupos_marca
(id_grupo_marca, nombre_grupo_marca)
values ('GM3', 'Grupo Ford');

insert into practica_eduardo_garrido.grupos_marca
(id_grupo_marca, nombre_grupo_marca)
values ('GM4', 'Grupo Hyundai');

insert into practica_eduardo_garrido.grupos_marca
(id_grupo_marca, nombre_grupo_marca)
values ('GM5', 'Grupo Nissan');

-------------------------
-- RELLENADO TABLA marcas
-------------------------

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M1', 'GM1', 'Toyota');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M2', 'GM1', 'Lexus');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M3', 'GM1', 'Daihatsu');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M4', 'GM2', 'Honda');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M5', 'GM2', 'Acura');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M6', 'GM3', 'Lincoln');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M7', 'GM3', 'Ford');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M8', 'GM4', 'Kia');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M9', 'GM4', 'Hyundai');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M10', 'GM4', 'Genesis');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M11', 'GM5', 'Infiniti');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M12', 'GM5', 'Nissan');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M13', 'GM5', 'Datsun');

insert into practica_eduardo_garrido.marcas
(id_marca, id_grupo_marca, nombre_marca)
values ('M14', 'GM5', 'Mitsubishi');

--------------------------
-- RELLENADO TABLA modelos
--------------------------

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO1', 'M1', 'Corolla');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO2', 'M1', 'Rav4');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO3', 'M2', 'RX 350');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO4', 'M2', 'LX 470');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO5', 'M3', 'Terios');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO6', 'M3', 'Mira');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO7', 'M4', 'Civic');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO8', 'M4', 'Pilot');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO9', 'M5', 'ILX');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO10', 'M5', 'MDX');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO11', 'M6', 'Aviator');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO12', 'M6', 'Continental');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO13', 'M7', 'Focus');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO14', 'M7', 'Escape');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO15', 'M8', 'Picanto');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO16', 'M8', 'Sorento');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO17', 'M9', 'Santa Fe');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO18', 'M9', 'Avante');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO19', 'M10', 'GV60');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO20', 'M10', 'GV70');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO21', 'M11', 'Q50');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO22', 'M11', 'Q60');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO23', 'M12', 'Murano');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO24', 'M12', 'Sentra');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO25', 'M13', 'Fairlady');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO26', 'M13', 'Cross');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO27', 'M14', 'Lancer');

insert into practica_eduardo_garrido.modelos
(id_modelo, id_marca, nombre_modelo)
values ('MO28', 'M14', 'Outlander');

--------------------------
-- RELLENADO TABLA colores
--------------------------

insert into practica_eduardo_garrido.colores
(id_color, nombre_color)
values('C1', 'Rojo');

insert into practica_eduardo_garrido.colores
(id_color, nombre_color)
values('C2', 'Azul');

insert into practica_eduardo_garrido.colores
(id_color, nombre_color)
values('C3', 'Negro');

insert into practica_eduardo_garrido.colores
(id_color, nombre_color)
values('C4', 'Blanco');

insert into practica_eduardo_garrido.colores
(id_color, nombre_color)
values('C5', 'Verde');

-------------------------------
-- RELLENADO TABLA aseguradoras
-------------------------------

insert into practica_eduardo_garrido.aseguradoras
(id_aseguradora, nombre_aseguradora)
values('A1', 'Seguros Teriyaki');

insert into practica_eduardo_garrido.aseguradoras
(id_aseguradora, nombre_aseguradora)
values('A2', 'Seguros Hermanos');

insert into practica_eduardo_garrido.aseguradoras
(id_aseguradora, nombre_aseguradora)
values('A3', 'Seguros Furia');

insert into practica_eduardo_garrido.aseguradoras
(id_aseguradora, nombre_aseguradora)
values('A4', 'Seguros Inspirar');

insert into practica_eduardo_garrido.aseguradoras
(id_aseguradora, nombre_aseguradora)
values('A5', 'Seguros Norman');

----------------------------
-- RELLENADO TABLA empleados
----------------------------

insert into practica_eduardo_garrido.empleados
(id_empleado, nombre, apellido1, apellido2)
values('E1', 'Jeremias', 'Alberti', null);

insert into practica_eduardo_garrido.empleados
(id_empleado, nombre, apellido1, apellido2)
values('E2', 'Pedro', 'Piantini', 'Bermudez');

insert into practica_eduardo_garrido.empleados
(id_empleado, nombre, apellido1, apellido2)
values('E3', 'José', 'Cruz', 'Rodriguez');

insert into practica_eduardo_garrido.empleados
(id_empleado, nombre, apellido1, apellido2)
values('E4', 'Natalia', 'Gomez', 'Duarte');

insert into practica_eduardo_garrido.empleados
(id_empleado, nombre, apellido1, apellido2)
values('E5', 'Martin', 'Rizo', null);

insert into practica_eduardo_garrido.empleados
(id_empleado, nombre, apellido1, apellido2)
values('E6', 'Julia', 'Matos', 'Cristo');

insert into practica_eduardo_garrido.empleados
(id_empleado, nombre, apellido1, apellido2)
values('E7', 'Mariana', 'Garrido', 'Surum');

insert into practica_eduardo_garrido.empleados
(id_empleado, nombre, apellido1, apellido2)
values('E8', 'Gertrudis', 'Rosario', 'Petrenka');

insert into practica_eduardo_garrido.empleados
(id_empleado, nombre, apellido1, apellido2)
values('E9', 'Marco', 'Nuñez', 'Herrera');

insert into practica_eduardo_garrido.empleados
(id_empleado, nombre, apellido1, apellido2)
values('E10', 'Isabel', 'Almanzar', null);

-----------------------------
-- RELLENADO TABLA revisiones
-----------------------------

insert into practica_eduardo_garrido.revisiones
(id_revision, categoria_revision)
values('R1', 'Cambio de Aceite');

insert into practica_eduardo_garrido.revisiones
(id_revision, categoria_revision)
values('R2', 'Prueba de Motor');

insert into practica_eduardo_garrido.revisiones
(id_revision, categoria_revision)
values('R3', 'Renovacion Liquido de Frenos');

insert into practica_eduardo_garrido.revisiones
(id_revision, categoria_revision)
values('R4', 'Desabolladura');

insert into practica_eduardo_garrido.revisiones
(id_revision, categoria_revision)
values('R5', 'Revision de Garantia');

insert into practica_eduardo_garrido.revisiones
(id_revision, categoria_revision)
values('R6', 'Pintura menor');

--------------------------
-- RELLENADO TABLA monedas
--------------------------

insert into practica_eduardo_garrido.monedas
(tipo_moneda, nombre_moneda)
values('EUR', 'Euro');

insert into practica_eduardo_garrido.monedas
(tipo_moneda, nombre_moneda)
values('GBP', 'Libra Esterlina');

insert into practica_eduardo_garrido.monedas
(tipo_moneda, nombre_moneda)
values('CAD', 'Dolar Canadiense');

insert into practica_eduardo_garrido.monedas
(tipo_moneda, nombre_moneda)
values('USD', 'Dolar Estadounidense');

-------------------------
-- RELLENADO TABLA coches
-------------------------

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('0935 KGB', now(), '096525', 39000, 'GM1', 'M1', 'MO1', 'C1', 'A1', 'E1');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('9583 BMW', now(), '749500', 6000, 'GM4', 'M8', 'MO16', 'C4', 'A4', 'E9');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('5633 HRT', now(), '750325', 87600, 'GM2', 'M4', 'MO8', 'C2', 'A2', 'E10');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('0053 RDT', now(), '539643', 8900, 'GM5', 'M12', 'MO23', 'C5', 'A5', 'E2');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('6390 RFN', now(), '639087', 6899, 'GM3', 'M6', 'MO12', 'C3', 'A3', 'E3');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('9327 LMO', now(), '063864', 7000, 'GM1', 'M2', 'MO3', 'C1', 'A1', 'E8');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('7669 KJH', now(), '673218', 80966, 'GM3', 'M7', 'MO13', 'C3', 'A3', 'E4');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('0907 MUB', now(), '458990', 45000, 'GM5', 'M13', 'MO25', 'C5', 'A5', 'E7');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('7600 LAD', now(), '684321', 5098, 'GM4', 'M9', 'MO18', 'C4', 'A4', 'E5');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('6428 JMF', now(), '579421', 90544, 'GM1', 'M3', 'MO5', 'C1', 'A1', 'E6');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('7537 OMB', now(), '539054', 68420, 'GM2', 'M5', 'MO10', 'C2', 'A2', 'E10');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('8404 LDF', now(), '863569', 9000, 'GM5', 'M14', 'MO28', 'C5', 'A5', 'E4');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('8442 MNU', now(), '965320', 64056, 'GM4', 'M10', 'MO19', 'C4', 'A4', 'E3');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('9012 MNX', now(), '684280', 9885, 'GM3', 'M7', 'MO14', 'C3', 'A3', 'E9');

insert into practica_eduardo_garrido.coches
(matricula, fecha_compra, poliza, kilometraje, id_grupo_marca,
id_marca, id_modelo, id_color, id_aseguradora, id_empleado)
values('8403 VTR', now(), '056732', 8000, 'GM2', 'M4', 'MO7', 'C2', 'A2', 'E2');

-----------------------------------------
-- RELLENADO TABLA hist_revisiones_coches
-----------------------------------------

insert into practica_eduardo_garrido.hist_revisiones_coches
(matricula, id_revision, km_revision, fecha_revision, costo_revision, tipo_moneda)
values('8403 VTR', 'R1', 8000, now(), 250, 'EUR');

insert into practica_eduardo_garrido.hist_revisiones_coches
(matricula, id_revision, km_revision, fecha_revision, costo_revision, tipo_moneda)
values('9012 MNX', 'R6', 9885, now(), 300, 'USD');

insert into practica_eduardo_garrido.hist_revisiones_coches
(matricula, id_revision, km_revision, fecha_revision, costo_revision, tipo_moneda)
values('8442 MNU', 'R2', 64056, now(), 150, 'GBP');

insert into practica_eduardo_garrido.hist_revisiones_coches
(matricula, id_revision, km_revision, fecha_revision, costo_revision, tipo_moneda)
values('8404 LDF', 'R4', 9000, now(), 500, 'EUR');

insert into practica_eduardo_garrido.hist_revisiones_coches
(matricula, id_revision, km_revision, fecha_revision, costo_revision, tipo_moneda)
values('7537 OMB', 'R5', 68420, now(), 100, 'GBP');

insert into practica_eduardo_garrido.hist_revisiones_coches
(matricula, id_revision, km_revision, fecha_revision, costo_revision, tipo_moneda)
values('6428 JMF', 'R1', 90544, now(), 260, 'USD');

insert into practica_eduardo_garrido.hist_revisiones_coches
(matricula, id_revision, km_revision, fecha_revision, costo_revision, tipo_moneda)
values('7600 LAD', 'R3', 5098, now(), 100, 'USD');

insert into practica_eduardo_garrido.hist_revisiones_coches
(matricula, id_revision, km_revision, fecha_revision, costo_revision, tipo_moneda)
values('8403 VTR', 'R2', 8000, now(), 200, 'CAD');

insert into practica_eduardo_garrido.hist_revisiones_coches
(matricula, id_revision, km_revision, fecha_revision, costo_revision, tipo_moneda)
values('8404 LDF', 'R5', 9000, now(), 300, 'CAD');

insert into practica_eduardo_garrido.hist_revisiones_coches
(matricula, id_revision, km_revision, fecha_revision, costo_revision, tipo_moneda)
values('6428 JMF', 'R4', 90544, now(), 700, 'USD');