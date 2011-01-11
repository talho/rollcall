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
            var result_obj = null;
            var column_obj = null;
            for(var i=0;i<record.length;i++){
              for(var cnt=0;cnt<record[i].data.saved_queries.length;cnt++){
                column_obj = this.add({
                  columnWidth: .25,
                  listeners:{
                    scope: this
                  }
                });
                result_obj = column_obj.add({
                  title: record[i].data.saved_queries[cnt].saved_query.name,
                  tools: [{
                    id:'save',
                    qtip: 'Edit Query'
                  }],
                  cls: 'ux-saved-graphs',
                  //autoWidth: true,
                  //autoHeight: true,
                  html: '<div class="ux-saved-graph-container"><img class="ux-ajax-loader" src="/images/Ajax-loader.gif" /></div>'
                });
                this.ownerCt.ownerCt.renderGraphs(cnt, record[i].data.img_urls.image_urls[cnt], result_obj, 'ux-saved-graph-container');
              }
            }
            this.doLayout();
            this.setSize('auto','auto');
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