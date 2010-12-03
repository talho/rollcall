Ext.namespace('Talho.ux.rollcall');

Talho.ux.rollcall.result_store = new Ext.data.JsonStore({
  idProperty: 'id',
  totalProperty: 'total_results',
  root:   'results',
  fields: ['id', 'value'],
  listeners: {
    scope: this,
    'load': function(this_store, record){
      var item_id = null;
      var graphImageConfig = null;
      for(var i = 0; i < record.length; i++){
        item_id = 'query_result_'+i;
        graphImageConfig = {
          title: 'Query Result',
          style:'margin:5px',
          itemId: item_id,
          tools: [{
            id:'plus',
            qtip: 'Save Query',
            handler: function(e, targetEl, panel, tc){
              Ext.getCmp('searchResultPanel')._showAlarmConsole();
            }
          },{
            id:'close',
            handler: function(e, target, panel){
              panel.ownerCt.remove(panel, true);
            }
          }],
          height: 230,
          html: '<div style="text-align:center">Loading...</div>'
        };
        if(i == 0 || i%2 == 0)Ext.getCmp('searchResultPanel').get('columnRight').add(graphImageConfig);
        else Ext.getCmp('searchResultPanel').get('columnLeft').add(graphImageConfig);
        Ext.getCmp('searchResultPanel').get('columnLeft').doLayout();
        Ext.getCmp('searchResultPanel').get('columnRight').doLayout();
      }
      Ext.getCmp('searchResultPanel').renderGraphs(record, 0);
    }
  }
});

Talho.ux.rollcall.RollcallSearchResultPanel = Ext.extend(Ext.ux.Portal, {
  constructor: function(config){
    Ext.applyIf(config,{
      hidden: true,
      id:     'searchResultPanel',
      itemId: 'portalId',
      items:[{
        columnWidth: .50,
        id: 'columnLeft',
        listeners:{
          scope: this
        }
      },
      {
        columnWidth: .50,
        id: 'columnRight',
        listeners:{
          scope: this
        }
      }]
    });
    Talho.ux.rollcall.RollcallSearchResultPanel.superclass.constructor.call(this, config);
  },

  processQuery: function(json_result)
  {
    
    Talho.ux.rollcall.result_store.loadData(json_result);
  },

  _showAlarmConsole: function()
  {
    /*
    * Setting up mock data for presentation.  This code might be useful
    * in constructing the app.
    * */
    var myStore = new Ext.data.ArrayStore({
        storeId: 'my-store',
        fields: ['field', 'value'],
        idIndex: 0
    });
    var myData = [
        ['Absenteeism', 'Confirmed Illness'],
        ['School Type', 'Elementary']
    ];
    myStore.loadData(myData);

    /*
    * Creating Ext Component Window.  Mocking up
    * alarm console
    * */
    var alarm_console = new Ext.Window({
      layout:'fit',
      autoWidth:true,
      autoHeight:true,
      closeAction:'hide',
      title: 'Set Alarm for Query Result(1)',
      plain: true,
      items: [{
        xtype: 'form',
        border:false,
        items:[{
          xtype:'textfield',
          labelStyle:'margin: 10px 0px 0px 5px',
          fieldLabel: 'Alarm Name',
          width: 195,
          style:{
            marginTop: '10px',
            marginBottom: '5px'
          }
        },{
          xtype: 'fieldset',
          width : 300,
          autoHeight: true,
          title : 'Deviation',
          style:{
            marginLeft: '5px',
            marginRight: '5px'
          },
          defaultType: 'sliderfield',
          buttonAlign: 'left',
          defaults: {
              anchor: '95%',
              tipText: function(thumb){
                  return String(thumb.value) + '%';
              }
          },
          items: [{
              fieldLabel: 'Threshold',
              value: 50,
              name: 'th'
          },{
              fieldLabel: 'Min',
              value: 80,
              name: 'min'
          },{
              fieldLabel: 'Max',
              value: 25,
              name: 'max'
          }],
          fbar: {
              xtype: 'toolbar',
              items: ['->', {
                  text: 'Max All',
                  handler: function(){
                      form.items.each(function(c){
                          c.setValue(100);
                      });
                  }
              },{
                  text: 'Reset',
                  handler: function(){
                      form.getForm().reset();
                  }
              }]
          }
        },{
          xtype: 'fieldset',
          width : 300,
          autoHeight: true,
          title : 'Severity',
          style:{
            marginLeft: '5px',
            marginRight: '5px'
          },
          defaultType: 'sliderfield',
          buttonAlign: 'left',
          defaults: {
              anchor: '95%',
              tipText: function(thumb){
                  return String(thumb.value) + '%';
              }
          },
          items: [{
              fieldLabel: 'Min',
              value: 80,
              name: 'min'
          },{
              fieldLabel: 'Max',
              value: 25,
              name: 'max'
          }],
          fbar: {
              xtype: 'toolbar',
              items: ['->', {
                  text: 'Max All',
                  handler: function(){
                      form.items.each(function(c){
                          c.setValue(100);
                      });
                  }
              },{
                  text: 'Reset',
                  handler: function(){
                      form.getForm().reset();
                  }
              }]
          }
        },{
          xtype: 'fieldset',
          autoWidth : true,
          autoHeight: true,
          title : 'Parameters',
          style:{
            marginLeft: '5px',
            marginRight: '5px'
          },
          collapsible: true,
          items: [{
            xtype: 'listview',
            store: myStore,
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
      buttons: [{
        text:'Submit',
        disabled:true
      },{
        text: 'Close',
        handler: function(){
          alarm_console.hide();
        }
      }]
    });
    alarm_console.show();
  },
  renderGraphs: function(image_array, cnt)
  {
    var item_id = 'query_result_'+cnt;
    Ext.Ajax.request({
      url: image_array[cnt].data.value,
      success: function(){
        try{
          Ext.getCmp('searchResultPanel').get("columnRight").getComponent(item_id).add({html:'<div style="text-align:center"><img name="'+cnt+'" src="'+image_array[cnt].data.value+'" /></div>'});
        }catch(e){
          Ext.getCmp('searchResultPanel').get("columnLeft").getComponent(item_id).add({html:'<div style="text-align:center"><img name="'+cnt+'" src="'+image_array[cnt].data.value+'" /></div>'});
        }
        Ext.getCmp('searchResultPanel').get('columnLeft').doLayout();
        Ext.getCmp('searchResultPanel').get('columnRight').doLayout();
        cnt++;
        if(image_array.length != cnt) Ext.getCmp('searchResultPanel').renderGraphs(image_array, cnt);
      },
      failure: function(result, opts){
        Ext.Ajax.request(opts);
      },
      headers: {
        'type': 'HEAD'
      }
    });
  }
});