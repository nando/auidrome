Auidos.EditAuidoView = Ember.TextField.extend({
  didInsertElement: function() {
    this.$().focus();
  }
});

Ember.Handlebars.helper('edit-auido', Auidos.EditAuidoView);

