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

    Ext.apply(config,
    {
      layout:   'fit',
      closable: true,
      scope:    this,
      items:[{
        id:         'adst_container',
        layout:     'border',
        autoScroll: true,
        scope:      this,
        defaults: {
          collapsible: true,
          split:       true,
          cmargins:    '5 5 0 0',
          margins:     '5 0 0 0'
        },
        items: [{
          title:      'Saved Queries',
          itemId:     'saved_queries',
          id:         'saved_queries',
          region:     'south',
          height:     180,
          minSize:    180,
          maxSize:    300,
          autoScroll: true,
          layout:     'fit',
          items:      new Talho.Rollcall.SavedQueriesPanel({})
        },{
          title:       'Reports',
          region:      'east',
          bodyStyle:   'padding:0px',
          layout:      'fit',
          width:       200,
          minSize:     175,
          maxSize:     400,
          autoScroll:  true,
          items:       new Talho.Rollcall.ReportsPanel({})
        },{
          title:     'Alarms',
          region:    'west',
          layout:    'fit',
          bodyStyle: 'padding:0px',
          width:     200,
          items:     new Talho.Rollcall.AlarmsPanel({})
        },{
          title:       'ADST',
          itemId:      'ADST_panel',
          id:          'ADST_panel',
          collapsible: false,
          region:      'center',
          autoScroll:  true,
          scope:       this,
          items:[{
            xtype:  'container',
            itemId: 'query_container',
            layout: 'column',
            scope:  this,
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
                text: "Submit",
                scope: this,
                hidden: true,
                handler: this.submitQuery,
                formBind: true
              },{
                text: "Reset Form",
                scope: this,
                hidden: true,
                handler: this.resetForm
              },{
                text: "Export Result Set",
                hidden: true,
                scope: this,
                handler: this.exportResultSet
              },{
                text: "Map Result Set",
                hidden: true,
                scope: this,
                handler: this.mapResultSet
              }],
              listeners:{
                scope: this,
                beforerender: this.initFormComponent
              }
            }]
          }, resultPanel ],
          bbar: new Ext.PagingToolbar({
            scope: this,
            displayInfo: true,
            pageSize: 6,
            prependButtons: true,
            listeners:{
              'beforechange': this.setNextPage
            }
          })
        }]
      }]
    });
    Talho.Rollcall.ADST.superclass.constructor.call(this, config);
  },
  renderGraphs: function(id, image, obj, class_name)
  {
    provider = new Ext.direct.PollingProvider({
      id: 'image' + id + '-provider',
      type: 'polling',
      url: image,
      listeners: {
        scope: obj,
        data: function(provider, e)
        {
          if(e.xhr.status == 200) {
            var element_id = Math.floor(Math.random() * 10000);
            (function(provider)
            {
              this.update('<div id="'+element_id+'" class="'+class_name+'" >' +
                          '<img style="display:none;" src="'+provider.url+'?' + element_id + '" />' +
                          '</div>');
              this.doLayout();
            }).defer(50,this,[provider]);
            (function(provider)
            {
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
  },
  buildParams: function(form_values)
  {
    var params = new Object;
    for(key in form_values)
      params[key.replace(/_adv|_simple/,'')] = form_values[key];
    return params;
  },
  mapResultSet: function(buttonEl, eventObj)
  {
    var form_values  = buttonEl.findParentByType('form').getForm().getValues();
    var params = this.buildParams(form_values);
    params["limit"] = this.getResultPanel().getResultStore().getTotalCount();
    Ext.Ajax.request({
      url:    'rollcall/adst',
      method: 'GET',
      params: params,
      scope:  this,
      callback: function(options, success, response){
        var gmapPanel = new Ext.ux.GMapPanel({zoomLevel: 9});
        var win = new Ext.Window({
          title: "Google Map of Schools",
          layout: 'fit',
          labelAlign: 'top',
          padding: '5',
          width: 510, height: 450,
          items: [gmapPanel]
        });
        win.schools = Ext.decode(response.responseText).results;
        win.addButton({xtype: 'button', text: 'Dismiss', handler: function(){ win.close(); }, scope: this, width:'auto'});
        win.addListener("afterrender", function(w){
          var center = new google.maps.LatLng(w.schools[0].school.gmap_lat, w.schools[0].school.gmap_lng);
          gmapPanel.gmap.setCenter(center);
          for(var i = 0; i < w.schools.length; i++) {
            var loc = new google.maps.LatLng(w.schools[i].school.gmap_lat, w.schools[i].school.gmap_lng);
            var marker = gmapPanel.addMarker(loc, w.schools[i].school.display_name, {});
            var addr_elems = w.schools[i].school.gmap_addr.split(",");
            marker.info = "<b>" + w.schools[i].school.display_name + "</b><br>";
            marker.info += addr_elems[0] + "<br>" + addr_elems[1] + "<br>" + addr_elems.slice(2).join(",");
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
    Ext.Ajax.request({
      url:    'rollcall/export',
      method: 'GET',
      params: this.buildParams(buttonEl.findParentByType("form").getForm().getValues()),
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
    //Talho.ux.FileDownloadFrame.download('rollcall/export?'+param_string);   
  },
  resetForm: function(buttonEl, eventObj)
  {
    buttonEl.findParentByType("form").getForm().reset();
  },
  submitQuery: function(buttonEl, eventObj)
  {
    this.getResultPanel().clearProviders();
    var form_values  = buttonEl.findParentByType('form').getForm().getValues();
    var result_store = this.getResultPanel().getResultStore();
    buttonEl.findParentByType('form').findParentByType('panel').getBottomToolbar().bindStore(result_store);
    form_values.page  = 1;
    form_values.start = 0;
    form_values.limit = 6;
    result_store.baseParams = {}; // clear previous search values
    var params = this.buildParams(form_values);
    for(key in params)
      result_store.setBaseParam(key, params[key]);
    buttonEl.findParentByType("form").buttons[2].show();
    buttonEl.findParentByType("form").buttons[3].show();

    var panel_mask = new Ext.LoadMask(this.getComponent('adst_container').getComponent('ADST_panel').getEl(), {msg:"Please wait..."});
    panel_mask.show();
    result_store.on('write', function(){ panel_mask.hide(); });
    result_store.load({params: this.buildParams(form_values)});
    return true;
  },
  setNextPage: function(this_toolbar, params)
  {
    var result_store   = this_toolbar.ownerCt.ownerCt.ownerCt.getResultPanel().getResultStore();
    var container_mask = new Ext.LoadMask(this_toolbar.ownerCt.ownerCt.ownerCt.getResultPanel().getEl(), {msg:"Please wait..."});
    params['page']     = Math.floor(params.start /  params.limit) + 1;
    container_mask.show();
    result_store.on('write', function(){
      container_mask.hide();
    });
    return true;
  },
  loadInitMask: function()
  {
    new Ext.LoadMask(this.getComponent('adst_container').getComponent('ADST_panel').getEl(), {msg:"Please wait...", store: this.init_store});
  },
  loadQueryOptions: function(this_store, record)
  {
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
  },
  initFormComponent: function(form_panel)
  {
    this.init_store = new Ext.data.JsonStore({
      root:     'options',
      fields:   ['absenteeism', 'age', 'data_functions', 'gender', 'grade', 'school_type', 'schools', 'symptoms', 'zipcode'],
      url:      '/rollcall/query_options',
      autoLoad: false,
      listeners:{
        scope: form_panel,
        load:  function(this_store, record)
        {
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
          this.buttons[0].show();
          this.buttons[1].show();
          this.doLayout();
        }
      }
    });
    this.loadInitMask();
    this.init_store.load();
  },
  init_store: null
});

Talho.Rollcall.ADST.initialize = function(config)
{
  return new Talho.Rollcall.ADST(config);
}

Talho.ScriptManager.reg('Talho.Rollcall.ADST', Talho.Rollcall.ADST, Talho.Rollcall.ADST.initialize);
