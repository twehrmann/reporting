var getUrl = window.location;
var baseUrl = getUrl.protocol + "//" + getUrl.host + "/";

$report = '';
$cycle = 1;
$strata_type = "";

var FEcolumns = [ {
	"data" : "Estrato", "title":"Estrato"
}, {
	"data" : "NumCong", "title":"Num. congl."
}, {
	"data" : "NumSitios", "title":"Num. sitios"
}, {
	"data" : "AreaHa", "title":"Area (ha)"
}, {
	"data" : "ER", "title":"ER (tonC/ha)"
}, {
	"data" : "U", "title":"U (%)"
}];

var ObservationCarbonoAereoColumns = [{
	"data" : "numero_conglomerado", "title":"num conglomerado"}, {
	"data" : "numero_arbol", "title":"num arboles"}, {
	"data" : "seccion_infys", "title":"seccion de INFyS"}, {
	"data" : "carbono_aereo_estimado", "title":"carbono (tonC/ha)"
}]

var UdmVivoColumns = [{
	"data" : "id_unidad_muestreo", "title":"id"}, {
	"data" : "numero_conglomerado", "title":"# cong"}, {
	"data" : "numero_especies_existentes", "title":"# especies"}, {
	"data" : "biomasa_vivos", "title":"biomasa"}, {
	"data" : "carbono_vivos", "title":"carbono"}, {
	"data" : "tallos_totales", "title":"tallos"
}]

var UdmMuertosColumns = [{
	"data" : "id_unidad_muestreo", "title":"id"}, {
	"data" : "numero_conglomerado", "title":"# cong"}, {
	"data" : "numero_especies_existentes", "title":"# especies"}, {
	"data" : "biomasa_muertos_pie", "title":"biomasa"}, {
	"data" : "carbono_muertos_pie", "title":"carbono"}, {
	"data" : "individuos_muertos_pie", "title":"# muertos pie"}, {
	"data" : "tallos_totales", "title":"tallos"
}]

var UdmToconesColumns = [{
	"data" : "id_unidad_muestreo", "title":"id"}, {
	"data" : "numero_conglomerado", "title":"# cong"}, {
	"data" : "numero_especies_existentes", "title":"# especies"}, {
	"data" : "biomasa_tocones", "title":"biomasa"}, {
	"data" : "carbono_tocones", "title":"carbono"}, {
	"data" : "individuos_tocones", "title":"# muertos pie"}, {
	"data" : "tallos_totales", "title":"tallos"
}]

var NationalReportColumns = [{
	"data" : "Dinamica", "title":"Dinamica"}, {
	"data" : "Area", "title":"Area"}, {
	"data" : "EmisionesAbsorciones", "title":"Emisiones/Absorciones"}, {
	"data" : "U", "title":"U (%)"
}]
