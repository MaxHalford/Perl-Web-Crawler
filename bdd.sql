CREATE TABLE Pages( 
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

	INSERT INTO Pages (id,url,titre,dateEcriture)
			values (
			1,
			https://fr.wikinews.org/wiki/France_:_conf%C3%A9rence_de_Richard_Stallman_%C3%A0_Paris,
			France : conférence de Richard Stallman à Paris — Wikinews,
			14 novembre 2010
			);

	INSERT INTO Sommaire (id,partie)
				values (
				1,
				1 Rappel
				);

	INSERT INTO Sommaire (id,partie)
				values (
				1,
				2 Situation
				);

	INSERT INTO Sommaire (id,partie)
				values (
				1,
				3 Propositions
				);

	INSERT INTO Sommaire (id,partie)
				values (
				1,
				4 Interview
				);

	INSERT INTO Sommaire (id,partie)
				values (
				1,
				5 Notes
				);

	INSERT INTO Sommaire (id,partie)
				values (
				1,
				6 Sources
				);

	INSERT INTO Categories (id,categorie)
				values (
				1,
				Article archivé	
				);

	INSERT INTO Categories (id,categorie)
				values (
				1,
				France	
				);

	INSERT INTO Categories (id,categorie)
				values (
				1,
				Logiciel libre	
				);

	INSERT INTO Categories (id,categorie)
				values (
				1,
				Informatique	
				);

	INSERT INTO Categories (id,categorie)
				values (
				1,
				Paris	
				);

	INSERT INTO Sources (id,source)
				values (
				1,
				((fr)) – cybunk, « Approches Interdisciplinaires du Web : « Copyright vs. Community » by Richard Stallman ». Université Paris-Descartes, 12 octobre 2010.
				);

	INSERT INTO Sources (id,source)
				values (
				1,
				((en)) – Richard Stallman, « Copyright versus Community in the Age of Computer Networks ». Free Software Foundation, 12 octobre 2009.
				);

	INSERT INTO Pages (id,url,titre,dateEcriture)
			values (
			2,
			https://fr.wikinews.org/wiki/Br%C3%A8ves_:_16_janvier_2011,
			Brèves : 16 janvier 2011 — Wikinews,
			16 janvier 2011
			);

	INSERT INTO Sommaire (id,partie)
				values (
				2,
				1 Séismes
				);

	INSERT INTO Categories (id,categorie)
				values (
				2,
				Brèves	
				);

	INSERT INTO Sources (id,source)
				values (
				2,
				Pas de sources.
				);

	