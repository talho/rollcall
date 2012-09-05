Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ADSTAlarmQueriesPanel = Ext.extend(Ext.Container, {
  constructor: function(config){

    Ext.applyIf(config, {
      layout:      'column',
      autoScroll:  true,
      cls:         'x-portal',
      defaultType: 'portalcolumn',
      itemId:      'portalId_south',
      border:      false,
      bodyStyle:   'padding:6px 10px 0px;',
      saved_store: new Ext.data.JsonStore({
        autoLoad: true,
        root:     'results',
        fields:   ['id', 'name'],
        proxy:    new Ext.data.HttpProxy({url: '/rollcall/alarm_query', method: 'get'}),
        listeners:{
          scope:      this,
          beforeload: function(this_store, options)
          {
            this_store.container_mask = new Ext.LoadMask(this.getEl(), {msg:"Please wait..."});
            this_store.container_mask.show();
          },
          load: this._loadAlarmQueries
        }
      })
    });
    Talho.Rollcall.ADSTAlarmQueriesPanel.superclass.constructor.call(this, config);
  },
  /*
  Method loads up alarm query panels into the ADSTAlarmQueriesPanel after creating an empty container, listener
  function for load attached to this saved_store
   @param this_store    the ext store requesting the alarm queries
   @param alarm_queries the alarm queries, Ext records
   */
  _loadAlarmQueries: function(this_store, alarm_queries)
  {
    var result_obj = null;
    var column_obj = null;
    var alarm_id   = '';
    var q_tip      = '';
    if(alarm_queries.length == 0){
      column_obj = this.add({itemId: 'empty_alarm_query_container'});
      result_obj = column_obj.add({
        cls:    'ux-alarm-thumbnails',
        html:   '<div class="ux-empty-alarm-query-container"><p>There are no alarm queries.</p></div>',
        height: 80,
        width:  300
      });
    }else{
      if(this.getComponent('empty_alarm_query_container')) this.getComponent('empty_alarm_query_container').destroy();
      for(var cnt=0;cnt<alarm_queries.length;cnt++){
        var param_config          = alarm_queries[cnt].json;
        var myData                = new Array();
        param_config.query_params = Ext.decode(alarm_queries[cnt].json.query_params);
        alarm_id                  = (param_config.alarm_set) ? 'alarm-on' : 'alarm-off';
        column_obj                = this.add({});
        myData.push(['severity_min', param_config.severity_min]);
        myData.push(['severity_max', param_config.severity_max]);
        myData.push(['deviation_min', param_config.deviation_min]);
        myData.push(['deviation_max', param_config.deviation_max]);
        for(param in param_config.query_params){myData.push([param, param_config.query_params[param]]);}
        var store = new Ext.data.ArrayStore({
          fields: [
            {name: 'settings'},
            {name: 'values'}
          ]
        });
        store.loadData(myData);
        var grid_obj = {
          xtype:       'grid',
          store:       store,
          hideHeaders: true,
          columns: [
            {id:'settings', header: 'Settings', sortable: true, dataIndex: 'settings'},
            {id:'values', header: 'values', sortable: true, dataIndex: 'values'}
          ],
          stripeRows:       true,
          autoExpandColumn: 'settings',
          autoHeight:       true,
          autoWidth:        true,
          stateful:         true
        };

        result_obj = column_obj.add({
          title:        param_config.name,
          param_config: param_config,
          collapsible:  false,
          draggable:    false,
          width:        250,
          height:       80,
          autoScroll:   true,
          tools:        [{
            id:      'run-query',
            qtip:    "Run This Query",
            scope:   this,
            handler: this._runSavedQuery
          },{
            id:      alarm_id,
            qtip:    "Toggle Alarm",
            scope:   this,
            handler: this._toggleAlarm
          },{
            id:      'save',
            qtip:    'Edit Alarm Query',
            scope:   this,
            handler: function(e, targetEl, panel, tc)
            {
              this._showEditAlarmQueryConsole(panel,this);
            }
          },{
            id:      'close',
            qtip:    'Delete Alarm Query',
            scope:   this,
            handler: this._deleteAlarmQuery
          }],
          cls:        'ux-alarm-thumbnails',
          adst_panel: this.adst_panel,
          items:      [grid_obj],
          style:      {marginTop: '5px', marginLeft: '5px'}
        });
      }
    }
    this_store.container_mask.hide();
    this.doLayout();
    this.setSize('auto','auto');
  },
  /*
  Method runs a search query off a saved query, sets and configures form for submission, handler function for "Run This Query"
  button tool item
  @param e        the click event
  @param targetEl the ext tool element pressed
  @param panel    the panel the tool button is attached to
  @param tc       the tool configuration object
   */
  _runSavedQuery: function(e, targetEl, panel, tc)
  {
    var form      = panel.adst_panel.find('id', 'ADSTFormPanel')[0].getForm();
    var qtype     = panel.param_config.query_params["type"];
    var vals      = new Object;
    this.adst_panel._resetForm();
    if (qtype == "adv") {
      Ext.getCmp('simple_query_select').hide();
      Ext.getCmp('advanced_query_select').show().doLayout();
    } else {
      Ext.getCmp('advanced_query_select').hide();
      form_view = Ext.getCmp('simple_query_select').show().doLayout();
    }  
    for (prop in panel.param_config.query_params){
      var temp_array = new Array();
      var new_key    = prop.replace(/\[]/g, "")+"_"+qtype;
      vals[new_key]  = panel.param_config.query_params[prop];
      if(vals[new_key].constructor == Array){
        var list_store = Ext.getCmp(new_key).getStore();
        for(var cnt=0; cnt < vals[new_key].length; cnt++){
          var index = list_store.findExact('value', vals[new_key][cnt]);
          if(index != -1) temp_array.push(index)
        }
        Ext.getCmp(new_key).select(temp_array);
      }
    }
    form.setValues(vals);
    panel.adst_panel._submitQuery();
  },
   /*
   Method makes a call to the back-end to destroy selected alarm query
   @param e        the click event
   @param targetEl the ext tool element pressed
   @param panel    the panel the tool button is attached to
   @param tc       the tool configuration object
    */
  _deleteAlarmQuery: function(e, targetEl, panel, tc)
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
              panel.ownerCt.ownerCt._destroyQueryAlarms(panel);
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
  /*
  Method is called after the deleteAlarmQuery function finishes making an AJAX request, method makes a call to the backend
  to destroy alarms attached to alarm query
  @param panel the original query alarm panel
   */
  _destroyQueryAlarms: function(panel)
  {
    Ext.Ajax.request({
      url: '/rollcall/alarms/'+panel.param_config.id+'.json',
      method: 'DELETE',
      params: {
        alarm_query_id: panel.param_config.id
      },
      callback: function(options, success, response){
        Ext.getCmp('alarm_panel').getComponent(0).getStore().load();
      }
    });
  },

  /*
  Method is called from alarm query panel tool icon, makes back end call to generate alarms, if any, for selected
  alarm query
  @param e        the click event
  @param targetEl the ext tool element pressed
  @param panel    the panel the tool button is attached to
  @param tc       the tool configuration object
   */
  _toggleAlarm: function(e, targetEl, panel, tc)
  {
    var panel_mask = new Ext.LoadMask(Ext.getCmp('adst_container').getEl(),{msg:"Please wait..."});
    var alarm_set  = false;
    panel_mask.show();
    if(targetEl.hasClass('x-tool-alarm-off')) alarm_set = true;
    if(alarm_set == false) Ext.getCmp('alarm_panel').alarms_store.container_mask.show();
    Ext.Ajax.request({
      url:      '/rollcall/alarm_query/'+panel.param_config.id+'.json',
      params:   {alarm_set: alarm_set},
      method:   'PUT',
      callback: function(options, success, response)
      {
        panel_mask.hide();
        if(alarm_set == false){
          Ext.getCmp('alarm_panel').getComponent(0).getStore().load();
        }else{
          Ext.MessageBox.show({
            title:   'Creating Alarms',
            msg:     'Your alarms have been activated and the system will alert you via email when any alarms are generated.',
            buttons: Ext.MessageBox.OK,
            icon:    Ext.MessageBox.INFO
          });
          Ext.Ajax.request({
            url:      '/rollcall/alarms/',
            method:   'POST',
            params:   {alarm_query_id: panel.param_config.id}
          });
        }
        targetEl.toggleClass('x-tool-alarm-off');
        targetEl.toggleClass('x-tool-alarm-on');
      },
      failure: function(){}
    });
  },
  /*
  Method reloads store data from URL with given options
  @param options object container parameters with which to reload data from URL
   */
  _updateAlarmQueries: function(options)
  {
    this.saved_store.load(options);
  },
  /*
  Method builds and shows an AlarmQueryWindow
  @param panel       the query alarm panel
  @param south_panel this panel (ADSTAlarmQueriesPanel)
   */
  _showEditAlarmQueryConsole: function(panel,south_panel)
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
    o_i = {
      render_to:         'adst_container',
      alarm_query_title: alarm_query_title,
      form_id:           'editAlarmQueryForm',
      form_url:          '/rollcall/alarm_query/'+alarm_query_id+'.json',
      query_params:      alarm_query_params,
      deviation_min:     deviation_min,
      deviation_max:     deviation_max,
      severity_min:      severity_min,
      severity_max:      severity_max,
      stored_params:     storedParams,
      buttons:           [{
        text:    'Save As New',
        handler: function(buttonEl, eventObj){
          alarm_console.getComponent('editAlarmQueryForm').getForm().on('actioncomplete', function(){
            south_panel._updateAlarmQueries({params: {alarm_query_id: alarm_query_id,clone: true}});
            this.hide();
            this.destroy();
          }, alarm_console);
          alarm_console.getComponent('editAlarmQueryForm').getForm().doAction('submit',{
            url: '/rollcall/alarm_query',
            method: 'post'
          });
        }
      },{
        text:    'Submit',
        handler: function(buttonEl, eventObj){
          alarm_console.getComponent('editAlarmQueryForm').getForm().on('actioncomplete', function(){
            south_panel._updateAlarmQueries({params: {alarm_query_id: alarm_query_id}});
            panel.hide();
            panel.destroy();
            this.hide();
            this.destroy();
          }, alarm_console);
          alarm_console.getComponent('editAlarmQueryForm').getForm().doAction('submit',{
            method: 'put'
          });
        }
      },{
        text:    'Close',
        handler: function(buttonEl, eventObj){
          alarm_console.close();
        }
      }]
    }
    var alarm_console = new Talho.Rollcall.ux.AlarmQueryWindow(o_i);
    alarm_console.doLayout();
    alarm_console.show();
  }
});
