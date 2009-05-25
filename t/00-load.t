use Test::More tests => 16;

BEGIN {
    use_ok 'Business::Qiwi';
    use_ok 'Business::Qiwi::Request';
    use_ok 'Business::Qiwi::MooseSubtypes';
    
    use_ok 'Business::Qiwi::Bill';
    use_ok 'Business::Qiwi::Bill::Status';
    use_ok 'Business::Qiwi::Bill::Accept';
    use_ok 'Business::Qiwi::Bill::Reject';
    
    use_ok 'Business::Qiwi::Payment';
    use_ok 'Business::Qiwi::Payment::Status';
    use_ok 'Business::Qiwi::Payment::Incoming';
    
    
    use_ok 'Business::Qiwi::PhoneBook';
    use_ok 'Business::Qiwi::PhoneBook::Add';
    use_ok 'Business::Qiwi::PhoneBook::Delete';
    
    use_ok 'Business::Qiwi::Report';
    use_ok 'Business::Qiwi::Balance';
    use_ok 'Business::Qiwi::Registration';
}
