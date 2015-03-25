//= require underscore
//= require backbone
//= require handlebars.runtime
//= require_tree ./templates
//= require_tree ./views

(function(){
  var self;

  Rollcall = window.Rollcall || {};
  Rollcall.Graphing = function(){

  };

  Rollcall.Graphing.prototype = {
    params: null,

    draw_school: function(id){
      this.draw('/graphing/' + id + '/school');
    },

    draw_school_district: function(id){
      this.draw('/graphing/' + id + '/school_district');
    },

    draw: function(url){
      var m = new Backbone.Model(),
          v = new Rollcall.GraphView({model: m});
      $('#graph-holder').append(v.el);
      $.get(url, this.params).then(function(data){
        m.set(data);
        v.render();
      });
    }
  }

  Rollcall.Graphing.init = function(opts){
    if(!self){
      self = new Rollcall.Graphing();
    }

    self.params = opts.params;

    _(opts.entities).each(function(s){
      if(opts.type === 'school'){
        self.draw_school(s);
      } else {
        self.draw_school_district(s);
      }
    });
  }
})();
