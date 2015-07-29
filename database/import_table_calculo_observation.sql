create table mssql.staging_calculo_20150727_obs_t1 as select * from mssql.import_calculo_20150727_obs_t1;
drop table IF EXISTS mssql.calculo_20150721_reporte_nivel_observacion_estimacion_t1_v20;

UPDATE mssql.staging_calculo_20150727_obs_t1 SET desposito_ipcc_1=NULL where desposito_ipcc_1 = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET desposito_ipcc_2=NULL where desposito_ipcc_2 = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET desposito_ipcc_3=NULL where desposito_ipcc_3 = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET seccion_infys=NULL where seccion_infys = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET familia=NULL where familia = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET nombre_cientifico=NULL where nombre_cientifico = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET condicion=NULL where condicion = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET se_utilizo_para_contar_biomasa=NULL where se_utilizo_para_contar_biomasa = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET fecha_calculo=NULL where fecha_calculo = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET modelo_alometrico=NULL where modelo_alometrico = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET referencia_modelo_alometrico=NULL where referencia_modelo_alometrico = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET tipo_modelo_alometrico=NULL where tipo_modelo_alometrico = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET densidad_de_madera=NULL where densidad_de_madera = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET referencia_densidad_de_madera=NULL where referencia_densidad_de_madera = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET diametro_basal_estimado=NULL where diametro_basal_estimado = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET biomasa_area_estimada=NULL where biomasa_area_estimada = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET fraccion_carbono=NULL where fraccion_carbono = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET tipo_fraccion_carbono=NULL where tipo_fraccion_carbono = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET carbono_aereo_estimado=NULL where carbono_aereo_estimado = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t1 SET tipificacion=NULL where tipificacion = 'NULL';

UPDATE mssql.staging_calculo_20150727_obs_t1 SET fecha_calculo = NULL where fecha_calculo = 'NULL'; 
UPDATE mssql.staging_calculo_20150727_obs_t1 SET densidad_de_madera = NULL where densidad_de_madera = 'NULL'; 
UPDATE mssql.staging_calculo_20150727_obs_t1 SET referencia_densidad_de_madera = NULL where referencia_densidad_de_madera = 'NULL'; 
UPDATE mssql.staging_calculo_20150727_obs_t1 SET diametro_basal_estimado = NULL where diametro_basal_estimado = 'NULL'; 
UPDATE mssql.staging_calculo_20150727_obs_t1 SET biomasa_area_estimada = NULL where biomasa_area_estimada = 'NULL'; 
UPDATE mssql.staging_calculo_20150727_obs_t1 SET carbono_aereo_estimado = NULL where carbono_aereo_estimado = 'NULL'; 

ALTER TABLE mssql.staging_calculo_20150727_obs_t1 ALTER COLUMN fecha_calculo  TYPE TIMESTAMP using fecha_calculo::TIMESTAMP;
ALTER TABLE mssql.staging_calculo_20150727_obs_t1 ALTER COLUMN densidad_de_madera  TYPE NUMERIC using densidad_de_madera::NUMERIC;
ALTER TABLE mssql.staging_calculo_20150727_obs_t1 ALTER COLUMN diametro_basal_estimado  TYPE NUMERIC using diametro_basal_estimado::NUMERIC;
ALTER TABLE mssql.staging_calculo_20150727_obs_t1 ALTER COLUMN biomasa_area_estimada  TYPE NUMERIC using biomasa_area_estimada::NUMERIC;
ALTER TABLE mssql.staging_calculo_20150727_obs_t1 ALTER COLUMN carbono_aereo_estimado  TYPE NUMERIC using carbono_aereo_estimado::NUMERIC;

create table mssql.calculo_20150721_reporte_nivel_observacion_estimacion_t1_v20 as select * from mssql.staging_calculo_20150727_obs_t1;
ALTER TABLE mssql.calculo_20150721_reporte_nivel_observacion_estimacion_t1_v20 ADD PRIMARY KEY (id);
drop table mssql.staging_calculo_20150727_obs_t1;
---

create table mssql.staging_calculo_20150727_obs_t2 as select * from mssql.import_calculo_20150727_obs_t2;
drop table IF EXISTS mssql.calculo_20150721_reporte_nivel_observacion_estimacion_t2_v20;

UPDATE mssql.staging_calculo_20150727_obs_t2 SET desposito_ipcc_1=NULL where desposito_ipcc_1 = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET desposito_ipcc_2=NULL where desposito_ipcc_2 = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET desposito_ipcc_3=NULL where desposito_ipcc_3 = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET seccion_infys=NULL where seccion_infys = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET familia=NULL where familia = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET nombre_cientifico=NULL where nombre_cientifico = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET condicion=NULL where condicion = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET se_utilizo_para_contar_biomasa=NULL where se_utilizo_para_contar_biomasa = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET fecha_calculo=NULL where fecha_calculo = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET modelo_alometrico=NULL where modelo_alometrico = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET referencia_modelo_alometrico=NULL where referencia_modelo_alometrico = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET tipo_modelo_alometrico=NULL where tipo_modelo_alometrico = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET densidad_de_madera=NULL where densidad_de_madera = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET referencia_densidad_de_madera=NULL where referencia_densidad_de_madera = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET diametro_basal_estimado=NULL where diametro_basal_estimado = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET biomasa_area_estimada=NULL where biomasa_area_estimada = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET fraccion_carbono=NULL where fraccion_carbono = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET tipo_fraccion_carbono=NULL where tipo_fraccion_carbono = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET carbono_aereo_estimado=NULL where carbono_aereo_estimado = 'NULL';
UPDATE mssql.staging_calculo_20150727_obs_t2 SET tipificacion=NULL where tipificacion = 'NULL';

UPDATE mssql.staging_calculo_20150727_obs_t2 SET fecha_calculo = NULL where fecha_calculo = 'NULL'; 
UPDATE mssql.staging_calculo_20150727_obs_t2 SET densidad_de_madera = NULL where densidad_de_madera = 'NULL'; 
UPDATE mssql.staging_calculo_20150727_obs_t2 SET referencia_densidad_de_madera = NULL where referencia_densidad_de_madera = 'NULL'; 
UPDATE mssql.staging_calculo_20150727_obs_t2 SET diametro_basal_estimado = NULL where diametro_basal_estimado = 'NULL'; 
UPDATE mssql.staging_calculo_20150727_obs_t2 SET biomasa_area_estimada = NULL where biomasa_area_estimada = 'NULL'; 
UPDATE mssql.staging_calculo_20150727_obs_t2 SET carbono_aereo_estimado = NULL where carbono_aereo_estimado = 'NULL'; 

ALTER TABLE mssql.staging_calculo_20150727_obs_t2 ALTER COLUMN fecha_calculo  TYPE TIMESTAMP using fecha_calculo::TIMESTAMP;
ALTER TABLE mssql.staging_calculo_20150727_obs_t2 ALTER COLUMN densidad_de_madera  TYPE NUMERIC using densidad_de_madera::NUMERIC;
ALTER TABLE mssql.staging_calculo_20150727_obs_t2 ALTER COLUMN diametro_basal_estimado  TYPE NUMERIC using diametro_basal_estimado::NUMERIC;
ALTER TABLE mssql.staging_calculo_20150727_obs_t2 ALTER COLUMN biomasa_area_estimada  TYPE NUMERIC using biomasa_area_estimada::NUMERIC;
ALTER TABLE mssql.staging_calculo_20150727_obs_t2 ALTER COLUMN carbono_aereo_estimado  TYPE NUMERIC using carbono_aereo_estimado::NUMERIC;

create table mssql.calculo_20150721_reporte_nivel_observacion_estimacion_t2_v20 as select * from mssql.staging_calculo_20150727_obs_t2;
ALTER TABLE mssql.calculo_20150721_reporte_nivel_observacion_estimacion_t2_v20 ADD PRIMARY KEY (id);
drop table mssql.staging_calculo_20150727_obs_t2;