Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ADSTResultPanel = Ext.extend(Ext.ux.Portal, {
  constructor: function(config){
    Ext.applyIf(config,{
      hidden: true,
      id:     'ADSTResultPanel',
      itemId: 'portalId',
      border: false,
      items:[{
        columnWidth: .50,
        itemId:      'leftColumn',
        listeners:{
          scope: this
        }
      },{
        columnWidth: .50,
        itemId:      'rightColumn',
        listeners:{
          scope: this
        }
      }]
    });

    var result_store = new Ext.data.JsonStore({
      totalProperty: 'total_results',
      root:          'results',
      url:           '/rollcall/adst',
      fields:        ['id','img_urls', 'r_ids', 'schools', 'school_names'],
      writer:        new Ext.data.JsonWriter({encode: false}),
      restful:       true,
      autoLoad:      false,
      autoSave:      true,
      listeners: {
        scope: this,
        load:  this.loadGraphResults
      }
    });

    this._getResultStore = function()
    {
      return result_store;
    };

    Talho.Rollcall.ADSTResultPanel.superclass.constructor.call(this, config);
  },

  writeGraphs: function(store)
  {
    this.ownerCt.find('id', 'ADSTFormPanel')[0].buttons[0].disable();
    var resultLength = store.getRange().length;
    var leftColumn   = this.getComponent('leftColumn');
    var rightColumn  = this.getComponent('rightColumn');
    rightColumn.items.each(function(item){
      if(!item.pinned) rightColumn.remove(item.id, true);
    });

    leftColumn.items.each(function(item) {
      if(!item.pinned) leftColumn.remove(item.id, true);
    });

    Ext.each(store.getRange(), function(school_record,i){
      var school           = school_record.json; // TODO
      var school_id        = school.id;
      var school_name      = typeof school.display_name == "undefined" ? school.name : school.display_name;
      var result_obj       = null;
      var graphImageConfig = {
        title:       'Query Result for '+school_name,
        style:       'margin:5px',
        school:      school,
        school_name: school.display_name,
        school_id:   school_id,
        provider_id: 'image'+i+'-provider',
        collapsible: false,
        pinned:      false,
        tools: [{
          id:      'pin',
          qtip:    'Pin This Graph',
          handler: this.pinGraph
        },{
          id:      'report',
          qtip:    'Generate Report',
          handler: function(e, targetEl, panel, tc)
          {
            Ext.MessageBox.show({
              title: 'Generating Report',
              msg: 'Your report will be placed in the report portal when the system '+
              'is done generating it. Please check the report portal in a few minutes.',
              buttons: Ext.MessageBox.OK,
              icon: Ext.MessageBox.INFO
            });
          },
          hidden: true
        },{
          id:      'gis',
          qtip:    'Show School Profile',
          handler: this.showSchoolProfile,
          hidden:  typeof school.gmap_lat == "undefined" ? true : false
        },{
          id:      'save',
          qtip:    'Save As Alarm',
          scope:   this,
          handler: function(e, targetEl, panel, tc)
          {
            this.showAlarmQueryConsole(panel.school_name);
          }
        },{
          id:      'down',
          qtip:    'Export Result',
          handler: this.exportResult
        },{
          id:      'close',
          qtip:    "Close",
          handler: this.closeResult
        }],
        height: 230,
        boxMinWidth: 320,
        html:   '<div class="ux-result-graph-container"><img src="/images/Ajax-loader.gif" /></div>'
      };

      if(i == 0 || i%2 == 0){
        result_obj = rightColumn.add(graphImageConfig);
      }else{
        result_obj = leftColumn.add(graphImageConfig);
      }
      this.doLayout();
      this.ownerCt.ownerCt.ownerCt.renderGraphs(i, school.image_url, result_obj, 'ux-result-graph-container', resultLength);
    }, this);
    if(resultLength == 0) this.ownerCt.find('id', 'ADSTFormPanel')[0].buttons[0].enable();
  },

  closeResult: function(e, target, panel)
  {
    var provider = Ext.Direct.getProvider(panel.provider_id);
    provider.purgeListeners();
    provider.disconnect();
    panel.ownerCt.remove(panel, true);
  },

  showSchoolProfile: function(e, targetEl, panel, tc)
  {
    var html_pad          = '<table class="alarm-tip-table"><tr><td><b>Student Daily Info:</b></td>'+
                            '<td><span>&nbsp;</span></td></tr></table>';
    var gmapPanel         = new Ext.ux.GMapPanel({zoomLevel: 12, width: 450, height: 400});
    var sch_info_tpl      = new Ext.XTemplate(
      '<tpl for=".">',
        '<table class="alarm-tip-table">',
          '<tr>',
            '<td><b>School:</b></td>',
            '<td><span>{display_name}</span></td>',
          '</tr>',
          '<tr>',
            '<td><b>School Type:</b></td>',
            '<td><span>{school_type}</span></td>',
          '</tr>',
          '<tr>',
            '<td><b>School Daily Info:</b></td>',
            '<td><span>&nbsp;</span></td>',
          '</tr>',
        '</table>',
      '</tpl>');
    var school_grid_panel = new Ext.grid.GridPanel({
      forceLayout: true,
      scope:       this,
      height:      125,
      viewConfig:  {
        emptyText: '<div><b style="color:#000">No School Data Available</b></div>',
        forceFit:  true
      },
      store: new Ext.data.JsonStore({
        autoDestroy: true,
        autoSave:    true,
        autLoad:     false,
        root:        'school_daily_infos',
        fields:      [
          {name:'id',                type:'int'},
          {name:'school_id',         type:'int'},
          {name:'report_date',       renderer: Ext.util.Format.dateRenderer('m-d-Y')},
          {name:'total_absent',      type:'int'},
          {name:'total_enrolled',    type:'int'}
        ]
      }),
      columns: [
        {header: 'Absent',      sortable: true,  dataIndex: 'total_absent'},
        {header: 'Enrolled',    sortable: true,  dataIndex: 'total_enrolled'},
        {header: 'Report Date', sortable: true,  dataIndex: 'report_date'}
      ],
      stripeRows:  true,
      stateful:    true
    });
    var student_grid_panel = new Ext.grid.GridPanel({
      forceLayout: true,
      scope:       this,
      height:      125,
      viewConfig:  {
        emptyText: '<div><b style="color:#000">No Student Data Available</b></div>',
        forceFit: true
      },
      store: new Ext.data.JsonStore({
        autoDestroy: true,
        autoSave:    true,
        autLoad:     false,
        root:        'student_daily_infos',
        fields:      [
          {name:'id',                type:'int'},
          {name:'age',               type:'int'},
          {name:'confirmed_illness', type:'bool'},
          {name:'gender',            type:'string'},
          {name:'grade',             type:'int'},
          {name:'school_id',         type:'int'},
          {name:'report_date',       renderer: Ext.util.Format.dateRenderer('m-d-Y')}
        ]
      }),
      columns: [
        {header: 'Age',           sortable: true,  dataIndex: 'age'},
        {header: 'Gender',        sortable: true,  dataIndex: 'gender'},
        {header: 'Grade',         sortable: true,  dataIndex: 'grade'},
        {header: 'Confirmed',     sortable: true,  dataIndex: 'confirmed_illness'},
        {header: 'Report Date',   sortable: true,  dataIndex: 'report_date'}
      ],
      stripeRows:  true,
      stateful:    true
    });
    var school_radio_group = new Ext.form.RadioGroup({
      fieldLabel: 'School Daily Info',
      id:         'school_radio_group',
      items: [
          {boxLabel: '1 month',  name: 'school_time', value: 1, checked: true},
          {boxLabel: '2 months', name: 'school_time', value: 2},
          {boxLabel: '3 months', name: 'school_time', value: 3}
      ],
      scope: this
    });
    var student_radio_group = new Ext.form.RadioGroup({
      fieldLabel: 'Student Daily Info',
      id:         'student_radio_group',
      items: [
          {boxLabel: '1 month',  name: 'student_time', value: 1, checked: true},
          {boxLabel: '2 months', name: 'student_time', value: 2},
          {boxLabel: '3 months', name: 'student_time', value: 3}
      ],
      scope: this
    });
    school_radio_group.addListener("change", function(group, chkd_radio )
      {
        panel.ownerCt.ownerCt.getSchoolData(chkd_radio.value, win, panel, school_grid_panel, 'school');
      }
    );
    student_radio_group.addListener("change", function(group, chkd_radio )
      {
        panel.ownerCt.ownerCt.getSchoolData(chkd_radio.value, win, panel, student_grid_panel, 'student');
      }
    );
    var win = new Ext.Window({
      title:      "School Profile for " + panel.school_name,
      layout:     'hbox',
      labelAlign: 'top',
      padding:    '5',
      width:      810,
      items: [{
        xtype:  'container',
        layout: 'vbox',
        width:  350,
        height: 400,
        defaults:{
          xtype: 'container',
          width: 345
        },
        items: [{
          html:  sch_info_tpl.applyTemplate(panel.school)
        },{
          items: [school_radio_group,school_grid_panel],
          html:  '<table class="alarm-tip-table"><tr><td><b>Student Daily Info:</b></td><td><span>&nbsp;</span></td></tr></table>'
        },{
          items: [student_radio_group,student_grid_panel]
        }]
      },{
        xtype: 'spacer',
        width: 10
      },gmapPanel]
    });
    win.addButton({xtype: 'button', text: 'Dismiss', handler: function(){ win.close(); }, scope: this, width:'auto'});
    gmapPanel.addListener("mapready", function(obj){
      var loc = new google.maps.LatLng(panel.school.gmap_lat, panel.school.gmap_lng);
      gmapPanel.gmap.setCenter(loc);
      var addr_elems    = panel.school.gmap_addr.split(",");
      var marker        = gmapPanel.addMarker(loc, panel.school.display_name, {});
      marker.info       = "<b>" + panel.school.display_name + "</b><br/>";
      marker.info      += addr_elems[0] + "<br/>" + addr_elems[1] + "<br/>" + addr_elems.slice(2).join(",");
      marker.info_popup = null;
      google.maps.event.addListener(marker, 'click', function(){
        if (marker.info_popup) {
          this.info_popup.close(gmapPanel.gmap, this);
          this.info_popup = null;
        } else {
          this.info_popup = new google.maps.InfoWindow({content: this.info});
          this.info_popup.open(gmapPanel.gmap, this);
        }
      });
      marker.info_popup = new google.maps.InfoWindow({content: marker.info});
      marker.info_popup.open(gmapPanel.gmap, marker);
    });
    win.addListener("afterrender", function(obj){
      panel.ownerCt.ownerCt.getSchoolData(1, obj, panel, school_grid_panel, 'school');
      panel.ownerCt.ownerCt.getSchoolData(1, obj, panel, student_grid_panel, 'student');

    });
    win.show();
  },

  getSchoolData: function(month, win_obj, main_panel, grid_panel, type)
  {
    var grid_mask = new Ext.LoadMask(grid_panel.getEl(), {msg:"Please wait...", removeMask: true});
    grid_mask.show();
    Ext.Ajax.request({
      url:     '/rollcall/get_'+type+'_data',
      method:  'POST',
      headers: {'Accept': 'application/json'},
      scope:   win_obj,
      params:  {
        school_id: main_panel.school_id,
        time_span: month
      },
      success: function(response, options)
      {
        jsonObj = Ext.decode(response.responseText).results;
        grid_panel.store.loadData(jsonObj);
        this.doLayout();
        grid_mask.hide();
      }
    });
  },

  exportResult: function(e, targetEl, panel, tc)
  {
    var adst_container = panel.ownerCt.ownerCt.ownerCt.ownerCt.ownerCt;
    var params = adst_container.buildParams(panel.ownerCt.ownerCt.ownerCt.findByType('form')[0].getForm().getValues());
    adst_container._grabListViewFormValues(params, adst_container);
    var param_string = '';
    for(key in params){
      if(key != 'school[]' && key != 'school_type[]' && key != 'zip[]') param_string += key + '=' + params[key] + '&';
    }
    if(Ext.getCmp('advanced_query_select').isVisible()){
      param_string += 'school[]=' + panel.school_name + "&";
    }else{
      param_string += 'school=' + panel.school_name + "&";
    }
    Ext.MessageBox.show({
      title: 'Creating CSV Export File',
      msg:   'Your CSV file will be placed in your documents folders when the system '+
      'is done generating it. Please check your documents folder in a few minutes.',
      buttons: Ext.MessageBox.OK,
      icon:    Ext.MessageBox.INFO
    });
    Ext.Ajax.request({
      url:      '/rollcall/export?'+param_string,
      method:   'GET',
      scope:    this,
      failure: function(){}
    });
  },

  loadGraphResults: function(store, records, options)
  {
    this.show();
    this.writeGraphs(store);
  },

  processQuery: function(json_result)
  {
    this._getResultStore().loadData(json_result);
  },

  getResultStore: function()
  {
    return this._getResultStore();
  },

  showAlarmQueryConsole: function(school_name)
  {
    var params       = new Array();
    var storedParams = new Ext.data.ArrayStore({
      storeId: 'my-store',
      fields:  ['field', 'value'],
      idIndex: 0
    });

    baseParams = this._getResultStore().baseParams;
    queryParams = {};
    for(key in baseParams){
      if(baseParams[key].indexOf("...") == -1 && key != "authenticity_token") queryParams[key] = baseParams[key];
    }
    queryParams["type"] = (Ext.getCmp('advanced_query_select').isVisible()) ? "adv" : "simple";
    if (school_name){
      if(queryParams["type"] == "adv"){
        queryParams["school[]"] = [];
        queryParams["school[]"].push(school_name);
        //queryParams["school"][] = t_a;
      }else queryParams["school"] = school_name;
    }
    for(key in queryParams){ params.push([key, queryParams[key]]); }
    storedParams.loadData(params);

    var o_i = {
      render_to:         'adst_container',
      alarm_query_title: (school_name) ? 'Alarm Query for '+school_name : 'Alarm Query',
      form_id:           'alarmQueryForm',
      form_url:          '/rollcall/alarm_query',
      auth_token:        FORM_AUTH_TOKEN,
      query_params:      Ext.encode(queryParams),
      deviation_min:     100,
      deviation_max:     100,
      severity_min:      100,
      severity_max:      100,
      stored_params:     storedParams,
      buttons: [{
        text:    'Submit',
        handler: this.submitAlarmQueryForm
      },{
        text: 'Close',
        handler: function(buttonEl, eventObj){
          alarm_console.close();
        }
      }]
    };
    var alarm_console = new Talho.Rollcall.ux.AlarmQueryWindow(o_i);
    alarm_console.doLayout();
    alarm_console.show();
  },

  showTipText: function(thumb)
  {
    return String(thumb.value) + '%';
  },

  submitAlarmQueryForm: function(buttonEl, eventObj)
  {
    var obj_options = {
      result_panel: this.ownerCt.ownerCt.result_panel
    };
    var update_params = {
      params:{
        latest: true
      }
    }
    this.ownerCt.ownerCt.getComponent('alarmQueryForm').getForm().on('actioncomplete', function(){
      Ext.getCmp('alarm_queries').getComponent('portalId_south').updateAlarmQueries(update_params);
      this.hide();
      this.destroy();
    }, this.ownerCt.ownerCt, obj_options);
    this.ownerCt.ownerCt.getComponent('alarmQueryForm').getForm().submit();
  },

  changeTextField: function(obj, new_number, old_number)
  {
    obj.ownerCt.findByType('textfield')[0].setValue(new_number)
  },

  changeSliderField: function(this_field, event_obj){
    this_field.nextSibling().setValue(this_field.getValue());
  },
  
  maxFields: function(buttonEl, eventObj)
  {
    sliders = buttonEl.ownerCt.ownerCt.findByType("sliderfield");
    for(key in sliders){
      try{
        sliders[key].setValue(100);
      }catch(e){}
    }
  },
  
  clearProviders: function()
  {
    Ext.each(this.providers, function(item, index, allItems) {
      item.purgeListeners();
      item.disconnect();
    });
    this.providers = new Array();
  },

  pinGraph: function(e, targetEl, panel, tc)
  {
    targetEl.findParent('div.x-panel-tl', 50, true).toggleClass('x-panel-pinned')
    targetEl.toggleClass('x-tool-pin');
    targetEl.toggleClass('x-tool-unpin');
    if(targetEl.hasClass('x-tool-unpin')) panel.pinned = true;
    else panel.pinned = false;
  }
});
