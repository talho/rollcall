//= require_tree ./view
//= require ext_extensions/YouTubeList
//= require ext_extensions/YouTubePlayer

Ext.namespace('Talho.Rollcall.tutorial');

Talho.Rollcall.tutorial.Controller = Ext.extend(Ext.util.Observable, {
  constructor: function () {
    this.layout = new Talho.Rollcall.tutorial.view.Layout();
    
    this.getPanel = function () {
      return this.layout;
    }
    
    this.layout.on({
      'loadvideo': this._loadVideo,
      scope: this
    });
    
    Talho.Rollcall.tutorial.Controller.superclass.constructor.apply(this, arguments);
  },
  
  _loadVideo: function (videoUrl, autoplay) {
    this.layout.loadVideo(videoUrl, autoplay);
  }
});

Talho.ScriptManager.reg("Talho.Rollcall.Tutorial", Talho.Rollcall.tutorial.Controller, function (config) {
  var cont = new Talho.Rollcall.tutorial.Controller(config);
  return cont.getPanel();
});
