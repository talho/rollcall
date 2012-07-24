//TODO: Require Files

Ext.namespace("Talho.Rollcall.ADST.view");

//TODO fix type
Talho.Rollcall.ADST.view.ResultsLegend = Ext.extend(Ext.Container, {

  constructor: function (config) {
    Talho.Rollcall.ADST.view.ResultsLegend.superclass.constructor.apply(this, config);
    
    this.buttons = [
      //TODO move handlers up to controller
      {text: "Submit", hidden: true, itemId: 'submit_ext4', handler: this._submitQuery, formBind: true},
      {text: "Reset Form", scope: this, hidden: true, handler: this._resetForm},
      {text: "Export Result Set", hidden: true, scope: this, handler: this._exportResultSet},
      {text: "Create Alarm from Result Set", hidden: true, scope: this, handler: this.saveResultSet},
      {text: "Generate Report from Result Set", hidden: true, scope: this,
        handler: function (buttonObj, eventObj) {
          this._showReportMenu(buttonObj.getEl(), null);
        }
      }
    ];
    
    html: '<div id="graph_legend" style="margin-top:4px;display:none;">' +
      '<div style="float:left;margin-left:8px;margin-right:20px">Legend:&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#99BBE8">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Raw&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#FF6600">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Average&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#0666FF">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Average 30 Day&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#660066">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Average 60 Day&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#006600">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Standard Deviation&nbsp;</div>' +
      '<div style="float:left;margin-right:20px"><span style="background-color:#FF0066">&nbsp;&nbsp;&nbsp;&nbsp;</span>&nbsp;Cusum&nbsp;</div>' +
      '</div>';
  }
});