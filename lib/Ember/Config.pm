package Ember::Config;

=head1 NAME

Ember::Config - Configuration handling for Ember.

=head1 SYNOPSIS

use Ember::Config;

my $config = Ember::Config->open();

=head1 DESCRIPTION

This class handles configuration data for Ember via platform-specific
subclasses.

=cut

use strict;
use warnings;
use fields qw( dir );

=head2 Fields

=over

=item dir

The configuration directory.

=back

=head2 Class Methods

=over

=item new()

Create a configuration instance. Will fail if not called on a subclass; instead
use the open() method to automatically create the correct object.

=cut

sub new {
    my ($self) = @_;

    $self = fields::new($self) unless (ref($self));

    return $self if ($self->_open());
}

=item open()

Create and return a confifiguration instance of the appropriate
platform-specific subclass.

=cut

sub open {
    if ($^O eq 'darwin') {
        require Ember::Config::MacOS;
        return Ember::Config::MacOS->new();
    } elsif ($^O eq 'MSWin32') {
        require Ember::Config::Windows;
        return Ember::Config::Windows->new();
    } else {
        require Ember::Config::UNIX;
        return Ember::Config::UNIX->new();
    }
}

=back

=head2 Instance Methods

=over

=item _open()

Subclasses must implement this to open the configuration. Should return a true
value on success.

=cut

sub _open {
    die('Cannot directly instantiate Ember::Config');
}

=item get_pos($filename)

Fetch the last reading position for a given eBook filename.

=cut

sub get_pos {
    my ($self, $filename) = @_;
    my $qfn = quotemeta($filename);
    my $file = $self->{dir} . '/position.txt';

    return unless (-e $file);

    CORE::open(IN, '<', $file);

    while (defined(my $line = <IN>)) {
        if ($line =~ /^$qfn\t(.+?)\t(\d+)$/) {
            my %result = ( chapter => $1, pos => $2 );
            close(IN);
            return %result;
        }
    }

    close(IN);

    return;
}

=item set_pos($reader)

Save the last reading position for a given eBook reader instance.

=cut

sub save_pos {
    my ($self, $reader) = @_;
    my $file = $self->{dir} . '/position.txt';
    my $tmp = $self->{dir} . '/position.tmp';
    my $filename = $reader->{book}{filename};
    my $qfn = quotemeta($filename);

    CORE::open(IN, '<', $file);
    CORE::open(OUT, '>', $tmp);
    # TODO PI line endings?
    print OUT $filename, "\t", $reader->{chapter}{path}, "\t", $reader->{pos}, "\n";

    while (defined(my $line = <IN>)) {
        print OUT $line unless ($line =~ /^$qfn\t/);
    }

    close(OUT);
    close(IN);

    unlink($file);
    rename($tmp, $file);
}

=back

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
