Auidos.Auido = DS.Model.extend({
  data: DS.attr('number'),
  value: DS.attr('string'),

  isCompleted: DS.attr('boolean'),

  createdAt: function(){
    var d = new Date(0);
    d.setUTCSeconds(this.get('data'));
    return d.toUTCString();
  }.property('data'),

  href: function(){
    return(auidrome_url + 'tuits/' + this.get('value'));
  }.property('value')
});

$.getJSON(auidrome_url + 'auidos.json', function(data) {
  var last_stored_second = 0,
      last_stored_auido = Auidos.Auido.store.all('auido').get('lastObject');

  if(last_stored_auido != undefined) {
    last_stored_second = last_stored_auido.get('data');
  }

  $.each(data, function(key, val) {
    if(val.data > last_stored_second) {
      Auidos.Auido.store.createRecord('auido', val).save();
    }
  });
});

