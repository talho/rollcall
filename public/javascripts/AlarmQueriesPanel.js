Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.AlarmQueriesPanel = Ext.extend(Ext.Panel, {
  constructor: function(config){

    Ext.applyIf(config, {
      layout:      'column',
      autoScroll:  true,
      cls:         'x-portal',
      defaultType: 'portalcolumn',
      itemId:      'portalId_south',
      border:      false,
      bodyStyle:   'padding:10 10 0 10;',
      saved_store: new Ext.data.JsonStore({
        autoLoad: true,
        root:     'results',
        fields:   ['id', 'alarm_queries', 'img_urls'],
        proxy: new Ext.data.HttpProxy({
          url:    '/rollcall/alarm_query',
          method: 'get'
        }),
        listeners:{
          scope: this,
          beforeload: function(this_store, options)
          {
            this_store.container_mask = new Ext.LoadMask(this.getEl(), {msg:"Please wait..."});
            this_store.container_mask.show();
          },
          load:  this.loadAlarmQueries
        }
      })
    });

    Talho.Rollcall.AlarmQueriesPanel.superclass.constructor.call(this, config);
  },

  loadAlarmQueries: function(this_store, record)
  {
    var result_obj          = null;
    var column_obj          = null;
    var alarm_id            = '';
    var q_tip               = '';
    for(var i=0;i<record.length;i++){
      if(record[i].data.alarm_queries.length == 0){
        column_obj = this.add({
          columnWidth: .25,
          itemId:      'empty_alarm_query_container',
          listeners:{
            scope: this
          }
        });
        result_obj = column_obj.add({
          cls:  'ux-alarm-thumbnails',
          html: '<div class="ux-empty-alarm-query-container"><p>There are no alarm queries.</p></div>'
        });
      }else{
        if(this.getComponent('empty_alarm_query_container')){
          this.getComponent('empty_alarm_query_container').destroy();
        }
        for(var cnt=0;cnt<record[i].data.alarm_queries.length;cnt++){
          var param_config          = record[i].data.alarm_queries[cnt];
          param_config.query_params = Ext.decode(record[i].data.alarm_queries[cnt].query_params);
          if(param_config.alarm_set){
            alarm_id = 'alarm-on';
          }else{
            alarm_id = 'alarm-off';
          }
          column_obj = this.add({
            listeners:{
              scope: this
            }
          });
          alarm_html_desc = '<div class="ux-alarm-tn-container">' +
            '<b>Severity:</b> '  + param_config.severity_min  + ' - ' + param_config.severity_max  + '<br>' +
            '<b>Deviation:</b> ' + param_config.deviation_min + ' - ' + param_config.deviation_max + '<br>';
          for (param in param_config.query_params){
            alarm_html_desc += '<b>'+param+':</b> ' + param_config.query_params[param] + '<br>';
          }
          alarm_html_desc += '</div>';
          result_obj       = column_obj.add({
            title:        param_config.name,
            param_config: param_config,
            scope:        this,
            width:        250,
            height:       90,
            collapsible:  false,
            draggable:    false,
            tools: [{
              id:      alarm_id,
              qtip:    "Toggle Alarm",
              scope:   this,
              handler: this.toggleAlarm
            },{
              id:      'save',
              qtip:    'Edit Alarm Query',
              scope:   this,
              handler: function(e, targetEl, panel, tc){
                this.showEditAlarmQueryConsole(panel,this);
              }
            },{
              id:      'close',
              qtip:    'Delete Alarm Query',
              scope:   this,
              handler: this.deleteAlarmQuery
            }],
            cls: 'ux-alarm-thumbnails',
            html: alarm_html_desc
          });
        }
      }

    }
    this_store.container_mask.hide();
    this.doLayout();
    this.setSize('auto','auto');
  },

  deleteAlarmQuery: function(e, targetEl, panel, tc)
  {
    Ext.MessageBox.show({
      title: 'Delete '+panel.title,
      msg:   'Are you sure you want to delete this alarm query?',
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
            url:    '/rollcall/alarm_query/'+this.param_config.id+'.json',
            method: 'DELETE',
            scope:  this,
            callback: function(options, success, response){
              panel.ownerCt.ownerCt.destroyQueryAlarms(panel);
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

  destroyQueryAlarms: function(panel)
  {
    Ext.Ajax.request({
      url: '/rollcall/alarms',
      method: 'DELETE',
      params: {
        alarm_query_id: panel.param_config.id
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
      url:    '/rollcall/alarm_query/'+panel.param_config.id+'.json',
      params: {
        alarm_set: alarm_set
      },
      method:  'PUT',
      callback: function(options, success, response)
      {
        Ext.Ajax.request({
          url:      '/rollcall/alarm/'+panel.param_config.id,
          callback: function(options, success, response){
            if(alarm_set) Ext.getCmp('alarm_panel').getComponent(0).getStore().load({
              add: true,
              params:{
                alarm_query_id: panel.param_config.id
              }
            });
            else Ext.getCmp('alarm_panel').getComponent(0).getStore().load();
            targetEl.toggleClass('x-tool-alarm-off');
            targetEl.toggleClass('x-tool-alarm-on');
          },
          failure: function(){

          }
        });
      },
      failure: function(){

      }
    });
  },

  updateAlarmQueries: function(options)
  {
    this.saved_store.load(options);
  },

  showEditAlarmQueryConsole: function(panel,south_panel)
  {
    var params              = new Array();
    var param_string        = '';
    var alarm_query_title   = panel.param_config.name;
    var school_name         = panel.param_config.school_name;
    var alarm_query_params  = panel.param_config.query_params;
    var severity_min        = panel.param_config.severity_min;
    var severity_max        = panel.param_config.severity_max;
    var deviation_min       = panel.param_config.deviation_min;
    var deviation_max       = panel.param_config.deviation_max;
    var school_id           = panel.param_config.school_id;
    var alarm_query_id      = panel.param_config.id;
    var storedParams        = new Ext.data.ArrayStore({
        storeId: 'edit-store',
        fields: ['field', 'value'],
        idIndex: 0
    });

    for(key in alarm_query_params){ params.push([key, alarm_query_params[key]]); }
    storedParams.loadData(params);

    var alarm_console = new Ext.Window({
      layout:'fit',
      width: 300,
      autoHeight:true,
      modal: true,
      constrain: true,
      renderTo: 'adst_container',
      closeAction:'close',
      title: alarm_query_title,
      plain: true,
      items: [{
        xtype: 'form',
        id: 'editAlarmQueryForm',
        url: '/rollcall/alarm_query/'+alarm_query_id+'.json',
        border: false,
        method: 'PUT',
        baseParams: {authenticity_token: FORM_AUTH_TOKEN, alarm_query_params: Ext.encode(alarm_query_params)},
        items:[{
          xtype:'textfield',
          labelStyle: 'margin: 10px 0px 0px 5px',
          fieldLabel: 'Name',
          value: alarm_query_title,
          id: 'alarm_query_name',
          allowBlank: false,
          blankText: "This field is required.",
          minLength: 3,
          minLengthText: 'The minimum length for this field is 3.',
          style:{
            marginTop: '10px',
            marginBottom: '5px'
          }
        },((alarm_query_params.school == null) ? {xtype: 'spacer'} : new Talho.Rollcall.ux.ComboBox({
          labelStyle: 'margin: 10px 0px 0px 5px',
          fieldLabel: 'School Name',
          emptyText:'Select School...',
          allowBlank: true,
          width: 150,
          value: alarm_query_params.school,
          mode: 'local',
          name: 'school',
          //hiddenName: 'school_id', valueField: 'id', hiddenValue: school_id,
          displayField: 'display_name',
          store: new Ext.data.JsonStore({fields: ['id', 'display_name'], data: Ext.getCmp('rollcall_adst').init_store.getAt(0).get('schools')})
        })),{
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
          alarm_console.getComponent('editAlarmQueryForm').getForm().on('actioncomplete', function(){
            south_panel.updateAlarmQueries({params: {alarm_query_id: alarm_query_id,clone: true}});
            this.hide();
            this.destroy();
          }, alarm_console);
          alarm_console.getComponent('editAlarmQueryForm').getForm().doAction('submit',{
            url: '/rollcall/alarm_query',
            method: 'post'
          });
        }
      },{
        text:'Submit',
        handler: function(buttonEl, eventObj){
          alarm_console.getComponent('editAlarmQueryForm').getForm().on('actioncomplete', function(){
            south_panel.updateAlarmQueries({params: {alarm_query_id: alarm_query_id}});
            panel.hide();
            panel.destroy();
            this.hide();
            this.destroy();
          }, alarm_console);
          alarm_console.getComponent('editAlarmQueryForm').getForm().submit();
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
