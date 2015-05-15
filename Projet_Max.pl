#!/usr/bin/perl -w

use strict;
use LWP::Simple;
use maxhtmlparsing;
use JSON;
use Switch;
# Il faut pouvoir lire les caractères HTML
use HTML::Entities;
# Environ 90% des pages internets sont encodés en UTF-8, il faut pouvoir le manipuler
use open qw/:std :utf8/;
use Encode;
use Term::Clui;
use Term::Clui::FileSelect;

# Les valeurs qui détermine l'exécution du script
my $getLiens = 1;
my $showData = 1;
my $storeWords = 1;
my $storeData = 1;
my $storeSQL = 1;
my $storeHTML = 1;
my $wordLookUp = 1;

# L'utilisateur peut changer le lancement du script
print Encode::decode('utf8',"Modifiez l'exécution du script, tapez
<cmd> pour voir les possibilités, 
<opt> pour voir le statut de l'exécution du script, 
<CTRL+D> (sous Linux) pour le lancer. \n");
while (<>) {
	my $input = $_;
	chomp($input);
	switch($input) {
		# Pour voir le statut de l'exécution
		case 'cmd' {
			print Encode::decode('utf8',
"1 -> Liens
2 -> Affichage
3 -> Stockage des mots
4 -> Stockage des résumés
5 -> Génération du script SQL
6 -> Stockage des résumés en HTML
7 -> Activer la recherche de mots
CTRL + D : Lancer le script
")
		}
		# Pour voir les options de paramétrage
		case 'opt' {
			print Encode::decode('utf8',
"
• Récupérer les liens dans chaque page : $getLiens
• Afficher le résumé de chaque page dans le terminal : $showData
• Stocker les occurences de mots : $storeWords
• Stocker le résumé de chaque page en JSON : $storeData
• Générer un fichier SQL pour stocker les données : $storeSQL
• Sauvegarder les résumés sous forme de page HTML : $storeHTML
• Rechercher un ou plusieurs mots dans les pages : $wordLookUp
");
		}
		case 1 {
			$getLiens = ($getLiens - 1) ** 2;
		}
		case 2 {
			$showData = ($showData - 1) ** 2;
		}
		# On ne peut pas faire l'option 7 sans la 3
		case 3 {
			$storeWords = ($storeWords - 1) ** 2;
			$wordLookUp = 0;
		}
		# On ne peut pas faire les options 5 et 6 sans la 4
		case 4 {
			$storeData = ($storeData - 1) ** 2;
			$storeSQL = ($storeSQL - 1) ** 2;
			$storeHTML = ($storeHTML - 1) ** 2;
		}
		case 5 {
			# L'option 5 n'est pas activée si la 4 ne l'est pas
			if ($storeData == 0) {
				$storeSQL = 0;
			} else {
				$storeSQL = ($storeSQL - 1) ** 2;
			}
		}
		case 6 {
			# L'option 6 n'est pas activée si la 4 ne l'est pas
			if ($storeData == 0){
				$storeHTML = 0;
			} else {
				$storeHTML = ($storeHTML - 1) ** 2;
			}
		}
		case 7 {
			# L'option 7 n'est pas activée si la 3 ne l'est pas
			if ($storeWords == 0) {
				$wordLookUp = 0;
			} else {
				$wordLookUp = ($wordLookUp - 1) ** 2;
			}
		}
		else {
			print "Commande invalide. \n";
		}
	}
}	

# L'utilisateur choisit ou se situe son fichier contenant les liens de départ
print Encode::decode('utf8',
"Où se trouve le fichier contenant les liens à analyser?
Cherchez dans le dossier 'Projet Max'.");
# La séléction commence au home (toutes les machines devraient en avoir un)
my $fichier = &select_file(SelDir=>1, TopDir=>"/home");
# On stocke le chemin vers le répertoire
$fichier =~ /(.+\/).*/;
my $path = $1;

print 'lol';

# Les liens du fichier seléctionné sont stockés
open FILE, "<", $fichier or die $!;
my @liens = <FILE>;
chomp(@liens);

my %data = ();

foreach my $lien (@liens) {
	
	my $page = maxhtmlparsing::clean(get($lien));
	my $contenu = decode_entities($page);
	my $body = maxhtmlparsing::body($page);
	
	# Récupérons le titre
	my $titre = maxhtmlparsing::titre($contenu);
	
	# Récupérons la date
	my $date = maxhtmlparsing::date($contenu);
	
	# Récupérons le sommaire
	my @listeSommaire = maxhtmlparsing::sommaire($contenu);
	
	# Récupérons les catégories
	my @listeCategories = maxhtmlparsing::categories($contenu);
	
	# Récupérons les sources
	my @listeSources = maxhtmlparsing::sources($contenu);
	
	# Récupérons les liens dans chaque page (cf. TP 28)
	if ($getLiens) {
		my %liens = maxhtmlparsing::liens($contenu);
		#Sauvegardons les liens récupérés
		open my $fichierLiens, '>', "$path/url/$titre.txt" or die $!;
		foreach my $key (keys %liens) {
			print {$fichierLiens} "$key => $liens{$key}\n";
		}
	}
	
	# Récupérons les occurences de chaque mot (cf. TP 24)
	if ($storeWords) {
		my %occurrences = maxhtmlparsing::occurences(maxhtmlparsing::retirerHTML($body));
		#Sauvegardons les occurences de mots pour chaque page dans un dossier
		open my $fichierOccurences, '>', "$path/Occurrences/$titre.txt" or die $!;
		foreach my $key (keys %occurrences){
			print {$fichierOccurences} "$key => $occurrences{$key}\n";
		}
	}
	
	# Affichons enfin les données récupérées
	if ($showData) {
		print "TITRE : $titre\n";
		print "DATE : $date\n";
		print "SOMMAIRE :\n";
		print "$_\n" for @listeSommaire;
		print "CATEGORIES : ";
		print $listeCategories[0];
		shift @listeCategories;
		print ", $_" for @listeCategories;
		print "\nSOURCES : \n";
		print "$_\n" for @listeSources;
		print "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n \n";
	}
	
	# Stockons nos données dans un système "hash of hashes" pour une structure élégante
	if ($storeData) { 
		$data{$lien} = {
			Titre => $titre,
			Date => $date,
			Sommaire => [@listeSommaire],
			Categories => [@listeCategories],
			Sources => [@listeSources],
			
		};
		# Le hash est alors sauvegardé sous format JSON
		my $json = encode_json \%data;
		open my $fichierJSON, '>', "$path/JSON/$titre.json" or die $!;
		print {$fichierJSON} Encode::decode('utf8', $json);
	}
}

# Créons un fichier sql
if ($storeSQL) {
	my $chemin = "$path/bdd.sql";
	open(my $bdd, '>', $chemin) or die $!;
	print $bdd 
	"CREATE TABLE Pages( 
	id int constraint pk_Pages primary key,
	url varchar2, 
	titre varchar2, 
	dateEcriture date,
	);

	CREATE TABLE Sommaire(
	id int constraint fk_Sommaire_Pages references Pages(id),
	partie varchar2,
	constraint pk_Sommaire primary key(id,partie)
	);

	CREATE TABLE Categories(
	id int fk_Categories_Pages references Pages(id),
	categorie varchar2,
	constraint pk_Categories primary key(id,categorie)
	);

	CREATE TABLE Sources(
	id int fk_Sources_Pages references Pages(id),
	source varchar2,
	constraint pk_Sources primary key(id,source)
	);

	";
	my $id = 0;
	# Table "Pages"
	foreach my $key (keys %data) {
		$id++;
		my $url = $key;
		my $titre = $data{$key}{Titre};
		my $dateEcriture = $data{$key}{Date};
		print $bdd
		"INSERT INTO Pages (id,url,titre,dateEcriture)
			values (
			$id,
			$url,
			$titre,
			$dateEcriture
			);

	";
		# Table "Sommaire"
		foreach my $partie (@{$data{$key}{Sommaire}}) {
			print $bdd
			"INSERT INTO Sommaire (id,partie)
				values (
				$id,
				$partie
				);

	";
		}
		# Table "Categories"
		foreach my $categorie (@{$data{$key}{Categories}}) {
			print $bdd
			"INSERT INTO Categories (id,categorie)
				values (
				$id,
				$categorie	
				);

	";
		}
		# Table "Sources"
		foreach my $source (@{$data{$key}{Sources}}) {
			print $bdd
			"INSERT INTO Sources (id,source)
				values (
				$id,
				$source
				);

	";
		}
	}
}

# Sauvegardons nos données sous la forme d'une page html limpide
if ($storeHTML) {
	foreach my $key (keys %data) {
		my $url = $key;
		my $titre = $data{$key}{Titre};
		my $date = $data{$key}{Date};
		open my $fichier,'>',"$path/Informations/$titre.html" or die $!;
		print $fichier
		# Ne pas oublier le UTF-8!
		"<meta charset=\"UTF-8\" />
		<h2>Titre</h2>
		<p>$titre</p>
		<h2>URL</h2>
		<p>$url</p>
		<h2>Date</h2>
		<p>$date</p>
		<h2>Sommaire</p>
		";
		foreach my $partie (@{$data{$key}{Sommaire}}) {
			print {$fichier}
			"<p>$partie</p>
			";
		}
		print {$fichier}
		"<h2>Categories</h2>
		";
		foreach my $categorie (@{$data{$key}{Categories}}) {
			print {$fichier}
			"<p>$categorie</p>
			";
		}
		print {$fichier}
		"<h2>Sources</h2>
		";
		foreach my $source (@{$data{$key}{Sources}}) {
			print {$fichier}
			"<p>$source</p>
			";
		}
	}
}

# Implémentons une fonction de recherche
if ($wordLookUp) {
	my $dossier = "$path/Occurrences/";
	print "Vous pouvez cherchez des mots dans chaque page : \n";
	while (<>) {
		my $input = $_;
		chomp ($input);
		#'DIR' est un itérable (on peut le parcourir une seule fois, il faut le mettre dans la boucle)
		opendir (DIR, $dossier) or die $!;
		while (my $fichier = readdir(DIR)) {
			# On vérifie que le fichier lu est un fichier texte
			if ($fichier =~ /.+.txt/) {
				# On regarde chaque ligne
				open MOTS,'<',"$path/Occurrences/$fichier";
				my @mots = <MOTS>;
				chomp(@mots);
				my $occurences = 0;
				foreach my $mot (@mots) {
					# Si la ligne contient ce que l'utilisateur cherche
					if ($mot =~ /$input => (\d+)/) {
						# On incrémente
						$occurences += $1;
					}
				}
				print Encode::decode('utf8', "'$input' est présent $occurences fois dans le document $fichier.\n");
			}
		}
	}	
}
