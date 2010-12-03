Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.init_store = null;

Talho.Rollcall.result_store = new Ext.data.JsonStore({
  idProperty: 'id',
  totalProperty: 'total_results',
  root:   'results',
  fields: ['id', 'value'],
  listeners: {
    scope: this,
    'load': function(this_store, record){
      var image_uri = '';
      var item_id = null;
      var graphImageConfig = null;
      var image_load = false;
      var d_cnt = 0;
      for(var i = 0; i < record.length; i++){
        item_id = 'query_result_'+i;
        graphImageConfig = {
          title: 'Query Result',
          style:'margin:5px',
          itemId: item_id,
          tools: [{
            id:'plus',
            qtip: 'Save Query',
            handler: function(e, targetEl, panel, tc){
              Ext.getCmp('ADSTResultPanel')._showAlarmConsole();
            }
          },{
            id:'close',
            handler: function(e, target, panel){
              panel.ownerCt.remove(panel, true);
            }
          }],
          height: 230,
          html: '<div style="text-align:center">Loading...</div>'
        };
        if(i == 0 || i%2 == 0)Ext.getCmp('ADSTResultPanel').get('columnRight').add(graphImageConfig);
        else Ext.getCmp('ADSTResultPanel').get('columnLeft').add(graphImageConfig);
        Ext.getCmp('ADSTResultPanel').get('columnLeft').doLayout();
        Ext.getCmp('ADSTResultPanel').get('columnRight').doLayout();
      }

//      for(var i = 0; i < record.length; i++){
//        var image_uri = record[i].data.value;
//        var item_id = 'query_result_'+i;
//        var graphImageConfig = {
//          title: 'Query Result',
//          style:'margin:5px',
//          itemId: item_id,
//          listeners:{
//            scope: this,
//            'render': function()
//            {
//              Ext.Ajax.request({
//                url: image_uri,
//                success: function(){
//                  var temp_comp = Ext.getCmp('searchResultPanel').get("columnRight").getComponent(item_id).add({html:'<div style="text-align:center"><img name="'+i+'" src="'+image_uri+'" /></div>'});
//                  if(temp_comp == undefined)
//                    Ext.getCmp('searchResultPanel').get("columnLeft").getComponent(item_id).add({html:'<div style="text-align:center"><img name="'+i+'" src="'+image_uri+'" /></div>'});
//                  Ext.getCmp('searchResultPanel').get('columnLeft').doLayout();
//                  Ext.getCmp('searchResultPanel').get('columnRight').doLayout();
//                },
//                failure: function(result, opts){
//                  Ext.Ajax.request(opts);
//                },
//                headers: {
//                  'type': 'HEAD'
//                }
//              });
//
//            }
//          },
//          tools: [{
//            id:'plus',
//            qtip: 'Save Query',
//            handler: function(e, targetEl, panel, tc){
//              Ext.getCmp('searchResultPanel')._showAlarmConsole();
//            }
//          },{
//            id:'close',
//            handler: function(e, target, panel){
//              panel.ownerCt.remove(panel, true);
//            }
//          }],
//          height: 230,
//          html: '<div style="text-align:center">Loading...</div>'
//        };
//        if(i == 0 || i%2 == 0)Ext.getCmp('searchResultPanel').get('columnRight').add(graphImageConfig);
//        else Ext.getCmp('searchResultPanel').get('columnLeft').add(graphImageConfig);
//        Ext.getCmp('searchResultPanel').get('columnLeft').doLayout();
//        Ext.getCmp('searchResultPanel').get('columnRight').doLayout();
//      }
    }
  }
});

Talho.RollcallQuery = Ext.extend(Ext.util.Observable, {
  constructor: function(config)
  {
    Ext.apply(this, config);
    Talho.RollcallQuery.superclass.constructor.call(this, config);
    var panel = new Ext.Panel({
      title:      config.title,
      id:         config.id,
      itemdId:    config.id,
      closable:   true,
      autoScroll: true,
      layout:     'border',
      listeners: {
        scope: this,
        'render': function(this_panel){
          Talho.Rollcall.init_store = new Ext.data.JsonStore({
            autoLoad: true,
            root:   'options',
            fields: ['absenteeism', 'age', 'data_functions', 'gender', 'grade', 'school_type',   'schools', 'symptons', 'temperature', 'zipcode'],
            url:    '/rollcall/query_options',
            listeners:{
              scope: this,
              'load': function(this_store, record){
                var simple_config = {};
                var adv_config = {};
                for(var i =0; i < record.length; i++){
                  if(record[i].data.schools != ""){
                    simple_config.schools = adv_config.schools = new Array();
                    for(var s = 0; s < record[i].data.schools.length; s++){
                      simple_config.schools[s] = adv_config.schools[s] = [
                        record[i].data.schools[s].id, record[i].data.schools[s].display_name
                      ]
                    }
                  }else{
                    string_eval = "simple_config."+this_store.fields.items[i].name+" = adv_config."+this_store.fields.items[i].name+" = new Array();"+
                    "for(var a = 0; a "+"<"+" record[i].data."+this_store.fields.items[i].name+".length; a++){"+
                        "simple_config."+this_store.fields.items[i].name+"[a] = adv_config."+this_store.fields.items[i].name+"[a] = ["+
                          "record[i].data."+this_store.fields.items[i].name+"[a].id, record[i].data."+this_store.fields.items[i].name+"[a].value"+
                        "];"+
                     "}"
                    eval(string_eval);  
                  }
                }
                this.getPanel().getComponent("ADST_panel").getComponent('query_container').show();
                this.getPanel().getComponent("ADST_panel").getComponent("query_container").getComponent("ADSTFormPanel").add(new Talho.Rollcall.SimpleADSTContainer(simple_config));
                this.getPanel().getComponent("ADST_panel").getComponent("query_container").getComponent("ADSTFormPanel").add(new Talho.Rollcall.AdvancedADSTContainer(adv_config));
                this.getPanel().getComponent("ADST_panel").getComponent("query_container").getComponent("ADSTFormPanel").doLayout();
                this.getPanel().getComponent("ADST_panel").doLayout();
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
        items:    new Talho.Rollcall.SavedQueriesPanel({})
      },{
        title:       'Reports',
        region:      'east',
        width:       200,
        minSize:     175,
        maxSize:     400,
        bodyStyle:   'padding:0px',
        layout:      'fit',
        autoScroll:  true,
        items:       new Talho.Rollcall.ReportsPanel({})
      },{
        title: 'Alarms',
        region:'west',
        width: 200,
        minSize: 175,
        maxSize: 400,
        bodyStyle: 'padding:0px',
        items: new Talho.Rollcall.AlarmsPanel({})
      },{
        listeners:   { scope: this},
        title:       'ADST',
        itemId:      'ADST_panel',
        id:          'ADST_panel',
        collapsible: false,
        region:      'center',
        autoScroll:  true,
        listeners: {
          render: function(this_comp){
            new Ext.LoadMask(this_comp.getEl(), {msg:"Please wait...", store: Talho.Rollcall.init_store});  
          }
        },
        items:[{
          xtype:  'container',
          itemId: 'query_container',
          layout: 'column',
          hidden: true,
          items:[{
            xtype: 'form',
            itemId: 'ADSTFormPanel',
            columnWidth: 1,
            labelAlign: 'top',
            id: "ADSTFormPanel",
            url:'/rollcall/adst',
            buttonAlign: 'left',
            buttons: [{
              text: "Submit",
              scope: this,
              handler: function(buttonEl, eventObj){
                Ext.getCmp('ADSTFormPanel').getForm().submit({
                  scope: this,
                  waitMsg: "Please wait...",
                  waitTitle: "Loading",
                  success: function(form, action)
                  {
                    Ext.getCmp('ADSTResultPanel').show();
                    Ext.getCmp('ADSTResultPanel').processQuery(action.result);
                  },
                  failure: function(form, action)
                  {

                  }
                });
              },
              formBind: true
            },{
              text: "Cancel",
              handler: this.clearForm
            }]
          }]
        },
          new Talho.Rollcall.ADSTResultPanel({})
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
