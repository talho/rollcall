Ext.namespace('Talho.Rollcall');

Talho.Rollcall.Schools = Ext.extend(function(){}, {
  constructor: function(config)
  {
    Ext.apply(this, config);
    Ext.apply(this,
    {
      layout:   'fit',
      closable: true,
      scope:    this,
      items:[{
        layout:     'border',
        autoScroll: true,
        scope:      this,
        defaults: {
          collapsible: true,
          split:       true
        },
        items: [{
          title:     'Schools',
          region:    'west',
          layout:    'fit',
          bodyStyle: 'padding:0px',
          width:     175,
          minSize:   150,
          maxSize:   175,
          hideBorders: true
        },{
          collapsible: false,
          region:      'center',
          autoScroll:  true,
          scope:       this
        }]
      }]
    });
  }
});

Talho.Rollcall.Schools.initialize = function(config)
{
  return new Talho.Rollcall.Schools(config);
}

Talho.ScriptManager.reg('Talho.Rollcall.Schools', Talho.Rollcall.Schools, Talho.Rollcall.Schools.initialize);
