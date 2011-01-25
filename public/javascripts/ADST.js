Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ADST = Ext.extend(Ext.Panel, {
  constructor: function(config)
  {
    var resultPanel = new Talho.Rollcall.ADSTResultPanel({});

    this.getResultPanel = function() {
      return resultPanel;
    };
    this.providers    = new Array();
    this.renderGraphs = function(id, image, obj, class_name) {
      provider = new Ext.direct.PollingProvider({
        id: 'image' + id + '-provider',
        type: 'polling',
        url: image,
        listeners: {
          scope: obj,
          data: function(provider, e) {
            if(e.xhr.status == 200) {
              var element_id = Math.floor(Math.random() * 10000);
              (function(provider) {
                this.update('<div id="'+element_id+'" class="'+class_name+'" >' +
                            '<img style="display:none;" src="'+provider.url+'?' + element_id + '" />' +
                            '</div>');
                this.doLayout();
              }).defer(50,this,[provider]);
              (function(provider) {
                this.update('<div id="'+element_id+'" class="'+class_name+'">' +
                            '<img src="'+provider.url+'?' + element_id + '" />' +
                            '</div>');
                this.doLayout();
              }).defer(1000,this,[provider]);
              provider.disconnect();
              return true;
            } else {
              return false;
            }
          }
        }
      });
      this.providers.push(provider);
      Ext.Direct.addProvider(provider);
    };

    Ext.apply(config,
    {
      layout: 'fit',
      closable:   true,
      items:[{
        id: 'adst_container',
        init_store: null,
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
          itemId:   'saved_queries',
          id:       'saved_queries',
          region:   'south',
          height:   180,
          minSize:  180,
          maxSize:  300,
          autoScroll: true,
          layout: 'fit',
//          bodyStyle:   'padding:10px;',
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
          layout:'fit',
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

                  var panel_mask = new Ext.LoadMask(this.getComponent('adst_container').getComponent('ADST_panel').getEl(), {msg:"Please wait..."});
                  panel_mask.show();
                  result_store.on('write', function(){
                    panel_mask.hide();
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
                      var adv_config    = {};
                      for(var i =0; i < record.length; i++){
                        if(record[i].data.schools != ""){
                          simple_config.schools = adv_config.schools = new Array();
                          for(var s = 0; s < record[i].data.schools.length; s++){
                            simple_config.schools[s] = adv_config.schools[s] = [
                              record[i].data.schools[s].id, record[i].data.schools[s].display_name
                            ];
                          }
                        }else if(record[i].data.symptoms != ""){
                          simple_config['symptoms'] = adv_config['symptoms'] = new Array();
                          for(var c =0; c< record[i].data.symptoms.length; c++){
                            simple_config.symptoms[c] = adv_config.symptoms[c] = [
                              record[i].data.symptoms[c].id, record[i].data.symptoms[c].name
                            ];
                          }
                        }else{
                          simple_config[this_store.fields.items[i].name] = adv_config[this_store.fields.items[i].name] = new Array();
                          for(var a = 0; a < record[i].data[this_store.fields.items[i].name].length; a++) {
                            simple_config[this_store.fields.items[i].name][a] = adv_config[
                              this_store.fields.items[i].name][a] = [record[i].data[this_store.fields.items[i].name][a].id,
                              record[i].data[this_store.fields.items[i].name][a].value
                            ]
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
                var result_store = this_toolbar.ownerCt.ownerCt.ownerCt.getResultPanel().getResultStore();
                var container_mask = new Ext.LoadMask(this_toolbar.ownerCt.ownerCt.ownerCt.getResultPanel().getEl(), {msg:"Please wait..."});
                container_mask.show();

                result_store.on('write', function(){
                  container_mask.hide();
                })
                params['page'] = Math.floor(params.start /  params.limit) + 1;
                return true;
              }
            }
          })
        }]
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