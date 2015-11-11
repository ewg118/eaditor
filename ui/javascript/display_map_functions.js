function initialize_timemap(id, path) {
	var path = $('#path').text();
	var url = path + "api/get?id=" + id + "&format=json&model=timemap";
	var datasets = new Array();
	
	//first dataset
	datasets.push({
		id: 'dist',
		title: "Distribution",
		type: "json",
		options: {
			url: url
		}
	});
	
	var tm;
	tm = TimeMap.init({
		mapId: "map", // Id of map div element (required)
		timelineId: "timeline", // Id of timeline div element (required)
		options: {
			eventIconPath: path + "images/timemap/"
		},
		datasets: datasets,
		bandIntervals:[
		Timeline.DateTime.YEAR,
		Timeline.DateTime.DECADE]
	});
}