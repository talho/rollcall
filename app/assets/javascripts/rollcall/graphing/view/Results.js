//= require ext_extensions/Graph
//= require rollcall/graphing/view/SchoolProfile
//= require rollcall/graphing/view/GraphWindow

Ext.namespace("Tahlo.Rollcall.Graphing.view");

Tahlo.Rollcall.Graphing.view.Results = Ext.extend(Ext.Panel, {
  border: false,
  
  initComponent: function () {
    this.addEvents('showreportmessage', 'exportresult', 'getneighbors', 'pagingparams');
    this.enableBubble(['showreportmessage', 'exportresult', 'getneighbors', 'pagingparams']);
    
    this.results = new Ext.Panel({autoScroll: true, border: false, cls: 'rollcall-results', items: []});       
    
    this.neighbor_mode = false;
    
    var result_store = new Ext.data.JsonStore({
      autoLoad: false,
      autoSave: true,   
      root: 'results',
      totalProperty: 'total_results',
      idProperty: 'school_id',
      fields: ['tea_id', 'school_id', 'name', 'results', 'id'],
      writer: new Ext.data.JsonWriter({encode: false}),
      url: '/rollcall/graphing',
      restful: true,
      listeners: {
        scope: this,
        load: this._loadGraphResults
      }
    });
    
    var neighbor_store = new Ext.data.JsonStore({
      autoLoad: false,
      root: 'results',
      totalProperty: 'total_results',
      idProperty: 'title',
      fields: ['id', 'name', 'title', 'results'],
      writer: new Ext.data.JsonWriter({encode: false}),
      url: '/rollcall/get_neighbors',
      restful: true,
      listeners: {
        scope: this,
        load: this._loadGraphResults
      }
    });
    
    var export_btn = new Ext.Button({ text: 'Export Result Set' });
    
    var alarm_btn = new Ext.Button({ text: 'Create Alarm from Result Set' });

    this.getResultsStore = function () {
      return (this.neighbor_mode ? neighbor_store : result_store);
    };
    
    this.paging_toolbar = new Ext.PagingToolbar(
      {displayInfo: true, prependButtons: true, pageSize: 6, store: this.getResultsStore(),
       listeners: {'beforechange': function (tb, params) { this.fireEvent ('pagingparams', tb, params); return false; }, scope: this}
      }
    );
    
    this.items = [
      {xtype: 'container', cls: 'rollcall-legend', html: '<div id="graph_legend" style="margin-top:4px;">' +
        '<div style="float:left;margin-left:8px;margin-right:20px">Legend:&nbsp;</div>' +
        '<div style="float:left;margin-right:20px"><span style="background-color:#99BBE8">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Raw&nbsp;</div>' +
        '<div style="float:left;margin-right:20px"><span style="background-color:#FF6600">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Average&nbsp;</div>' +
        '<div style="float:left;margin-right:20px"><span style="background-color:#0666FF">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Average 30 Day&nbsp;</div>' +
        '<div style="float:left;margin-right:20px"><span style="background-color:#660066">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Average 60 Day&nbsp;</div>' +
        '<div style="float:left;margin-right:20px"><span style="background-color:#006600">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Standard Deviation&nbsp;</div>' +
        '<div style="float:left;margin-right:20px"><span style="background-color:#FF0066">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Cusum&nbsp;</div>' +
        '</div><br /><hr />'
      },
      this.results,
    ];
    
    this.bbar = new Ext.Toolbar({ hidden: true, items: [
        this.paging_toolbar,        
        '->',
        new Ext.Spacer({height: 26}),
        export_btn,
        alarm_btn
      ]
    });
    
    Tahlo.Rollcall.Graphing.view.Results.superclass.initComponent.call(this);
  },
  
  loadResultStore: function (params, callback) {
    this.getResultsStore().load({params: params, callback: function () { 
      this.getBottomToolbar().show(); callback(); }, scope: this});    
  },
  
  _loadGraphResults: function (store, records, options) {
    if (!options) { options = this.options }
    else { this.options = options } 
    
    var resultLength = store.getRange().length;
    var height = 280;

    this.results.items.each(function (item) {
      if (!item.pinned) {
        this.results.remove(item, true);
      }
    }, this);
    
    this.results.setHeight(this.getHeight() - 69);
    
    store.each(function (school, i) {
      var id = school.id;      
      var name = school.get('name');
      var field_array = this._getFieldArray(school);
      var graph_series = this._getGraphSeries(field_array);
      //Fixes a bug in IE
      if (!Talho.Detection.SVG()) {
        Ext.each(school.data.results, function (record, i) {
          var date = record.report_date.split("-");
          school.data.results[i].report_date = new Date(date[0], date[1], date[2]);
        });
      }
      var school_store = new Ext.data.JsonStore({fields: field_array, data: school.get('results')});
      var gis = typeof school.gmap_lat == "undefined" ? true : false;
      var getFA = this._getFieldArray;
      var local_params = new Object();
      for (key in options.params) { local_params[key] = options.params[key]; }
      var hideToolTip = (school.get('title') && school.get('title') != school.get('name')) 
      
      var graphImageConfig = {
        title: (school.get('title') ? school.get('title') : 'Query Result for ' + name),
        style: 'margin:5px',
        school: school,
        school_name: name,
        school_id: id,
        provider_id: 'image' + i + '-provider',
        collapsible: false,
        pinned: false,
        height: height,
        layout: 'fit',
        cls: 'ux-portlet ' + name.replace(' ','-'),
        boxMinWidth: 320,
        
        tools: [
          {id: 'pin', qtip: 'Pin Graph', handler: function (e, targetEl, panel, tc) { 
            targetEl.findParent('div.x-panel-tl', 50, true).toggleClass('x-panel-pinned');
            targetEl.toggleClass('x-tool-pin');
            targetEl.toggleClass('x-tool-unpin');
            if(targetEl.hasClass('x-tool-unpin')) panel.pinned = true;
            else panel.pinned = false;
          }},
          /*{id: 'report', qtip: 'Generate Report', scope: this, hidden: hideToolTip,
            handler: function(e, targetEl, panel, tc) {              
              var scrollMenu = new Ext.menu.Menu();
              scrollMenu.add({text: 'Attendance Report', handler: function () { 
                this.fireEvent('showreportmessage', 'RecipeInternal::AttendanceAllRecipe', panel.school_id) }, scope: this
              });
              scrollMenu.add({text: 'ILI Report', handler: function () { 
                this.fireEvent('showreportmessage', 'RecipeInternal::IliAllRecipe', panel.school_id) }, scope: this
              });
              scrollMenu.show(targetEl);
            }
          },*/          
          {id: 'gis', qtip: 'School Profile', handler: function (e, targetEl, panel, tc) {
              var gmap = new Tahlo.Rollcall.Graphing.view.SchoolProfile({school_name: panel.school_name, school: panel.school.json});
              gmap.show();        
            },
            hidden: this.gis
          },          
          {id: 'save', qtip: 'Create Alarm', scope: this, hidden: hideToolTip,
            handler: function(e, targetEl, panel, tc) {
              this.fireEvent('createalarmquery', school.get('id'), school.get('name'));
            }
          },
          {id: 'down', qtip: 'Export Result', hidden: hideToolTip, scope: this, handler: function () { this.fireEvent('exportresult') } },
          {id: 'close', qtip: "Close", handler: this._closeResult }
        ],               
                 
        items: new Talho.ux.Graph({
          store: school_store,
          width: 'auto',
          height: 193,
          series: graph_series,
          xField: 'report_date',
          cls: 'x-panel-mc',
          listeners: {'render': function (c) {
            c.getEl().on('click', function () {
              var w = new Tahlo.Rollcall.Graphing.view.GraphWindow({
                graphNumber: id, _getFieldArray: getFA, graph_series: graph_series,
                search_params: local_params
              }).show();
            });
          }}
        })
      }          
      
      this.results.add(graphImageConfig);
    }, this);
    
    //Checking to see if we should display the neighbors buttons
    if (store.getCount() < 6 && store.getCount() > 0 && store.getAt(0).get('tea_id') == "" && store.getAt(0).get('title') == undefined) {
      var districts = [];      
      store.each(function (record, i) { districts.push(record.get('id')) });
      
      var neighbor = {
        style: 'margin:5px',
        collapsible: false,
        pinned: false,
        frame: false,
        draggable: false,
        border: false,
        cls: '',
        height: height,
        scope: this,
        items: [new Ext.Button({text: 'View Neighboring School Districts', height: 40,  width: 200,
          style: 'margin: -20px -100px; position:relative; top:50%; left:50%;',
          handler: function () {
            this.fireEvent('getneighbors', districts);
          }, 
          scope: this })]
      };
      
      this.results.add(graphImageConfig);
    }
    
    this.doLayout();
  },
  
  _getFieldArray: function (school) {
    var results;
    if ('results' in school) { results = school['results']; }
    else { results =  school.get('results'); }    
    var field_array = [
      {name: 'report_date', type: 'date'},
      {name: 'total', type:'int'},
      {name: 'enrolled', type:'int'}
    ];
    if (results.length > 0)
    {
      if ('average' in results[0]) {
        field_array.push({name:'average', type: 'int'})
      }
      if ('deviation' in results[0]) {
        field_array.push({name:'deviation', type: 'int'})
      }
      if('average30' in results[0]) {
        field_array.push({name:'average30', type: 'int'})
      }
      if('average60' in results[0]) {
        field_array.push({name:'average60', type: 'int'})
      }
      if('cusum' in results[0]) {
        field_array.push({name:'cusum', type: 'int'})
      }
    }
    
    return field_array;
  },
  
  _getGraphSeries: function (field_array) {
    var possible = {
      'total': {type: 'line', displayName: 'Absent', yField: 'total', 
        style: {
          mode: 'stretch',
          color:0x99BBE8,
          stroke:"#99BBE8"
        },
        qtip: function(d){
          return '<div class="d3-tip-row"><span>Report Date:</span><span>' + d3.time.format.utc('%m-%d-%y')(d.get('report_date')) + '</span></div>' +
                 '<div class="d3-tip-row"><span>Absent:</span><span>' + d.get('total') + '</span></div>' +
                 '<div class="d3-tip-row"><span>Enrolled:</span><span>' + ((d.get('enrolled') == 0 || d.get('enrolled') == null) ? 'Not Reported' : d.get('enrolled')) + '</span></div>';
        }
      },
      'average' : {type: 'line', displayName: 'Average', yField: 'average',
        style: {
          mode: 'stretch',
          color:0xFF6600,
          stroke:"#FF6600"
        }
      },      
      'deviation' : {type: 'line', displayName: 'Deviation', yField: 'deviation',
        style: {
          mode: 'stretch',
          color:0x006600,
          stroke:"#006600"
        }
      },
      'average30' : {type: 'line', displayName: 'Average 30 Day', yField: 'average30',
        style: {
          mode: 'stretch',
          color:0x0666FF,
          stroke:"#0666FF"
        }
      },
      'average60' : {type: 'line', displayName: 'Average 60 Day', yField: 'average60',
        style: {
          mode: 'stretch',
          color:0x660066,
          stroke:"#660066"
        }
      },
      'cusum' : {type: 'line', displayName: 'Cusum', yField: 'cusum',
        style: {
          mode: 'stretch',
          color:0xFF0066,
          stroke:"#FF0066"
        }
      }
    };
    
    var series = []; 
    
    Ext.each(field_array, function(field){
      if(possible[field.name]){
        series.push(possible[field.name]);
      }
    });
    
    return series;
  },
  
  _closeResult: function (e, target, panel) {
    panel.ownerCt.remove(panel, true);
  },
  
});
