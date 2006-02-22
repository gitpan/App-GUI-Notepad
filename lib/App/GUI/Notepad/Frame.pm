package App::GUI::Notepad::Frame;

use strict;
use File::Spec  ();
use base qw/Wx::Frame/;
use Wx          qw/:allclasses wxTE_MULTILINE wxID_OK wxSAVE wxOK wxCENTRE wxFONTENCODING_SYSTEM wxMODERN wxNORMAL wxNullColour wxSWISS wxTE_RICH/;
use Wx::Event   qw/EVT_MENU/;


use App::GUI::Notepad::MenuBar;

use vars qw{$VERSION};
BEGIN {
	$VERSION = '0.01';
}

sub new {
	my ($class) = shift;
	my ($title, $position, $size) = @_;
	my ($this) = $class->SUPER::new( undef, -1, $title, $position, $size );
	$this->SetIcon( Wx::GetWxPerlIcon() );

	$this->{menubar} = App::GUI::Notepad::MenuBar->new();
	$this->SetMenuBar( $this->{menubar}->menubar() );

	EVT_MENU( $this, $this->{menubar}->{ID_NEW},    \&_menu_new    );
	EVT_MENU( $this, $this->{menubar}->{ID_OPEN},   \&_menu_open   );
	EVT_MENU( $this, $this->{menubar}->{ID_SAVE},   \&_menu_save   );
	EVT_MENU( $this, $this->{menubar}->{ID_SAVEAS}, \&_menu_saveas );
	EVT_MENU( $this, $this->{menubar}->{ID_CLOSE},  \&_menu_close  );
	EVT_MENU( $this, $this->{menubar}->{ID_EXIT},   \&_menu_exit   );
	EVT_MENU( $this, $this->{menubar}->{ID_UNDO},   \&_menu_undo   );
	EVT_MENU( $this, $this->{menubar}->{ID_REDO},   \&_menu_redo   );
	EVT_MENU( $this, $this->{menubar}->{ID_CUT},    \&_menu_cut    );
	EVT_MENU( $this, $this->{menubar}->{ID_COPY},   \&_menu_copy   );
	EVT_MENU( $this, $this->{menubar}->{ID_PASTE},  \&_menu_paste  );
	EVT_MENU( $this, $this->{menubar}->{ID_ABOUT},  \&_menu_about  );
	# Create the main text control
	$this->{textctrl} = Wx::TextCtrl->new(
		$this,
		-1,
		"", 
	        [ 0, 0 ], 
		[ 100, 100 ],
		wxTE_MULTILINE | wxTE_RICH,
		);

	my $font = Wx::Font->new(10, wxMODERN, wxNORMAL, wxNORMAL, 0, "Courier New");

	my $black = Wx::Colour->new(255,255,255);
	my $white = Wx::Colour->new(0,0,0);
	my $textattr = Wx::TextAttr->new($white, $black, $font);

	$this->{textctrl}->SetDefaultStyle($textattr);

	$this->CreateStatusBar(2);
	return $this;
}

sub _menu_new {
	my ($this) = @_;
	$this->SetTitle("Perlpad");
	$this->{textctrl}->SetValue("");
	$this->{filename} = "";
	return 1;
}

sub _menu_open {
	my ($this) = @_;
	my $opendialog = Wx::FileDialog->new($this, "Choose a file to open", "", "", "*.*", 0, [0,0]);
	my $result = $opendialog->ShowModal();
	if ($result == wxID_OK) { 
		$this->{filename} = File::Spec->catfile(
			$opendialog->GetDirectory(), $opendialog->GetFilename()
			);
		$this->{textctrl}->LoadFile( $this->{filename} );

		$this->SetTitle( "Perlpad - " . $this->{filename} );
	}
}

sub _menu_exit {
	exit(0);
}



sub _menu_save {
	my ($this) = @_;
	#print "Save\n";
	#print $this->{filename};
	$this->{textctrl}->SaveFile( $this->{filename} );
	return 1;
}

sub _menu_saveas {
	my ($this) = @_;
	print "SaveAs\n";
	print $this->{filename};
	my $saveasdialog = Wx::FileDialog->new($this, "Choose a file name and location to save to", "", "", "*.*", wxSAVE, [0,0]);
	my $result = $saveasdialog->ShowModal();
	if ($result == wxID_OK) {
		$this->{textctrl}->SaveFile(File::Spec->catfile($saveasdialog->GetDirectory(), $saveasdialog->GetFilename()));
		$this->{filename} = File::Spec->catfile($saveasdialog->GetDirectory(), $saveasdialog->GetFilename());
		$this->SetTitle("Perlpad - " . $this->{filename});
	}
}

sub _menu_close{
	my ($this) = @_;
	$this->SetTitle("Perlpad");
	$this->{textctrl}->SetValue("");
	$this->{filename} = "";

}

sub _menu_undo {
	my ($this) = @_;
	$this->{textctrl}->Undo();

}

sub _menu_redo {
	my ($this) = @_;
	$this->{textctrl}->Redo();

}

sub _menu_cut {
	my ($this) = @_;
	$this->{textctrl}->Cut();
	print "Cut\n";
	#Put a message in the status "Cut text placed in clipboard"?
}

sub _menu_copy{
	my ($this) = @_;
	$this->{textctrl}->Copy();
	print "Copy\n";
	#Put a message in the status "Copied text placed in clipboard"?
}

sub _menu_paste{
	my ($this) = @_;
	$this->{textctrl}->Paste();
	print "Paste\n";
	#Put a message in the status "Copied text placed in clipboard"?
}

sub _menu_about{
	my ($this) = @_;

	my $dialogtext = "Copyright 2005 by \n" . 
				"\tBen Marsh <blm\@woodheap.org> \n" . 
				"\tAdam Kennedy <cpan\@ali.as>\n" . 
			"All rights reserved.  You can redistribute and/or modify this \n" .
			"bundle under the same terms as Perl itself\n\n" .
			"See http://www.perl.com/perl/misc/Artistic.html";

	Wx::MessageBox($dialogtext, "About perlpad", wxOK|wxCENTRE, $this);
}

1;
