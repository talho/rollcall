//= require d3

(function(){
  Rollcall = window.Rollcall || {}

  Rollcall.GraphView = Backbone.View.extend({
    template: HandlebarsTemplates['graph'],

    render: function(){
      this.$el.html(this.template(this.model.attributes));

      // render d3 here
    }
  });
})();
