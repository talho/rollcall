Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.SavedQueriesPanel = Ext.extend(Ext.ux.Portal, {
  constructor: function(config){
//    var savedQueryStore = new Talho.Rollcall.ADSTResultPanel({});
//    this.getResultPanel = function() {
//      return resultPanel;
//    }
    Ext.applyIf(config, {
      itemId: 'portalId_south',
      border: false,
      saved_store: new Ext.data.JsonStore({
        autoLoad: true,
        root:   'results',
        fields: ['id', 'saved_queries', 'img_urls'],
        proxy: new Ext.data.HttpProxy({
          url: '/rollcall/save_query',
          method:'get'
        }),
        listeners:{
          scope: this,
          load: function(this_store, record){
            var result_obj          = null;
            var column_obj          = null;
            var query_title         = null;
            var query_params        = null;
            var severity_min        = null;
            var severity_max        = null;
            var deviation_threshold = null;
            var deviation_min       = null;
            var deviation_max       = null;
            var r_id                = null;
            var query_id            = null;
            var south_panel         = this;
            for(var i=0;i<record.length;i++){
              if(record[i].data.saved_queries.length == 0){
                column_obj = this.add({
                  columnWidth: .25,
                  itemId: 'empty_saved_query_container',
                  listeners:{
                    scope: this
                  }
                });
                result_obj = column_obj.add({
                  cls: 'ux-saved-graphs',
                  html: '<div class="ux-empty-saved-query-container"><p>There are no saved queries.</p></div>'
                });
              }else{
                if(this.getComponent('empty_saved_query_container')){
                  this.getComponent('empty_saved_query_container').destroy();
                }
                for(var cnt=0;cnt<record[i].data.saved_queries.length;cnt++){
                  query_id            = record[i].data.saved_queries[cnt].saved_query.id;
                  query_title         = record[i].data.saved_queries[cnt].saved_query.name;
                  query_params        = record[i].data.saved_queries[cnt].saved_query.query_params;
                  severity_min        = record[i].data.saved_queries[cnt].saved_query.severity_min;
                  severity_max        = record[i].data.saved_queries[cnt].saved_query.severity_max;
                  deviation_threshold = record[i].data.saved_queries[cnt].saved_query.deviation_threshold;
                  deviation_min       = record[i].data.saved_queries[cnt].saved_query.deviation_min;
                  deviation_max       = record[i].data.saved_queries[cnt].saved_query.deviation_max;
                  r_id                = record[i].data.saved_queries[cnt].saved_query.rrd_id;
                  column_obj = this.add({
                    columnWidth: .25,
                    listeners:{
                      scope: this
                    }
                  });
                  result_obj = column_obj.add({
                    title: query_title,
                    tools: [{
                      id:'save',
                      qtip: 'Edit Query',
                      handler: function(e, targetEl, panel, tc){
                        panel.ownerCt.ownerCt.showEditSavedQueryConsole(query_title, query_params, severity_min,
                          severity_max, deviation_threshold, deviation_min, deviation_max, r_id, query_id, south_panel);
                      }
                    }],
                    cls: 'ux-saved-graphs',
                    //autoWidth: true,
                    //autoHeight: true,
                    html: '<div class="ux-saved-graph-container"><img class="ux-ajax-loader" src="/images/Ajax-loader.gif" /></div>'
                  });
                  this.ownerCt.ownerCt.ownerCt.renderGraphs(cnt, record[i].data.img_urls.image_urls[cnt], result_obj, 'ux-saved-graph-container');
                }
              }

            }
            this.doLayout();
            this.setSize('auto','auto');
          }
        }
      })
    });

    Talho.Rollcall.SavedQueriesPanel.superclass.constructor.call(this, config);
  },
  updateSavedQueries: function(r_id){
    var options = {
      params: {
        r_id: r_id
      }
    }
    this.saved_store.load(options);
  },
  showEditSavedQueryConsole: function(query_title,query_params,severity_min,severity_max,deviation_threshold,
                                      deviation_min,deviation_max,r_id,query_id,south_panel)
  {
    var params       = [];
    var tea_id       = null;
    var storedParams = new Ext.data.ArrayStore({
        storeId: 'my-store',
        fields: ['field', 'value'],
        idIndex: 0
    });

    query_params = query_params.split("|");
    query_params.pop(query_params.length);
    for(var i=0; i<query_params.length;i++){
      var key_value = query_params[i].split("=");
      if(key_value[0].indexOf("undefined") == -1){
        if(key_value[0] == "tea_id") tea_id = key_value[0];
        params.push([key_value[0], key_value[1]]);  
      }
    }

    storedParams.loadData(params);
    param_string = '';

    for(key in params){
      param_string += params[key][0] + '=' + params[key][1] + "|"
    }

    var alarm_console = new Ext.Window({
      layout:'fit',
      width: 300,
      autoHeight:true,
      modal: true,
      constrain: true,
      renderTo: 'adst_container',
      closeAction:'close',
      title: query_title,
      plain: true,
      items: [{
        xtype: 'form',
        id: 'editSavedQueryForm',
        url: 'rollcall/save_query/'+query_id+'.json',
        border: false,
        method: 'PUT',
        baseParams:{
          query_params: param_string,
          r_id: r_id,
          tea_id: tea_id
        },
        items:[{
          xtype:'textfield',
          labelStyle: 'margin: 10px 0px 0px 5px',
          fieldLabel: 'Query Name',
          value: query_title,
          id: 'query_name',
          style:{
            marginTop: '10px',
            marginBottom: '5px'
          }
        },{
          xtype: 'fieldset',
          title: 'Deviation',
          style:{
            marginLeft: '5px',
            marginRight: '5px'
          },
          buttonAlign:'left',
          defaults: {
            xtype: 'container'
          },
          items: [{
            fieldLabel: 'Threshold',
            items:[{
              xtype: 'textfield',
              width: 32,
              cls: 'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              value: '50%'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                scope: this,
                change: function(obj, new_number, old_number){
                  obj.ownerCt.findByType('textfield')[0].setValue(new_number)
                }
              },
              tipText: function(thumb){
                return String(thumb.value) + '%';
              },
              id: 'deviation_threshold',
              cls: 'ux-layout-auto-float-item',
              value: deviation_threshold
            }]
          },{
            fieldLabel: 'Min',
            items:[{
              xtype: 'textfield',
              width: 32,
              cls: 'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              value: '50%'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                scope: this,
                change: function(obj, new_number, old_number){
                  obj.ownerCt.findByType('textfield')[0].setValue(new_number)
                }
              },
              tipText: function(thumb){
                return String(thumb.value) + '%';
              },
              id: 'deviation_min',
              cls: 'ux-layout-auto-float-item',
              value: deviation_min
            }]
          },{
            fieldLabel: 'Max',
            items:[{
              xtype: 'textfield',
              width: 32,
              cls: 'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              value: '50%'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                scope: this,
                change: function(obj, new_number, old_number){
                  obj.ownerCt.findByType('textfield')[0].setValue(new_number)
                }
              },
              tipText: function(thumb){
                return String(thumb.value) + '%';
              },
              id: 'deviation_max',
              cls: 'ux-layout-auto-float-item',
              value: deviation_max
            }]
          }],
          fbar: {
            xtype: 'toolbar',
            items: ['->', {
              text: 'Max All',
              handler: function(buttonEl, eventObj){
                sliders = buttonEl.ownerCt.ownerCt.findByType("sliderfield");
                for(key in sliders){
                  try{
                    sliders[key].setValue(100);
                  }catch(e){

                  }
                }
              }
            },{
              text: 'Reset',
              handler: function(buttonEl, eventObj){
                sliders = buttonEl.ownerCt.ownerCt.findByType("sliderfield");
                for(key in sliders){
                  try{
                    sliders[key].reset();
                  }catch(e){

                  }
                }
              }
            }]
          }
        },{
          xtype: 'fieldset',
          autoHeight: true,
          title: 'Severity',
          style:{
            marginLeft: '5px',
            marginRight: '5px'
          },
          buttonAlign: 'left',
          defaults: {
            xtype: 'container',
            layout: 'anchor'
          },
          items: [{
            fieldLabel: 'Min',
            items:[{
              xtype: 'textfield',
              width: 32,
              cls: 'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              value: '50%'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                scope: this,
                change: function(obj, new_number, old_number){
                  obj.ownerCt.findByType('textfield')[0].setValue(new_number)
                }
              },
              tipText: function(thumb){
                return String(thumb.value) + '%';
              },
              id: 'severity_min',
              value: severity_min,
              cls: 'ux-layout-auto-float-item'
            }]
          },{
            fieldLabel: 'Max',
            items:[{
              xtype: 'textfield',
              width: 32,
              cls: 'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              value: '50%'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                scope: this,
                change: function(obj, new_number, old_number){
                  obj.ownerCt.findByType('textfield')[0].setValue(new_number)
                }
              },
              tipText: function(thumb){
                return String(thumb.value) + '%';
              },
              id: 'severity_max',
              value: severity_max,
              cls: 'ux-layout-auto-float-item'
            }]
          }],
          fbar: {
            xtype: 'toolbar',
            items: ['->', {
              text: 'Max All',
              handler: function(buttonEl, eventObj){
                sliders = buttonEl.ownerCt.ownerCt.findByType("sliderfield");
                for(key in sliders){
                  try{
                    sliders[key].setValue(100);
                  }catch(e){

                  }
                }
              }
            },{
              text: 'Reset',
              handler: function(buttonEl, eventObj){
                sliders = buttonEl.ownerCt.ownerCt.findByType("sliderfield");
                for(key in sliders){
                  try{
                    sliders[key].reset();
                  }catch(e){

                  }
                }
              }
            }]
          }
        },{
          xtype: 'fieldset',
          autoWidth: true,
          autoHeight: true,
          title: 'Parameters',
          style:{
            marginLeft: '5px',
            marginRight: '5px'
          },
          collapsible: false,
          items: [{
            xtype: 'listview',
            store: storedParams,
            multiSelect: true,
            reserveScrollOffset: true,
            columns: [{
                header: 'Field Name',
                width: .65,
                dataIndex: 'field'
            },{
                header: 'Value Set',
                width: .35,
                dataIndex: 'value'
            }]
          }]
        }]
      }],
      buttonAlign: 'right',
      buttons: [{
        text:'Submit',
        handler: function(buttonEl, eventObj){
          alarm_console.getComponent('editSavedQueryForm').getForm().on('actioncomplete', function(){
            south_panel.removeAll();
            south_panel.saved_store.load();
            this.hide();
            this.destroy();
          }, alarm_console);
          alarm_console.getComponent('editSavedQueryForm').getForm().submit();
        }
      },{
        text: 'Close',
        handler: function(buttonEl, eventObj){
          alarm_console.close();
        }
      }]
    });
    alarm_console.doLayout();
    alarm_console.show();
  }
});