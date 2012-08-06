
Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.AlarmQueries = Ext.extend(Ext.DataView, {
  style: "x-overflow:auto;",
  loadingText: 'Loading...',
  itemSelector: 'div.rollcall-query-holder',
  constructor: function(){
    Talho.Rollcall.ADST.view.AlarmQueries.superclass.constructor.apply(this, arguments);
    this.addEvents('deletequery', 'editquery', 'togglequery', 'runquery');
    this.enableBubble('deletequery');
    this.enableBubble('editquery');
    this.enableBubble('togglequery');
    this.enableBubble('runquery');
  },
  initComponent: function () {
    // Build a store to get all of the 
    this.store = new Ext.data.JsonStore({
      url: '/rollcall/alarm_query',
      root: 'results',
      fields: ['id', 'user_id', 'name', 'alarm_set', 'deviation_min', 'deviation_max', 'severity_min', 'severity_max', 'query_params', {name: 'query_param_array', mapping: 'query_params', convert: function(v, rec){
        var params,
            param_array = [];
        try{
          params = Ext.decode(v);
        }
        catch(e){}
        
        for(var k in params){
          param_array.push({key: k, value: params[k]});
        }
        return param_array;
      }}],
      autoLoad: true,
      autoDestroy: true
    });
    
    this.tpl = new Ext.XTemplate(
      '<tpl for=".">',
        '<div class="rollcall-query-holder" style="float:left;height:100%;border:1px solid black;border-radius:3px;position:relative;margin:0px 8px;">',
          '<div style="border-bottom:1px solid black;color:white;font-size:11px;font-weight:bold;background-color:#697B93;">',
            '<div style="float:right;padding:2px">',
              '<div class="x-tool x-tool-close" qtip="Delete Alarm Query"></div>',
              '<div class="x-tool x-tool-gear" qtip="Edit Alarm Query"></div>',
              '<div class="x-tool {[values.alarm_set ? "x-tool-alarm-on" : "x-tool-alarm-off"]}" qtip="Toggle Alarm State"></div>',
              '<div class="x-tool x-tool-run-query" qtip="Run Query"></div>',
            '</div>',
            '<span class="rollcall-query-name" style="text-align:center;padding:2px;">{name}</span>',
          '</div>',
          '<div style="overflow-y:scroll;padding:2px;position:absolute;bottom:0;right:0;top:19px;left:0px;">',
            '<table style="width:100%;">',
              '<tbody>',
              '<tpl for="query_param_array">',
                '<tr style="border-bottom:1px solid #ADADAD;">',
                  '<td style="border-right: 1px solid #ADADAD;padding-right:2px;">{key}</td>',
                  '<td style="padding:0 2px;">{value}</td>',
                '</tr>',
              '</tpl>',
              '</tbody>',
            '</table>',
          '</div>',
        '</div>',
      '</tpl>'
    );
    
    Talho.Rollcall.ADST.view.AlarmQueries.superclass.initComponent.apply(this, arguments);
    
    this.on('click', this._item_clicked, this);        
  },
  
  _item_clicked: function(dv, index, node, e){
    var tar = e.getTarget('.x-tool');
    if(!tar){
      return true;
    }
    
    tar = Ext.get(tar);
    var rec = dv.getStore().getAt(index);
    if(tar.hasClass('x-tool-close')){
      this.fireEvent('deletequery', rec.get('id'));
    }
    else if(tar.hasClass('x-tool-gear')){
      this.fireEvent('editquery', rec.get('id'), rec);      
    }
    else if(tar.hasClass('x-tool-alarm-off') || tar.hasClass('x-tool-alarm-on')){
      this.fireEvent('togglequery', rec.get('id'), rec);
    }
    else if(tar.hasClass('x-tool-run-query')){
      this.fireEvent('runquery', rec.get('id'), rec);
    }
  },
  
  reload: function(){
    this.getStore().load();
  }
});
