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
        itemId: 'leftColumn',
        listeners:{
          scope: this
        }
      }, {
        columnWidth: .50,
        itemId: 'rightColumn',
        listeners:{
          scope: this
        }
      }]
    });

    var result_store = new Ext.data.JsonStore({
      totalProperty: 'total_results',
      root:   'results',
      url: '/rollcall/adst',
      fields: ['id','img_urls', 'r_ids', 'schools', 'school_names'],
      writer: new Ext.data.JsonWriter({encode: false}),
      restful: true,
      autoLoad: false,
      autoSave: true,
      listeners: {
        scope: this,
        load: function(store, records, options){
          this.show();
          var schools = new Array();
          for(var i =0; i < records.length; i++){
            schools += records[i].json.school.tea_id+',';
          }
          record = new store.recordType({id: null, img_urls: '', schools: schools},null);
          store.add([record]);
        },
        write: function(store, action, result, res, rs) {
          var item_id          = null;
          var graphImageConfig = null;
          var result_obj       = null;
          this.getComponent('rightColumn').removeAll();
          this.getComponent('leftColumn').removeAll();
          for(var i = 0; i < result[0]['img_urls'].length; i++){
            item_id          = result[0]["schools"][i];
            school_name          = result[0]["school_names"][i];
            graphImageConfig = {
              title: 'Query Result for '+school_name,
              style:'margin:5px',
              itemId: item_id,
              school_name: result[0]["school_names"][i],
              r_id: result[0]["r_ids"][i],
              tools: [{
                id:'save',
                qtip: 'Save Query',
                handler: function(e, targetEl, panel, tc){
                  panel.ownerCt.ownerCt.showSaveQueryConsole(store.baseParams, panel.itemId, panel.school_name, panel.r_id.value, panel);
                }
              },{
                id:'down',
                qtip: 'Export Query Result',
                handler: function(e, targetEl, panel, tc){
                  var form_values  = panel.ownerCt.ownerCt.ownerCt.findByType('form')[0].getForm().getValues();
                  var param_string = '';
                  for(key in form_values){
                    if(key == 'school_simple' || key == 'school_adv'){
                      param_string += key + '=' + panel.school_name + "&";
                    }else{
                      param_string += key + '=' + form_values[key] + "&";
                    }
                  }
                  Talho.ux.FileDownloadFrame.download('rollcall/export?'+param_string);
                }
              },{
                id:'close',
                qtip: "Close",
                handler: function(e, target, panel){
                  panel.ownerCt.remove(panel, true);
                }
              }],
              height: 230,
              html: '<div class="ux-result-graph-container"><img src="/images/Ajax-loader.gif" /></div>'
            };

            if(i == 0 || i%2 == 0){
              result_obj = this.getComponent('rightColumn').add(graphImageConfig);
            }else{
              result_obj = this.getComponent('leftColumn').add(graphImageConfig);
            }
            this.doLayout();
            this.ownerCt.ownerCt.ownerCt.renderGraphs(i, result[0]['img_urls'][i].value, result_obj, 'ux-result-graph-container');
          }
        }
      }
    });
    this._getResultStore = function(){
      return result_store;
    }

    Talho.Rollcall.ADSTResultPanel.superclass.constructor.call(this, config);
  },

  reportExportFailure: function(response, obj)
  {

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
    var params       = [];
    var storedParams = new Ext.data.ArrayStore({
        storeId: 'my-store',
        fields: ['field', 'value'],
        idIndex: 0
    });

    if(queryParams['adv'] == 'true') var paramSwitch = 'adv';
    else var paramSwitch = 'simple';
    
    for(key in queryParams){
      if(key.indexOf(paramSwitch) != -1){
        if(queryParams[key].indexOf("...") == -1 && key != 'adv')
          params.push([key.substr(0, key.indexOf("_")), queryParams[key]]);
      }
    }
    params.push(['tea_id', tea_id]);

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
      title: 'Save Query for '+school_name,
      plain: true,
      items: [{
        xtype: 'form',
        id: 'savedQueryForm',
        url: 'rollcall/save_query',
        border: false,
        baseParams:{
          query_params: param_string,
          r_id: r_id,
          tea_id: tea_id
        },
        items:[{
          xtype:'textfield',
          labelStyle: 'margin: 10px 0px 0px 5px',
          fieldLabel: 'Query Name',
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
              value: 50
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
              value: 50
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
              value: 50
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
              value: 50,
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
              value: 50,
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
          var obj_options = {
            result_panel: result_panel
          };
          alarm_console.getComponent('savedQueryForm').getForm().on('actioncomplete', function(){
            var adst_panel = obj_options.result_panel.ownerCt.ownerCt.ownerCt.ownerCt;
            adst_panel.getComponent('saved_queries').getComponent('portalId_south').updateSavedQueries(r_id);
            this.hide();
            this.destroy();
          }, alarm_console, obj_options);
          alarm_console.getComponent('savedQueryForm').getForm().submit();
        }
      },{
        text: 'Close',
        handler: function(buttonEl, eventObj){
          alarm_console.close();
          //alarm_console.hide();
          //alarm_console.destroy();
        }
      }]
    });
    alarm_console.doLayout();
    alarm_console.show();
  },
  clearProviders: function() {
    Ext.each(this.providers, function(item, index, allItems) {
      item.disconnect();
    });
    this.providers = new Array();
  }
});
