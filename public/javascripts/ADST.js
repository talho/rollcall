Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ADST = Ext.extend(Ext.Panel, {
  constructor: function(config)
  {
    this.providers      = new Array();
    var resultPanel     = new Talho.Rollcall.ADSTResultPanel({});
    this.getResultPanel = function()
    {
      return resultPanel;
    };

    Ext.apply(this, config);
    Ext.apply(this,
    {
      layout:   'fit',
      border:   false,
      closable: true,
      scope:    this,
      items:[{
        id:         'adst_container',
        itemId:     'adst_container',
        layout:     'border',
        autoScroll: true,
        scope:      this,
        defaults: {
          collapsible: false,
          split:       true
        },
        items: [{
          title:      'Alarm Queries',
          itemId:     'alarm_queries',
          id:         'alarm_queries',
          region:     'south',
          height:     120,
          minSize:    120,
          maxSize:    120,
          autoScroll: true,
          layout:     'fit',
          items:      new Talho.Rollcall.ADSTAlarmQueriesPanel({adst_panel: this})
        },{
          title:     'Alarms',
          itemId:    'alarms_c',
          id:        'alarms_c',
          region:    'west',
          layout:    'fit',
          bodyStyle: 'padding:0px',
          width:     140,
          minSize:   140,
          maxSize:   140,
          hideBorders: true,
          items:     new Talho.Rollcall.ADSTAlarmsPanel({}),
          bbar:[{
            text:    'Refresh',
            iconCls: 'x-tbar-loading',
            handler: function(btn,event)
            {
              this.ownerCt.ownerCt.getComponent('alarm_panel').alarms_store.load();
            }
          },'->',{
            text:     'GIS',
            id:       'gis_button',
            itemId:   'gis_button',
            iconCls:  'x-tbar-gis',
            disabled: true,
            handler:  function()
            {
              this.ownerCt.ownerCt.getComponent('alarm_panel').load_alarm_gmap_window();
            }
          }]
        },{
          title:       'ADST',
          itemId:      'ADST_panel',
          id:          'ADST_panel',
          border:      false,
          collapsible: false,
          region:      'center',
          autoScroll:  true,
          scope:       this,
          items:[{
            xtype:  'container',
            itemId: 'query_container',
            layout: 'column',
            scope:  this,
            hideBorders: true,
            items:[{
              xtype:       'form',
              itemId:      'ADSTFormPanel',
              labelAlign:  'top',
              id:          "ADSTFormPanel",
              url:         '/rollcall/adst',
              buttonAlign: 'left',
              columnWidth: 1,
              scope:       this,
              buttons: [{
                text:     "Submit",
                scope:    this,
                hidden:   true,
                handler:  this.submitQuery,
                formBind: true
              },{
                text:    "Reset Form",
                scope:   this,
                hidden:  true,
                handler: this.resetForm
              },{
                text:    "Export Result Set",
                hidden:  true,
                scope:   this,
                handler: this.exportResultSet
              },{
                text:    "Map Result Set",
                hidden:  true,
                scope:   this,
                handler: this.mapResultSet
              },{
                text:    "Create Alarm from Result Set",
                hidden:  true,
                scope:   this,
                handler: this.saveResultSet
              },{
                text:    "Generate Report from Result Set",
                hidden:  true,
                scope:   this,
                handler: function(buttonObj, eventObj){
                  this.showReportMenu(buttonObj.getEl(), null);
                }
              }],
              listeners:{
                scope:        this,
                beforerender: this.initFormComponent
              }
            }]
          }, resultPanel ],
          bbar: new Ext.PagingToolbar({
            scope:          this,
            displayInfo:    true,
            prependButtons: true,
            pageSize:       6,
            listeners:{
              'beforechange': this.setNextPage
            }
          })
        }]
      }]
    });
    Talho.Rollcall.ADST.superclass.constructor.call(this, config);
    this.addListener("deactivate", function(w){
      if(Ext.getCmp('gmap_alarm_window')) Ext.getCmp('gmap_alarm_window').close();
      this.get(0).get(1).getComponent('alarm_panel').close_alarm_tip();
    });
    this.addListener("close", function(w){
      if(Ext.getCmp('gmap_alarm_window')) Ext.getCmp('gmap_alarm_window').close();
      this.get(0).get(1).getComponent('alarm_panel').close_alarm_tip();
    });
  },/*
  renderGraphs: function(id, image, obj, class_name, total)
  {
    provider = new Ext.direct.PollingProvider({
      id:         'image' + id + '-provider',
      type:       'polling',
      url:        image,
      form_panel: this.find('id', 'ADSTFormPanel')[0],
      index:      id,
      total:      total - 1,
      interval:   5000,
      listeners: {
        scope: obj,
        data: function(provider, e)
        {
          if(e.xhr.status == 200) {
            var element_id = Ext.id();
            this.update('<div id="'+element_id+'" class="'+class_name+'"><img src="'+provider.url+'"/></div>');
            this.doLayout();
            provider.purgeListeners();
            provider.disconnect();
            if(provider.index == provider.total) provider.form_panel.buttons[0].enable();
            return true;
          } else {
            return false;
          }
        }
      }
    });
    this.providers.push(provider);
    Ext.Direct.addProvider(provider); 
  },*/
  buildParams: function(form_values)
  {
    var params = new Object;
    params['authenticity_token'] = FORM_AUTH_TOKEN;
    for (key in form_values){
      if (Ext.getCmp('advanced_query_select').isVisible()){
        if(key.indexOf('_adv') != -1 && form_values[key].indexOf('...') == -1)
          params[key.replace(/_adv/,'')] = form_values[key].replace(/\+/g, " ");
      }else{
        if(key.indexOf('_simple') != -1 && form_values[key].indexOf('...') == -1)
          params[key.replace(/_simple/,'')] = form_values[key].replace(/\+/g, " ");
      }
    }
    if (Ext.getCmp('advanced_query_select').isVisible()) params['type'] = 'adv'
    else params['type'] = 'simple'
    return params;
  },
  saveResultSet: function(buttonEl, eventObj)
  {
    this.getResultPanel().showAlarmQueryConsole(null);
    return true;
  },
  mapResultSet: function(buttonEl, eventObj)
  {
    var form_panel  = this.find('id', 'ADSTFormPanel')[0];
    var form_values = form_panel.getForm().getValues();
    var params      = this.buildParams(form_values);
    params["limit"] = this.getResultPanel().getResultStore().getTotalCount();
    this._grabListViewFormValues(params, this);
    Ext.Ajax.request({
      url:      '/rollcall/schools',
      method:   'GET',
      params:   params,
      scope:    this,
      callback: function(options, success, response){
        var gmapPanel = new Ext.ux.GMapPanel({zoomLevel: 9});
        var win       = new Ext.Window({
          title:      "Google Map of Schools",
          id:         'gmap_result_window',
          itemId:     'gmap_result_window',
          layout:     'fit',
          labelAlign: 'top',
          padding:    '5',
          width:      510,
          height:     450,
          items:      [gmapPanel]
        });
        win.schools = Ext.decode(response.responseText).results;
        win.addButton({xtype: 'button', text: 'Dismiss', handler: function(){ win.close(); }, scope: this, width:'auto'});
        gmapPanel.addListener("mapready", function(obj){
          min_lat = Ext.min(win.schools, function(a,b){ return (a.gmap_lat<b.gmap_lat) ? -1 : (a.gmap_lat>b.gmap_lat) ? 1 : 0; });
          max_lat = Ext.max(win.schools, function(a,b){ return (a.gmap_lat<b.gmap_lat) ? -1 : (a.gmap_lat>b.gmap_lat) ? 1 : 0; });
          min_lng = Ext.min(win.schools, function(a,b){ return (a.gmap_lng<b.gmap_lng) ? -1 : (a.gmap_lng>b.gmap_lng) ? 1 : 0; });
          max_lng = Ext.max(win.schools, function(a,b){ return (a.gmap_lng<b.gmap_lng) ? -1 : (a.gmap_lng>b.gmap_lng) ? 1 : 0; });
          var center = new google.maps.LatLng((max_lat.gmap_lat+min_lat.gmap_lat)/2, (max_lng.gmap_lng+min_lng.gmap_lng)/2);
          gmapPanel.gmap.setCenter(center);
          for(var i = 0; i < win.schools.length; i++) {
            var loc           = new google.maps.LatLng(win.schools[i].gmap_lat, win.schools[i].gmap_lng);
            var marker        = gmapPanel.addMarker(loc, win.schools[i].display_name, {});
            var addr_elems    = win.schools[i].gmap_addr.split(",");
            marker.info       = "<b>" + win.schools[i].display_name + "</b><br>";
            marker.info      += addr_elems[0] + "<br>" + addr_elems[1] + "<br>" + addr_elems.slice(2).join(",");
            marker.info_popup = null;
            google.maps.event.addListener(marker, 'click', function(){
              if (this.info_popup) {
                this.info_popup.close(gmapPanel.gmap, this);
                this.info_popup = null;
              } else {
                this.info_popup = new google.maps.InfoWindow({content: this.info});
                this.info_popup.open(gmapPanel.gmap, this);
              }
            });
          }
        });
        win.show();
      },
      failure: function(){}
    });
  },
  exportResultSet: function(buttonEl, eventObj)
  {
    var params = this.buildParams(buttonEl.findParentByType("form").getForm().getValues());
    this._grabListViewFormValues(params, this);
    Ext.Ajax.request({
      url:    '/rollcall/export',
      method: 'GET',
      params: params,
      scope:  this,
      callback: function(options, success, response){
        Ext.MessageBox.show({
          title: 'Creating CSV Export File',
          msg: 'Your CSV file will be placed in your documents folders when the system '+
          'is done generating it. Please check your documents folder in a few minutes.',
          buttons: Ext.MessageBox.OK,
          icon: Ext.MessageBox.INFO
        });
      },
      failure: function(){}
    });  
  },
  resetForm: function()
  {
    this.find('id', 'ADSTFormPanel')[0].getForm().reset();
    //buttonEl.findParentByType("form").getForm().reset();
    this.find('id', 'school_adv')[0].clearSelections();
    this.find('id', 'school_type_adv')[0].clearSelections();
    this.find('id', 'zip_adv')[0].clearSelections();
    this.find('id', 'age_adv')[0].clearSelections();
    this.find('id', 'grade_adv')[0].clearSelections();
    this.find('id', 'symptoms_adv')[0].clearSelections();
    this.find('id', 'school_district_adv')[0].clearSelections();
  },
  _grabListViewFormValues: function(params, topEl)
  {
    var list_fields  = ["school", "school_district", "school_type", "zip", "age", "grade", "symptoms"];
    for (var i=0; i < list_fields.length; i++) {
      var selected_records = topEl.find('id', list_fields[i]+'_adv')[0].getSelectedRecords();
      var vals             = jQuery.map(selected_records, function(e,i){ return e.get('value'); });
      if (vals.length > 0) params[list_fields[i]+'[]'] = vals;
    }
  },
  submitQuery: function(buttonEl, eventObj)
  {
    this.getResultPanel().clearProviders();
    var form_panel   = this.find('id', 'ADSTFormPanel')[0];
    var form_values  = form_panel.getForm().getValues();
    var result_store = this.getResultPanel().getResultStore();
    form_panel.findParentByType('panel').getBottomToolbar().bindStore(result_store);
    result_store.baseParams = {}; // clear previous search values
    var params              = this.buildParams(form_values);
    this._grabListViewFormValues(params, this);
    for(key in params){
      if(params[key].indexOf('...') == -1 && key.indexOf("[]") == -1 && key != 'authenticity_token'){
        result_store.setBaseParam(key, params[key].replace(/\+/g, " "));
      }else if(params[key].indexOf('...') == -1){
        result_store.setBaseParam(key, params[key]);      
      }
    }
    //form_panel.buttons[0].disable();
    form_panel.buttons[2].show();
    form_panel.buttons[3].show();
    form_panel.buttons[4].show();
    //form_panel.buttons[5].show();
    var panel_mask = new Ext.LoadMask(this.getComponent('adst_container').getComponent('ADST_panel').getEl(), {msg:"Please wait..."});
    panel_mask.show();
    result_store.on('load', function(){ panel_mask.hide(); });
    result_store.load();
    return true;
  },
  setNextPage: function(this_toolbar, params)
  {
    var result_store   = this_toolbar.ownerCt.ownerCt.ownerCt.getResultPanel().getResultStore();
    var container_mask = new Ext.LoadMask(this_toolbar.ownerCt.ownerCt.ownerCt.getResultPanel().getEl(), {msg:"Please wait..."});
    params['page']     = Math.floor(params.start /  params.limit) + 1;
    container_mask.show();
    result_store.on('load', function(){ container_mask.hide(); });
    return true;
  },
  loadInitMask: function()
  {
    new Ext.LoadMask(this.getComponent('adst_container').getComponent('ADST_panel').getEl(),    {msg:"Please wait...", store: this.init_store});
  },
  initFormComponent: function(form_panel)
  {
    this.init_store = new Ext.data.JsonStore({
      root:     'options',
      fields:   ['absenteeism', 'age', 'data_functions', 'data_functions_adv', 'gender', 'grade', 'school_districts','school_type', 'schools', 'symptoms', 'zipcode'],
      url:      '/rollcall/query_options',
      autoLoad: false,
      listeners:{
        scope: form_panel,
        load:  function(this_store, records){
          this.ownerCt.show();
          this.add(new Talho.Rollcall.ADSTSimpleContainer({options: records[0].data}));
          this.add(new Talho.Rollcall.ADSTAdvancedContainer({options: records[0].data}));
          this.buttons[0].show();
          this.buttons[1].show();
          //this.ownerCt.ownerCt.ownerCt.getComponent('reports_panel').getBottomToolbar().findById('create_report_button').enable();
          this.doLayout();
        },
        exception: function(misc){
          Ext.Msg.alert('Access', 'You are not authorized to access this feature.  Please contact TX PHIN.', function(){
            Ext.getCmp('adst_container').ownerCt.destroy();
          });
        }
      }
    });
    this.loadInitMask();
    this.init_store.load();
  },
  showReportMenu: function(element, school_id)
  {
    var scrollMenu = new Ext.menu.Menu();
    scrollMenu.add({school_id: school_id, recipe: 'Report::AttendanceAllRecipe', text: 'Attendance Report', handler: this.showReportMessage});
    scrollMenu.add({school_id: school_id, recipe: 'Report::IliAllRecipe',        text: 'ILI Report',        handler: this.showReportMessage});
    scrollMenu.show(element);
  },
  showReportMessage: function(buttonObj, eventObj)
  {
    Ext.Ajax.request({
      url:      '/rollcall/report',
      params:   {recipe_id: buttonObj.recipe, school_id: buttonObj.school_id},
      method:   'GET',
      callback: function(options, success, response)
      {
        var title = 'Generating Report';
        var msg   = 'Your report will be placed in the report portal when the system '+
                    'is done generating it. Please check the report portal in a few minutes.';
        Ext.MessageBox.show({
          title:   title,
          msg:     msg,
          buttons: Ext.MessageBox.OK,
          icon:    Ext.MessageBox.INFO
        });
      },
      failure: function(){}
    });
  },
  init_store: null
});

Talho.Rollcall.ADST.initialize = function(config)
{
  return new Talho.Rollcall.ADST(config);
}

Talho.ScriptManager.reg('Talho.Rollcall.ADST', Talho.Rollcall.ADST, Talho.Rollcall.ADST.initialize);
