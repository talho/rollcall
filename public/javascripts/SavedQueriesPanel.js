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
        fields: ['saved_queries'],        
        url:    '/rollcall/save_query',
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
                    html: '<div style="text-align:center"><img src="/images/school_absenteeism.png" /></div>'
                  }]
                });
                this.doLayout();
              }
            }
          }
        }
      })
      
//      items:[{
//        columnWidth: .25,
//        listeners:{
//          scope: this
//        },
//        items:[{
//          title: 'Saved Query(1)',
//          style:{
//            marginRight: '5px',
//            top: '-5px'
//          },
//          autoWidth: true,
//          autoHeight: true,
//          html: '<div style="text-align:center"><img src="/images/school_absenteeism.png" /></div>'
//        }]
//      },{
//        columnWidth: .25,
//        listeners:{
//          scope: this
//        },
//        items:[{
//          title: 'Saved Query(2)',
//          style:{
//            marginRight: '5px',
//            top: '-5px'
//          },
//          autoWidth: true,
//          autoHeight: true,
//          html: '<div style="text-align:center"><img src="/images/school_absenteeism_berry.png" /></div>'
//        }]
//      },{
//        columnWidth: .25,
//        listeners:{
//          scope: this
//        },
//        items:[{
//          title: 'Saved Query(3)',
//          style:{
//            marginRight: '5px',
//            top: '-5px'
//          },
//          autoWidth: true,
//          autoHeight: true,
//          html: '<div style="text-align:center"><img src="/images/school_absenteeism_lewis.png" /></div>'
//        }]
//      },{
//        columnWidth: .25,
//        listeners:{
//          scope: this
//        },
//        items:[{
//          title: 'Saved Query(4)',
//          style:{
//            marginRight: '5px',
//            top: '-5px'
//          },
//          autoWidth: true,
//          autoHeight: true,
//          html: '<div style="text-align:center"><img src="/images/school_absenteeism_south.png" /></div>'
//        }]
//      }]
    });

    Talho.Rollcall.SavedQueriesPanel.superclass.constructor.call(this, config);
  },
  updateSavedQueries: function(){
    this.saved_store.load();
  }
});