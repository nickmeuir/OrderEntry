package OrderEntry;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
  my $self = shift;

  # Load configuration from hash returned by "my_app.conf"
  my $config = $self->plugin('Config');

  # Documentation browser under "/perldoc"
  $self->plugin('PODRenderer') if $config->{perldoc};

  # Router
  my $r = $self->routes;

  # Normal route to controller
  
  $r->get('/')->to('order#home');
  
  $r->get('/orders')->to('order#orders');
  
  $r->get('/new')->to('order#new');
  $r->post('/new_order')->to('order#new_post');
  
  $r->get('/order/:id')->to('order#order');

  $r->post('/delete')->to('order#delete_post');

  $r->get('/items')->to('order#items');

  $r->websocket('/additem')->to('order#additem');
}

1;
