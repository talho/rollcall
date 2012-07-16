Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ux.D3Graph = Ext.extend(Ext.Container,{
    
  constructor: function (config) {
    config.width = config.width- 40;    
    config.padding = [20,50];
    config.margin = [20,40];
    config.dateFormatParse = d3.time.format("%Y-%m-%d").parse;
    
    if (!("height" in config))
    {
      config.height = 175;
    }
    if (!("xScale" in config))
    {
      config.xScale = d3.time.scale().range([0, config.w]);
    }
    if (!("yScale" in config))
    {
      config.yScale = d3.scale.linear().range([config.h, 0]);
    }
        
    Talho.Rollcall.ADSTResultPanel.superclass.constructor.call(this, config);
  },
  
  initComponent: function () {
    this.data = this._getD3GraphData();
    this.lines = this._getLinesFromData();
    
    this.area = d3.svg.area.interpolate("monotone")
      .x(function(d) { return x(d.x); })
      .y0(this.height)
      .y1(function(d) { return y(d.y); });
      
    this.line = d3.svg.line()
      .x(function(d) { return x(d.x); })
      .y(function(d) { return y(d.y); });
      
    this.svg = d3.select(this.container.dom)
      .append("svg:svg")
        .attr("width", this.width + (this.padding[1] * 2))
        .attr("height", this.height + (this.padding[0] * 2))
      .append("svg:g")
        .attr("transform", "translate(" + (this.padding[0] + 10) + "," +this.padding[0] - 15 + ")");
        
    this._buildSVG();
    this._addCircles();
    this._formatLines();
  },
  
  _getD3GraphData: function () {
    returnData = [];
    this.store.each( function (record) {
      returnData.push({
        x:  record.get('report_date'),
        y:  record.get('total'),
        e:  record.get('enrolled'),
        a:  record.get("average"),
        d:  record.get('deviation'),
        a3: record.get('average30'),
        a6: record.get('average60'),
        c:  record.get('cusum')
      });
    });
  
    return returnData;  
  },
  
  _getLinesFromData: function () {
    returnLines = [];
    
    if (this.data[0].e > 0)
    {
      returnLines.push([
        d3.svg.line()
          .x(function(d) { return x(d.x); })
          .y(function(d) { return y(d.e); }),
        'e'
      ]);
    }
    if ("a" in this.data[0])
    {
      returnLines.push([
        d3.svg.line()
          .x(function(d) { return x(d.x); })
          .y(function(d) { return y(d.a); }),
        'a'
      ]);
    }
    if ("a3" in this.data[0])
    {
      returnLines.push([
        d3.svg.line()
          .x(function(d) { return x(d.x); })
          .y(function(d) { return y(d.a3); }),
        'a3'
      ]);
    }
    if ("a6" in this.data[0])
    {
      returnLines.push([
        d3.svg.line()
          .x(function(d) { return x(d.x); })
          .y(function(d) { return y(d.a6); }),
        'a6'
      ]);
    }
    if ("d" in this.data[0])
    {
      returnLines.push([
        d3.svg.line()
          .x(function(d) { return x(d.x); })
          .y(function(d) { return y(d.d); }),
        'd'
      ]);
    }
    if ("c" in this.data[0])
    {
      returnLines.push([
        d3.svg.line()
          .x(function(d) { return x(d.x); })
          .y(function(d) { return y(d.c); }),
        'c'
      ]);
    }
  },
  
  _buildSVG: function () {
    this.data.forEach(function(d) {
      d.x = this.dateFormatParse(d.x);
      d.y = +d.y;
    });
    
    this.svg
      .append("svg:clipPath")
        .attr("id", "clip")
      .append("svg:rect")
        .attr("width", this.width)
        .attr("height", this.height);
    
    this.svg.append("svg:path")
      .attr("class", "area")
      .attr("clip-path", "url(#clip)")
      .attr("d", this.area(this.data));            
      
    this.svg.append("svg:g")
      .attr("class", "x axis")
      .call(this._getXAxis);
    
    this.svg.append("svg:g")
      .attr("class", "y axis")
      .attr("transform", "translate(-5,0)")
      .call(this._getYAxis);
      
    this.svg.append("svg:path")
      .attr("class", "line")
      .attr("clip-path", "url(#clip)")
      .attr("d", this.line(this.data));
      
    //TODO: Add axis labels
  },
  
  _getXAxis: function () {
    xAxis = d3.svg.axis()
      .scale(this.xScale)
      .tickSubdivide(true)
      .orient("bottom")
      .domain([this.data[0].x,  data[data.length - 1].x]);
    
    return xAxis;
  },
  
  _getYAxis: function () {
    yAxis =  d3.svg.axis()
      .scale(this.yScale)
      .ticks(4)
      .orient("left")
      .domain([0, d3.max(data, function(d) { return d.y; })])
      .nice();
      
    return yAxis;
  },
  
  _addCircles: function () {
    this.svg.selcAll(".line")
      .data(this.data).enter()
      .append("svg:circle")
        .attr("class", "line")
        .attr("cx", function(d) { return x(d.x) })
        .attr("cy", function(d) { return y(d.y) })
        .attr("ext:qtip", function(d) {
          return '<table><tr><td>Report Date:&nbsp;&nbsp;</td><td>'+d.x.format('M d, Y')+'&nbsp;&nbsp;</td></tr>'+
                 '<tr><td>Total Absent:&nbsp;&nbsp;</td><td>'+d.y+'&nbsp;&nbsp;</td></tr>'+
                 '<tr><td>Total Enrolled:&nbsp;&nbsp;</td><td>'+d.e+'&nbsp;&nbsp;</td></tr></table>'
        })
        .attr("r", 3.5);
  },
  
  _formatLines: function () {
    for(func in this.lines){
      try {
        if(this.lines[func][1] == 'e'){
          var d_d      = 'd.e';
          var qtip_txt = 'Enrollment';
          var line_class = 'line2';
        }
        else if(lines[func][1] == 'a'){
          var d_d        = 'd.a';
          var qtip_txt   = 'Average';
          var line_class = 'line-avg';
        }
        else if(lines[func][1] == 'd'){
          var d_d      = 'd.d';
          var qtip_txt = 'Deviation';
          var line_class = 'line-deviation';
        }
        else if(lines[func][1] == 'a3'){
          var d_d      = 'd.a3';
          var qtip_txt = 'Average';
          var line_class = 'line-avg-30';
        }
        else if(lines[func][1] == 'a6'){
          var d_d      = 'd.a6';
          var qtip_txt = 'Average';
          var line_class = 'line-avg-60';
        }
        else if(lines[func][1] == 'c'){
          var d_d      = 'd.c';
          var qtip_txt = 'Cusum';
          var line_class = 'line-cusum';
        }
        this.svg.append("svg:path")
          .attr('class', line_class)
          .attr("clip-path","url(#clip)")
          .attr("d", lines[c][0](this.data));
        this.svg.selectAll(line_class)
          .data(this.data).enter()
          .append("svg:circle")
            .attr("class", line_class)
            .attr("cx", function(d) { return x(d.x) })
            .attr("cy", function(d) {
              if(d_d == 'd.e') return y(d.e);
              if(d_d == 'd.a') return y(d.a);
              if(d_d == 'd.d') return y(d.d);
              if(d_d == 'd.a3') return y(d.a3);
              if(d_d == 'd.a6') return y(d.a6);
              if(d_d == 'd.c') return y(d.c);
            })
            .attr("ext:qtip", function(d){
              if(d_d == 'd.e') d_d = d.e;
              if(d_d == 'd.a') d_d = d.a;
              if(d_d == 'd.d') d_d = d.d;
              if(d_d == 'd.a3') d_d = d.a3;
              if(d_d == 'd.a6') d_d = d.a6;
              if(d_d == 'd.c') d_d = d.c;
              return '<table><tr><td>Report Date:&nbsp;&nbsp;</td><td>'+d.x.format('M d, Y')+'&nbsp;&nbsp;</td></tr>'+
                     '<tr><td>'+qtip_txt+':&nbsp;&nbsp;</td><td>'+d_d+'&nbsp;&nbsp;</td></tr></table>';
            })
            .attr("r", 3.5);
      }
      catch(e){};
    }
  }
  
});
