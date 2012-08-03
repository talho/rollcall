
Ext.namespace("Talho.Rollcall.ADST.view");

Talho.Rollcall.ADST.view.AlarmQueries = Ext.extend(Ext.DataView, {
  initComponent: function () {
    // Build a store to get all of the 
    this.store = new Ext.data.JsonStore({
      url: '/rollcall/alarm_query',
      root: 'results',
      fields: ['id', 'user_id', 'name', 'query_params', {name: 'query_param_array', mapping: 'query_params', convert: function(v, rec){
        var params = Ext.decode(v),
            param_array = [];
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
        '<div class="rollcall-query-holder" style="float:left;height:100%;border:1px solid black;border-radius:3px;position:relative;">',
          '<h2 class="rollcall-query-name" style="text-align:center;padding:2px">{name}</h2>',
          '<table style="overflow-y:scroll;padding:2px;position:absolute;bottom:0;right:0;top:16px;">',
            '<tpl for="query_param_array">',
              '<tr>',
                '<td>{key}</td>  <td>{value}</td>',
              '</tr>',
            '</tpl>',
          '</table>',
        '</div>',
      '</tpl>'
    );
    Talho.Rollcall.ADST.view.AlarmQueries.superclass.initComponent.apply(this, arguments);        
  }
});
