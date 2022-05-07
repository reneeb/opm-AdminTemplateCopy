# --
# Copyright (C) 2017 - 2022 Perl-Services.de, https://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Modules::AdminTemplateCopy;

use strict;
use warnings;

use Kernel::Language qw(Translatable);

our $ObjectManagerDisabled = 1;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ParamObject            = $Kernel::OM->Get('Kernel::System::Web::Request');
    my $LayoutObject           = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $StandardTemplateObject = $Kernel::OM->Get('Kernel::System::StandardTemplate');
    my $StdAttachmentObject    = $Kernel::OM->Get('Kernel::System::StdAttachment');

    # challenge token check for write action
    $LayoutObject->ChallengeTokenCheck();

    my ( %GetParam, %Errors );
    for my $Parameter (qw(ID)) {
        $GetParam{$Parameter} = $ParamObject->GetParam( Param => $Parameter ) || '';
    }

    my %Data = $StandardTemplateObject->StandardTemplateGet(
        ID => $GetParam{ID},
    );

    # check if a standard template exist with this name
    my $NameExists = 1;

    while( $NameExists ) {
        $Data{Name} .= ' (Copy)';
        $NameExists = $StandardTemplateObject->NameExistsCheck(
            Name => $Data{Name},
        );
    }

    my $TemplateID = $StandardTemplateObject->StandardTemplateAdd(
        %Data,
        UserID => $Self->{UserID},
    );

    # update group
    if ( $TemplateID ) {
        my %SelectedAttachmentData = $StdAttachmentObject->StdAttachmentStandardTemplateMemberList(
            StandardTemplateID => $GetParam{ID},
        );

        my %AttachmentsAll = $StdAttachmentObject->StdAttachmentList();

        # check all used attachments
        for my $AttachmentID ( sort keys %AttachmentsAll ) {
            my $Active = $SelectedAttachmentData{$AttachmentID} ? 1 : 0;

            # set attachment to standard template relation
            my $Success = $StdAttachmentObject->StdAttachmentStandardTemplateMemberAdd(
                AttachmentID       => $AttachmentID,
                StandardTemplateID => $TemplateID,
                Active             => $Active,
                UserID             => $Self->{UserID},
            );
        }
    }

    return $LayoutObject->Redirect(
        OP => 'Action=AdminTemplate',
    );
}

1;
