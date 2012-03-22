Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ADSTResultPanel = Ext.extend(Ext.ux.Portal, {
  /*
  Method builds the ADSTResultPanel, a Ext.ux.Portal, which is responsible for displaying the result sets as portlets and attaching the
  necessary functions to each one
  @param config
   */
  constructor: function(config){
    Ext.applyIf(config,{
      hidden: true,
      id:     'ADSTResultPanel',
      itemId: 'portalId',
      border: false,
      defaults: {
        listeners:{
          scope: this,
          afterrender: function(this_obj){
            this_obj.addListener('resize', function(this_column, width, height){
              try{
                Ext.each(this_column.findByType('container'), function(c){
                  if(c.drawn) c.fireEvent('resize', c, (width - 10), height);
                  c.drawn = true;
                }, this);
              }catch(e){}
            },this);
          }
        }
      },
      items:[{
        columnWidth: .50,
        itemId:      'leftColumn'
      },{
        columnWidth: .50,
        itemId:      'rightColumn'
      }]
    });

    var result_store = new Ext.data.JsonStore({
      autoLoad:       false,
      autoSave:       true,   
      root:          'results',
      totalProperty: 'total_results',
      fields: [
        {name:'tea_id',      type:'int'},
        {name:'report_date', renderer: Ext.util.Format.dateRenderer('m-d-Y')},
        {name:'enrolled',    type:'int'},
        {name:'total',       type:'int'},
        {name:'school_name', type:'string'}
      ],
      writer:         new Ext.data.JsonWriter({encode: false}),
      url:            '/rollcall/adst',
      restful:        true,
      listeners:      {
        scope:      this,
        load:       this._loadGraphResults
      }
    });

    this._getResultStore = function()
    {
      return result_store;
    };

    Talho.Rollcall.ADSTResultPanel.superclass.constructor.call(this, config);
  },
  /*
  Method shows the ADSTResultPanel and then proceeds to write the graphs out to the Panel, method is listener function
  for load on result_store
  @param store   the ext store containing the results
  @param records the records pulled in from the store
  @param options the store config options
   */
  _loadGraphResults: function(store, records, options)
  {
    this.show();
    try{
      this._writeGraphs(store);
    }catch(e){
      this._writeFlashGraphs(store);
    }

  },
  /*
  Method returns the result store
   */
  _getResultStore: function()
  {
    return this._getResultStore();
  },
  /*
  Method creates an Ext portlet for each returned result in result set, called from loadGraphResults function
  @param store the store containing the result set
   */
  _writeGraphs: function(store)
  {
    this.ownerCt.find('id', 'ADSTFormPanel')[0].buttons[0].disable();
    var resultLength = store.getRange().length;
    var leftColumn   = this.getComponent('leftColumn');
    var rightColumn  = this.getComponent('rightColumn');
    rightColumn.items.each(function(item){
      if(!item.pinned) rightColumn.remove(item.id, true);
    });

    leftColumn.items.each(function(item) {
      if(!item.pinned) leftColumn.remove(item.id, true);
    });

    Ext.each(store.getRange(), function(school_record,i){
      var school           = school_record.json[0]; // TODO
      var school_id        = school.school_id;
      var school_name      = typeof school.school_name == "undefined" ? school.name : school.school_name;
      var result_obj       = null;
      var field_array      = [
          {name: 'report_date', renderer: Ext.util.Format.dateRenderer('m-d-Y')},
          {name: 'total', type:'int'},
          {name: 'enrolled', type:'int'}
        ];
      var graph_series = [{
          type: 'line',
          displayName: 'Absent',
          yField: 'total',
          style: {
              mode: 'stretch',
              color:0x99BBE8
          }
        },{
          type: 'line',
          displayName: 'Average',
          yField: 'average',
          style: {
              mode: 'stretch',
              color:0xFF6600
          }
        },{
          type: 'line',
          displayName: 'Deviation',
          yField: 'deviation',
          style: {
              mode: 'stretch',
              color:0x006600
          }
        },{
          type: 'line',
          displayName: 'Average 30 Day',
          yField: 'average30',
          style: {
              mode: 'stretch',
              color:0x0666FF
          }
        },{
          type: 'line',
          displayName: 'Average 60 Day',
          yField: 'average60',
          style: {
              mode: 'stretch',
              color:0x660066
          }
        },{
          type: 'line',
          displayName: 'Cusum',
          yField: 'cusum',
          style: {
              mode: 'stretch',
              color:0xFF0066
          }
        }];
      if(typeof school.average != "undefined"){
        field_array.push({name:'average', type: 'int'})
      }else if(typeof school.deviation != "undefined"){
        field_array.push({name:'deviation', type: 'int'})
      }else if(typeof school.average30 != "undefined"){
        field_array.push({name:'average30', type: 'int'})
      }else if(typeof school.average60 != "undefined"){
        field_array.push({name:'average60', type: 'int'})
      }else if(typeof school.cusum != "undefined"){
        field_array.push({name:'cusum', type: 'int'})
      }
      //var some_store = new Ext.data.JsonStore({fields: field_array,data: school_record.json});

      var graphImageConfig = {
        title:       'Query Result for '+school_name,
        style:       'margin:5px',
        school:      school,
        school_name: school_name,
        school_id:   school_id,
        provider_id: 'image'+i+'-provider',
        collapsible: false,
        pinned:      false,
        tools: [{
          id:      'pin',
          qtip:    'Pin Graph',
          handler: this._pinGraph
        },{
          id:      'report',
          qtip:    'Generate Report',
          scope:   this,
          handler: function(e, targetEl, panel, tc){
            var adst_container = panel.ownerCt.ownerCt.ownerCt.ownerCt.ownerCt;
            adst_container._showReportMenu(targetEl, school_id);
          }
        },{
          id:      'gis',
          qtip:    'School Profile',
          handler: this._showSchoolProfile,
          hidden:  typeof school.gmap_lat == "undefined" ? true : false
        },{
          id:      'save',
          qtip:    'Create Alarm',
          scope:   this,
          handler: function(e, targetEl, panel, tc)
          {
            this._showAlarmQueryConsole(panel.school_name);
          }
        },{
          id:      'down',
          qtip:    'Export Result',
          handler: this._exportResult
        },{
          id:      'close',
          qtip:    "Close",
          handler: this._closeResult
        }],
        height: 230,
        boxMinWidth: 320,
        items: {
          xtype: 'container',
          store: new Ext.data.JsonStore({fields: field_array,data: school_record.json}),
          drawn: false,
          listeners: {
            scope: this,
            afterrender: function(this_container){
              this._createD3Graphs(this_container, this_container.getWidth(), 230);
              this_container.doLayout();
            },
            resize: function(this_container, width, height){
              Ext.each(Ext.query('svg', this_container.container.dom), function(s){
                Ext.removeNode(s);
              },this_container);
              this._createD3Graphs(this_container, width, height);
              this_container.doLayout();
            }
          }
        }
      };
      if(i == 0 || i%2 == 0) result_obj = rightColumn.add(graphImageConfig);
      else result_obj = leftColumn.add(graphImageConfig);
      this.doLayout();
    }, this);
    this.ownerCt.find('id', 'ADSTFormPanel')[0].buttons[0].enable();
  },
  /*
  Method creates graphs using the D3 library, attaches them portlet elements - method is listener function for
  afterrender and resize attached to portlet
  @param this_container the container that the SVG graph will be rendered to
  @param width          the width to create the graph with
  @param height         the height to create the graph with
   */
  _createD3Graphs: function(this_container, width, height)
  {
    var data    = [];
    var lines   = [];
    var circles = [];
    d3.range(this_container.store.getTotalCount()).map(function(cnt){
      var some_date = this_container.store.getAt(cnt).get('report_date');
      data.push({
        x:  some_date,
        y:  this_container.store.getAt(cnt).get('total'),
        e:  this_container.store.getAt(cnt).get('enrolled'),
        a:  this_container.store.getAt(cnt).get("average"),
        d:  this_container.store.getAt(cnt).get('deviation'),
        a3: this_container.store.getAt(cnt).get('average30'),
        a6: this_container.store.getAt(cnt).get('average60'),
        c:  this_container.store.getAt(cnt).get('cusum')
      });
    });

    var w     = width - 40,
        h     = 175,
        p     = [20,50],
        m     = [20,40],
        parse = d3.time.format("%m-%d-%y").parse,
        x     = d3.time.scale().range([0, w]),
        y     = d3.scale.linear().range([h, 0]),
        xAxis = d3.svg.axis().scale(x).tickSize(-h).tickSubdivide(true),
        yAxis = d3.svg.axis().scale(y).ticks(4).orient("left");


    // An area generator, for the light fill.
    var area = d3.svg.area().interpolate("monotone").x(function(d) { return x(d.x); })
        .y0(h).y1(function(d) { return y(d.y); });

    // A line generator, for the dark stroke.
    var line = d3.svg.line().x(function(d) { return x(d.x); }).y(function(d) { return y(d.y); });

    if(typeof data[0].e > 0){
      lines.push([d3.svg.line().x(function(d){return x(d.x);}).y(function(d){ return y(d.e);}),'e']);
    }else if(typeof data[0].a != "undefined"){
      lines.push([d3.svg.line().x(function(d){return x(d.x);}).y(function(d){ return y(d.a);}),'a']);
    }else if(typeof data[0].d != "undefined"){
      lines.push([d3.svg.line().x(function(d){return x(d.x);}).y(function(d){ return y(d.d);}),'d']);
    }else if(typeof data[0].a3 != "undefined"){
      lines.push([d3.svg.line().x(function(d){return x(d.x);}).y(function(d){ return y(d.a3);}),'a3']);
    }else if(typeof data[0].a6 != "undefined"){
      lines.push([d3.svg.line().x(function(d){return x(d.x);}).y(function(d){ return y(d.a6);}),'a6']);
    }else if(typeof data[0].c != "undefined"){
      lines.push([d3.svg.line().x(function(d){return x(d.x);}).y(function(d){ return y(d.c);}),'c']);
    }
    // Parse dates and numbers. We assume values are sorted by date.
    data.forEach(function(d) {
      d.x = parse(d.x);
      d.y = +d.y;
    });

    // Compute the minimum and maximum date, and the maximum price.
    x.domain([data[0].x, data[data.length - 1].x]);
    y.domain([0, d3.max(data, function(d) { return d.y; })]).nice();

    // Add an SVG element with the desired dimensions and margin.
    var svg = d3.select(this_container.container.dom).append("svg:svg").attr("width", w + p[1] * 2)
        .attr("height", h+p[0]*2).append("svg:g").attr("transform", "translate("+(p[0]+10)+","+(p[0] - 15)+")");

    // Add the clip path.
    svg.append("svg:clipPath").attr("id", "clip").append("svg:rect").attr("width", w).attr("height", h);

    // Add the area path.
    svg.append("svg:path").attr("class", "area").attr("clip-path", "url(#clip)").attr("d", area(data));

    // Add the x-axis.
    svg.append("svg:g").attr("class", "x axis").attr("transform", "translate(0," + h + ")").call(xAxis);

    // Add the y-axis.
    svg.append("svg:g").attr("class", "y axis").call(yAxis);

    // Add the line path.
    svg.append("svg:path").attr("class", "line").attr("clip-path", "url(#clip)").attr("d", line(data));

    svg.selectAll(".line").data(data).enter().append("svg:circle").attr("class", "line")
            .attr("cx", function(d) { return x(d.x)})
            .attr("cy", function(d) { return y(d.y)})
            .attr("ext:qtip", function(d){
              return '<table><tr><td>Report Date:&nbsp;&nbsp;</td><td>'+d.x.format('M d, Y')+'&nbsp;&nbsp;</td></tr>'+
                      '<tr><td>Total Absent:&nbsp;&nbsp;</td><td>'+d.y+'&nbsp;&nbsp;</td></tr>'+
                      '<tr><td>Total Enrolled:&nbsp;&nbsp;</td><td>'+d.e+'&nbsp;&nbsp;</td></tr></table>'
            }).attr("r", 3.5);

    for(c in lines){
      try{
        if(lines[c][1] == 'e'){
          var d_d      = 'd.e';
          var qtip_txt = 'Enrollment';
          var line_class = 'line2';
        }else if(lines[c][1] == 'a'){
          var d_d        = 'd.a';
          var qtip_txt   = 'Average';
          var line_class = 'line-avg';
        }else if(lines[c][1] == 'd'){
          var d_d      = 'd.d';
          var qtip_txt = 'Deviation';
          var line_class = 'line-deviation';
        }else if(lines[c][1] == 'a3'){
          var d_d      = 'd.a3';
          var qtip_txt = 'Average';
          var line_class = 'line-avg-30';
        }else if(lines[c][1] == 'a6'){
          var d_d      = 'd.a6';
          var qtip_txt = 'Average';
          var line_class = 'line-avg-60';
        }else if(lines[c][1] == 'c'){
          var d_d      = 'd.c';
          var qtip_txt = 'Cusum';
          var line_class = 'line-cusum';
        }
        var li = svg.append("svg:path").attr('class',line_class).attr("clip-path","url(#clip)").attr("d", lines[c][0](data));
        svg.selectAll(line_class).data(data).enter().append("svg:circle")
                      .attr("class", line_class)
                      .attr("cx", function(d) { return x(d.x)})
                      .attr("cy", function(d) {
                        if(d_d == 'd.e') return y(d.e);
                        if(d_d == 'd.a') return y(d.a);
                        if(d_d == 'd.d') return y(d.d);
                        if(d_d == 'd.a3') return y(d.a3);
                        if(d_d == 'd.a6') return y(d.a6);
                        if(d_d == 'd.c') return y(d.c);
                      }).attr("ext:qtip", function(d){
                        if(d_d == 'd.e') d_d = d.e;
                        if(d_d == 'd.a') d_d = d.a;
                        if(d_d == 'd.d') d_d = d.d;
                        if(d_d == 'd.a3') d_d = d.a3;
                        if(d_d == 'd.a6') d_d = d.a6;
                        if(d_d == 'd.c') d_d = d.c;
                        return '<table><tr><td>Report Date:&nbsp;&nbsp;</td><td>'+d.x.format('M d, Y')+'&nbsp;&nbsp;</td></tr>'+
                                 '<tr><td>'+qtip_txt+':&nbsp;&nbsp;</td><td>'+d_d+'&nbsp;&nbsp;</td></tr></table>';
                      }).attr("r", 3.5);
      }catch(e){};
    }
  },
  _writeFlashGraphs: function(store)
  {
      this.ownerCt.find('id', 'ADSTFormPanel')[0].buttons[0].disable();
      var resultLength = store.getRange().length;
      var leftColumn   = this.getComponent('leftColumn');
      var rightColumn  = this.getComponent('rightColumn');
      rightColumn.items.each(function(item){
        if(!item.pinned) rightColumn.remove(item.id, true);
      });

      leftColumn.items.each(function(item) {
        if(!item.pinned) leftColumn.remove(item.id, true);
      });

      Ext.each(store.getRange(), function(school_record,i){
        var school           = school_record.json[0]; // TODO
        var school_id        = school.school_id;
        var school_name      = typeof school.school_name == "undefined" ? school.name : school.school_name;
        var result_obj       = null;
        var field_array      = [
            {name: 'report_date', renderer: Ext.util.Format.dateRenderer('m-d-Y')},
            {name: 'total', type:'int'},
            {name: 'enrolled', type:'int'}
          ];
        var graph_series = [{
            type: 'line',
            displayName: 'Absent',
            yField: 'total',
            style: {
                mode: 'stretch',
                color:0x99BBE8
            }
          },{
            type: 'line',
            displayName: 'Average',
            yField: 'average',
            style: {
                mode: 'stretch',
                color:0xFF6600
            }
          },{
            type: 'line',
            displayName: 'Deviation',
            yField: 'deviation',
            style: {
                mode: 'stretch',
                color:0x006600
            }
          },{
            type: 'line',
            displayName: 'Average 30 Day',
            yField: 'average30',
            style: {
                mode: 'stretch',
                color:0x0666FF
            }
          },{
            type: 'line',
            displayName: 'Average 60 Day',
            yField: 'average60',
            style: {
                mode: 'stretch',
                color:0x660066
            }
          },{
            type: 'line',
            displayName: 'Cusum',
            yField: 'cusum',
            style: {
                mode: 'stretch',
                color:0xFF0066
            }
          }];
        if(typeof school.average != "undefined"){
          field_array.push({name:'average', type: 'int'})
        }else if(typeof school.deviation != "undefined"){
          field_array.push({name:'deviation', type: 'int'})
        }else if(typeof school.average30 != "undefined"){
          field_array.push({name:'average30', type: 'int'})
        }else if(typeof school.average60 != "undefined"){
          field_array.push({name:'average60', type: 'int'})
        }else if(typeof school.cusum != "undefined"){
          field_array.push({name:'cusum', type: 'int'})
        }
        var some_store = new Ext.data.JsonStore({fields: field_array,data: school_record.json});

        var graphImageConfig = {
          title:       'Query Result for '+school_name,
          style:       'margin:5px',
          school:      school,
          school_name: school_name,
          school_id:   school_id,
          provider_id: 'image'+i+'-provider',
          collapsible: false,
          pinned:      false,
          tools: [{
            id:      'pin',
            qtip:    'Pin This Graph',
            handler: this._pinGraph
          },{
            id:      'report',
            qtip:    'Generate Report',
            scope:   this,
            handler: function(e, targetEl, panel, tc){
              var adst_container = panel.ownerCt.ownerCt.ownerCt.ownerCt.ownerCt;
              adst_container._showReportMenu(targetEl, school_id);
            }
          },{
            id:      'gis',
            qtip:    'Show School Profile',
            handler: this._showSchoolProfile,
            hidden:  typeof school.gmap_lat == "undefined" ? true : false
          },{
            id:      'save',
            qtip:    'Save As Alarm',
            scope:   this,
            handler: function(e, targetEl, panel, tc)
            {
              this._showAlarmQueryConsole(panel.school_name);
            }
          },{
            id:      'down',
            qtip:    'Export Result',
            handler: this._exportResult
          },{
            id:      'close',
            qtip:    "Close",
            handler: this._closeResult
          }],
          height: 230,
          boxMinWidth: 320,
          items: {
            xtype: 'columnchart',
            store: some_store,
            xField: 'report_date',
            chartStyle: {
                padding: 10,
                animationEnabled: true,
                font: {
                    name: 'Tahoma',
                    color: 0x444444,
                    size: 11
                },
                dataTip: {
                    padding: 5,
                    border: {
                        color: 0x99bbe8,
                        size:1
                    },
                    background: {
                        color: 0xDAE7F6,
                        alpha: .9
                    },
                    font: {
                        name: 'Tahoma',
                        color: 0x15428B,
                        size: 10,
                        bold: true
                    }
                },
                xAxis: {
                    color: 0x69aBc8,
                    majorTicks: {color: 0x69aBc8, length: 4},
                    minorTicks: {color: 0x69aBc8, length: 2},
                    majorGridLines: {size: 1, color: 0xeeeeee}
                },
                yAxis: {
                    color: 0x69aBc8,
                    majorTicks: {color: 0x69aBc8, length: 4},
                    minorTicks: {color: 0x69aBc8, length: 2},
                    majorGridLines: {size: 1, color: 0xdfe8f6}
                }
            },
            yAxis: new Ext.chart.NumericAxis({
                displayName: 'Absent',
                labelRenderer : Ext.util.Format.numberRenderer('0,0')
            }),
            tipRenderer : function(chart, record, index, series){
              var tip_string = Ext.util.Format.number(record.data.total, '0,0') + ' students absent on ' + record.data.report_date;
              tip_string    += '\n\r'+Ext.util.Format.number(record.data.enrolled, '0,0') + ' students enrolled on ' + record.data.report_date;
              return tip_string;
            },
            series: graph_series
          }
        };
        if(i == 0 || i%2 == 0) result_obj = rightColumn.add(graphImageConfig);
        else result_obj = leftColumn.add(graphImageConfig);
        this.doLayout();
      }, this);
      this.ownerCt.find('id', 'ADSTFormPanel')[0].buttons[0].enable();
    },
  /*
  Method is called when uses closes a graph result, resulting in removing it from the panel - method is handler function
  for close tool button
  @param e      the click event
  @param target the tool button element
  @param panel  the panel the tool element is attached to
   */
  _closeResult: function(e, target, panel)
  {
    panel.ownerCt.remove(panel, true);
  },
  /*
  Method creates an ext window display school profile and recent student data - method is handler function for the
  show school profile tool button
  @param e        the click event
  @param targetEl the tool button element pressed
  @param panel    the panel the tool button is attached to
  @param tc       the tool button config object
   */
  _showSchoolProfile: function(e, targetEl, panel, tc)
  {
    var html_pad          = '<table class="alarm-tip-table"><tr><td><b>Student Daily Info:</b></td>'+
                            '<td><span>&nbsp;</span></td></tr></table>';
    var gmapPanel         = new Ext.ux.GMapPanel({zoomLevel: 12, width: 450, height: 400});
    var sch_info_tpl      = new Ext.XTemplate(
      '<tpl for=".">',
        '<table class="alarm-tip-table">',
          '<tr>',
            '<td><b>School:</b></td>',
            '<td><span>{display_name}</span></td>',
          '</tr>',
          '<tr>',
            '<td><b>School Type:</b></td>',
            '<td><span>{school_type}</span></td>',
          '</tr>',
          '<tr>',
            '<td><b>School Daily Info:</b></td>',
            '<td><span>&nbsp;</span></td>',
          '</tr>',
        '</table>',
      '</tpl>');
    var school_grid_panel = new Ext.grid.GridPanel({
      forceLayout: true,
      scope:       this,
      height:      125,
      viewConfig:  {
        emptyText: '<div><b style="color:#000">No School Data Available</b></div>',
        forceFit:  true
      },
      store: new Ext.data.JsonStore({
        autoDestroy: true,
        autoSave:    true,
        autLoad:     false,
        root:        'school_daily_infos',
        fields:      [
          {name:'id',                type:'int'},
          {name:'school_id',         type:'int'},
          {name:'report_date',       renderer: Ext.util.Format.dateRenderer('m-d-Y')},
          {name:'total_absent',      type:'int'},
          {name:'total_enrolled',    type:'int'}
        ]
      }),
      columns: [
        {header: 'Absent',      sortable: true,  dataIndex: 'total_absent'},
        {header: 'Enrolled',    sortable: true,  dataIndex: 'total_enrolled'},
        {header: 'Report Date', sortable: true,  dataIndex: 'report_date'}
      ],
      stripeRows:  true,
      stateful:    true
    });
    var student_grid_panel = new Ext.grid.GridPanel({
      forceLayout: true,
      scope:       this,
      height:      125,
      viewConfig:  {
        emptyText: '<div><b style="color:#000">No Student Data Available</b></div>',
        forceFit: true
      },
      store: new Ext.data.JsonStore({
        autoDestroy: true,
        autoSave:    true,
        autLoad:     false,
        root:        'student_daily_infos',
        fields:      [
          {name:'id',                type:'int'},
          {name:'age',               type:'int'},
          {name:'confirmed_illness', type:'bool'},
          {name:'gender',            type:'string'},
          {name:'grade',             type:'int'},
          {name:'school_id',         type:'int'},
          {name:'report_date',       renderer: Ext.util.Format.dateRenderer('m-d-Y')}
        ]
      }),
      columns: [
        {header: 'Age',           sortable: true,  dataIndex: 'age'},
        {header: 'Gender',        sortable: true,  dataIndex: 'gender'},
        {header: 'Grade',         sortable: true,  dataIndex: 'grade'},
        {header: 'Confirmed',     sortable: true,  dataIndex: 'confirmed_illness'},
        {header: 'Report Date',   sortable: true,  dataIndex: 'report_date'}
      ],
      stripeRows:  true,
      stateful:    true
    });
    var school_radio_group = new Ext.form.RadioGroup({
      fieldLabel: 'School Daily Info',
      id:         'school_radio_group',
      items: [
          {boxLabel: '1 month',  name: 'school_time', value: 1, checked: true},
          {boxLabel: '2 months', name: 'school_time', value: 2},
          {boxLabel: '3 months', name: 'school_time', value: 3}
      ],
      scope: this
    });
    var student_radio_group = new Ext.form.RadioGroup({
      fieldLabel: 'Student Daily Info',
      id:         'student_radio_group',
      items: [
          {boxLabel: '1 month',  name: 'student_time', value: 1, checked: true},
          {boxLabel: '2 months', name: 'student_time', value: 2},
          {boxLabel: '3 months', name: 'student_time', value: 3}
      ],
      scope: this
    });
    school_radio_group.addListener("change", function(group, chkd_radio )
      {
        panel.ownerCt.ownerCt._getSchoolData(chkd_radio.value, win, panel, school_grid_panel, 'school');
      }
    );
    student_radio_group.addListener("change", function(group, chkd_radio )
      {
        panel.ownerCt.ownerCt._getSchoolData(chkd_radio.value, win, panel, student_grid_panel, 'student');
      }
    );
    var win = new Ext.Window({
      title:      "School Profile for " + panel.school_name,
      layout:     'hbox',
      labelAlign: 'top',
      padding:    '5',
      width:      810,
      items: [{
        xtype:  'container',
        layout: 'vbox',
        width:  350,
        height: 400,
        defaults:{
          xtype: 'container',
          width: 345
        },
        items: [{
          html:  sch_info_tpl.applyTemplate(panel.school)
        },{
          items: [school_radio_group,school_grid_panel],
          html:  '<table class="alarm-tip-table"><tr><td><b>Student Daily Info:</b></td><td><span>&nbsp;</span></td></tr></table>'
        },{
          items: [student_radio_group,student_grid_panel]
        }]
      },{
        xtype: 'spacer',
        width: 10
      },gmapPanel]
    });
    win.addButton({xtype: 'button', text: 'Dismiss', handler: function(){ win.close(); }, scope: this, width:'auto'});
    gmapPanel.addListener("mapready", function(obj){
      var loc = new google.maps.LatLng(panel.school.gmap_lat, panel.school.gmap_lng);
      gmapPanel.gmap.setCenter(loc);
      var addr_elems    = panel.school.gmap_addr.split(",");
      var marker        = gmapPanel.addMarker(loc, panel.school.display_name, {});
      marker.info       = "<b>" + panel.school.display_name + "</b><br/>";
      marker.info      += addr_elems[0] + "<br/>" + addr_elems[1] + "<br/>" + addr_elems.slice(2).join(",");
      marker.info_popup = null;
      google.maps.event.addListener(marker, 'click', function(){
        if (marker.info_popup) {
          this.info_popup.close(gmapPanel.gmap, this);
          this.info_popup = null;
        } else {
          this.info_popup = new google.maps.InfoWindow({content: this.info});
          this.info_popup.open(gmapPanel.gmap, this);
        }
      });
      marker.info_popup = new google.maps.InfoWindow({content: marker.info});
      marker.info_popup.open(gmapPanel.gmap, marker);
    });
    win.addListener("afterrender", function(obj){
      panel.ownerCt.ownerCt._getSchoolData(1, obj, panel, school_grid_panel, 'school');
      panel.ownerCt.ownerCt._getSchoolData(1, obj, panel, student_grid_panel, 'student');

    });
    win.show();
  },
  /*
  Method gets called from showSchoolProfile method, above, retrieves the latest school data for school
  @param month      the number of months to retrieve latest data for
  @param win_obj    the school profile window
  @param main_panel the main panel that makes up the profiel window
  @param grid_panel the grid panel to populate data with
  @param type       type of call to make (student or school)
   */
  _getSchoolData: function(month, win_obj, main_panel, grid_panel, type)
  {
    var grid_mask = new Ext.LoadMask(grid_panel.getEl(), {msg:"Please wait...", removeMask: true});
    grid_mask.show();
    Ext.Ajax.request({
      url:     '/rollcall/get_'+type+'_data',
      method:  'POST',
      headers: {'Accept': 'application/json'},
      scope:   win_obj,
      params:  {
        school_id: main_panel.school_id,
        time_span: month
      },
      success: function(response, options)
      {
        jsonObj = Ext.decode(response.responseText).results;
        grid_panel.store.loadData(jsonObj);
        this.doLayout();
        grid_mask.hide();
      }
    });
  },
  /*
  Method starts the export process on the back end by making an ext ajax request to start exporting data for school
  @param e        the click event
  @param targetEl the ext element clicked
  @param panel    the panel the tool element is attached to
  @param tc       the original tool config object
   */
  _exportResult: function(e, targetEl, panel, tc)
  {
    var adst_container = panel.ownerCt.ownerCt.ownerCt.ownerCt.ownerCt;
    var params = adst_container._buildParams(panel.ownerCt.ownerCt.ownerCt.findByType('form')[0].getForm().getValues());
    adst_container._grabListViewFormValues(params);
    var param_string = '';
    for(key in params){
      if(key != 'school[]' && key != 'school_type[]' && key != 'zip[]') param_string += key + '=' + params[key] + '&';
    }
    if(Ext.getCmp('advanced_query_select').isVisible()){
      param_string += 'school[]=' + panel.school_name + "&";
    }else{
      param_string += 'school=' + panel.school_name + "&";
    }
    Ext.MessageBox.show({
      title: 'Creating CSV Export File',
      msg:   'Your CSV file will be placed in your documents folders when the system '+
      'is done generating it. Please check your documents folder in a few minutes.',
      buttons: Ext.MessageBox.OK,
      icon:    Ext.MessageBox.INFO
    });
    Ext.Ajax.request({
      url:      '/rollcall/export?'+param_string,
      method:   'GET',
      scope:    this,
      failure: function(){}
    });
  },
  /*
  Method builds the alarm query console, it sends along the params that generated the result
   @param school_name the school name for which the alarm query is being created for
   */
  _showAlarmQueryConsole: function(school_name)
  {
    var params       = new Array();
    var storedParams = new Ext.data.ArrayStore({
      storeId: 'my-store',
      fields:  ['field', 'value'],
      idIndex: 0
    });

    baseParams = this._getResultStore().baseParams;
    queryParams = {};
    for(key in baseParams){
      if(baseParams[key].indexOf("...") == -1 && key != "authenticity_token") queryParams[key] = baseParams[key];
    }
    queryParams["type"] = (Ext.getCmp('advanced_query_select').isVisible()) ? "adv" : "simple";
    if (school_name){
      if(queryParams["type"] == "adv"){
        queryParams["school[]"] = [];
        queryParams["school[]"].push(school_name);
        //queryParams["school"][] = t_a;
      }else queryParams["school"] = school_name;
    }
    for(key in queryParams){ params.push([key, queryParams[key]]); }
    storedParams.loadData(params);

    var o_i = {
      render_to:         'adst_container',
      alarm_query_title: (school_name) ? 'Alarm Query for '+school_name : 'Alarm Query',
      form_id:           'alarmQueryForm',
      form_url:          '/rollcall/alarm_query',
      auth_token:        FORM_AUTH_TOKEN,
      query_params:      Ext.encode(queryParams),
      deviation_min:     100,
      deviation_max:     100,
      severity_min:      100,
      severity_max:      100,
      stored_params:     storedParams,
      buttons: [{
        text:    'Submit',
        handler: this._submitAlarmQueryForm
      },{
        text: 'Close',
        handler: function(buttonEl, eventObj){
          alarm_console.close();
        }
      }]
    };
    var alarm_console = new Talho.Rollcall.ux.AlarmQueryWindow(o_i);
    alarm_console.doLayout();
    alarm_console.show();
  },
  /*
  Method submits the form and sets a callback on actioncomplete along with certain options
  @param buttonEl the ext element pressed
  @param eventObj the event object
   */
  _submitAlarmQueryForm: function(buttonEl, eventObj)
  {
    var obj_options   = {result_panel: this.ownerCt.ownerCt.result_panel};
    var update_params = {params:{latest: true}};
    this.ownerCt.ownerCt.getComponent('alarmQueryForm').getForm().on('actioncomplete', function(){
      Ext.getCmp('alarm_queries').getComponent('portalId_south')._updateAlarmQueries(update_params);
      this.hide();
      this.destroy();
    }, this.ownerCt.ownerCt, obj_options);
    this.ownerCt.ownerCt.getComponent('alarmQueryForm').getForm().submit();
  },
  /*
  Method toggles classes x-tool-pin and x-tool-unpin
  @param e        the click event
  @param targetEl the ext element clicked
  @param panel    the panel the ext element is attached to
  @param tc       the tool config option
   */
  _pinGraph: function(e, targetEl, panel, tc)
  {
    targetEl.findParent('div.x-panel-tl', 50, true).toggleClass('x-panel-pinned')
    targetEl.toggleClass('x-tool-pin');
    targetEl.toggleClass('x-tool-unpin');
    if(targetEl.hasClass('x-tool-unpin')) panel.pinned = true;
    else panel.pinned = false;
  }
});
