package Ember::Config;

=head1 NAME

Ember::Config - Configuration handling for Ember.

=head1 SYNOPSIS

use Ember::Config;

my $config = Ember::Config->open();

=head1 DESCRIPTION

This is an abstract superclass for objects which handle configuration data for
Ember.

=cut

use 5.008;
use strict;
use warnings;
use fields qw( db db_file );

use DB_File;
use DBM_Filter;
use File::Spec;

use Ember::Metadata;
use Ember::Util;

=head2 Fields

=over

=item db

The configuration database as a tied hash.

=item db_file

The underlying DB_File object.

=back

=head2 Class Methods

=over

=item new($dir)

Create a configuration instance using the given directory. Normally, you should
simply use the open() method to create a platform-specific instance.

=cut

sub new {
    my ($class, $dir) = @_;
    my $self = fields::new($class);
    my $file = File::Spec->join($dir, 'ember.db');
    my %db;

    $self->{db} = \%db;
    $self->{db_file} = tie(%db, 'DB_File', $file);
    $self->{db_file}->Filter_Push('utf8');

    return $self;
}

=item open()

Create and return a confifiguration instance of the appropriate
platform-specific subclass.

=cut

sub open {
    my ($class) = @_;
    my $os = 'UNIX';

    if ($^O eq 'darwin') {
        $os = 'MacOS';
    } elsif ($^O eq 'MSWin32') {
        $os = 'Windows';
    }

    $class = get_class('Config', $os);

    return $class->new();
}

=back

=head2 Instance Methods

=over

=item get_id($path)

Fetch the Ember ID for the book at the given file path. In a list context, may
return a second value which indicates that the ID was newly created.

=cut

sub get_id {
    my ($self, $path) = @_;
    my $id = $self->{db}->{"id:$path"};

    return $id if ($id);

    $id = ($self->{db}->{last_id} || 0) + 1;

    $self->{db}->{last_id} = $id;
    $self->{db}->{"id:$path"} = $id;
    $self->{db}->{"$id:path"} = $path;

    return wantarray ? ($id, 1) : $id;
}

=item get_filename($id)

Fetch the filename for a given Ember book ID.

=cut

sub get_filename {
    my ($self, $id) = @_;

    return $self->{db}->{"$id:path"};
}

=item get_pos($id)

Fetch the last chapter and reading position for a given eBook.

=cut

sub get_pos {
    my ($self, $id) = @_;

    return ($self->{db}->{"$id:chapter"}, $self->{db}->{"$id:pos"});
}

=item save_pos($id, $chapter, $pos)

Save the last reading position for a book.

=cut

sub save_pos {
    my ($self, $id, $chapter, $pos) = @_;

    $self->{db}->{"$id:chapter"} = $chapter;
    $self->{db}->{"$id:pos"} = $pos;
}

=item get_recent()

Fetch a list of recently-viewed books. Returns an array of book IDs.

=cut

sub get_recent {
    my ($self) = @_;

    return split(',', $self->{db}->{recent} || '');
}

=item add_recent($id)

Add an entry for the given book to the recents list.

=cut

sub add_recent {
    my ($self, $id) = @_;
    my @recent = $self->get_recent();
    my $count = @recent;

    return if (($count > 0) && ($recent[0] == $id));

    for (my $i = 1; $i < $count; $i++) {
        if ($recent[$i] == $id) {
            splice(@recent, $i, 1);
            last;
        }
    }

    unshift(@recent, $id);
    $self->{db}->{recent} = join(',', @recent);
}

=item get_metadata($id [, @fields])

Fetch metadata for a book. If I<@fields> is given, returns an array with the
values of those fields, otherwise, returns an L<Ember::Metadata> object for the
book.

=cut

sub get_metadata {
    my ($self, $id, @fields) = @_;
    my ($metadata, @values);
    my $db = $self->{db};

    if (!@fields) {
        @fields = @Ember::Metadata::FIELDS;
        $metadata = Ember::Metadata->new();
    }

    foreach my $field (@fields) {
        my $type = $Ember::Metadata::TYPES{$field};
        my $value = $db->{"$id:$field"};

        if ($type eq 'array') {
            $value = defined($value) ? [ split(/\0/, $value) ] : [];
        } elsif ($type eq 'hash') {
            $value = defined($value) ? { split(/\0/, $value) } : {};
        } elsif (!defined($value)) {
            $value = '';
        }

        if ($metadata) {
            $metadata->{$field} = $value;
        } else {
            push(@values, $value);
        }
    }

    return $metadata ? $metadata : @values;
}

=item set_metadata($id, $metadata)

Set the metadata for a book.

=cut

sub set_metadata {
    my ($self, $id, $metadata) = @_;
    my $db = $self->{db};

    foreach my $field (@Ember::Metadata::FIELDS) {
        my $value = $metadata->{$field};
        my $key = "$id:$field";

        if (defined($value)) {
            my $type = $Ember::Metadata::TYPES{$field};
            my $ref = ref($value);

            if ($type eq 'array') {
                if ($ref eq 'ARRAY') {
                    $value = join('\0', map {
                        defined($_) ? $_ : ''
                    } @{$value});
                } else {
                    undef($value);
                }
            } elsif ($type eq 'hash') {
                if ($ref eq 'HASH') {
                    $value = join('\0', map {
                        defined($_) ? $_ : ''
                    } %{$value});
                } else {
                    undef($value);
                }
            } elsif ($ref || ($value eq '')) {
                undef($value);
            }
        }

        if (defined($value)) {
            $db->{$key} = $value;
        } elsif (exists($db->{$key})) {
            delete($db->{$key});
        }
    }
}

=back

=head1 SEE ALSO

L<Ember::Metadata>

=head1 AUTHOR

Mark Rigby-Jones <mark@rigby-jones.net>

=cut

1;
