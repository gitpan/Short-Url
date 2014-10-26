package Short::URL;
use strict;
use Mouse;
use List::Util qw//;
use Carp qw//;
#ABSTRACT: Encodes and Decodes short urls by using Bijection

has alphabet => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub {
        [qw/a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9/]
    },  
);

has shuffled_alphabet => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub {
        [qw/G w d A t H J 0 P o W C 6 3 y K 8 L u 7 X E O a e q 1 9 D c F x Z 5 M T N l z r i s j h B 4 b I f V Y Q g n S 2 m U k p v R/]
    },  
);

has use_shuffled_alphabet => (
    is => 'rw',
    isa => 'Any',
    default => undef,
);

has offset => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

sub alphabet_in_use { 
    my ($self) = @_;
    return $self->use_shuffled_alphabet ? $self->shuffled_alphabet : $self->alphabet;
}

sub encode { 
    my ($self, $i) = @_; 

    $i += $self->offset;
    return $self->alphabet_in_use->[0] if $i == 0;

    my $s = ''; 
    my $base = @{$self->alphabet_in_use};

    while($i > 0) {
        $s .= $self->alphabet_in_use->[$i % $base];
        $i = int($i / $base);
    }   

    reverse $s; 
}

sub decode { 
	my ($self, $s) = @_;
	
	my $i = 0;
	my $base = @{$self->alphabet_in_use};
	my $last_index = $#{$self->alphabet_in_use};
	
	for my $char (split //, $s) { 
		my ($index) = grep { $self->alphabet_in_use->[$_] eq $char } 0..$last_index;
		Carp::croak "invalid character $char in $s" unless defined($index);
		
		$i = $i * $base + $index;
	}

    $i -= $self->offset;

    Carp::croak "invalid string $s for offset @{[$self->offset]}. produces negative int: $i" if $i < 0;

	return $i;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Short::URL - Encodes and Decodes short urls by using Bijection

=head1 VERSION

version 0.001

=head1 SYNOPSIS

    use Short::URL;
    
    #use default alphabet
    my $su = Short::URL->new;

    my $encoded = $su->encode(10000);
    my $short_url = "http://www.example.com/$encoded";

    print "Encoded: $encoded\n"; #prints cP6
    print "Short url: $short_url\n"; #prints http://www.example.com/cP6

    my $decoded = $su->decode('cP6');

    print "Decoded: $decoded\n"; #prints 10000

    #set new alphabet
    $su->alphabet([qw/1 2 3 a b c/]);

    #or when you create the Short::URL object
    my $su = Short::URL(alphabet => [qw/1 2 3 a b c/]);

    #have an 'offset'. Meaning if you pass in integer $i, you get unique string for $i + offset
    $su->offset(10000);

    #or
    my $su = Short::URL(offset => 10000);

    my $encoded_with_offset = $su->encode(0);

    print "Encoded with offset: $encoded_with_offset\n"; #prints unique string for 10000, 'cP6'

    my $decoded_with_offset = $su->decode('cP6');

    print "Decoded with offset: $decoded_with_offset\n"; #prints 0

    #use shuffled alphabet
    $su->use_shuffled_alphabet(1);

    #or
    my $su = Short::URL(use_shuffled_alphabet => 1);

    my $encoded_with_shuffled_alphabet = $su->encode(10000);

    print "Encoded with shuffled alphabet: $encoded_with_shuffled_alphabet"; #prints 'dlu'

    my $decoded_with_shuffled_alphabet = $su->decode(10000);

    print "Decoded with shuffled alphabet: $decoded_with_shuffled_alphabet"; #prints 10000

=head1 DESCRIPTION

Short::URL can be used to help generate short, unique character string urls. It uses L<Bijection|http://en.wikipedia.org/wiki/Bijection> to
create a one-to-one mapping from integers to strings over your alphabet, and from strings over your alphabet back to the original integer. An integer
primary key in your database would be a good example of an integer you could use to generate a unique character string that maps uniquely to that row.

=head1 METHODS

=head2 alphabet

    $su->alphabet([qw/1 2 3 a b c/]);

The alphabet that will be used for creating strings when mapping an integer to a string. The default alphabet is:

   [qw/a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 0 1 2 3 4 5 6 7 8 9/]

All lower case letters, upper case letters, and digits 0-9.

=head2 encode

    my $encoded = $su->encode(1);

Takes an integer and encodes it into a unique string over your alphabet.

=head2 decode

    my $decoded = $su->decode('b');

Takes a string made from your alphabet and returns the corresponding integer that it maps to.

=head2 use_shuffled_alphabet

    $su->use_shuffled_alphabet(1);

    my $encoded_with_shuffled_alphabet = $su->encode(10000);

    print "Encoded with shuffled alphabet: $encoded_with_shuffled_alphabet"; #prints 'dlu'

Setting L</use_shuffled_alphabet> to 1 means that instead of using the more common alphabet used for this algorithm that is stored in L</alphabet>, L<Short::URL> will use a shuffled alphabet.
Note, this shuffled alphabet will be the same every time, so encoding and decoding will work even with the use_shuffled_alphabet set to 1 even in 
different sessions of using L<Short::URL>. This can be 
useful if for some reason you don't want people to know how many ids you have in your database. With the more standard alphabet it's clear when you are going
up by one between strings, and thus also how many ids you have. When used in combination with L</offset>, it is a lot harder to track what string would correspond
to what id in your databse, or how many ids you have in total. Below is the shuffled alphabet that is used:

    [qw/G w d A t H J 0 P o W C 6 3 y K 8 L u 7 X E O a e q 1 9 D c F x Z 5 M T N l z r i s j h B 4 b I f V Y Q g n S 2 m U k p v R/]

This is just a shuffled version of L</alphabet>. The default for L</use_shuffled_alphabet> is undef.

=head1 SEE ALSO

=over 4

=item

L<http://stackoverflow.com/a/742047/834140>

=item

L<https://gist.github.com/zumbojo/1073996>

=back

=head1 AUTHOR

Adam Hopkins <srchulo@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Adam Hopkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
