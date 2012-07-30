//= require ext_extensions/Graph

Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.Results = Ext.extend(Ext.ux.Portal, {
  id:     'ADSTResultPanel',
  itemId: 'portalId',
  border: false,
  
  constructor: function (config) {
    Ext.applyIf(config, {
        hidden: true,
        //TODO set up resize event
      }
    );
    
    this.items = [
      {itemId: 'leftColumn', columnWidth: .50},
      {itemId: 'rightColumn', columnWidth: .50}
    ];
    
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

    this._getResultStore = function ()
    {
      return result_store;
    };
    
    Talho.Rollcall.ADST.view.Results.superclass.constructor.apply(this, config);
  },
  
  _loadGraphResults: function (store, records, options) {    
    this.show();
    //TODO disable submit
    
    var resultLength = store.getRange().length;
    var leftColumn = this.getComponent('leftColumn');
    var rightColumn = this.getComponent('rightColumn');
    
    //TODO Keep pinned graphs
    var graph_series = _getGraphSeries();
    
    //TODO make graph image config
    store.each(function (school, i) {
      var id = school.id;
      var name = typeof school.get('name');
      var field_array = _getFieldArray(school);
      var school_store = new Ext.DataView.JsonStore({fields: field_array, data: school.get('results')});      
      var graphImageConfig = {
        title: 'Query Result for ' + name,
        style: 'margin:5px',
        school: school,
        school_name: name,
        school_id: id,
        provider_id: 'image' + i + '-provider',
        collapsible: false,
        pinned: false,
        //TODO ping graph up to Controller
        tools: [
          {id: 'pin', qtip: 'Pin Graph', handler: this._pinGraph },
          {id: 'report', qtip: 'Generate Report', scope: this,
            handler: function(e, targetEl, panel, tc) {
              //TODO fix so it doesn't do all da ownerCts
              var adst_container = panel.ownerCt.ownerCt.ownerCt.ownerCt.ownerCt;
              adst_container._showReportMenu(targetEl, school_id);
            }
          },
          //TODO up to controller
          {id: 'gis', qtip: 'School Profile', handler: this._showSchoolProfile,
            hidden: typeof school.gmap_lat == "undefined" ? true : false
          },
          //TODO up to controller
          {id: 'save', qtip: 'Create Alarm', scope: this,
            handler: function(e, targetEl, panel, tc) {
              this._showAlarmQueryConsole(panel.name);
            }
          },
          //TODO export up to controller
          {id: 'down', qtip: 'Export Result', handler: this._exportResult },
          //TODO close result up to controller
          {id: 'close', qtip: "Close", handler: this._closeResult }
        ],
        height: 230,
        boxMinWidth: 320,
        //TODO switch to dynamic width
        items: new Talho.ux.Graph({
          store: new Ext.data.JsonStore({fields: field_array, data: school.json}),
          width: 500,
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
<<<<<<< HEAD
    if (typeof record.average != "undefined") {
      field_array.push({name:'average', type: 'int'})
    }
    if(typeof record.deviation != "undefined") {
      field_array.push({name:'deviation', type: 'int'})
    }
    if(typeof record.average30 != "undefined") {
      field_array.push({name:'average30', type: 'int'})
    }
    if(typeof record.average60 != "undefined") {
      field_array.push({name:'average60', type: 'int'})
    }
    if(typeof record.cusum != "undefined") {
=======
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
>>>>>>> 8dbb9501a9f7c93528d1c2dc37608c763bc35758
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
  }
});
