% Rapport de stage de fin d'études
% Corentin Gay
  GISTRE 2018
% Du 19/02/2018 au 24/08/2018

---
fontsize: 11pt
fontfamily: utopia
graphics: true
---
[//]: # (Hello this is a comment)
# Résumé

J'ai découvert Ada lors des cours à EPITA donnés par Raphaël Amiard. J'ai
trouvé le langage très intéressant car les concepts (notamment l'orienté objet)
sont assez différents de leurs équivalents en C++. De plus, grâce aux concepts
des `contrats`, Ada simplifie la vérification de l'exactitude d'un programme.

Plusieurs facteurs ont affecte mon choix pour ce stage. Le premier est
l'opportunite d'intégrer mon travail dans un outil pré-éxistant. Ce point me
semble important car il permet de comprendre le contexte technique dans lequel
sera utilisé mon travail. Le second point est le sujet qui me permet de toucher
a plusieurs technologies tout en restant dans mon domaine de prédilection, le
développement embarqué. Par exemple, en apprendre plus sur les différents
processeurs ARM et leurs assembleurs me paraissait être une bonne
expérience a avoir.

C'est donc pour ces différentes raisons que j'ai candidaté chez AdaCore.

J'ai commencé mon stage le 19 février, j'ai d'abord été accueilli par mes
collègues et ma première tâche a été d'écrire un plugin Python pour l'IDE
d'AdaCore, GPS. Le but de cette tâche était de me familiariser avec le système
de revue de code ainsi qu'avec le code de GPS. J'ai ensuite commencé à étudier
mon sujet de stage et comment pouvions nous améliorer le support du
`bare-metal` dans GPS.

Apres deux prototypes explorant le sujet, nous avons fait une réunion avec
mes encadrants afin de décider de la suite du stage et nous avons ainsi
décidé d'une architecture et des outils que j'allait développer.

# Introduction

## Rappel du sujet de stage

Mon sujet de stage s'intitulait 'Improve baremetal support in GPS' et
comportait les axes suivants:

- améliorer la `stack view`
- développer une register view
- explorer la possibilité d'intégrer les CMSIS-Packs dans GPS

J'ai choisi de m'attaquer à ce dernier sujet. L'idée etait de fournir les outils à
l'utilisateur fin qu'il puisse choisir sa cible de développement et que GPS
génère les fichiers nécessaires afin de pouvoir commencer a développer apres la
création du projet.

Cependant pour pouvoir exécuter du code Ada sur une cible donnée, il faut
avoir un logiciel appellé une `runtime`. Ce logiciel implémente des
fonctionnalitées du langage qui sont utilisée par le programme comme le support
multi-tâches, la propagation des exceptions ou un allocateur mémoire.

Etant donné que le code étant dans la runtime doit tourner sur la cible, il
faut adapter la runtime à chaque cible. Actuellement, c'est une étape qui est
faite manuellement. Il faut également savoir qu'il y a plusieurs types de
runtime qui ne fournissent pas toutes les mêmes fonctionnatlités. Dans le cas
de mon stage je me suis attaqué a la question des `runtimes` dites `ZFP` pour
`zero footprint`. Ce type de runtime est le minimum pour pouvoir faire tourner
du code Ada. Par exemple, elle n'a pas de propagation d'exception, pas de
support multi-tâches et ne possède qu'un allocateur memoire naif.

Dans le cas décrit ci-dessus, les modifications à effectuer dans le code de la
runtime elle-même sont nulles. Cependant, il faut tout de même modifier le
`startup-code` qui permet de préparer le matériel à l'execution du programme et
appelle la fonction `main`. Il faut également modifier le `linker script`, le fichier
responsable de la cartographie mémoire, afin de spécifier les zones memoires et
quelles portions du code y mettre.

Ces modifications dépendent de la cible et nécessite actuellement de lire la
documentation afin de récuperer les infos utiles. Dans le cas ou on travail
avec un processeur cortex-m, ARM a créé un standard qui permet de décrire
le materiel d'une `board` ou d'un `device` et `packageant` ces infos dans une
archive zip. On appelle ces archives des CMSIS-Packs.

La solution est donc d'utiliser ces packs pour automatiser le processus de
modification du `startup code` et du `linker script`. Cette automatisation
permet a l'utilisateur de choisir sa `board` de dévelopement lors de la
création d'un projet.

## Présentation de l'entreprise
### Historique
En 1992, l'université de New York conclut un contrat avec l'`US Air Force` afin
de créer un compilateur libre afin d'aider a la diffusion du
nouveau standard Ada, Ada 9X (qui deviendra Ada 95).
Suite a ce projet, la société Ada Core Technologies est crée a New York et la
sociétée sœur ACT-Europe est crée deux années plus tard. Ce n'est qu'en 2012
que les deux sociétés sont unifiées.

AdaCore fournit un compilateur Ada appellé GNAT en plusieurs versions avec des
licenses différentes. Chaque version possède des fonctionnalite differentes,
par exemple la version `Community` ne supporte que la dernière version du
standard Ada, Ada 2012, alors que la version `Assurance` destinée aux projets
de certifications ou a des projets de longues durees supporte jusqu'à Ada 83.
De plus, avec la version `Community`, tout le code écrit est soumis à la
license GPL ce qui n'est pas le cas avec la version commerciale

Pour aller avec le compilateur, AdaCore peut egalement aider les clients avec
des projets de certifications. En effet,
une partie des outils fournis par AdaCore, comme GNATcoverage, est qualifie
pour le développement d'outil en DO-178B en DAL A. C'est a dire le niveau de
criticité le plus élevé dans pourl le standard avionique. GNATcoverage aide a
l'analyse de couverture de code ce qui permet de garantir qu'il n'y a pas de
code qui n'est jamais éxecuté.

AdaCore a beaucoup de clients dans des domaines ou la présence d'erreurs dans
un logiciel d'erreurs n'est pas acceptable. Par exemple, les deux domaines ou
AdaCore le plus de clients sont l'avionique de le secteur de la défense.

Voici des exemples de projets que des clients d'AdaCore ont realisés :

- MDA, une division de Maxar Technologies, va utiliser Ada ainsi que le produit
  GNAT Pro Assurance afin de remplacer le logiciel en charge de la
  communication espace-terre a bord de l'ISS.

- Real Heart AB est une entreprise suedoise qui travaille sur un coeur totalement
  artificiel. Afin de garantir le bon fonctionnement du logiciel qui pilote le
  moteur de la pompe du coeur artificiel, elle a choisi d'utiliser Ada ainsi
  que le compilateur GNAT Pro fourni par AdaCore.

### Contexte concurentiel

AdaCore n'est pas la seule entreprise  dans le domaine des compilateurs Ada.
Voici un rapide aperçu des principaux compilateurs concurrents.

                        Green Hills Ada Compilers
---------------------   -----------------------------------------
Entreprise              Greens Hills Software
Standards               Ada95
Plates-formes cibles    Power, ARM/Thumb, 68k, MIPS, x86, SPARC
Runtime                 Ravenscar (non multitâche)
---------------------   -----------------------------------------
: Aperçu des compilateurs Ada concurrents

                          ObjectAda
---------------------     -----------------------------------------------------
Entreprise                PTC
Standards                 Ada95
                          Ada2012 (partiel, seulement pour Windows 10 natif)
Plates-formes cibles      PPC, x86
Runtime                   Ravenscar
---------------------     -----------------------------------------------------

Par rapport a ses concurrents, GNAT Pro a l'avantage de supporter la derniere
version du standard Ada (Ada2012) ainsi que toutes les version anterieures, et
ce tout aussi bien sur des plate-formes natives qu'en compilation croisee.
GNAT Pro supporte egalement bien plus de plate-formes cibles 64bits et supporte
egalement plus d'OS temps-reels comme PikeOS ou LynxOS. On peut donc en
conclure que meme si AdaCore a de la competition, elle reste premiere dans
son domaine.

### Organisation

AdaCore est organisée en cercles. Chaque cercle a une responsabilité bien
particulière. Dans mon cas, j'ai intégré le cercle PE (Product Engineering).
Ce cercle est responsable de créer, de faire évoluer et de maintenir les
produits d'AdaCore. Il est également responsable du support client pour les outils qu'il
maintient. C'est la force du support offert d'AdaCore, de pouvoir contacter
directement les personnes qui ont une expertise forte sur les produits qu'ils
maintiennent. Ce cercle s'occupe aussi
de la QA (Quality Assurance) et des partenariats de contrats de recherche.

Au sein de ce cercle j'ai intégrer le sous-cercle IDE. Son rôle est de s'occuper de
l'IDE (GPS) ainsi que des bibliothèques périphériques. Par exemple, cette
équipe s'occupe de l'intégration de GNAT dans l'IDE de WindRiver (Workbench)
afin de pouvoir facilement faire tourner des applications en Ada sur les
différentes versions de VxWorks, un OS propriétaire très utilisé dans le
domaine du temps-réel embarqué.

Dans ce contexte j'ai surtout interagi avec l'équipe GPS dont mon maître de
stage fait partie. Comme je devait intégrer mon travail dans GPS, cela a été
très utile de pouvoir communiquer facilement avec les personnes qui
travaillent sur l'outil. J'ai également beaucoup avec un membre de l'équipe
CROSS qui a été à l'origine de mon sujet de stage. Il a pu me guider lorsque
j'avais des questions techniques vis-a-vis des `runtimes` Ada.

## État des connaissances sur le sujet

J'avais déjà utilisé les runtimes Ada pour un projet embarque sur une STM32F729
dont le but était d'interfacer du code C++ avec du code Ada. Mon expérience
avec l'Ada était donc plutôt limitée et je voulais profiter de ce stage pour en
apprendre plus sur ce langage.

Au cours de mon cursus, je n'ai pas beaucoup utilisé Python, cependant je
l'utilise sur mon temps libre pour personnaliser certains aspects de ma
distribution Linux, je n'étais donc pas complètement novice sur ce sujet.

J'ai l'expérience de plusieurs projets à EPITA concernant l'assembleur, le
premier projet est le projet assembleur en ING1 qui touchait surtout
l'assembleur x86. En GISTRE, j'ai touché un peu à de l'assembleur ARM grâce au
projet ARM. Enfin, lors de mon projet de fin d'études, j'ai dû lire de
l'assembleur 8080 afin de débugguer notre émulateur Gameboy. Je voulais
profiter de mon stage pour en apprendre plus sur les différentes architectures
ARM et leurs différents assembleurs.

## Maturité et intérêt du stage pour l'entreprise

[//]: # (TODO DO IT)

Maturite:
En ce qui concerne le support des plates-formes embarquées, AdaCore supporte a
la fois des cibles dites `bare-metal` ou des cibles avec des OS embarqués de
type VxWorks, PikeOS ou encore LynxOS.

Thematiques du stage : bare board, IDE et CMSIS-Packs et Communauté
Actuellement pas d'integration des CMSIS-Packs dans GPS.
Contrairement a Eclipse qui supporte parfaitement les pack.

Mon stage se déroule dans l'équipe IDE. Cette équipe s'occupe de la maintenance
de l'IDE GPS. Cet IDE utilise les références croisées afin de fournir une
meilleure experience de développement a l'utilisateur. Mon stage s'insère donc
parfaitement dans les thématiques de cette équipe.

Ce support est spécifique au langage Ada,
car le concept de runtime est plus ou moins unique à ce langage.

## Contexte de travail

J'ai pu rapidement me mettre a travailler efficacement grace a la
documentation interne. De plus, la disposition physique des locaux m'a permit,
lorsque j'avais des questions complexes, d'aller voir directemetn la personne
concernee afin d'obtenir une reponse claire.

Concernant le sujet du stage, un collegue avait deja realise un prototype
utilisant les CMSIS-Packs, j'ai pu donc m'en inspirer afin d'avancer plus vite
dans mon travail. De plus, la haute disponibilite des 2 personnes encadrant mon
stage m'a permis d'avancer vite et de ne pas rester bloque sur des obstacles
qu'ils pouvaient m'aider a resoudre.

Pour comprendre comment fonctionnaient les runtimes j'ai utilise les papiers
suivants (Papers related to runtimes HERE). + DETAILS

Lorsque j'ai commence a tester les prototypes que j'ai fait, j'avait 3 cartes
differentes a ma disposition. Une STM32F429 et deux cartes Atmel, une xplained
pro samd20 et une xplained pro sam4e. Toutes ces cartes avaient de moyens de
communication et des CPUS differents afin de me permettre de tester mes outils
le plus possible.

LINK TO DESCRIPTION of those boards in the appendix

En termes de logiciels utilises, j'ai principalement utilise la bibliotheque
standard Python 2.7, ainsi qu'une bibliotheque Ada nommee GNATCOLL (GNAT
COLlection of Libraries). J'ai utilisee cette derniere afin de pouvoir
interagir avec ce qu'on appelle les fichiers projets. Ces fichiers decrivent
comment compiler un programme en Ada en utilisant GNAT, j'ai utilise la
grammaire de ces fichiers pour pouvoir representer les infos concernat une
board.

# Aspects organisationnels
## Découpage du stage
Périodes:

- plugin GPS au début
- fais 2-3 scripts pour explorer les possibilités des packs
- phase principale
    - point sur le stage
    - architecture des outils
    - travail sur les differents outils
        - gpr2ld
	- database
	- integration dans GPS
	- tests
Livrables:

- différents outils

## Diagramme de Gantt, Kanban ??

- schéma des tâches successives a réaliser

## Points de controle

- Parler des monthly internship commits

## Gestions des problèmes
Liste:

- mauvais analyseur syntaxique pour le python XML
    - problemes d'efficacite (malloc tout le fichier en memoire)

- probleme du schéma de la base de donnée
    - refait le schéma en simplifiant les données (plus 'd'héritage')

- intégration a pris plus de temps que prévu, j'ai du ajouter une
  fonctionnalité à GPS afin de pouvoir y intégrer mon travail

# Aspects techniques
Liste:

- schéma de l'architecture du code
- géneration du startup code
- géneration du linker script
- base de données représentant les packs
- intégration dans GPS
- fix des bugs

## Objectifs
### Alternatives
## Cadre du stage dans l'entreprise
## Propositions retenues ou pas
on ne génère pas des runtimes on prend celles de bb_runtimes
probablement par raison politique, le code de la runtime n'est pas ouvert au
public
## Difficultes éventuelles
## Résultats obtenus
avancement

# Premier bilan
## état de l'art du marché ? (Eclipse, sans doute ??)
- intégration totale des cmsispacks dans Eclipse (pick and choose your
  driver)
- plugin Ada incompatible avec l'integration CMSIS-Packs ??
## intéret pour l'entreprise
- perspectives pour le futur
    - ajouter le support des drivers pour les packs
    - générer des bindings Ada pour les drivers
    - intégrer l'outil dans la suite de compilation
- valeur ajoutée (way better support for hobbyists)
## expérience (technique et organisationnelle) acquise pendant le stage
- technique
	- bien meilleure connaissance de l'Ada
    - bien meilleure connaissance de Python
    - ameliore mes connaissances en Vim
    - ameliore mes connaissances en Assembleur (ARM)
    - plus de facilite a lire du code
    - grace aux internships commits,
      meilleur a communiquer mon avancement et a des presentations
- organisationnelle
    - meilleure organisation personnelle
    - note tout
    - peut etre utilise un agenda electronique pour noter mes
    - taches plutot qu'un cahier
## retour d'expérience, points perfectibles a posteriori
## pertinence de la formation au regard du stage

