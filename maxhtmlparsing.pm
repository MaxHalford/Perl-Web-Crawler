#!/usr/bin/perl -w

package maxhtmlparsing;

use strict;
use utf8;
use LWP::Simple;

# Max Halford
# 27/11/14


sub body {
	#On prend un fichier html en paramètre (on suppose que c'est une ligne sans retour chariot)
	my $html = $_[0];
	#On en extrait le body
	if ($html =~ /<body.*?>(.*)<\/body>/i) {
		return $1;
	} else {
		return "Pas de body :( \n";
	}
}

sub clean {
	#Paramètres
	my @fichier = @_;
	#On raccorde les lignes
	my $ligne = join("",@fichier);
	#Et on enlève les retours chariots
	$ligne =~ s/\s+/ /g;
	return $ligne;
}


sub paragraphes {
	
}


sub retirerHTML {
	#Paramètres
	my $chaine = $_[0];
	#Et maintenant on enlève les balises
	$chaine =~ s/<.+?>//g;
	return $chaine;
}


sub titre {
	my $contenu = $_[0];
	if ($contenu =~ /<title>(.*?)<\/title>/) {
		return $1;
	} else {
		return "Pas de titre."
	}
}


sub date {
	my $contenu = $_[0];
	if ($contenu =~ /(\d*\d\s\w*?\s\d\d\d\d)/) {
		return $1;
	} else {
		return "Pas de date."
	}
}


sub sommaire {
	my $contenu = $_[0];
	if ($contenu =~ /<ul>(.*?)<\/ul>/) {
		my $sommaire = retirerHTML($1);
		my @listeSommaire = ();
		while ($sommaire =~ /(\d\s*\w*)/g) {
			push(@listeSommaire,$1);	
		}
		return @listeSommaire;
	} else {
		return "Pas de sommaire."
	}
}


sub categories {
	my $contenu = $_[0];
	if ($contenu =~ />catégories.*?<li>(.*?)<\/div>/i) {
		my $categories = $1;
		my @listeCategories = ();
		while ($categories =~ /(.*?)<\/li>/g){
			push(@listeCategories,retirerHTML($1));	
		}
		return @listeCategories;
	} else {
		return "Pas de categories."
	}
}	


sub sources {
	my $contenu = $_[0];
	if ($contenu =~ /<h2>.*sources.*<\/h2>/i) {
		my @listeSources = ();
		while ($contenu =~ /<ul>\s*<li>(.*?\(\(\w{2}\)\).*?)<\/li>/gi) {
			push(@listeSources,retirerHTML($1));	
		}
		return @listeSources;
	} else {
		return "Pas de sources."
	}
}


sub occurences {
	#On suppose que le paramètre $contenu est une ligne sans balisage html
	my $contenu =$ _[0];
	my @mots = split " ",$contenu;
	my %occurrences = ();
	foreach my $mot (@mots) {
		#S'il a déjà été rentré alors on incrémente l'entrée du dictionnaire
		if (exists $occurrences{$mot}) {
			$occurrences{$mot}++;
		#Sinon on crée une entrée dans le dictionnaire
		} else {
			$occurrences{$mot}=1;
		}
	}
	return %occurrences;
}


sub liens {
	my $contenu = $_[0];
	my %liens = ();
	while ($contenu =~ /\s+href\s*=\s*[\"\'\s]*([^'"\s]+)[\"\'\s]*\s*\>\s*([\p{L}+\(\)\'\s]+)/gi) {
		$liens{$2} = $1;
	}
	return %liens;
}

1;
