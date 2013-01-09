
Ext.namespace("Talho.Rollcall.alarm.view.alarmquery");

Talho.Rollcall.alarm.view.alarmquery.Index = Ext.extend(Ext.Panel, { 
  layout: 'fit',
  title: 'Alarm Queries',
  
  initComponent: function () {
    var tpl = new Ext.XTemplate(
      '<ul>',
        '<tpl for=".">',
          '<li class="rollcallalarmquery-click" queryid="{id}"><div>',
            '<h3>{name}</h3>',
            '<table>',
              '<tpl for="alarm_info_array">',
                '<tr><td>{key}: </td><td>{value}</td></tr>',
              '</tpl>',                          
            '</table>',      
          '</div></li>',
        '</tpl>',
      '</ul>'
    );
    
    var store = new Ext.data.JsonStore({
      url: '/rollcall/alarm_query',
      root: 'results',
      fields: ['id', 'user_id', 'name', 'alarm_set', 'deviation_min', 'deviation_max', 'severity_min', 'severity_max', 'query_params', 'schools', 
        {name: 'query_param_array', mapping: 'query_params', 
          convert: function(v, rec){
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
          }
        }, 
        {name: 'alarm_info_array', mapping: 'query_params', 
          convert: function(v, rec){
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
          }
        }
      ],
      autoLoad: true,
      autoDestroy: true
    });
    
    var indexView = new Ext.DataView({
      store: store,
      tpl: tpl,
      listeners: {
        'click': {
          fn: function (div, index, node, e) {
            if (node.classList.contains('rollcallalarmquery-click')) {
              this.fireEvent('queryclick', parseInt(node.attributes['queryid'].value));
            }
          }
        }
      }      
    });
    
    this.items = [
      indexView
    ];
    
    Talho.Rollcall.alarm.view.alarmquery.Index.superclass.initComponent.call(this);
  }
});