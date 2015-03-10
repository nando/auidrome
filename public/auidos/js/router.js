Auidos.Router.map(function() {
  this.resource('auidos', { path: '/' }, function(){

    this.route('active');

    this.route('completed');

  });
});

Auidos.AuidosRoute = Ember.Route.extend({
  model: function() {
    return this.store.find('auido');
  }
});

Auidos.AuidosIndexRoute = Ember.Route.extend({
  model: function() {
    return this.modelFor('auidos');
  }
});

Auidos.AuidosActiveRoute = Ember.Route.extend({
  model: function(){
    return this.store.filter('auido', function(auido) {
      return !auido.get('isCompleted');
    });
  },
  renderTemplate: function(controller) {
    this.render('auidos/index', {controller: controller});
  }
});

Auidos.AuidosCompletedRoute = Ember.Route.extend({
  model: function() {
    return this.store.filter('auido', function(auido) {
      return auido.get('isCompleted');
    });
  },
  renderTemplate: function(controller) {
    this.render('auidos/index', {controller: controller});
  }
});

