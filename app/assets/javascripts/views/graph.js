//= require d3

(function(){
  function isFloat(n) {
    return n === +n && n !== (n|0);
  }

  function isInteger(n) {
    return n === +n && n === (n|0);
  }

  Rollcall = window.Rollcall || {}

  var weekday = (function() {
    // Returns the weekday number for the given date relative to January 1, 1970.
    function weekday(date) {
      var weekdays = weekdayOfYear(date),
          year = date.getFullYear();
      while (--year >= 1970) weekdays += weekdaysInYear(year);
      return weekdays;
    }

    // Returns the date for the specified weekday number relative to January 1, 1970.
    weekday.invert = function(weekdays) {
      var year = 1970,
          yearWeekdays;

      // Compute the year.
      while ((yearWeekdays = weekdaysInYear(year)) <= weekdays) {
        ++year;
        weekdays -= yearWeekdays;
      }

      // Compute the date from the remaining weekdays.
      var days = weekdays % 5,
          day0 = ((new Date(year, 0, 1)).getDay() + 6) % 7;
      if (day0 + days > 4) days += 2;
      return new Date(year, 0, (weekdays / 5 | 0) * 7 + days + 1);
    };

    // Returns the number of weekdays in the specified year.
    function weekdaysInYear(year) {
      return weekdayOfYear(new Date(year, 11, 31)) + 1;
    }

    // Returns the weekday number for the given date relative to the start of the year.
    function weekdayOfYear(date) {
      var days = d3.time.dayOfYear(date),
          weeks = days / 7 | 0,
          day0 = (d3.time.year(date).getDay() + 6) % 7,
          day1 = day0 + days - weeks * 7;
      return Math.max(0, days - weeks * 2
          - (day0 <= 5 && day1 >= 5 || day0 <= 12 && day1 >= 12) // extra saturday
          - (day0 <= 6 && day1 >= 6 || day0 <= 13 && day1 >= 13)); // extra sunday
    }

    return weekday;
  })();

  Rollcall.GraphView = Backbone.View.extend({
    initialize: function() {
      this.listenTo(this.model, "change", this.render);
    },

    template: HandlebarsTemplates['graph'],

    render: function(){
      this.$el.html(this.template(this.model.attributes));

      // render d3 here
      var margin = {top: 20, right: 20, bottom: 30, left: 50},
          width = this.$el.width() - 47 - margin.left - margin.right,
          height = width*0.5 - margin.top - margin.bottom;

      var tickFormat = d3.time.format("%m-%d"),
          parseDate = d3.time.format("%Y-%m-%d").parse;

      var x = d3.scale.linear()
          .range([0, width]);

      var y = d3.scale.linear()
          .range([height, 0]);

      var xAxis = d3.svg.axis()
          .scale(x)
          .orient("bottom")
          .tickFormat(function(t){
            if(isInteger(t)){
              return tickFormat(weekday.invert(t));
            }
          });

      var yAxis = d3.svg.axis()
          .scale(y)
          .orient("left")
          .tickFormat(d3.format("0%"));

      var line = d3.svg.line().x(function(d) {return x(weekday(parseDate(d.report_date)));})
                              .y(function(d) { return y(d.pct); });

      var svg = d3.select(this.$('.panel-body')[0]).append('svg')
                  .attr('width', width + margin.left + margin.right)
                  .attr('height', height + margin.top + margin.bottom)
                  .attr('class', 'graph')
                .append("g")
                  .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      x.domain(d3.extent(this.model.attributes.infos, function(d) {
        return weekday(parseDate(d.report_date));
      }));
      var y_extent = d3.extent(this.model.attributes.infos, function(d) { return d.pct; })
      y.domain([Math.floor(y_extent[0]*10)/10, Math.ceil(y_extent[1]*10)/10]);

      svg.append("g")
          .attr("class", "x axis")
          .attr("transform", "translate(0," + height + ")")
          .call(xAxis);

      svg.append("g")
          .attr("class", "y axis")
          .call(yAxis);

      svg.append("path")
          .datum(this.model.attributes.infos)
          .attr("class", "line")
          .attr("d", line);
    }
  });
})();
