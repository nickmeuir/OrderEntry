package OrderEntry::Controller::Order;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Log;
use DBI;
use JSON;

my $log = Mojo::Log->new;

my $dbh = DBI->connect('dbi:SQLite:dbname=orders.db','','',{AutoCommit=>1,RaiseError=>1,PrintError=>0});


# This action will render a template
sub home {
    
    my $self = shift;
    
    $self->render(msg => '');
    
}


sub orders {
    my $self = shift; 

    my $sth = $dbh->prepare("SELECT * FROM orders");
    $sth->execute();

    $self->render(orders => $sth->fetchall_arrayref());
}

sub order {
    my $self = shift;

    my $orderno = $self->stash('id');
    
    my $sth = $dbh->prepare("SELECT items.partno, items.description, items_list.qty FROM items INNER JOIN items_list ON items.partno = items_list.partno WHERE items_list.orderno = $orderno;");
    $sth->execute();
    
    $self->render(orderno => $orderno, item_list => $sth->fetchall_arrayref());
}

sub new_post {
    my $self = shift;

    my $name = $self->req->param('name');
    
    my $sth = $dbh->prepare("INSERT INTO orders (name) VALUES('$name')");
    $sth->execute();
    
    $self->redirect_to('orders');
}

sub delete_post {
    my $self = shift;

    my $id = $self->req->param('id');

    
    my $sth = $dbh->prepare("DELETE FROM orders WHERE id = $id");
    $sth->execute();

    $self->redirect_to('orders');
}

sub items {
    my $self = shift;

    my $sth = $dbh->prepare("SELECT * FROM items");
    $sth->execute();
    
    $self->render(items => $sth->fetchall_arrayref());
}

sub additem {
    my $self = shift;

    $self->on(message => sub {
	my ($self, $data) = @_;

	my @splitdata = split('!', $data);

	$log->debug($splitdata[0]);
	
	my $sth = $dbh->prepare(qq/SELECT * FROM items WHERE PARTNO = '$splitdata[0]'/);
	$sth->execute();

	my @row = @{$sth->fetchrow_arrayref()};

	my ($id, $partno, $partdesc) = @row;

	if(@row) {

	    $sth = $dbh->prepare("INSERT INTO items_list (ORDERNO, PARTNO, QTY) VALUES($splitdata[2], '$partno', $splitdata[1])");
	    $sth->execute();
	    
	    $self->send( { json => { partno => $partno, partdesc => $partdesc, partqty => $splitdata[1] } } );
	}
        
	      });
}

1;
