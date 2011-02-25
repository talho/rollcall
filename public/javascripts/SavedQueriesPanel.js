Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.SavedQueriesPanel = Ext.extend(Ext.Panel, {
  constructor: function(config){

    Ext.applyIf(config, {
      layout:      'column',
      autoScroll:  true,
      cls:         'x-portal',
      defaultType: 'portalcolumn',
      itemId:      'portalId_south',
      border:      false,
      bodyStyle:   'padding:10px;',
      saved_store: new Ext.data.JsonStore({
        autoLoad: true,
        root:     'results',
        fields:   ['id', 'saved_queries', 'img_urls'],
        proxy: new Ext.data.HttpProxy({
          url:    '/rollcall/save_query',
          method: 'get'
        }),
        listeners:{
          scope: this,
          beforeload: function(this_store, options)
          {
            this_store.container_mask = new Ext.LoadMask(this.getEl(), {msg:"Please wait..."});
            this_store.container_mask.show();
          },
          load:  this.loadSavedQueries
        }
      })
    });

    Talho.Rollcall.SavedQueriesPanel.superclass.constructor.call(this, config);
  },

  loadSavedQueries: function(this_store, record)
  {
    var result_obj          = null;
    var column_obj          = null;
    var param_config        = {};
    var alarm_id            = '';
    var q_tip               = '';
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
          param_config = {
            query_id:            record[i].data.saved_queries[cnt].id,
            query_title:         record[i].data.saved_queries[cnt].name,
            query_params:        record[i].data.saved_queries[cnt].query_params,
            severity_min:        record[i].data.saved_queries[cnt].severity_min,
            severity_max:        record[i].data.saved_queries[cnt].severity_max,
            deviation_min:       record[i].data.saved_queries[cnt].deviation_min,
            deviation_max:       record[i].data.saved_queries[cnt].deviation_max,
            r_id:                record[i].data.saved_queries[cnt].rrd_id,
            alarm_set:           record[i].data.saved_queries[cnt].alarm_set
          };
          if(param_config.alarm_set){
            alarm_id = 'alarm-on';
          }else{
            alarm_id = 'alarm-off';
          }
          column_obj = this.add({
            columnWidth: .25,
            listeners:{
              scope: this
            }
          });
          result_obj = column_obj.add({
            title: param_config.query_title,
            param_config: param_config,
            scope: this,
            img_url: record[i].data.img_urls.image_urls[cnt],
            polling_id: cnt,
            collapsible: false,
            draggable: false,
            tools: [{
              id:alarm_id,
              qtip: "Toggle Alarm",
              scope: this,
              handler: this.toggleAlarm
            },{
              id:'save',
              qtip: 'Edit Query',
              scope: this,
              handler: function(e, targetEl, panel, tc){
                this.showEditSavedQueryConsole(panel,this);
              }
            },{
              id:'close',
              qtip: 'Delete Query',
              scope: this,
              handler: this.deleteSavedQuery
            }],
            cls: 'ux-saved-graphs',
            html: '<div class="ux-saved-graph-container"><img class="ux-ajax-loader" src="/images/Ajax-loader.gif" /></div>'
          });
          this.ownerCt.ownerCt.ownerCt.renderGraphs(cnt, record[i].data.img_urls.image_urls[cnt], result_obj, 'ux-saved-graph-container');
        }
      }

    }
    this_store.container_mask.hide();
    this.doLayout();
    this.setSize('auto','auto');
  },

  deleteSavedQuery: function(e, targetEl, panel, tc)
  {
    Ext.MessageBox.show({
      title: 'Delete '+panel.title,
      msg:   'Are you sure you want to delete this query?',
      buttons: {
        ok:     'Yes',
        cancel: 'No'
      },
      scope: panel,
      icon:  Ext.MessageBox.QUESTION,
      fn: function(btn,txt,cfg_obj)
      {
        if(btn == 'ok'){
          Ext.Ajax.request({
            url:    'rollcall/save_query/'+this.param_config.query_id+'.json',
            method: 'DELETE',
            scope:  this,
            callback: function(options, success, response){
              panel.ownerCt.ownerCt.destroySavedQueryAlarms(panel);
              this.hide();
              this.destroy();
            },
            failure: function(){

            }
          });
        }
      }
    });
  },

  destroySavedQueryAlarms: function(panel)
  {
    Ext.Ajax.request({
      url: 'rollcall/alarms',
      method: 'DELETE',
      params: {
        saved_query_id: panel.param_config.query_id
      },
      callback: function(options, success, response){
        Ext.getCmp('alarm_panel').getComponent(0).getStore().load();
      }
    });
  },

  toggleAlarm: function(e, targetEl, panel, tc)
  {
    var alarm_set = false;
    if(targetEl.hasClass('x-tool-alarm-off')) alarm_set = true;
    Ext.getCmp('alarm_panel').alarms_store.container_mask.show();
    Ext.Ajax.request({
      url:    'rollcall/save_query/'+panel.param_config.query_id+'.json',
      params: {
        alarm_set: alarm_set
      },
      method:  'PUT',
      callback: function(options, success, response)
      {
        Ext.Ajax.request({
          url:      'rollcall/alarm/'+panel.param_config.query_id,
          callback: function(options, success, response){
            Ext.getCmp('alarm_panel').getComponent(0).getStore().alarm_icon_el = targetEl;
            if(alarm_set) Ext.getCmp('alarm_panel').getComponent(0).getStore().load({
              add: true,
              params:{
                query_id: panel.param_config.query_id
              }
            });
            else Ext.getCmp('alarm_panel').getComponent(0).getStore().load();
          },
          failure: function(){

          }
        });
      },
      failure: function(){

      }
    });
  },

  updateSavedQueries: function(options)
  {
    this.saved_store.load(options);
  },

  showEditSavedQueryConsole: function(panel,south_panel)
  {
    var params              = new Array();
    var param_string        = '';
    var tea_id              = null;
    var query_title         = panel.param_config.query_title;
    var query_params        = panel.param_config.query_params;
    var severity_min        = panel.param_config.severity_min;
    var severity_max        = panel.param_config.severity_max;
    var deviation_min       = panel.param_config.deviation_min;
    var deviation_max       = panel.param_config.deviation_max;
    var r_id                = panel.param_config.r_id;
    var query_id            = panel.param_config.query_id;
    var storedParams        = new Ext.data.ArrayStore({
        storeId: 'edit-store',
        fields: ['field', 'value'],
        idIndex: 0
    });

    query_params = query_params.split("|");

    for(var i=0; i<query_params.length;i++){
      var key_value = query_params[i].split("=");
      if(key_value[0] == "tea_id") tea_id = key_value[1];
      params.push([key_value[0], key_value[1]]);
    }

    storedParams.loadData(params);

    for(key in params){
      if(key != "remove" && params[key][0] != '') param_string += params[key][0] + '=' + params[key][1] + "|"
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
          authenticity_token: FORM_AUTH_TOKEN,
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
          allowBlank: false,
          blankText: "This field is required.",
          minLength: 3,
          minLengthText: 'The minimum length for this field is 3.',
          style:{
            marginTop: '10px',
            marginBottom: '5px'
          }
        },{
          xtype: 'fieldset',
          title: 'Absentee Rate Deviation',
          style:{
            marginLeft: '5px',
            marginRight: '5px'
          },
          buttonAlign:'left',
          defaults: {
            xtype: 'container'
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
              value: '0%'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                scope: this,
                change: this.changeSlider
              },
              tipText: this.showTipText,
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
                change: this.changeSlider
              },
              tipText: this.showTipText,
              id: 'deviation_max',
              cls: 'ux-layout-auto-float-item',
              value: deviation_max
            }]
          }],
          fbar: {
            xtype: 'toolbar',
            items: ['->', {
              text: 'Max All',
              handler: this.maxAllSliders
            },{
              text: 'Reset',
              handler: this.resetSliders
            }]
          }
        },{
          xtype: 'fieldset',
          autoHeight: true,
          title: 'Absentee Rate Severity',
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
              value: '0%'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                scope: this,
                change: this.changeSlider
              },
              tipText: this.showTipText,
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
                change: this.changeSlider
              },
              tipText: this.showTipText,
              id: 'severity_max',
              value: severity_max,
              cls: 'ux-layout-auto-float-item'
            }]
          }],
          fbar: {
            xtype: 'toolbar',
            items: ['->', {
              text: 'Max All',
              handler: this.maxAllSliders
            },{
              text: 'Reset',
              handler: this.resetSliders
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
        text:'Save As New',
        handler: function(buttonEl, eventObj){
          alarm_console.getComponent('editSavedQueryForm').getForm().on('actioncomplete', function(){
            south_panel.updateSavedQueries({params: {query_id: query_id,clone: true}});
            this.hide();
            this.destroy();
          }, alarm_console);
          alarm_console.getComponent('editSavedQueryForm').getForm().doAction('submit',{
            url: 'rollcall/save_query',
            method: 'post'
          });
        }
      },{
        text:'Submit',
        handler: function(buttonEl, eventObj){
          alarm_console.getComponent('editSavedQueryForm').getForm().on('actioncomplete', function(){
            south_panel.updateSavedQueries({params: {query_id: query_id}});
            south_panel.ownerCt.ownerCt.ownerCt.renderGraphs(panel.polling_id, panel.img_url, panel, 'ux-saved-graph-container');
            panel.hide();
            panel.destroy();
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
  },

  changeSlider: function(obj, new_number, old_number)
  {
    obj.ownerCt.findByType('textfield')[0].setValue(new_number)
  },

  resetSliders: function(buttonEl, eventObj)
  {
    sliders = buttonEl.ownerCt.ownerCt.findByType("sliderfield");
    for(key in sliders){
      try{
        sliders[key].reset();
      }catch(e){

      }
    }
  },

  maxAllSliders: function(buttonEl, eventObj)
  {
    sliders = buttonEl.ownerCt.ownerCt.findByType("sliderfield");
    for(key in sliders){
      try{
        sliders[key].setValue(100);
      }catch(e){

      }
    }
  },

  showTipText: function(thumb)
  {
    return String(thumb.value) + '%';
  }
});
