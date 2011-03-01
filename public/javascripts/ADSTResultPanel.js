Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.ADSTResultPanel = Ext.extend(Ext.ux.Portal, {
  constructor: function(config){
    Ext.applyIf(config,{
      hidden: true,
      id:     'ADSTResultPanel',
      itemId: 'portalId',
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
        load:  this.loadGraphResults,
        write: this.writeGraphs
      }
    });

    this._getResultStore = function()
    {
      return result_store;
    }

    Talho.Rollcall.ADSTResultPanel.superclass.constructor.call(this, config);
  },

  writeGraphs: function(store, action, result, res, rs)
  {
    var tea_id           = null;
    var graphImageConfig = null;
    var result_obj       = null;
    var leftColumn       = this.getComponent('leftColumn');
    var rightColumn      = this.getComponent('rightColumn');
    rightColumn.items.each(function(item){
      if(!item.pinned) rightColumn.remove(item.id, true);
    });

    leftColumn.items.each(function(item) {
      if(!item.pinned) leftColumn.remove(item.id, true);
    });

    for(var i = 0; i < result[0]['img_urls'].length; i++){
      tea_id          = result[0]["schools"][i].school.tea_id;
      school_name      = result[0]["schools"][i].school.display_name;
      graphImageConfig = {
        title:       'Query Result for '+school_name,
        style:       'margin:5px',
        tea_id:      tea_id,
        school:      result[0]["schools"][i].school,
        school_name: result[0]["schools"][i].school.display_name,
        r_id:        result[0]["r_ids"][i],
        collapsible: false,
        pinned:      false,
        tools: [{
          id:      'pin',
          qtip:    'Pin This Graph',
          handler: function(e, targetEl, panel, tc)
          {
            targetEl.toggleClass('x-tool-pin');
            targetEl.toggleClass('x-tool-unpin');
            if(targetEl.hasClass('x-tool-unpin')) panel.pinned = true;
            else panel.pinned = false;
          }
        },{
          id:      'gear',
          qtip:    'Show School on Google Map',
          handler: this.showOnGoogleMap
        },{
          id:      'save',
          qtip:    'Save Query',
          scope:   this,
          handler: function(e, targetEl, panel, tc)
          {
            this.showSaveQueryConsole(store.baseParams, panel.tea_id, panel.school_name, panel.r_id.value, panel);
          }
        },{
          id:      'down',
          qtip:    'Export Query Result',
          handler: this.exportResult
        },{
          id:      'close',
          qtip:    "Close",
          handler: this.closeResult
        }],
        height: 230,
        html:   '<div class="ux-result-graph-container"><img src="/images/Ajax-loader.gif" /></div>'
      };

      if(i == 0 || i%2 == 0){
        result_obj = rightColumn.add(graphImageConfig);
      }else{
        result_obj = leftColumn.add(graphImageConfig);
      }
      this.doLayout();
      this.ownerCt.ownerCt.ownerCt.renderGraphs(i, result[0]['img_urls'][i].value, result_obj, 'ux-result-graph-container');
    }
  },

  closeResult: function(e, target, panel)
  {
    panel.ownerCt.remove(panel, true);
  },

  showOnGoogleMap: function(e, targetEl, panel, tc)
  {
    var gmapPanel = new Ext.ux.GMapPanel({zoomLevel: 14});
    var win = new Ext.Window({
      title: "Google Map for '" + panel.school_name + "'",
      layout: 'fit',
      labelAlign: 'top',
      padding: '5',
      width: 510, height: 450,
      items: [gmapPanel]
    });
    win.addButton({xtype: 'button', text: 'Dismiss', handler: function(){ win.close(); }, scope: this, width:'auto'});
    win.addListener("afterrender", function(){
      var loc = new google.maps.LatLng(panel.school.gmap_lat, panel.school.gmap_lng);
      gmapPanel.gmap.setCenter(loc);
      var addr_elems = panel.school.gmap_addr.split(",");
      var marker = gmapPanel.addMarker(loc, panel.school.display_name, {});
      marker.info = "<b>" + panel.school.display_name + "</b><br>";
      marker.info += addr_elems[0] + "<br>" + addr_elems[1] + "<br>" + addr_elems.slice(2).join(",");
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
    });
    win.show();
  },

  exportResult: function(e, targetEl, panel, tc)
  {
    var form_values  = panel.ownerCt.ownerCt.ownerCt.findByType('form')[0].getForm().getValues();
    var param_string = '';
    for(key in form_values){
      if(Ext.getCmp('advanced_query_select').isVisible()){
        if(key.indexOf('adv') != -1){
          if(key == 'school_adv') param_string += key.replace('_adv','') + '=' + panel.school_name + "&";
          else param_string += key.replace('_adv','') + '=' + form_values[key] + "&";
        }
      }else{
        if(key.indexOf('simple') != -1){
          if(key == 'school_simple') param_string += key.replace('_simple','') + '=' + panel.school_name + "&";
          else param_string += key.replace('_simple','') + '=' + form_values[key] + "&";
        }
      }
    }
    Ext.Ajax.request({
      url:    'rollcall/export?'+param_string,
      method: 'GET',
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
      failure: function(){

      }
    });
  },

  loadGraphResults: function(store, records, options)
  {
    this.show();
    var schools = new Array();
    for(var i = 0; i < records.length; i++){
      schools += records[i].json.school.tea_id+',';
    }
    record = new store.recordType({id: null, img_urls: '', schools: schools},null);
    store.add([record]);
  },

  processQuery: function(json_result)
  {
    this._getResultStore().loadData(json_result);
  },

  getResultStore: function()
  {
    return this._getResultStore();
  },

  showSaveQueryConsole: function(queryParams, tea_id, school_name, r_id, result_panel)
  {
    var params       = new Array();
    var storedParams = new Ext.data.ArrayStore({
      storeId: 'my-store',
      fields:  ['field', 'value'],
      idIndex: 0
    });
    
    for(key in queryParams){
      if(queryParams[key].indexOf("...") == -1 && key != "authenticity_token") params.push([key, queryParams[key]]);
    }
    params.push(['tea_id', tea_id]);
    storedParams.loadData(params);

    param_string = '';

    for(key in params){
      if(key != "remove") param_string += params[key][0] + '=' + params[key][1] + "|"
    }

    var alarm_console = new Ext.Window({
      layout:       'fit',
      width:        300,
      autoHeight:   true,
      modal:        true,
      constrain:    true,
	    renderTo:     'adst_container',
      closeAction:  'close',
      title:        'Save Query for '+school_name,
      plain:        true,
      result_panel: result_panel,
      r_id:         r_id,
      items: [{
        xtype:      'form',
        id:         'savedQueryForm',
        url:        'rollcall/save_query',
        border:     false,
        baseParams: {
          authenticity_token: FORM_AUTH_TOKEN,
          query_params: param_string,
          r_id:         r_id,
          tea_id:       tea_id
        },
        items:[{
          xtype:         'textfield',
          labelStyle:    'margin: 10px 0px 0px 5px',
          fieldLabel:    'Query Name',
          id:            'query_name',
          minLengthText: 'The minimum length for this field is 3',
          blankText:     "This field is required.",
          minLength:     3,
          allowBlank:    false,
          style:{
            marginTop:    '10px',
            marginBottom: '5px'
          }
        },{
          xtype: 'fieldset',
          title: 'Absentee Rate Deviation',
          style: {
            marginLeft:  '5px',
            marginRight: '5px'
          },
          buttonAlign: 'left',
          defaults: {
            xtype: 'container'
          },
          items: [{
            fieldLabel: 'Min',
            items:[{
              xtype: 'textfield',
              width: 32,
              cls:   'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              value: '100%'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                scope:  this,
                change: this.changeTextField
              },
              tipText: this.showTipText,
              id:      'deviation_min',
              cls:     'ux-layout-auto-float-item',
              value:   100
            }]
          },{
            fieldLabel: 'Max',
            items:[{
              xtype: 'textfield',
              width: 32,
              cls:   'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              value: '100%'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                scope:  this,
                change: this.changeTextField
              },
              tipText: this.showTipText,
              id:      'deviation_max',
              cls:     'ux-layout-auto-float-item',
              value:   100
            }]
          }],
          fbar: {
            xtype: 'toolbar',
            items: ['->', {
              text:    'Max All',
              handler: this.maxFields
            },{
              text:    'Reset',
              handler: this.resetFields
            }]
          }
        },{
          xtype:      'fieldset',
          autoHeight: true,
          title:      'Absentee Rate Severity',
          style:{
            marginLeft:  '5px',
            marginRight: '5px'
          },
          buttonAlign: 'left',
          defaults: {
            xtype:  'container',
            layout: 'anchor'
          },
          items: [{
            fieldLabel: 'Min',
            items:[{
              xtype: 'textfield',
              width: 32,
              cls:   'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              value: '100%'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                scope:  this,
                change: this.changeTextField
              },
              tipText: this.showTipText,
              id:      'severity_min',
              value:   100,
              cls:     'ux-layout-auto-float-item'
            }]
          },{
            fieldLabel: 'Max',
            items:[{
              xtype: 'textfield',
              width: 32,
              cls:   'ux-layout-auto-float-item',
              style:{
                marginLeft: '-40px'
              },
              value: '100%'
            },{
              xtype: 'sliderfield',
              width: 135,
              listeners: {
                scope:  this,
                change: this.changeTextField
              },
              tipText: this.showTipText,
              id:      'severity_max',
              value:   100,
              cls:     'ux-layout-auto-float-item'
            }]
          }],
          fbar: {
            xtype: 'toolbar',
            items: ['->', {
              text:    'Max All',
              handler: this.maxFields
            },{
              text:    'Reset',
              handler: this.resetFields
            }]
          }
        },{
          xtype:      'fieldset',
          autoWidth:  true,
          autoHeight: true,
          title:      'Parameters',
          style:{
            marginLeft:  '5px',
            marginRight: '5px'
          },
          collapsible: false,
          items: [{
            xtype:               'listview',
            store:               storedParams,
            multiSelect:         true,
            reserveScrollOffset: true,
            columns: [{
                header:    'Field Name',
                width:     .65,
                dataIndex: 'field'
            },{
                header:    'Value Set',
                width:     .35,
                dataIndex: 'value'
            }]
          }]
        }]
      }],
      buttonAlign: 'right',
      buttons: [{
        text:    'Submit',
        handler: this.submitSavedQuery
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

  showTipText: function(thumb)
  {
    return String(thumb.value) + '%';
  },

  submitSavedQuery: function(buttonEl, eventObj)
  {
    var obj_options = {
      result_panel: this.ownerCt.ownerCt.result_panel
    };
    var update_params = {
      params:{
        r_id: this.ownerCt.ownerCt.r_id
      }
    }
    this.ownerCt.ownerCt.getComponent('savedQueryForm').getForm().on('actioncomplete', function(){
      var adst_panel = obj_options.result_panel.ownerCt.ownerCt.ownerCt.ownerCt;
      adst_panel.getComponent('saved_queries').getComponent('portalId_south').updateSavedQueries(update_params);
      this.hide();
      this.destroy();
    }, this.ownerCt.ownerCt, obj_options);
    this.ownerCt.ownerCt.getComponent('savedQueryForm').getForm().submit();
  },

  changeTextField: function(obj, new_number, old_number)
  {
    obj.ownerCt.findByType('textfield')[0].setValue(new_number)
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

  resetFields: function(buttonEl, eventObj)
  {
    sliders = buttonEl.ownerCt.ownerCt.findByType("sliderfield");
    for(key in sliders){
      try{
        sliders[key].reset();
      }catch(e){}
    }
  },

  clearProviders: function()
  {
    Ext.each(this.providers, function(item, index, allItems) {
      item.disconnect();
    });
    this.providers = new Array();
  }
});
