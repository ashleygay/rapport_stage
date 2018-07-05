% Rapport de stage de fin d'études
% 19 février au 24 aout
% Corentin Gay : GISTRE

---
fontsize: 11pt
fontfamily: utopia
graphics: true
---

# Résumé

J'ai découvert Ada lors des cours a EPITA donnes par Raphael Amiard. J'ai
trouve le langage tres interessant car les concepts (notamment l'oriente objet)
sont assez differents de leurs equivalents en C++.

Plusieurs facteurs ont affecte mon choix pour ce stage. Le premier est
l'opportunite d'integrer mon travail dans un outil pre-existant. Ce point me
semble important car il permet de comprendre le contexte technique dans lequel
sera utilise mon travail. Le second point est le sujet qui me permet de toucher
a plusieurs technologies tout en restant dans mon domaine de predilection, le
developpement embarque. Par exemple, en apprendre plus sur les differents
processeurs ARM et leurs assembleurs differents me paraissait etre une bonne
experience a avoir.

C'est donc pour ca que j'ai candidaté chez AdaCore pour ce stage.

J'ai commencé mon stage le 19 février, j'ai d'abord été accueilli par mes
collègues et ma première tâche a été d'écrire un plugin Python pour l'IDE
d'AdaCore, GPS. Le but de cette tâche était de me familiariser avec le système
de revue de code ainsi qu'avec le code de GPS. J'ai ensuite commencé à étudier
mon sujet de stage et comment pouvions nous améliorer le support du
`bare-metal` dans GPS.

Apres a

# Introduction

## Rappel du sujet de stage

Mon sujet de stage s'intitulait 'Improve baremetal support in GPS' et
comportait plusieurs axes. Par exemple : ameliorer la stack view ou bien
developper une register view ou encore, 'investiguer' comment rendre la
creation d'un projet plus simple et plus generique.

J'ai choisi de m'attaquer a ce dernier. L'idee etait de fournir les outils a
l'utilisateur fin qu'il puisse choisir sa cible de developpement et que GPS
genere les fichiers necessaires afin de pouvoir commencer a developper apres la
creation du projet.

Cependant pour pouvoir executer du code Ada sur une cible donnee, il faut
avoir un logiciel appelle une `runtime`. Ce logiciel fournit des
fonctionnalitees du langage qui sont utilisee par le programme comme le support
multi-taches, la propagation des exceptions ou un allocateur memoire.

Etant donne que le code etant dans la runtime doit tourner sur la cible, il
faut adapter la runtime a chaque cible. Actuellement, c'est une etape qui est
fait manuellement. Il faut egalement savoir qu'il y a plusieurs types de
runtime qui ne fournissent pas toutes les memes fonctionnatlites. Dans le cas
de mon stage je me suis attaque a la question des `runtimes` dites `ZFP` pour
`zero footprint`. Ce type de runtime est le minimum pour pouvoir faire tourner
du code Ada. Par exemple, elle n'a pas de propagation d'exception, pas de
support multi-taches et ne possede qu'un allocateur memoire naif.

Dans le cas decrit ci-dessus, les modifications a effectuer dans le code de la
runtime elle-meme sont nulles. Cependant, il faut tout de meme modifier le
`crt0` qui permet de preparer les differentes memoires et qui appelle la
fonction `main`. Il faut egalement modifier le `linker script`, le fichier
responsable de la cartographie memoire, afin de specifier les zones memoires et
quelles portions du code y mettre.

Ces modifications dependent de la cible et necessite actuellement de lire la
documentation afin de recuperer les infos utiles. Dans le cas d'une cible
possedant un processeur cortex-m, ARM a creer un standard qui permet de decrire
le materiel d'une `board` ou d'un `device` et `packageant` ces infos dans une
archive zip. On appelle ces archives des CMSIS-Packs.

La solution est donc d'utiliser ces packs pour automatiser le processus de
modification du `startup code` et du `linker script`. Cette automatisation
permet a l'utilisateur de choisir sa `board` de dévelopement lors de la
création d'un projet 

## Présentation de l'entreprise
En 1992, l'universite de New York conclut un contrat avec l'`US Air Force` afin
de creer un compilateur libre et standard afin d'aider a la diffusion du
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

## Intérèt du stage pour l'entreprise

Rapport a epita: j'ai fait du bareboard et de l'Ada.
J'avais deja essaye de faire un projet mixant Ada et C++, mais ce
ne s'etait pas fini comme prevu. Pas de compilateur ds la toolchain d'AdaCore.
Motivation: ca touchait a du bare metal, mais il fallait quand meme integrer ca
dans un ide 'classique' (en Ada lol)

## Contexte de travail

- moyens fournis par l'entreprise
    - ordinateur configure comme je l'entendais (QWERTY)
- l'accessibilite des documentation
    - wiki interne
    - github de Fabien avec un prototype
    - github ARM avec le standard CMSIS-Pack
- disponibilite des personnes competentes
    - Anthony
    - Fabien
- description de ce que j'ai utilise et comment cela a aide la realisation
  de mon stage
    - bibliotheque standard python 2.7
    - bibliotheque GNATCOLL pour interfacer avec les fichiers projets
- apports externes
    - parler des papers sur gnat de cyrille comar

# Aspects organisationnels
## Découpage du stage
## Diagramme de Gantt, Kanban ??
## Points de controle
## Situations de Crise ????? Kesako

# Aspects techniques
Liste:

- generation du startup code
- generation du linker script
- base de donnees representant les packs
- integration dans GPS

## Objectifs
### Alternatives
## Cadre du stage dans l'entreprise
## Propositions retenues ou pas
on ne genere pas des runtimes on prend celles de bb_runtimes
probablement par raison politique, le code de la runtime n'est pas ouvert au
public
## Difficultes éventuelles
## Résultats obtenus
avancement

# Bilan
- pretty good
