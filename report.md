% Rapport de stage de fin d'études
% Corentin Gay
  GISTRE 2018
% Du 19/02/2018 au 24/08/2018

---
fontsize: 11pt
fontfamily: utopia
glossary: true
graphics: true
biblatex: true
header-includes:
    - \usepackage{hyperref}
    - \usepackage[toc,section=section]{glossaries}
    - \makeglossaries
    - \newglossaryentry{bare-metal}{name=bare-metal,
       description={Un programme dit `bare-metal` (métal nu) est un programme
       qui tourne sur du matériel sans système d'exploitation}}
    - \newglossaryentry{IDE}{name=IDE,
       description={(Integrated Development Environment) Programme qui facilite
       le développement informatique en intégrant plusieurs outils dans le même
       environnement}}
    - \newglossaryentry{GPS}{name=GPS,
       description={GNAT Programming Studio, l'IDE phare d'AdaCore}}
    - \newglossaryentry{runtime}{name=runtime,
       description={Bibliothèque nécessaire pour faire tourner du code Ada sur
       une cible, elle fournit certaines fonctionnalitées du langage}}
    - \newglossaryentry{GNATCOLL}{name=GNATCOLL,
       description={(GNAT Components Collection) Bibliotèque Ada fournissant
       du code permettant d'utiliser des bibliothèques externes. Par
       exemple, GNATCOLL fournie une API pour interragir avec une base de
       données.}}
    - \newglossaryentry{linker script}{name=linker script,
       description={Fichier décrivant à l'éditeur de lien comment arranger la
       cartographie mémoire dans l'éxécutable final.}}
    - \newglossaryentry{startup code}{name=startup code,
       description={Aussi appellé 'crt0', c'est le bout de code qui est
       responsable d'initialiser la mémoire ainsi que d'appeller le point
       d'entrée du programme}}
    - \newglossaryentry{plugin}{name=plugin,
       description={Logiciel qui se greffe à un logiciel hôte et qui permet
       d'étendre les fonctionnalités de ce dernier}}
    - \newglossaryentry{boilerplate}{name=boilerplate,
       description={Se dit d'une fonctionnalité ou d'un programme dont le code
       source est quasiment le même quel que soit le programme}}
    - \newglossaryentry{generator function}{name=fonction génératrice,
       description={Fonction qui sauvegarde son état interne pour pouvoir
       reprendre l'execution lors d'un prochain appel}}
    - \newglossaryentry{pull-request}{name=pull-request,
       description={Requète pour qu'un projet incorpore des modifications
       tierces dans le code}}
---
[//]: # (TODO: Add transitionnal comments to all parts)
# Résumé

J'ai découvert Ada lors des cours à EPITA donnés par Raphaël Amiard. J'ai
trouvé le langage très intéressant car les concepts (notamment l'orienté objet)
étaient assez différents de leurs équivalents en C++. De plus, grâce à la
programmation par contrat, Ada simplifie la vérification de l'exactitude d'un programme.

Plusieurs facteurs ont affectés mon choix pour ce stage. Le premier est
l'opportunité d'intégrer mon travail dans un outil pré-éxistant. Ce point me
semble important car il permet de comprendre le contexte technique dans lequel
sera utilisé mon travail. Le second point est le sujet qui me permet de toucher
a plusieurs technologies tout en restant dans mon domaine de prédilection, le
développement embarqué. Par exemple, en apprendre plus sur les différents
processeurs ARM et leurs assembleurs me paraissait être une bonne
expérience a avoir.

C'est donc pour ces différentes raisons que j'ai candidaté chez AdaCore.

J'ai commencé mon stage le 19 février, j'ai d'abord été accueilli par mes
collègues et ma première tâche a été d'écrire un plugin Python pour l'\gls{IDE}
d'AdaCore, \gls{GPS}. Le but de cette tâche était de me familiariser avec le système
de revue de code ainsi qu'avec le code de \gls{GPS}. J'ai ensuite commencé à étudier
mon sujet de stage et comment pouvions nous améliorer le support du
\gls{bare-metal} dans \gls{GPS}.

Apres deux prototypes explorant le sujet, nous avons fait une réunion avec
mes encadrants afin de décider de la suite du stage et nous avons ainsi
décidé d'une architecture pour les outils que j'allait développer.

# Introduction

## Rappel du sujet de stage

Mon sujet de stage s'intitulait 'Improve baremetal support in \gls{GPS}' et
comportait les axes suivants:

- améliorer la `stack view`
- développer une register view
- explorer la possibilité d'intégrer les CMSIS-Packs dans \gls{GPS}

J'ai choisi de m'attaquer à ce dernier sujet. L'idée etait de fournir les outils à
l'utilisateur fin qu'il puisse choisir sa cible de développement et que \gls{GPS}
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
documentation afin de récuperer les informations nécessaires. Dans le cas où on travaille
avec un processeur cortex-m, ARM a créé un standard qui permet de décrire
le materiel d'une `board` ou d'un `device` et `packageant` ces infos dans une
archive zip. On appelle ces archives des CMSIS-Packs.

La solution est donc d'utiliser ces packs pour automatiser le processus de
modification du `startup code` et du `linker script`. Cette automatisation
permet a l'utilisateur de choisir sa `board` de dévelopement lors de la
création d'un projet.

## Présentation de l'entreprise
### Historique

En 1975, le DoD commence à rédiger un standard décrivant un langage visant à
remplacer les 450 langages utilisés à l'époque à l'intérieur de l'organisation.
En 1978, le dernier standard appellé 'Steelman' est finalisé. Le DoD organise
ensuite un concours visant à trouver le langage remplaçant qui respecte le
standard. Quatres équipes sont crées et parmis ces quatres, c'est l'équipe
'Green' qui remporte le concours et qui devient le nouveau langage de
programmation Ada, nommé en hommage à Ada Lovelace, mathématicienne anglaise du
19ème siècle.

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

Pour aller avec le compilateur, AdaCore peut également aider les clients avec
des projets de certifications. En effet,
une partie des outils fournis par AdaCore, comme GNATcoverage, est qualifié
pour le développement d'outil en DO-178B en DAL A. C'est à dire le niveau de
criticité le plus élevé pour le standard avionique. GNATcoverage aide à
l'analyse de couverture de code ce qui permet de garantir qu'il n'y a pas de
code qui n'est jamais exécuté.

AdaCore a beaucoup de clients dans des domaines ou la présence d'erreurs dans
un logiciel n'est pas acceptable. Par exemple, les deux domaines ou
AdaCore le plus de clients sont l'avionique de le secteur de la défense.

Cependant AdaCore n'est pas présente que dans ces domaines, voici deux exemples
de projets menés par des clients d'AdaCore dans des domaines très distincts.

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

Par rapport a ses concurrents, GNAT Pro a l'avantage de supporter la dernière
version du standard Ada (Ada2012) ainsi que toutes les versions antèrieures, et
ce tout aussi bien sur des plate-formes natives qu'en compilation croisée.
GNAT Pro supporte également bien plus de plate-formes 64bits et supporte
également plus d'OS temps-réels comme PikeOS ou LynxOS. On peut donc en
conclure que même si AdaCore a de la compétition, elle reste première dans
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

Au sein de ce cercle j'ai intégrer le sous-cercle \gls{IDE}. Son rôle est de s'occuper de
l'\gls{IDE} (\gls{GPS}) ainsi que des bibliothèques périphériques. Par exemple, cette
équipe s'occupe de l'intégration de GNAT dans l'\gls{IDE} de WindRiver (Workbench)
afin de pouvoir facilement faire tourner des applications en Ada sur les
différentes versions de VxWorks, un OS propriétaire très utilisé dans le
domaine du temps-réel embarqué.

Dans ce contexte j'ai surtout interagi avec l'équipe \gls{GPS} dont mon maître de
stage fait partie. Comme je devait intégrer mon travail dans \gls{GPS}, cela a été
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

Côté embarqué, AdaCore possède beaucoup de ports différents. GNAT Pro
supporte des OS dits temps-réels comme VxWorks ou LynxOS et supporte
également des cibles \gls{bare-metal}, c'est à dire des cibles sans OS.

L'\gls{IDE} d'AdaCore (\gls{GPS}) permet de faciliter le développement embarqué en
fournissant une interface de connection à la `board` facile d'utilisation.
Cependant, \gls{GPS} ne supporte pas les CMSIS-Packs dans son état actuel, ce qui
rend difficile le développement embarqué sur une carte non supportée.
L'intérêt du stage est donc clair pour AdaCore, la simplification du processus
de développement permet d'enlever une barrière à l'adoption de l'\gls{IDE} \gls{GPS}.

Aucun outil Ada ne posséde actuellement d'intégration des CMSIS-Packs,
contrairement aux outils pour le C ou il y a déjà un écosystème bien installé.
Cela permet donc de faciliter la diffusion du langage en levant une autre
barrière au développement.

## Contexte de travail

J'ai pu rapidement me mettre à travailler efficacement grâce a la
documentation interne. De plus, la disposition physique des locaux m'a permis,
lorsque j'avais des questions complexes, d'aller voir directement la personne
concernée afin d'obtenir une réponse claire.

J'était encadré par deux anciens épitéens, Anthony Leonardo Gracio et Fabien
Chouteau. Anthony fait partie de l'équipe \gls{GPS} et m'a
aidé à intégrer mon code dans \gls{GPS} et à écrire du meilleur code en faisant les
revues sur le code que j'écrivait. Fabien fait partie de l'équipe Bare-Board et
c'est lui qui est à l'origine de mon sujet de stage. Il m'a aidé lorsque
j'avais des questions vis à vis de certaines technologies ou du
fonctionnement d'Ada dans le domaine de l'embarqué.

Concernant le sujet du stage, un collègue avait déjà realisé un prototype
utilisant les CMSIS-Packs, j'ai pu m'en inspirer afin d'avancer plus vite
dans mon travail. De plus, la haute disponibilité de mes 2 encadrants m'a permis
d'avancer vite et de ne pas rester bloqué sur des problêmes qu'ils pouvaient
m'aider a resoudre.

Pour comprendre comment fonctionnaient les runtimes j'ai utilisé les papiers
suivants (Papers related to runtimes HERE). + DETAILS
LINK TO DESCRIPTION of those boards in the appendix

Lorsque j'ai commencé à tester mon travail, j'avait 3 cartes
différentes a ma disposition. Une STM32F429 et deux cartes Atmel, une SAMD20
et une SAM4E. Toutes ces cartes avaient des moyens de communication ou des
CPUS différents afin de me permettre de tester le code que je produisait sur le
plus de cibles variées.

En termes de logiciels utilisés, j'ai principalement utilisé la bibliothèque
standard Python 2.7, ainsi qu'une bibliothèque Ada nommée \gls{GNATCOLL}.
Cette bibliothèque fournie beaucoup de
fonctionnalitées, mais je l'ai principalement utilisé pour modifier et lire les
fichiers dits `projets`. Ces fichiers servent à décrire la structure d'un
projet Ada et j'ai utilisé le même formalisme afin de décrire les informations
nécessaires pour décrire une board.

# Aspects organisationnels
## Découpage du stage
Périodes:

- plugin \gls{GPS} au début
- fais 2-3 scripts pour explorer les possibilités des packs
- phase principale
    - point sur le stage
    - architecture des outils
    - travail sur les differents outils
        - gpr2ld
	- database
	- json2gpr
	- integration dans \gls{GPS}
	- tests
Livrables:

- différents outils

## Diagramme de Gantt, Kanban ??

- schéma des tâches successives a réaliser

## Points de contrôle

- Parler des monthly internship commits
- points réguliers avec mon maître de stage
- pull requests sur github

## Gestions des problèmes
Liste:

- mauvais analyseur syntaxique pour le python XML
    - problemes d'efficacite (malloc tout le fichier en memoire)

- probleme du schéma de la base de donnée
    - refait le schéma en simplifiant les données (no more héritage)

- intégration a pris plus de temps que prévu, j'ai du ajouter une
  fonctionnalité à \gls{GPS} afin de pouvoir y intégrer mon travail.

# Aspects techniques

expliquer le concept de runtime dans un des outils

Liste:

- schéma de l'architecture du code
- géneration du startup code et du linker script
- base de données représentant les packs
- intégration dans \gls{GPS}
- fix des bugs

## Faire fonctionner les harnais de test avec GNATemu
### Objectifs

GPS possède un outil appellé GNATtest. Cet outil permet de générer un projet
qui va se charger de tester les fonctions d'un autre projet, ce sont les
harnais de test.

Dans GPS, pour un projet embarqué, il est possible de lancer
le projet sur un émulateur : GNATemu. Il se repose sur l'émulateur libre QEMU.
GNATemu est utilisé pour tester des projets plus facilement que sur une carte
physique. Il permet également d'émuler des devices sur un bus (AMBA ou PCI)
via l'outil GNATbus.

L'objectif de cette tâche étaient de pouvoir lancer le harnais de test sur
l'émulateur dans le cas d'un projet embarqué.

GNATtest était déjà intégré dans GPS avec un \gls{plugin}. Il fallait modifier
ce dernier afin de prendre en compte le cas où la cible de compilation était
non-native.

### Cadre de la tâche

GPS utilise des \gls{plugin}s en Python.

### Résultats obtenus et impact sur l'avancement du stage

Le plugin GPS a été modifié pour tenir compte de la cible et permet de lancer
la suite de test sur l'émulateur. J'ai utilisé les bibliothèques de workflows
python pour rendre mon code asynchrone. J'ai également utilisé les
\gls{generator function} pour rendre mon code plus efficace.

J'ai refactorer le code qui servait à lancer l'émulateur afin de permettre
l'appel des fonctions depuis d'autre modules python.

Ce \gls{plugin} possède neanmoins une limitation.
Normalement, lorsque des tests echoue, GPS peut afficher le resultat de ces
tests en permettant a l'utilisateur de voir directement quel test echoue et a
quelle ligne il est situe. Nous avons ce comportement lorsque l'on lance
l'emulateur sur un harnais de test. Cependant, lorsque l'on lance l'emulateur
sur une liste de harnais de test, GPS ne peut pas recuperer les differents
output et ne peut donc pas les afficher comme decrit precedemment. Nous avons
donc decider de les afficher dans une console, une par harnais de test.

Ce projet m'a permis de me familiariser avec l'API des \gls{plugin}s Python
dans GPS. J'ai pu également aussi prendre en main le système de revue de code.

## Prototypes de générations de runtimes
### Objectifs

L'objectif principal était de me familiariser avec le comportement des runtimes
Ada et comment elle fonctionnaient. Je devais également explorer ce qu'il était
possible de faire avec les CMSIS-Packs et comment nous pourrions les utiliser
dans le contexte de la programmation embarqué Ada.

Le rôle du script est de générer une runtime ZFP pour une board spécifique.
Le script doit pouvoir analyser le contenu du fichier et proposer à
l'utilisateur quelle board choisir.

### Cadre de la tâche

- intégration dans GPS et bonne utilisation de gnatemu

### Propositions retenues ou pas

- pas d'outils traduisant l'assembleur et le linker script ARM vers leurs
  équivalents GCC

### Difficultés éventuelles

Je n'était pas très familier avec le parsing XML en Python. J'ai donc passé un
peu de temps à comprendre comment récupérer les informations intéressantes dans
le fichier XML.

J'ai également passé du temps à comprendre la structure des CMSIS-Packs.
Le ficher XML peut associer certains fichiers à des conditions. Par exemple, le
pack peut faire la distinction entre le compilateur GCC et le compilateur ARM
et peut spécifier quels fichiers utiliser pour un compilateur donné. GNAT est
basé sur GCC, il était donc nécessaire dans notre cas de ne récupérer que les
informations utilisables avec GCC.


### Résultats obtenus et impact sur l'avancement du stage

À la fin de cette tâche, j'avais réaliser deux outils. Le premier outil
sert à générer les fichiers utilisés lors de la compilation comme le
\gls{linker script} ou le \gls{startup code}.

Le second outil générait la structure d'une runtime prête à compiler. C'est à
dire les fichiers projets qui décrivaient à GPRbuild comment compiler la
runtime.

Cette tâche m'a permis de comprendre comment étaient agencés les packs et
quelles fonctionnalitées pouvaient être utiliser depuis le contenu des packs.
Certains packs possèdent un \gls{linker script} et un \gls{startup code}
compatible avec GCC mais ce n'est pas le cas de tout les packs. Il fallait dont
générer ces fichiers à partir des informations contenus dans les packs.

## Architecture de la chaîne d'outils
### Objectifs

Suite à l'accomplissement de la tâche précédente, j'ai organisé une réunion
avec mes encadrants afin de décider de la prochaine étape à suivre lors du
stage. Nous avons donc décider d'une architecture décrivant les outils que
j'allait écrire et leurs responsabilitées.

### Cadre de la tâche

- devait s'intégrer dans GPS
- devait pouvoir s'utiliser facilement depuis la command line
  ou depuis un script python
- devait être réalisés en python 2.7 ou en Ada

### Propositions retenues ou pas

Nous avons décider de laisser tomber la génération de runtime. En effet, il
existait un projet d'AdaCore appellé \href{https://github.com/AdaCore/bb-runtimes}{`bb-runtimes`}.
Le but de ce projet est de
fournir des runtimes dépendantes et non dépendantes de la board. Le support de
la board est dans le BSP à la place. Le but de ce projet est de réduire le
nombre de runtimes à supporter et de simplifier le processus de création de
runtimes. J'allais donc me reposer sur les runtimes de ce projet.

- séparation du pilotage de la chaîne d'outils et de l'intégration GPS

### Résultats obtenus et impact sur l'avancement du stage

![Architecture des outils](plan.png)

Pour que la chaîne d'outils soit extensible il fallait que chaque outil soit
clairement défini et qu'il n'accomplisse qu'un rôle, le plus simple possible et
le plus simplement possible.

Il fallait ensuite écrire un script qui allait piloter la chaîne d'outil et
enfin intégrer ce script dans GPS. Il fallait que les outils soient utilisables
depuis la ligne de commande ou importable comme un module Python.

- m'a permit d'avancer clairement sur un outil en particulier

## Base de données
### Objectifs

- représenter les informations utiles dans la base de donnée
    - documentation pour une board
    - addresse à laquelle télécharger le pack
    - informations sur la memoire et le CPU de la board
    - stockage de la hiérachie de famille/sous-famille/device du pack
    - stockage des interruptions (index + noms)

### Cadre de la tâche

- code en python
- utilisation de la bibliothèque du standard python utilisant sqlite3

### Difficultés éventuelles

- pas de moyen de configurer la taille des champs TEXT depuis l'API python
    - vérifier la taille du champ TEXT

- changement du parseur python, à la place du miniDOM parser, etree
    - 10x the performance

- certains packs ne respectent pas le standard
    - XML mal formé

- les chemins relatifs sont windows/unix/mac
     - conversions avec la bibliothèque python

### Propositions retenues ou pas

- redesign des tables
    - première itération était trop complexe
    - représentation de la structure en héritage du XML dans la BD
    - résolu en résolvant l'héritage lors du parsing plutôt que lors du
      parcours de la base de donnée

### Résultats obtenus et impact sur l'avancement du stage

- base de données fonctionnelle
    - 3 MO pour tous les packs

## Outil d'interrogation de la base de données
### Objectifs

- fournir une API simple pour interragir avec la DB
- il faut qu'elle soit efficace (details ??)
    - actuellement ajouter les packs prends moins de 3 minutes en comptant
      l'unzip

### Cadre de la tâche

- module python et executable

### Difficultés éventuelles

- passé un peu de temps sur comment supprimer le contenu d'un pack
    - utilisé des triggers SQL pour détruire un pack et tous ce qu'il contenait
    - pour update un paquet on détruit d'abord l'ancienne version avant
      d'ajouter la nouvelle version

### Propositions retenues ou pas

- refais la façon dont on faisait les query
    - un maximum de SQL et un minimum de python
    - génération des statements SQL

### Résultats obtenus et impact sur l'avancement du stage

- permis de tester que la base de données fonctionnait correctement

## Transformation du JSON en fichiers projets
### Objectifs

- transformer un output JSON en fichier projets

### Alternatives

- ne pas utiliser les fichiers projets et passer par du JSON
     - downside: pas de moyen d'éditer graphiquement un fichier JSON
       contrairement aux fichiers projets

### Cadre de la tâche

- executable indépendant
- module python

### Résultats obtenus et impact sur l'avancement du stage

- permis de tester que tous les outils fonctionnaient ensemble

- j'ai trouvé des bugs dans la gestion de la DB

- le fichier projet ressemble à quelquechose comme:

```Ada
with "interruptions";
project Spec is

   package CPU is
      for Name use "cortex-m0plus";
      for Float_Handling use "soft";
      for Number_Of_Interrupts use "15";
   end CPU;

   package Memory_Map is

      --  MEMORY MAP
      for Memories use ("ROM", "RAM");

      for Boot_Memory use "ROM";

      for Mem_Kind("ROM") use "ROM";
      for Mem_Kind("RAM") use "RAM";

      --  ROM
      for Address("ROM") use "0x0";
      for Size("ROM") use "256K";

      -- RAM
      for Address("RAM") use "16#20000000#";
      for Size("RAM")    use "16#8000#";

   end Memory_Map;

end Spec;
```

- on peut voir le type de CPU et la gestion des flotants (hardware or software)
- 2 memoires : une ROM et une RAM
    - leurs tailles
    - leurs addresses

- par rapport au linker script
    - on gagne en lisibilité
    - modification dans GPS aisée

## Génération du \gls{startup code} et du \gls{linker script}
### Objectifs

- écrire un programme qui transforme un fichier projet décrivant des régions
  mémoires, un CPU et des interruptions afin de générer le linker script et le
  startup code associé

- doit supporter plusieurs architectures (armv6, armv7, PPC, ...)

- doit vérifier que le contenu du fichier projet est correct

- dans le linker script on doit mapper les sections de l'executable vers la
  bonne région mémoire
    - pas forcément évident dans certains cas
    - change selon quel région mémoire est choisie

### Cadre de la tâche

- executable indépendant

- écrit en Ada

- utilise 2 fichiers distincts:
    - cpu + board informations
    - interruptions

- rajouts de code samples doit être possible sans avoir à recompiler le code

### Propositions retenues ou pas

- pas de meta-assembleurs qui serait traduit dans l'assembleur de la
  plate-forme, des code samples à la place

### Difficultés éventuelles

- outil à écrire en Ada, pas si familier que ça avec ce langage
- utilisation de bibliothèques Ada pour lire les fichiers projets
    - peu de documentation et peu d'exemples
    - lu le code, code pas explicite
    - problèmes de typages (tout est une string lol)
    - demandé des conseils et éclaircissements au responsable des bibliothèques
    - ajouté un exemple à la documentation expliquant comment faire

- on a essayer d'utiliser github (soumission de pull-requests)
    - c'est pas très utile pour des outils non stables
    - beaucoup d'overhead
    - gerrit c'est mieux
    - impossibilité de faire des PR dépendantes d'autres PRs
    - utilisable pour les projets déjà stables

- les messages d'erreurs du linker ne sont pas très explicites
    - si il ne trouve pas le point d'entrée spécifié il prend \_start

### Résultats obtenus et impact sur l'avancement du stage

- outil qui génère un startup code et un linker script depuis des fichiers
  projets
- j'ai pu tester les fichiers générés

## Intégration dans GPS
### Objectifs

- intégrer les outils dans GPS
- créer une UI pour que l'utilisateur choisisse la board sur laquelle il veut
  travailler
- l'utilisateur doit pouvoir relancer l'outil si il a modifié les fichiers
  projets décrivant le matériel
- interraction avec la base de donnée depuis GPS
    - mettre à jour tous les packs ou un seul pack
    - installer un pack manuellement

- permettre à l'utilisateur de consulter la documentation liée à son projet

- permettre à l'utilisateur de récupérer l'output de SVD2ADA
  (headers describing the devices from the SVD files)

### Cadre de la tâche

- langages : Ada et Python
- revues de code

### Propositions retenues ou pas

- intégrer l'outil de génération comme une étape de compilation en plus

### Difficultés éventuelles

- sqlite3 python module not functional in GPS
    - créer un ticket pour IT pour fixer ce problème
    - le module sqlite3 du standard python n'était pas compilé et ajouté à
      l'environnement python que GPS utilise

- modification de la façon dont on instancie les patrons de projet
    - on ne peut pas avoir de menu spécifique à un projet
    - mais on peut executer un script python après l'installation du projet
    - étendue cette fonctionnalité en permettant de générer des widgets GTK
      depuis le code python et de les utiliser comme un menu depuis le code Ada

- problèmes de fichiers de configuration

### Résultats obtenus et impact sur l'avancement du stage

- intégration presque finie
- a pris plus de temps que prévu
- modification des patrons de projet

[//]: # (TODO: Image pour illustrer l'UI ???)

# Premier bilan

## État de l'art sur l'intégration des CMSIS-Packs

Eclipse est l'\gls{IDE} le plus populaire pour écrire du code Java. Il possède un système
de plugins (écrits en Java) et supporte beaucoup de langages allant du Fortran
au Scala.

ARM a réalisé un plugin permettant de sélectionner quel pack utiliser et de
sélectionner précisément quels éléments (pilotes, exemples) du pack l'utilisateur
veut utiliser dans son projet. Le plugin permet également à l'utilisateur
d'accéder à toute la documentation concernant les éléments que l'utilisateur a
choisi.

Le plugin est également capable de générer des \gls{linker script}s.
Cependant, le plugin génère un type de \gls{linker script} spécifique à l'éditeur de
liens ARM qui est incompatible avec l'outil LD que GNAT utilise. De plus, le \gls{plugin}
est réalisé en Java, ce qui rend l'intégration dans d'autres outils quasi-impossible.

## Intérêt du stage pour l'entreprise

Mon stage est surtout un avantage à long terme pour AdaCore. En effet, en
réduisant la barrière à l'entrée de la programmation embarquée en Ada, mon
stage permet de faciliter la transition du C vers l'Ada.
Il permet d'aider au support des runtimes ZFP et pourrait même être utiliser en
interne pour générer les futures runtimes distribuées aux clients.

Enfin, il est possible d'utiliser la chaîne d'outils actuelle pour d'autres
architectures qu'ARM et il serait très intéressant à long terme de supporter
les architectures LEON et PowerPC de cette manière.

## Perspectives d'amélioration

Toutes les fonctionnalitées que fournie Eclipse sont très intéressantes pour
l'utilisateur et seraient un atout pour AdaCore de les intégrer dans GPS.
Elles pourraient vraiment améliorer le développement en C dans GPS. On pourrait
également imaginer le cas où l'utilisateur veut utiliser certains pilotes du
pack depuis le code Ada, il pourrait être intéressant de fournir cette
fonctionnalité 'out-of-the-box'. On pourrait utiliser l'option '-fdump-ada-spec'
du compilateur qui permet de générer des fichiers .ads qui permetteraient au code
Ada d'appeller le code C.

La dernière étape de l'intégration dans GPS serait la re-génération du
\gls{linker script} et du \gls{startup code} dans le cas où l'utilisateur
changerait la description du matériel, par exemple, dans le cas où
l'utilisateur voudrait faire démarrer son code en RAM plutôt qu'en ROM.
Actuellement, il faut relancer l'outil qui génère ces fichiers.

Concernant la base de donnée stockant le contenu des packs, il serait
intéressant de pouvoir la synchronizer avec une version distante.
En effet, certains CMSIS-Packs, sont non-fonctionnels ou mal-formatés et il
pourrait être intéressant pour AdaCore de fournir des versions corrigées de ces
packs. Cela permet également à AdaCore de corriger des bogues trouvés dans le
contenu des packs et de propager rapidement le patch.

Certaines architectures possède une cartographie mémoire particulière (deux
sections de RAM et pas de ROM par exemple). Il serait intéressant de pouvoir
gérer ces cas en permettant à l'utilisateur de choisir précisément où il va
mettre une section de l'executable.

Il serait intéressant de se pencher sur la question de génération de runtime
plus complexes, comme les runtimes Ravenscar. Ces runtimes implémentent toutes
les fonctionnalitées du langage.

## Expérience personnelle acquise pendant le stage

### Intérêt technique

J'avais seulement fait un projet en Ada lors de mon cursus à EPITA et je
voulais profiter de mon expérience à AdaCore pour en apprendre plus. En
travaillant sur un des outils que j'ai fait en Ada j'ai beaucoup appris sur la
manière de travailler avec ce langage. Ada est un langage ou la phase de
design est particulièrement importante car le langage se veut résilient au
changement. J'ai pu donc m'améliorer sur ce que je considère être une de mes
faiblesse, la propention a commencer à coder sans avoir une vision claire de
l'architecture du code. Les diverses revues de code m'ont permis également de
rendre mon code plus clair notamment en limitant la taille des fonctions et en
choisissant des noms de fonction appropriées.

J'ai égalment beaucoup progressé dans mon apprentissage du Python. Beaucoup de
mes outils était développé sont en Python, ce qui m'a permis de mieux
comprendre certains idiomes du langage et d'avoir appris à mieux utiliser la
bibliothèque standard du langage.

En arrivant à AdaCore j'ai du configurer mon éditeur (Vim) afin de pouvoir
écrire du code Ada efficacement. J'ai écris plusieurs scripts qui me permettent
de générer du code \gls{boilerplate} et d'appliquer la coding-style
automatiquement en tappant du code. J'ai également écrit des scripts me
permettant d'écrire ce rapport en français de manière plus efficace, notamment
pour ce qui touche aux charactères accentués.

Lors de mon stage j'ai dû écrire des patrons de générations de code Assembleur
pour plusieurs architectures différentes (ARMV6 et ARMV7). J'ai du traduire du
code tournant sur ARMV7 vers l'architecture ARMV6. Comme j'ai dû écrire un
patron de linker script à générer, j'ai également approfondi ma connaissance des
différentes sections du linker et de leurs rôles.

A certains moments de mon stage, j'ai dû aller lire du code, soit parceque
j'avais des interrogations et que personne ne connaissait le réponse, soit
parceque j'avais un doute sur la façon dont certaines fonctions étaient
implémentées. Notamment, je n'ai pas trouvé de documentation qui expliquait
clairement quelles unitées de mesure de mémoire utilisait l'éditeur de liens,
j'ai du donc aller lire le code.

AdaCore organise des `Monthly Interns Commits`. Ce sont des séances d'une heure
ou chaqun des stagiaires d'AdaCore présente son travail, son avancement et les
problêmes qu'il a rencontré. Les retours suite aux présentations m'ont vraiment
aidé à rendre mes diapositives plus claires ainsi qu'à les rendre plus
synthétiques. J'ai passé un peu de temps à améliorer ma présentation et j'ai
réussi à rendre l'explication de mon sujet de stage beaucoup plus abordable,
notamment en situant mieux le contexte des runtimes qui est particulier à Ada.
Anthony a également revu certaines de mes présentations et m'a aidé à les
améliorer en les rendants plus pertinentes et plus claires, notamment en
expliquant le contenu de slides par un schéma.

### Intérêt organisationnel

J'ai appliqué ce que j'avais appris lors de mon stage précédent, c'est à dire
de ne pas hésiter à demander des éclaircissements quand les spécifications de
ce que je devais développer n'étaient pas claires. Dans le cas où je suis
bloqué à cause d'un problême technique j'ai également tiré les leçons de mon
stage précédent et je n'ai pas hésité à aller poser des questions aux personnes
qui m'encadraient.

Je pense également avoir été plus consciencieux que pendant mon stage précédent. Lorsque
je trouvais un problême dans les outils que j'utilisait, je créais un ticket au
minimum et dans certains cas je cherchais un peu pour essayer de trouver d'ou
venait le bug et j'ai soumis quelques patchs de cette façon.

Je me suis également beaucoup mieux organisé puisque je gardais une trace de
mes tâches à réaliser dans mon cahier. Cela m'a permis d'être beaucoup mieux
organisé, de prioriser mon travail et de me donner des buts à accomplir chaque
jour. Si j'avais quelquechose à changer dans cette organisation ce serait
d'utiliser un programme plutôt qu'un cahier pour organiser mes tâches.

## Retours sur le stage et pertinence de la formation

En ce qui concerne les points perfectibles du stage, je pense que j'aurais dû
commencer à penser au design des outils depuis le début du stage. En effet,
j'ai commencé par faire plusieurs scripts prototypes. Cependant, n'ayant pas
encore très bien cerné mon sujet de stage, ces script n'ont finalement pas été
utilisés car le problême qu'ils resolvaient était déjà résolu par d'autres
outils d'AdaCore.

La formation généraliste d'EPITA, notamment le projet TIGER en ING1, m'a permis
d'appréhender le fonctionnement des compilateurs et me sera très utile dans
mon futur emploi. Le projet ASM (aussi en ING1) m'a permis de me familiariser
avec l'assembleur de manière générale, ce qui m'a été très utile pour lire le
\gls{startup code} de référence et pouvoir l'adapter à de nouvelles plate-formes.

La formation Ada de GISTRE m'a aider à me familiariser avec le langage et m'a
permis d'avancer plus vite sur l'outil écrit en Ada. Le projet accompli dans le
contexte de cette matière m'a permis d'étudier comment interfacer de l'Ada et
du C++ sur une plate-forme embarqué et les difficultés qui s'ensuivaient, par
exemple lié à l'usage d'intialisation statique.

Grâce à cette formation, j'ai pu me renseigner en cherchant et en lisant des
papiers de recherche que j'ai pu lire et appréhender moi-même. Notamment des
articles qui m'ont permis de mieux comprendre le rôle et le fonctionnement de
la runtime Ada.

Les aspects temps-réels de la formation de GISTRE m'ont été à comprendre les
enjeux des clients d'AdaCore. Par exemple, le cours d'architecture distribuée
de Christian Garnier m'a permis de comprendre quels étaient les enjeux et les
garanties que devaient apporté un système temps réel. Le cours de freeRTOS de
Thierry Joubert m'a permis de comprendre comment fonctionnait un OS temps réel,
et les problêmes que le système résolvait. Enfin le cours de José Ruiz sur la
norme DO-178 était très intéressant car il permettait de comprendre comment le
processus de certifaction fonctionnait et comment on pouvait tracer les
exigences de haut-niveau jusqu'au code source.

[//]: # (TODO: paragraphe sur les articles de recherche ????)

Smith says blah [@gnatada9x].

Smith says blah [@bareboardkernelada2005].

Smith says blah [@adarealtimeclock].

Smith says blah [@ptcobjectada].

Smith says blah [@adacompetition].

- papiers de recherche
     - real time features on a bare board kernel
     - implementing Ada real time clock and absolute delays in real time kernels
     - ORK: An open source real-time kernel for on-board software systems.

[//]: # (TODO: parler des voitures automatiques comme secteur d'avenir)

# Bibliographie

