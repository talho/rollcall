//= require ext_extensions/Graph
//= require rollcall/ADST/view/SchoolProfile
Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.Results = Ext.extend(Ext.ux.Portal, {
  id:     'ADSTResultPanel',
  itemId: 'portalId',
  border: false,
  hidden: true,
  
  constructor: function(config){
    //TODO set up resize event
    Talho.Rollcall.ADST.view.Results.superclass.constructor.apply(this, arguments);
    
    this.addEvents('createalarmquery', 'showreportmessage', 'exportresult');
    this.enableBubble(['createalarmquery', 'showreportmessage', 'exportresult']);
  },
  
  initComponent: function () {
    this.items = [
      {itemId: 'leftColumn', columnWidth: .50},
      {itemId: 'rightColumn', columnWidth: .50}
    ];
    
    this.html = '<div id="graph_legend" style="margin-top:4px;">' +
      '<div style="float:left;margin-left:8px;margin-right:20px">Legend:&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#99BBE8">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Raw&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#FF6600">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Average&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#0666FF">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Average 30 Day&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#660066">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Average 60 Day&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#006600">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Standard Deviation&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#FF0066">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Cusum&nbsp;</div>' +
      '</div></ br> </ hr>';
    
    var result_store = new Ext.data.JsonStore({
      autoLoad: false,
      autoSave: true,   
      root: 'results',
      totalProperty: 'total_results',
      idProperty: 'school_id',
      fields: ['tea_id', 'school_id', 'name', 'results'],
      writer: new Ext.data.JsonWriter({encode: false}),
      url: '/rollcall/adst',
      restful: true,
      listeners: {
        scope: this,
        load: this._loadGraphResults
      }
    });

    this.getResultsStore = function ()
    {
      return result_store;
    };
    
    Talho.Rollcall.ADST.view.Results.superclass.initComponent.apply(this, arguments);
  },
  
  loadResultStore: function (params, callback) {
    this.getResultsStore().load({params: params, callback: callback});
  },
  
  _loadGraphResults: function (store, records, options) {    
    this.show();
    //TODO disable submit
    
    var resultLength = store.getRange().length;
    var leftColumn = this.getComponent('leftColumn');
    var rightColumn = this.getComponent('rightColumn');
    
    rightColumn.items.each(function(item){
      if(!item.pinned) rightColumn.remove(item.id, true);
    });

    leftColumn.items.each(function(item) {
      if(!item.pinned) leftColumn.remove(item.id, true);
    });
    
    var graph_series = this._getGraphSeries();
    
    store.each(function (school, i) {
      var id = school.id;
      var name = school.get('name');
      var field_array = this._getFieldArray(school);
      var school_store = new Ext.data.JsonStore({fields: field_array, data: school.get('results')});
      var gis = typeof school.gmap_lat == "undefined" ? true : false;  
      var graphImageConfig = {
        title: 'Query Result for ' + name,
        style: 'margin:5px',
        school: school,
        school_name: name,
        school_id: id,
        provider_id: 'image' + i + '-provider',
        collapsible: false,
        pinned: false,
        height: 230,
        cls: 'ux-portlet',
        boxMinWidth: 320,
        
        tools: [
          {id: 'pin', qtip: 'Pin Graph', handler: function (e, targetEl, panel, tc) { 
            targetEl.findParent('div.x-panel-tl', 50, true).toggleClass('x-panel-pinned');
            targetEl.toggleClass('x-tool-pin');
            targetEl.toggleClass('x-tool-unpin');
            if(targetEl.hasClass('x-tool-unpin')) panel.pinned = true;
            else panel.pinned = false;
          }},
          {id: 'report', qtip: 'Generate Report', scope: this,
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
          },          
          {id: 'gis', qtip: 'School Profile', handler: function (e, targetEl, panel, tc) {
              var gmap = new Talho.Rollcall.ADST.view.SchoolProfile({school_name: panel.school_name, school: panel.school.json});
              gmap.show();        
            },
            hidden: this.gis
          },          
          {id: 'save', qtip: 'Create Alarm', scope: this,
            handler: function(e, targetEl, panel, tc) {
              this.fireEvent('createalarmquery', school.get('id'), school.get('name'));
            }
          },
          //TODO export up to controller
          {id: 'down', qtip: 'Export Result', scope: this, handler: function () { this.fireEvent('exportresult') } },
          {id: 'close', qtip: "Close", handler: this._closeResult }
        ],
                 
        items: new Talho.ux.Graph({
          store: school_store,
          width: 'auto',
          series: graph_series
        })
      }          
      
      if(i % 2 == 0) {
        rightColumn.add(graphImageConfig);
      }
      else {
        leftColumn.add(graphImageConfig);
      }
      this.doLayout();
    }, this);        
  },
  
  _getFieldArray: function (school) {
    var results = school.get('results');
    var field_array = [
      {name: 'report_date', renderer: Ext.util.Format.dateRenderer('m-d-Y')},
      {name: 'total', type:'int'},
      {name: 'enrolled', type:'int'}
    ];
    if (typeof results.average != "undefined") {
      field_array.push({name:'average', type: 'int'})
    }
    if(typeof results.deviation != "undefined") {
      field_array.push({name:'deviation', type: 'int'})
    }
    if(typeof results.average30 != "undefined") {
      field_array.push({name:'average30', type: 'int'})
    }
    if(typeof results.average60 != "undefined") {
      field_array.push({name:'average60', type: 'int'})
    }
    if(typeof results.cusum != "undefined") {
      field_array.push({name:'cusum', type: 'int'})
    }
    
    return field_array;
  },
  
  _getGraphSeries: function () {
    var series = [
      {type: 'line', displayName: 'Absent', yField: 'total', 
        style: {
          mode: 'stretch',
          color:0x99BBE8
        }
      },
      {type: 'line', displayName: 'Average', yField: 'average',
        style: {
          mode: 'stretch',
          color:0xFF6600
        }
      },
      {type: 'line', displayName: 'Deviation', yField: 'deviation',
        style: {
          mode: 'stretch',
          color:0x006600
        }
      },
      {type: 'line', displayName: 'Average 30 Day', yField: 'average30',
        style: {
          mode: 'stretch',
          color:0x0666FF
        }
      },
      {type: 'line', displayName: 'Average 60 Day', yField: 'average60',
        style: {
          mode: 'stretch',
          color:0x660066
        }
      },
      {type: 'line', displayName: 'Cusum', yField: 'cusum',
        style: {
          mode: 'stretch',
          color:0xFF0066
        }
      }
    ];
    
    return series;
  },
  
  _closeResult: function (e, target, panel) {
    panel.ownerCt.remove(panel, true);
  },

  getSearchParams: function(){
    return this.getResultsStore().lastOptions.params;
  }
});
