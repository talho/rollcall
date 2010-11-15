Ext.namespace('Talho.ux.rollcall');

Talho.ux.rollcall.comboBoxConfig  = Ext.extend(Ext.form.ComboBox, {
  typeAhead:     true,
  triggerAction: 'all',
  mode:          'local',
  lazyRender:    true,
  autoSelect:    true,
  selectOnFocus: true,
  valueField:    'id',
  displayField:  'value'
});

Talho.ux.rollcall.optionStore = null;

Talho.RollcallQuery = Ext.extend(Ext.util.Observable, {
  constructor: function(config)
  {
    Ext.apply(this, config);
    Talho.RollcallQuery.superclass.constructor.call(this, config);
    var panel = new Ext.Panel({
      title:      config.title,
      id:         config.id,
      closable:   true,
      autoScroll: true,
      layout:     'border',
      listeners: {
        scope: this,
        'afterrender': function(this_panel){
          new Ext.data.JsonStore({
            autoLoad: true,
            root:   'options',
            fields: ['absenteeism', 'data_functions', 'school_type', 'schools'],
            url:    '/rollcall/query_options',
            listeners:{
              scope: this,
              'load': function(this_store, record){
                var simple_config = {};
                var adv_config = {};
                for(var i =0; i < record.length; i++){
                  if(record[i].data.absenteeism != ""){
                    simple_config.absenteeism = adv_config.absenteeism = new Array();
                    for(var a = 0; a < record[i].data.absenteeism.length; a++){
                      simple_config.absenteeism[a] = adv_config.absenteeism[a] = [
                        record[i].data.absenteeism[a].id, record[i].data.absenteeism[a].value
                      ];
                    }
                  }else if(record[i].data.data_functions != ""){
                    simple_config.data_functions = adv_config.data_functions = new Array();
                    for(var d = 0; d < record[i].data.data_functions.length; d++){
                      simple_config.data_functions[d] = adv_config.data_functions[d] = [
                        record[i].data.data_functions[d].id, record[i].data.data_functions[d].value
                      ]
                    }
                  }else if(record[i].data.school_type != ""){
                    simple_config.school_type = adv_config.school_type = new Array();
                    for(var st = 0; st < record[i].data.school_type.length; st++){
                      simple_config.school_type[st] = adv_config.school_type[st] = [
                        record[i].data.school_type[st].id, record[i].data.school_type[st].value
                      ]
                    }
                  }
                  else if(record[i].data.schools != ""){
                    simple_config.schools = adv_config.schools = new Array();
                    for(var s = 0; s < record[i].data.schools.length; s++){
                      simple_config.schools[s] = adv_config.schools[s] = [
                        record[i].data.schools[s].id, record[i].data.schools[s].display_name
                      ]
                    }
                  }
                }
                this.getPanel().getComponent("search_panel").getComponent("query_container").add(new Talho.ux.rollcall.RollcallSimpleSearchForm(simple_config));
                this.getPanel().getComponent("search_panel").getComponent("query_container").add(new Talho.ux.rollcall.RollcallAdvancedSearchForm(adv_config));
                this.getPanel().getComponent("search_panel").getComponent("query_container").doLayout();
                this.getPanel().getComponent("search_panel").doLayout();
              }
            }
          });
        }
      },
      defaults: {
        collapsible: true,
        split:       true,     
        cmargins:    '5 5 0 0',
        margins:     '5 0 0 0'
      },
      items: [{
        title:    'Saved Queries',
        region:   'south',
        height:   150,
        minSize:  75,
        maxSize:  250,
        bodyStyle:   'padding:15px',
        items:    new Talho.ux.rollcall.RollcallSavedQueriesPanel({})
      },{
        title:       'Reports',
        region:      'east',
        width:       200,
        minSize:     175,
        maxSize:     400,
        bodyStyle:   'padding:0px',
        layout:      'fit',
        autoScroll:  true,
        items:       new Talho.ux.rollcall.RollcallReportsPanel({})
      },{
        title: 'Alarms',
        region:'west',
        width: 200,
        minSize: 175,
        maxSize: 400,
        bodyStyle: 'padding:0px',
        items: new Talho.ux.rollcall.RollcallAlarmsPanel({})
      },{
        listeners:   { scope: this},
        title:       'Search',
        itemId:      'search_panel',
        collapsible: false,
        region:      'center',
        autoScroll:  true,
        items:[{
          xtype:  'container',
          itemId: 'query_container',
          layout: 'column'
        },
          new Talho.ux.rollcall.RollcallSearchResultPanel({})
        ]
      }]
    });

    this.getPanel = function()
    {
      return panel;
    }
  },
  buildReportPanel: function()
  {
    return true
  },
  submitQuery: function(b, e)
  {
    return false;
  },
  cancelForm: function(b,e)
  {
    return false;
  },
  resizeGraphs: function()
  {
    return false;
  }
});

Talho.RollcallQuery.initialize = function(config)
{
  var query = new Talho.RollcallQuery(config);
  return query.getPanel();
}

Talho.ScriptManager.reg('Talho.RollcallQuery', Talho.RollcallQuery, Talho.RollcallQuery.initialize);