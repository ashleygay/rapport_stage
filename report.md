% Rapport de stage de fin d'études
% Corentin Gay
  GISTRE 2018
% 19/02/2018 au 24/08/2018

---
fontsize: 11pt
fontfamily: utopia
graphics: true
---

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

J'ai choisi de m'attaquer à ce dernier sujet. L'idée etait de fournir les outils a
l'utilisateur fin qu'il puisse choisir sa cible de developpement et que GPS
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
En 1992, l'universite de New York conclut un contrat avec l'`US Air Force` afin
de creer un compilateur libre afin d'aider a la diffusion du
nouveau standard Ada, Ada 9X (qui deviendra Ada 95).
Suite a ce projet, la societe Ada Core Technologies est cree a New York et la
societee soeur ACT-Europe est cree deux annees plus tard. Ce n'est qu'en 2012
que les deux societes sont unifiees.

AdaCore fournit un compilateur Ada appelle GNAT en plusieurs versions avec des
licenses differentes. La version chaque version des fonctionnalite differentes,
par exemple la version `Community` ne supporte que la derniere version du
standard Ada, Ada 2012, alors que la version `Assurance` destinee aux projets
de certifications ou a des projets de longues durees supporte jusqu'a Ada 83.
De plus, avec la version `Community`, tout le code ecrit est soumis a la
license GPL tandis qu'avec la version commerciale, une exception est presente
dans la license permettant de ne pas etre soumis a la GPL.

Pour aller avec le compilateur, AdaCore peut egalement aider les clients avec
des projets de certifications. En effet,
une partie des outils fournis par AdaCore, comme GNATcoverage, est qualifie
pour le developpement d'outil en DO-178B en DAL A. C'est a dire le niveau de
criticite le plus eleve dans l'industrie avionique. GNATcoverage aide a
l'analyse de couverture de code ce qui permet de garantie qu'il n'y a pas de
code qui n'est jamais execute.

AdaCore a beaucoup de clients dans des domaines ou la presence d'erreurs n'est
pas acceptable comme le domaine de l'avionique ou de la defense. Voici quelques
projets que des clients d'AdaCore ont realises :

- MDA, une division de Maxar Technologies, va utiliser Ada ainsi que le
produit GNAT Pro Assurance afin de realiser le logiciel en charge de la
communication espace-terre a bord de l'ISS.

- Real Heart AB est une entreprise suedoise qui travaille sur un coeur totalement
artificiel. Afin de garantir le bon fonctionnement du logiciel qui
pilote le moteur de la pompe du coeur artificiel, elle a choisi d'utiliser
Ada ainsi que le compilateur GNAT Pro fourni par AdaCore.

secteur <> entreprise <> service <> equipe <> stage
Secteur:

- leader dans son secteur malgré de la compétition
    - PTC ObjectAda, partial support for Ada 2012 ppc and x86 targets

- service PE: product enhancement c'est la partie technique de l'entreprise

- équipe IDE: s'occupe de l'outil GPS, ainsi qu'une partie des outils qu'il
  utilise : GNATCOLL,  GNATHub, integration de GNAT dans workbench

- stage : improve the experience of a user starting developing in Ada on a new
  board

Mon stage se situe dans la perspective d'ameliorer l'experience
des utilisateurs de GPS dans le domaine du `bare board`.

## Maturité de l'entreprise sur les thématiques du stage

Thematiques du stage : bare board, IDE et CMSIS-Packs
Actuellement pas d'integration des CMSIS-Packs dans GPS.
Contrairement a Eclipse qui supporte parfaitement les pack.

Mon stage se deroule dans l'equipe IDE. Cette equipe s'occupe de la maintenace
de l'IDE GPS. Cet IDE utilise les references croisees afin de fournir une
meilleure experience de developpement a l'utilisateur. Mon stage s'insere donc
parfaitement dans les thematiques de cette equipe.

Ce support est specifique au langage Ada,
car le concept de runtime est plus ou moins unique a ce langage.

## État des connaissances sur le sujet

J'avais déjà utilisé les runtimes Ada pour un projet embarque sur une STM32F729
dont le but était d'interfacer du code C++ avec du code Ada.

- Détailler Ada
- Détailler Python
- Détailler ASM

Cursus EPITA:
- projet Ada

## Intérêt du stage pour l'entreprise

Rapport a EPITA: j'ai fait du bareboard et de l'Ada.
J'avais déjà essayé de faire un projet mixant Ada et C++, mais ce
ne s'était pas fini comme prévu. Pas de compilateur dans la toolchain d'AdaCore.
Motivation: ça touchait à du bare metal, mais il fallait quand meme intégrer ça
dans un IDE 'classique' (en Ada lol)

## Contexte de travail

- moyens fournis par l'entreprise
    - ordinateur configure comme je l'entendais (QWERTY)
- l'accessibilite des documentation
    - wiki interne
    - github de Fabien avec un prototype
    - github ARM avec le standard CMSIS-Pack
- disponibilité des personnes compétentes
    - Anthony
    - Fabien
- description de ce que j'ai utilisé et comment cela a aidé la réalisation
  de mon stage
    - bibliothèque standard python 2.7
    - bibliothèque GNATCOLL pour interfacer avec les fichiers projets
- apports externes
    - parler des papiers sur gnat et du site qui explique les runtimes

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
## état de l'art du marché ? (Eclipse)
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

