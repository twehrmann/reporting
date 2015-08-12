function RefreshTable(tableId, urlData) {
	console.debug("Loading new data from " + urlData + " to fill table "
			+ tableId);

	$.getJSON(urlData, null, function(json) {
		table = $(tableId).dataTable();
		oSettings = table.fnSettings();

		table.fnClearTable(this);

		for (var i = 0; i < json.data.length; i++) {
			table.oApi._fnAddData(oSettings, json.data[i]);
		}

		oSettings.aiDisplay = oSettings.aiDisplayMaster.slice();
		table.fnDraw();
	});
}

function InitTable(tableId, columns, serverSide) {
	if (!serverSide) {
		$(tableId).dataTable({
			"processing" : false,
			"serverSide" : false,
			"paging" : false,
			"ordering" : true,
			"info" : true,
			"filter" : false,
			"scrollY" : "650px",
			"scrollCollapse" : true,
			"pagingType" : "simple",
			"columns" : columns
		});
	} else {
		$(tableId).dataTable({
			"processing" : true,
			"serverSide" : true,
			"paging" : true,
			"ordering" : false,
			"info" : true,
			"filter" : false,
			"scrollY" : "650px",
			"scrollCollapse" : true,
			"pagingType" : "simple",
			"ajax" : {
				"url" : "datatable",
				"type" : "POST",
				"contentType" : 'application/json',
				"data" : function(d) {
					d.sourceResource = baseUrl + $report;
					d.cycle = $cycle;
					d.strata_type = $strata_type;
				},
				"error": function (xhr, error, thrown) {
				       alert( 'You are not logged in' );
				    }
			},
			"columns" : columns,

		});
	}
}

function switchTable(tableId, url, columns, title, serverSide) {
	serverSide = typeof serverSide !== 'undefined' ? serverSide : false;
	console.info("Switching to table:" + url + " : " + serverSide);

	if ($.fn.dataTable.isDataTable(tableId)) {
		console.debug("Removing old table:" + tableId);
		var oTable = $(tableId).dataTable();
		oTable.fnDestroy();
		$(tableId).empty();
	}
	$report = url;

	InitTable(tableId, columns, serverSide);
	if (!serverSide) {
		RefreshTable(tableId, baseUrl + url);
	}

	$("#tableCaption").text(title);

	console.log($report);

}

function setStrataReport() {
	var cycle = $("#strataPeriod option:selected").val();
	var deposit = $("#strataDeposit option:selected").val();
	var stratification = $("#strataStratification option:selected").val();
	var subcategory = $("#strataSubcategory option:selected").val();
	columns = FEcolumns;

	url = "report/strata/" + subcategory + "/" + stratification + "/" + cycle
			+ "/" + deposit + ".json?mode=short";
	title = "Biomasa aereo nivel de UdM";
	$cycle = cycle;

	switchTable("#strata", url, columns, title, false);
	return false;
}

function setObservationReport(deposit, title) {
	var cycle = $("#observationPeriod option:selected").val();
	columns = ObservationCarbonoAereoColumns;

	url = "report/observation/" + cycle + ".json?mode=" + deposit;
	title = title;
	$cycle = cycle;

	switchTable("#strata", url, columns, title, true);
}

function setUdmReport(deposit, title) {
	var cycle = $("#observationPeriod option:selected").val();
	columns = UdmVivoColumns;

	url = "report/udm/" + cycle + ".json?a=0&b=10&mode=" + deposit;
	title = title;
	$cycle = cycle;

	switchTable("#strata", url, columns, title, true);
	return false;
}

function setNationalReport(type,title) {
	var cycle = $("#nationalPeriod option:selected").val();
	columns = NationalReportColumns;

	url = "report/national/"+type+"/" + cycle + ".json";
	title = title;
	$cycle = cycle;
	$strata_type = type;

	switchTable("#strata", url, columns, title, false);
	return false;
}

$(document).ready(function() {
	$('#ObservationAV').click(function() {
		console.log("ObservationAV choosen... ");
		setObservationReport("arbolado_vivo", "Biomasa aerea en el nivel de observación");

		return false;
	});

	$('#ObservationMEP').click(function() {
		console.log("ObservationMEP choosen... ")
		setObservationReport("arbolado_vivo");

		return false;
	});

	$('#ObservationT').click(function() {
		console.log("Observation tocones choosen... ")
		setObservationReport("arbolado_vivo");

		return false;
	});

	$('#UdmAV').click(function() {
		console.log("UdmAV choosen... ")
		setUdmReport("vivos");

		return false;
	});

	$('#UdmM').click(function() {
		console.log("UdmAV choosen... ");
		setUdmReport("muertos_pie");

		return false;
	});

	$('#UdmT').click(function() {
		console.log("UdmAV choosen... ");
		setUdmReport("tocones");

		return false;
	});

	$('#strataSubcategory').click(function() {
		console.log("Strata subcategory choosen... ")
		setStrataReport();

		return false;
	});

	$('#strataStratification').click(function() {
		console.log("Strata stratification choosen... ")
		setStrataReport();

		return false;
	});

	$('#strataPeriod').click(function() {
		console.log("Strata cycle choosen... ")
		setStrataReport();

		return false;
	});

	$('#strataDeposit').click(function() {
		console.log("Strata deposit choosen... ")
		setStrataReport();

		return false;
	});
	
	$('#nationalBUR').click(function() {
		console.log("National BUR choosen... ")
		setNationalReport("bur","National BUR");

		return false;
	});
	
	$('#nationalREDD+').click(function() {
		console.log("National REDD choosen... ")
		setNationalReport("redd","National REDD+");

		return false;
	});
});
