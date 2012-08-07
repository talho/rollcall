
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
      }}, {name: 'alarm_info_array', mapping: 'query_params', convert: function(v, rec){
        var params,
            param_array = [];
        try{
          params = Ext.decode(v);
        }
        catch(e){}
        
        param_array.push({key: 'deviation_min', value: rec.deviation_min});
        param_array.push({key: 'deviation_max', value: rec.deviation_max});
        param_array.push({key: 'severity_min', value: rec.severity_min});
        param_array.push({key: 'severity_max', value: rec.severity_max});
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
        '<div class="rollcall-query-holder">',
          '<div class="rollcall-query-header">',
            '<div class="rollcall-tool-holder">',
              '<div class="x-tool x-tool-close" qtip="Delete Alarm Query"></div>',
              '<div class="x-tool x-tool-gear" qtip="Edit Alarm Query"></div>',
              '<div class="x-tool {[values.alarm_set ? "x-tool-alarm-on" : "x-tool-alarm-off"]}" qtip="Toggle Alarm State"></div>',
              '<div class="x-tool x-tool-run-query" qtip="Run Query"></div>',
            '</div>',
            '<span class="rollcall-query-name">{name}</span>',
          '</div>',
          '<div class="rollcall-query-detail-holder">',
            '<table class="rollcall-query-detail-table">',
              '<tbody>',
              '<tpl for="alarm_info_array">',
                '<tr class="rollcall-query-detail-row">',
                  '<td class="rollcall-query-column-1">{key}</td>',
                  '<td class="rollcall-query-column-2">{value}</td>',
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
