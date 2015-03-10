Auidos.Auido = DS.Model.extend({
  sec: DS.attr('number'),
  title: DS.attr('string'),

  isCompleted: DS.attr('boolean'),

  createdAt: function(){
    var d = new Date(0);
    d.setUTCSeconds(this.get('sec'));
    return d.toUTCString();
  }.property('sec'),

  href: function(){
    return(auidrome_url + 'tuits/' + this.get('title'));
  }.property('title')
});

$.getJSON(auidrome_url + 'auidos.json', function(data) {
  var last_stored_second = 0,
      last_stored_auido = Auidos.Auido.store.all('auido').get('lastObject');

  if(last_stored_auido != undefined) {
    last_stored_second = last_stored_auido.get('sec');
  }

  $.each(data, function(key, val) {
    if(val.sec > last_stored_second) {
      Auidos.Auido.store.createRecord('auido', val).save();
    }
  });
});

