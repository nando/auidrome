Auidos.AuidoController = Ember.ObjectController.extend({

  actions: {
    editAuido: function() {
      this.set('isEditing', true);
    },

    acceptChanges: function() {
      this.set('isEditing', false);
  
      if (Ember.isEmpty(this.get('model.value'))) {
        this.send('removeAuido');
      } else {
        this.get('model').save();
      }
    },
    removeAuido: function () {
      var auido = this.get('model');
      auido.deleteRecord();
      auido.save();
    }

  },

  isEditing: false,

  isCompleted: function(key, value){
    var model = this.get('model');

    if (value === undefined) {
      // property being used as a getter
      return model.get('isCompleted');
    } else {
      // property being used as a setter
      model.set('isCompleted', value);
      model.save();
      return value;
    }
  }.property('model.isCompleted')
});

