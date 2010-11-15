Ext.namespace('Talho.ux.rollcall');

Talho.ux.rollcall.RollcallSavedQueriesPanel = Ext.extend(Ext.ux.Portal, {
  constructor: function(config){
    Ext.applyIf(config, {
      itemId: 'portalId_south',
      border: false,
      items:[{
        columnWidth: .25,
        listeners:{
          scope: this
        },
        items:[{
          title: 'Saved Query(1)',
          style:{
            marginRight: '5px',
            top: '-5px'
          },
          autoWidth: true,
          autoHeight: true,
          html: '<div style="text-align:center"><img src="/images/school_absenteeism.png" /></div>'
        }]
      },{
        columnWidth: .25,
        listeners:{
          scope: this
        },
        items:[{
          title: 'Saved Query(2)',
          style:{
            marginRight: '5px',
            top: '-5px'
          },
          autoWidth: true,
          autoHeight: true,
          html: '<div style="text-align:center"><img src="/images/school_absenteeism_berry.png" /></div>'
        }]
      },{
        columnWidth: .25,
        listeners:{
          scope: this
        },
        items:[{
          title: 'Saved Query(3)',
          style:{
            marginRight: '5px',
            top: '-5px'
          },
          autoWidth: true,
          autoHeight: true,
          html: '<div style="text-align:center"><img src="/images/school_absenteeism_lewis.png" /></div>'
        }]
      },{
        columnWidth: .25,
        listeners:{
          scope: this
        },
        items:[{
          title: 'Saved Query(4)',
          style:{
            marginRight: '5px',
            top: '-5px'
          },
          autoWidth: true,
          autoHeight: true,
          html: '<div style="text-align:center"><img src="/images/school_absenteeism_south.png" /></div>'
        }]
      }]
    });

    Talho.ux.rollcall.RollcallSavedQueriesPanel.superclass.constructor.call(this, config);
  }
});