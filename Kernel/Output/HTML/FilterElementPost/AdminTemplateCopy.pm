# --
# Copyright (C) 2017 - 2023 Perl-Services.de, https://www.perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::FilterElementPost::AdminTemplateCopy;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Output::HTML::Layout
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    # get template name
    my $Templatename = $Param{TemplateFile} || '';
    return 1 if !$Templatename;
    return 1 if !$Param{Templates}->{$Templatename};

    my $Baselink = $LayoutObject->{Baselink};
    my $Token    = $LayoutObject->{UserChallengeToken};
    my $Title    = $LayoutObject->{LanguageObject}->Translate("Copy Template");

    ${ $Param{Data} } =~ s{
        <a \s class="TrashCan .*? \s href=".*?ID=(\d+) .*? </a>\K
    }{
        $Self->__Linkify( $Baselink, $1, $Title, $Token );
    }exmsg;

    return 1;
}

sub __Linkify {
    my ($Self, $Baselink, $TemplateID, $Title, $Token ) = @_;

    my $Link = qq~
        | <a href="${Baselink}Action=AdminTemplateCopy&ID=$TemplateID&ChallengeToken=$Token" title="$Title">
             <span class="InvisibleText">$Title</span> <i class="fa fa-copy"></i></a>
    ~;

    return $Link;
}


1;
