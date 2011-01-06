Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ADST = Ext.extend(Ext.Panel, {
  constructor: function(config)
  {
    var resultPanel = new Talho.Rollcall.ADSTResultPanel({});
    this.getResultPanel = function() {
      return resultPanel;
    }
    
    Ext.apply(config, {
      init_store: null,
      closable:   true,
      autoScroll: true,
      layout:     'border',
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
        listeners:   {scope:this},
        title:       'ADST',
        itemId:      'ADST_panel',
        id:          'ADST_panel',
        collapsible: false,
        region:      'center',
        autoScroll:  true,
        listeners: {
          render: function(this_comp){
            new Ext.LoadMask(this_comp.getEl(), {msg:"Please wait...", store: this.ownerCt.init_store});
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
                this.getResultPanel().clearProviders();
                var form_values = buttonEl.findParentByType('form').getForm().getValues();
                var result_store = this.getResultPanel().getResultStore();
                buttonEl.findParentByType('form').findParentByType('panel').getBottomToolbar().bindStore(result_store);
                form_values.page = 1;
                form_values.start = 0;
                form_values.limit = 6;
                for(key in form_values){
                  result_store.setBaseParam(key, form_values[key]);
                }

                buttonEl.findParentByType("form").buttons[2].show();

                var test_mask = new Ext.LoadMask(this.getComponent('ADST_panel').getEl(), {msg:"Please wait..."});
                test_mask.show();
                result_store.on('write', function(){
                  test_mask.hide();
                })
                result_store.load();
                return true;
              },
              formBind: true
            },{
              text: "Cancel",
              handler: function(buttonEl, eventObj){
                buttonEl.findParentByType("form").getForm().reset();
              }
            },{
              text: "Export Result Set",
              hidden: true,
              handler: function(buttonEl, eventObj){
                var form_values  = buttonEl.findParentByType("form").getForm().getValues();
                var param_string = '';
                for(key in form_values){
                  param_string += key + '=' + form_values[key] + "&";
                }
                Talho.ux.FileDownloadFrame.download('rollcall/export?'+param_string);
              }
            }],
            initComponent: function() {
              this.ownerCt.ownerCt.ownerCt.init_store = new Ext.data.JsonStore({
                autoLoad: true,
                root:   'options',
                fields: ['absenteeism', 'age', 'data_functions', 'gender', 'grade', 'school_type', 'schools', 'symptoms', 'temperature', 'zipcode'],
                url:    '/rollcall/query_options',
                listeners:{
                  scope: this,
                  load: function(this_store, record){
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
                        simple_config[this_store.fields.items[i].name] = adv_config[this_store.fields.items[i].name] = new Array();
                        for(var a = 0; a < record[i].data[this_store.fields.items[i].name].length; a++) {
                          simple_config[this_store.fields.items[i].name][a] = adv_config[this_store.fields.items[i].name][a] = [record[i].data[this_store.fields.items[i].name][a].id, record[i].data[this_store.fields.items[i].name][a].value]
                        }
                      }
                    }
                    this.ownerCt.show();
                    this.add(new Talho.Rollcall.SimpleADSTContainer(simple_config));
                    this.add(new Talho.Rollcall.AdvancedADSTContainer(adv_config));
                    this.doLayout();
                  }
                }
              });

              this.__proto__.initComponent.apply(this);
            }
          }]
        }, resultPanel ],
        bbar: new Ext.PagingToolbar({
          scope: this,
          displayInfo: true,
          pageSize: 6,
          prependButtons: true,
          listeners:{
            'beforechange': function(this_toolbar, params){
              var result_store = this_toolbar.ownerCt.ownerCt.getResultPanel().getResultStore();
              var test_mask = new Ext.LoadMask(this_toolbar.ownerCt.ownerCt.getResultPanel().getEl(), {msg:"Please wait..."});
              test_mask.show();

              result_store.on('write', function(){
                test_mask.hide();
              })
              params['page'] = Math.floor(params.start /  params.limit) + 1;
              return true;
            }
          }
        })
      }]
    });
    Talho.Rollcall.ADST.superclass.constructor.call(this, config);
  }
});

Talho.Rollcall.ADST.initialize = function(config)
{
  return new Talho.Rollcall.ADST(config);
}

Talho.ScriptManager.reg('Talho.Rollcall.ADST', Talho.Rollcall.ADST, Talho.Rollcall.ADST.initialize);