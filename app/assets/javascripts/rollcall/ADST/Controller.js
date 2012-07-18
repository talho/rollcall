//TODO: Get file dependencies

Ext.namespace('Talho.Rollcall.ADST');

Talho.Rollcall.ADST.Controller = Ext.extend(Ext.util.Observable, {
  contstructor: function (config) {
 
    var layout = new Talho.Rollcall.view.Layout({
      title: "Advanced Disease Surveillance Tool",
      items: [this.index]
    });
    
    this.getPanel = function () {
      return layout;
    }
    
    //TODO: Set up index events
  }
});

Talho.ScriptManger.reg("Talho.Rollcall.ADST", Talho.Rollcall.ADST.Controller, function (config) {
  var cont = new Talho.Rollcall.ADST.Controller(config);
  return cont.getPanel();
});
