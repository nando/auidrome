Auidos.AuidosController = Ember.ArrayController.extend({
  actions: {
    clearCompleted: function() {
      var completed = this.filterBy('isCompleted', true);
      completed.invoke('deleteRecord');
      completed.invoke('save');
    },
    createAuido: function() {
      // Get the auido value set by the "New Auido" text field
      var value = this.get('newTitle');
      if (!value.trim()) { return; }

      // Create the new Auido model
      var auido = this.store.createRecord('auido', {
        value: value,
        isCompleted: false
      });

      // Clear the "New Auido" text field
      this.set('newTitle', '');

      // Save the new model
      auido.save();
    }
  },

  hasCompleted: function() {
    return this.get('completed') > 0;
  }.property('completed'),

  completed: function() {
    return this.filterBy('isCompleted', true).get('length');
  }.property('@each.isCompleted'),

  remaining: function() {
    return this.filterBy('isCompleted', false).get('length');
  }.property('@each.isCompleted'),
 
  allAreDone: function(key, value) {
    console.log("allAreDone key=>"+key+" value=>"+value);
    if (value === undefined) {
      return !!this.get('length') && this.isEvery('isCompleted', true);
    } else {
      this.setEach('isCompleted', value);
      this.invoke('save');
      return value;
    }

  }.property('@each.isCompleted'),

  inflection: function() {
    var remaining = this.get('remaining');
    return remaining === 1 ? 'item' : 'items';
  }.property('remaining')

});

