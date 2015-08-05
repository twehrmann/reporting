create table mssql.staging_calculo_20150727_udm_t1 as select * from mssql.import_calculo_20150727_udm_t1;
drop table IF EXISTS mssql.calculo_20150721_reporte_nivel_udm_estimacion_t1_v20;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET anio_levantamiento=NULL WHERE anio_levantamiento= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	anio_levantamiento TYPE integer using anio_levantamiento::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET area_basal_muertos_pie=NULL WHERE area_basal_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	area_basal_muertos_pie TYPE numeric using area_basal_muertos_pie::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET area_basal_muertos_pie_estimacion=NULL WHERE area_basal_muertos_pie_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	area_basal_muertos_pie_estimacion TYPE numeric using area_basal_muertos_pie_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET area_basal_tocones=NULL WHERE area_basal_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	area_basal_tocones TYPE numeric using area_basal_tocones::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET area_basal_tocones_estimacion=NULL WHERE area_basal_tocones_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	area_basal_tocones_estimacion TYPE numeric using area_basal_tocones_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET area_basal_vivos=NULL WHERE area_basal_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	area_basal_vivos TYPE numeric using area_basal_vivos::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET area_basal_vivos_estimacion=NULL WHERE area_basal_vivos_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	area_basal_vivos_estimacion TYPE numeric using area_basal_vivos_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET biomasa_muertos_pie=NULL WHERE biomasa_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	biomasa_muertos_pie TYPE numeric using biomasa_muertos_pie::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET biomasa_raices=NULL WHERE biomasa_raices= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	biomasa_raices TYPE numeric using biomasa_raices::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET biomasa_tocones=NULL WHERE biomasa_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	biomasa_tocones TYPE numeric using biomasa_tocones::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET biomasa_vivos=NULL WHERE biomasa_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	biomasa_vivos TYPE numeric using biomasa_vivos::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET carbono_muertos_pie=NULL WHERE carbono_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	carbono_muertos_pie TYPE numeric using carbono_muertos_pie::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET carbono_raices=NULL WHERE carbono_raices= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	carbono_raices TYPE numeric using carbono_raices::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET carbono_tocones=NULL WHERE carbono_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	carbono_tocones TYPE numeric using carbono_tocones::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET carbono_vivos=NULL WHERE carbono_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	carbono_vivos TYPE numeric using carbono_vivos::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET fecha_calculo=NULL WHERE fecha_calculo= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	fecha_calculo TYPE timestamp using fecha_calculo::timestamp ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET id_levantamiento=NULL WHERE id_levantamiento= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	id_levantamiento TYPE integer using id_levantamiento::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET individuos_muertos_pie=NULL WHERE individuos_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	individuos_muertos_pie TYPE integer using individuos_muertos_pie::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET individuos_muertos_pie_estimacion=NULL WHERE individuos_muertos_pie_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	individuos_muertos_pie_estimacion TYPE integer using individuos_muertos_pie_estimacion::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET individuos_tocones=NULL WHERE individuos_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	individuos_tocones TYPE integer using individuos_tocones::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET individuos_tocones_estimacion=NULL WHERE individuos_tocones_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	individuos_tocones_estimacion TYPE integer using individuos_tocones_estimacion::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET individuos_totales=NULL WHERE individuos_totales= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	individuos_totales TYPE integer using individuos_totales::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET individuos_totales_estimacion=NULL WHERE individuos_totales_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	individuos_totales_estimacion TYPE integer using individuos_totales_estimacion::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET individuos_vivos=NULL WHERE individuos_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	individuos_vivos TYPE integer using individuos_vivos::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET individuos_vivos_estimacion=NULL WHERE individuos_vivos_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	individuos_vivos_estimacion TYPE integer using individuos_vivos_estimacion::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET latitud=NULL WHERE latitud= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	latitud TYPE double precision using latitud::double precision ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET longitud=NULL WHERE longitud= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	longitud TYPE double precision using longitud::double precision ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET numero_especies_existentes=NULL WHERE numero_especies_existentes= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	numero_especies_existentes TYPE integer using numero_especies_existentes::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET numero_familias_existentes=NULL WHERE numero_familias_existentes= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	numero_familias_existentes TYPE integer using numero_familias_existentes::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_altura_total_muertos_pie=NULL WHERE promedio_altura_total_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_altura_total_muertos_pie TYPE numeric using promedio_altura_total_muertos_pie::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_altura_total_muertos_pie_estimacion=NULL WHERE promedio_altura_total_muertos_pie_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_altura_total_muertos_pie_estimacion TYPE numeric using promedio_altura_total_muertos_pie_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_altura_total_tocones=NULL WHERE promedio_altura_total_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_altura_total_tocones TYPE numeric using promedio_altura_total_tocones::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_altura_total_tocones_estimacion=NULL WHERE promedio_altura_total_tocones_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_altura_total_tocones_estimacion TYPE numeric using promedio_altura_total_tocones_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_altura_total_vivos=NULL WHERE promedio_altura_total_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_altura_total_vivos TYPE numeric using promedio_altura_total_vivos::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_altura_total_vivos_estimacion=NULL WHERE promedio_altura_total_vivos_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_altura_total_vivos_estimacion TYPE numeric using promedio_altura_total_vivos_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_diametro_muertos_pie=NULL WHERE promedio_diametro_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_diametro_muertos_pie TYPE numeric using promedio_diametro_muertos_pie::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_diametro_muertos_pie_estimacion=NULL WHERE promedio_diametro_muertos_pie_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_diametro_muertos_pie_estimacion TYPE numeric using promedio_diametro_muertos_pie_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_diametro_tocones=NULL WHERE promedio_diametro_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_diametro_tocones TYPE numeric using promedio_diametro_tocones::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_diametro_tocones_estimacion=NULL WHERE promedio_diametro_tocones_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_diametro_tocones_estimacion TYPE numeric using promedio_diametro_tocones_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_diametro_vivos=NULL WHERE promedio_diametro_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_diametro_vivos TYPE numeric using promedio_diametro_vivos::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET promedio_diametro_vivos_estimacion=NULL WHERE promedio_diametro_vivos_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	promedio_diametro_vivos_estimacion TYPE numeric using promedio_diametro_vivos_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET tallos_totales=NULL WHERE tallos_totales= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t1 ALTER COLUMN 	tallos_totales TYPE integer using tallos_totales::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t1 SET tipificacion=NULL WHERE tipificacion= 'NULL';

create table mssql.calculo_20150721_reporte_nivel_udm_estimacion_t1_v20 as select * from mssql.staging_calculo_20150727_udm_t1;
ALTER TABLE mssql.calculo_20150721_reporte_nivel_udm_estimacion_t1_v20 ADD PRIMARY KEY (id);
drop table mssql.staging_calculo_20150727_udm_t1;


---

create table mssql.staging_calculo_20150727_udm_t2 as select * from mssql.import_calculo_20150727_udm_t2;
drop table IF EXISTS mssql.calculo_20150721_reporte_nivel_udm_estimacion_t2_v20;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET anio_levantamiento=NULL WHERE anio_levantamiento= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	anio_levantamiento TYPE integer using anio_levantamiento::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET area_basal_muertos_pie=NULL WHERE area_basal_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	area_basal_muertos_pie TYPE numeric using area_basal_muertos_pie::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET area_basal_muertos_pie_estimacion=NULL WHERE area_basal_muertos_pie_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	area_basal_muertos_pie_estimacion TYPE numeric using area_basal_muertos_pie_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET area_basal_tocones=NULL WHERE area_basal_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	area_basal_tocones TYPE numeric using area_basal_tocones::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET area_basal_tocones_estimacion=NULL WHERE area_basal_tocones_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	area_basal_tocones_estimacion TYPE numeric using area_basal_tocones_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET area_basal_vivos=NULL WHERE area_basal_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	area_basal_vivos TYPE numeric using area_basal_vivos::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET area_basal_vivos_estimacion=NULL WHERE area_basal_vivos_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	area_basal_vivos_estimacion TYPE numeric using area_basal_vivos_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET biomasa_muertos_pie=NULL WHERE biomasa_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	biomasa_muertos_pie TYPE numeric using biomasa_muertos_pie::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET biomasa_raices=NULL WHERE biomasa_raices= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	biomasa_raices TYPE numeric using biomasa_raices::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET biomasa_tocones=NULL WHERE biomasa_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	biomasa_tocones TYPE numeric using biomasa_tocones::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET biomasa_vivos=NULL WHERE biomasa_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	biomasa_vivos TYPE numeric using biomasa_vivos::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET carbono_muertos_pie=NULL WHERE carbono_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	carbono_muertos_pie TYPE numeric using carbono_muertos_pie::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET carbono_raices=NULL WHERE carbono_raices= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	carbono_raices TYPE numeric using carbono_raices::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET carbono_tocones=NULL WHERE carbono_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	carbono_tocones TYPE numeric using carbono_tocones::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET carbono_vivos=NULL WHERE carbono_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	carbono_vivos TYPE numeric using carbono_vivos::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET fecha_calculo=NULL WHERE fecha_calculo= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	fecha_calculo TYPE timestamp using fecha_calculo::timestamp ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET id_levantamiento=NULL WHERE id_levantamiento= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	id_levantamiento TYPE integer using id_levantamiento::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET individuos_muertos_pie=NULL WHERE individuos_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	individuos_muertos_pie TYPE integer using individuos_muertos_pie::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET individuos_muertos_pie_estimacion=NULL WHERE individuos_muertos_pie_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	individuos_muertos_pie_estimacion TYPE integer using individuos_muertos_pie_estimacion::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET individuos_tocones=NULL WHERE individuos_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	individuos_tocones TYPE integer using individuos_tocones::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET individuos_tocones_estimacion=NULL WHERE individuos_tocones_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	individuos_tocones_estimacion TYPE integer using individuos_tocones_estimacion::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET individuos_totales=NULL WHERE individuos_totales= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	individuos_totales TYPE integer using individuos_totales::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET individuos_totales_estimacion=NULL WHERE individuos_totales_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	individuos_totales_estimacion TYPE integer using individuos_totales_estimacion::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET individuos_vivos=NULL WHERE individuos_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	individuos_vivos TYPE integer using individuos_vivos::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET individuos_vivos_estimacion=NULL WHERE individuos_vivos_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	individuos_vivos_estimacion TYPE integer using individuos_vivos_estimacion::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET latitud=NULL WHERE latitud= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	latitud TYPE double precision using latitud::double precision ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET longitud=NULL WHERE longitud= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	longitud TYPE double precision using longitud::double precision ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET numero_especies_existentes=NULL WHERE numero_especies_existentes= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	numero_especies_existentes TYPE integer using numero_especies_existentes::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET numero_familias_existentes=NULL WHERE numero_familias_existentes= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	numero_familias_existentes TYPE integer using numero_familias_existentes::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_altura_total_muertos_pie=NULL WHERE promedio_altura_total_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_altura_total_muertos_pie TYPE numeric using promedio_altura_total_muertos_pie::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_altura_total_muertos_pie_estimacion=NULL WHERE promedio_altura_total_muertos_pie_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_altura_total_muertos_pie_estimacion TYPE numeric using promedio_altura_total_muertos_pie_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_altura_total_tocones=NULL WHERE promedio_altura_total_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_altura_total_tocones TYPE numeric using promedio_altura_total_tocones::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_altura_total_tocones_estimacion=NULL WHERE promedio_altura_total_tocones_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_altura_total_tocones_estimacion TYPE numeric using promedio_altura_total_tocones_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_altura_total_vivos=NULL WHERE promedio_altura_total_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_altura_total_vivos TYPE numeric using promedio_altura_total_vivos::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_altura_total_vivos_estimacion=NULL WHERE promedio_altura_total_vivos_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_altura_total_vivos_estimacion TYPE numeric using promedio_altura_total_vivos_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_diametro_muertos_pie=NULL WHERE promedio_diametro_muertos_pie= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_diametro_muertos_pie TYPE numeric using promedio_diametro_muertos_pie::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_diametro_muertos_pie_estimacion=NULL WHERE promedio_diametro_muertos_pie_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_diametro_muertos_pie_estimacion TYPE numeric using promedio_diametro_muertos_pie_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_diametro_tocones=NULL WHERE promedio_diametro_tocones= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_diametro_tocones TYPE numeric using promedio_diametro_tocones::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_diametro_tocones_estimacion=NULL WHERE promedio_diametro_tocones_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_diametro_tocones_estimacion TYPE numeric using promedio_diametro_tocones_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_diametro_vivos=NULL WHERE promedio_diametro_vivos= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_diametro_vivos TYPE numeric using promedio_diametro_vivos::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET promedio_diametro_vivos_estimacion=NULL WHERE promedio_diametro_vivos_estimacion= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	promedio_diametro_vivos_estimacion TYPE numeric using promedio_diametro_vivos_estimacion::numeric ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET tallos_totales=NULL WHERE tallos_totales= 'NULL';
ALTER TABLE mssql.staging_calculo_20150727_udm_t2 ALTER COLUMN 	tallos_totales TYPE integer using tallos_totales::integer ;

UPDATE mssql.staging_calculo_20150727_udm_t2 SET tipificacion=NULL WHERE tipificacion= 'NULL';

create table mssql.calculo_20150721_reporte_nivel_udm_estimacion_t2_v20 as select * from mssql.staging_calculo_20150727_udm_t2;
ALTER TABLE mssql.calculo_20150721_reporte_nivel_udm_estimacion_t2_v20 ADD PRIMARY KEY (id);

drop table mssql.staging_calculo_20150727_udm_t2;