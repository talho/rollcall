Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.SavedQueriesPanel = Ext.extend(Ext.ux.Portal, {
  constructor: function(config){
    var savedQueryStore = new Talho.Rollcall.ADSTResultPanel({});
    this.getResultPanel = function() {
      return resultPanel;
    }
    Ext.applyIf(config, {
      itemId: 'portalId_south',
      border: false,
      saved_store: new Ext.data.JsonStore({
        autoLoad: true,
        root:   'results',
        fields: ['id', 'saved_queries', 'img_urls'],
        proxy: new Ext.data.HttpProxy({
          url: '/rollcall/save_query',
          method:'get'
        }),
        listeners:{
          scope: this,
          load: function(this_store, record){
            for(var i=0;i<record.length;i++){
              for(var cnt=0;cnt<record[i].data.saved_queries.length;cnt++){
                this.add({
                  columnWidth: .25,
                  listeners:{
                    scope: this
                  },
                  items:[{
                    title: record[i].data.saved_queries[cnt].saved_query.name,
                    style:{
                      marginRight: '5px',
                      top: '-5px'
                    },
                    autoWidth: true,
                    autoHeight: true,
                    html: '<div style="text-align:center"><img style="width:400px;height:70px;" src="'+record[i].data.img_urls.image_urls[cnt]+'" /></div>'
                  }]
                });
                this.doLayout();
              }
            }
          }
        }
      })
    });

    Talho.Rollcall.SavedQueriesPanel.superclass.constructor.call(this, config);
  },
  updateSavedQueries: function(r_id){
    var options = {
      params: {
        r_id: r_id
      }
    }
    this.saved_store.load(options);
  }
});