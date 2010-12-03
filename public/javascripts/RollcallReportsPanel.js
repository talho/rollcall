Ext.namespace('Talho.Rollcall');
Ext.namespace('Talho.Rollcall.ux');

Talho.Rollcall.RollcallReportsPanel = Ext.extend(Ext.grid.GridPanel, {
  constructor: function(config){
    // sample static data for the store
    var myData = [
        ['Bellaire High School'],
        ['Berry Elementary'],
        ['Lewis Elementary'],
        ['Southmayd Elementary'],
        ['Woodson Middle School']
    ];
    // create the data store
    var store = new Ext.data.ArrayStore({
        fields: [
           {name: 'school'}
        ]
    });
    // manually load local data
    store.loadData(myData);
    Ext.applyIf(config, {
      store: store,
      columns: [
          {id:'school', header: 'School', width: 160, sortable: true, dataIndex: 'school'},
          {
            xtype: 'actioncolumn',
            width: 50,
            items: [{
              iconCls: 'rollcall_pdf_icon',
              tooltip: 'Download Report',
              handler: function(grid, rowIndex, colIndex) {
                  var rec = store.getAt(rowIndex);
                  alert("Download " + rec.get('school') + " PDF");
              }
            }]
          }
      ],
      stripeRows: true,
      autoExpandColumn: 'school',
      autoHeight: true,
      autoWidth: true,
      // config options for stateful behavior
      stateful: true,
      stateId: 'grid'
    });
    //Ext.apply(this, config);
    Talho.Rollcall.RollcallReportsPanel.superclass.constructor.call(this, config);
  }
});