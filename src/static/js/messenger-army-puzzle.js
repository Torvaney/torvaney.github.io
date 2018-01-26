
// Define the Joy actors
window.onload = function(){
    var joy = Joy({

        // Where the Joy editor should go:
        // (you can pass a query string, or DOM element)
        container: "#joy",

        // The words & actors inside the editor:
        init: "A column of soldiers is {id:'armyLength', type:'number', placeholder: 40} " +
              "miles long and they march {id:'armySpeed', type:'number', placeholder: 40} " +
              "miles a day. One morning a messenger started at the top of the column with " +
              "a message for the soldier at the back. The messenger began to march and gave the " +
              "message to the rearmost soldier and then returned to his position at the end of " +
              "the day. The messenger marched at a constant speed the whole time. " +
              "What was the messenger's speed? " +
              "Messenger speed: {id:'speed', type:'number', placeholder: 80} miles per day",

        // Modules of "actions" to include, in order you want them shown
        modules: ["instructions", "math", "random"],

        // Optional: whether you want users to be able to preview numbers
        // or actions when they hover over them. (by default, true for both)
        previewActions: true,
        previewNumbers: true,

        // What to do when the user makes a change:
        onupdate: function(my){
            _updateGraph({
                armyLength: my.data.armyLength,
                armySpeed: my.data.armySpeed,
                messengerSpeed: my.data.speed
            })
        }
    });
};

// Draw the stuff (NB: some code copied from
// github.com/ncase/joy/blob/master/demo/nonlinear/nonlinear-demo.js)

// set the dimensions and margins of the graph
var margin = {top:30, right:75, bottom:50, left:60},
    width = 600 - margin.left - margin.right,
    height = 350 - margin.top - margin.bottom;

// set the ranges
var x = d3.scaleLinear().range([0, width]);
var y = d3.scaleLinear().range([height, 0]);

// Appends a chart
var chart = d3.select("#box").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate("+margin.left+","+margin.top+")");

// Append the path, xAxis, and yAxis.
var lineContainer = chart.append("g");
var xAxis = chart.append("g").attr("class", "x axis");
var yAxis = chart.append("g").attr("class", "y axis");

// Axis Labels
chart.append("text")
	.attr("transform", "translate(" + (width) + "," + (height+31) + ")")
	.attr("class", "axis-label")
	.style("text-anchor", "end")
	.html("time &rarr;");
chart.append("text")
	.attr("transform", "translate(" + (-31) + "," + (0) + ") rotate(-90)")
	.attr("class", "axis-label")
	.style("text-anchor", "end")
	.html("location &rarr;");

// Set the X Axis
x.domain([0, 1]);
xAxis.attr("transform", "translate(0,"+height+")")
    .call(d3.axisBottom(x));

y.domain([0, 100]);
yAxis.call(d3.axisLeft(y));


// Setup line generator
var line = d3.line()
    .x(function (d) { return x(d.x); })
    .y(function (d) { return y(d.y); });


function createLineData(m, c) {
    return d3.range(0, 1, 0.001).map(function(v) {
        return {
            x: v,
            y: (m * v) + c
        };
    })
};


function redrawLine(selector, classes, gradient, intercept, filterFunc) {
    // Construct data
    var data = createLineData(gradient, intercept);

    // JOIN
    var path = chart.selectAll(selector)
        .data([data]);

    // ENTER
    path.enter().append('path')
        .attr('class', classes)
        // ENTER + UPDATE
        .merge(path)
        .attr('d', line(data.filter(filterFunc)));
};


function _updateGraph(data) {

    // Set the Y Axis
    y.domain([0, data.armyLength + data.armySpeed]);
    yAxis.call(d3.axisLeft(y));

    redrawLine(
        'path.army-front',
        'line army army-front',
        data.armySpeed,
        data.armyLength,
        function(x) { return x; }
    );
    redrawLine(
        'path.army-back',
        'line army army-back',
        data.armySpeed,
        0,
        function(x) { return x; }
    );

    redrawLine(
        'path.messenger-first-leg',
        'line messenger messenger-first-leg',
        -data.messengerSpeed,
        data.armyLength,
        function(d) {
            return d.y >= (d.x * data.armySpeed);
        }
    );

    // Find the intercept of the line for the messenger's return leg
    var intercept = data.armyLength * (data.armySpeed - data.messengerSpeed) / (data.armySpeed + data.messengerSpeed);
    redrawLine(
        'path.messenger-second-leg',
        'line messenger messenger-second-leg',
        data.messengerSpeed,
        intercept,
        function(d) {
            return d.y >= (d.x * data.armySpeed);
        }
    );

};
