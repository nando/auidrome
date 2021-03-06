# AuiDrome

![Pair of Huia](https://upload.wikimedia.org/wikipedia/commons/0/00/Huia_Buller.jpg)

**Aui**: onomatopoeic fragment of the extinct Huia voice (trying to catch its "where-you-are" sound [0]).

**Drome**: a place where people can get in, and from some of them people can also get out.

In the context of a project, **a good long project** (e.g. a human life, a collective ambition, or a business line) there are **7 basic dromes** we'd like to manage:

1. **AuiDrome**: people that are coming soon or that are finally between us. Her or his name should be created using, of course, love, and optionally related to one of the languages of the different cultures of the world (e.g. choosing from Glottolog [1] or ISO 639-3 vocabularies [2]).

2. **AcadoDrome**: people that has started to learn things about the culture or cultures of her or his parents. This *"drome"* has three internal stages: play, learn and grant.


3. **PedaloDrome**: people currently doing their best for the project, working hard for it but also for the pleasure that doing it returns to them.

4. **ByebyeDrome**: farewell from the squad to those who decide to keep growing in other projects. A place to remember those riders and their stuff (twitter, skype, or whatever they choose to keep in contact with us).

5. **RestoDrome**: people who deserves to rest and give to the project whatever they want. They happily still read, hopefully write, and some of them can even keep making amazing things.

6. **RipoDrome**: people that is no longer between us but that their spirit keep pushing us to build a better world.

7. **LoveDrome**: people we love or admire regardless of the *drome* to which they belong (**our affection is more important** than the *drome* where whey should be).

That said, those 7 basic dromes give us the places where **another human being** can be in our head in the context of **the abovementioned project**, giving us **the main first-level drome**: the *Human Beings Drome*.

And **the project** itself would be an example of another *first-level drome*, **the ProjectDrome**. Each entry of the **ProjectDrome** will be *de facto* boosted by at least a *Pedalodrome* (though they don't know we're calling them that way:).

All *dromes* needed to semantically store important information handled by a person will be discussed and defined using Loomio[3] as decision-making tool.

*Auidrome* is supposed to run on a **collective and personal server** and the data of its different *dromes* (stored in simple JSON files) should be easily shared between servers (ideally using federated sharing similar to the *Smallest Federated Wiki[4]* one).

*Auidrome* is also desired to become *Hyperbooted[5]* to guarantee always **the rights of the user**.

[0] [https://en.wikipedia.org/wiki/Huia#Voice](https://en.wikipedia.org/wiki/Huia#Voice)

[1] [http://datahub.io/dataset/glottolog](http://datahub.io/dataset/glottolog)

[2] [http://datahub.io/dataset/iso-639-3](http://datahub.io/dataset/iso-639-3)

[3] [https://www.loomio.org/g/t4295q8g/auidrome](https://www.loomio.org/g/t4295q8g/auidrome)

[4] [https://github.com/WardCunningham/Smallest-Federated-Wiki](https://github.com/WardCunningham/Smallest-Federated-Wiki)

[5] [http://hyperboot.org](http://hyperboot.org)

## Think and Shout (and dance if you want:).

The two basic actions anybody (no matter if logged or not) can do on a *drome* are **to think** (great!) and **to shout** (awesome... my parents don't let me do that! :)

*To think* [to think ico](https://raw.githubusercontent.com/AuiDrome/auidrome/master/public/images/think.png) a name or nickname means send it to the server to share it with the people currently connected to that particular *drome* in that moment (through WebSockets).

*To shout* [to shout ico](https://raw.githubusercontent.com/AuiDrome/auidrome/master/public/images/shout.png) it will share it as when we think but also will store it by the server in its public *tuits* file available in its root with the name *tuits.json* (for example, if we send it to *drome* http://otaony.com:3003 we get it into the http://otaony.com:3003/tuits.json file).

So every *shout* is converted to a *tuit* as soon as is *"heard"* by the server. That means it will have its own web page where more things can be said about *"it"*.

(Notice: shout/tuits in the Auidrome as well as in some parts of the code are called "auidos").

## Login and "to amadrinate"

The basic idea is **amadrinate to login**. *"To amadrinate"* is a very popular verb in the *dromolands* which means **"to know"** something good/cool about that person to be told to anyone interested.

It should not be difficult to find someone to amadrinate so in order to get logged Auidrome force us to do it pushing the **Amadrinate** button on the *tuit* page of a person. We can amadrinate to the same person as many times as needed in order to login if no more *"amadrinable"* new people has appeared on that *drome* (something good if we're trying to login in the Ripodrome;)

If currently we are not part of the *drome* and we think we should, we can get logged also by *"shouting"* our favourite nickname (the one that the people use to call us that is more cool for us) and then pushing the *It's me!* button on *our tuit page*.

We can do something similar by *"shouting"* the nickname of someone you appreciate, clicking in her or his name in the warning message, and finally pushing the **Amadrinate** button.

An "*amadrinated*" shout/tuit/auido has its own file in the *tuits* directory and (not only for that reason:) is considered a *Human* (as defined in *lib/auidrome/human.rb*).

## 3 Access Levels & 3 Auidrome Repositories **WARNING: Work (even more) in progress**

Auidrome has the three classical levels of access to the data of the user: **public**, **protected** and **private**:

1. **Public**: The *tuits* are public in the *public/tuits.json* file and become *humans* in the *public/tuits* directory ([Iria](https://github.com/AuiDrome/auidrome_public_data/blob/master/auidrome/tuits/IRIA.json) for example) when someone *amadrinates* them. Ideally, they will eventually become part of the own repository of the server where that particular *auidrome* is running.

2. People idendified that are currently members of the *pedalodrome* (and even members of the *restodrome*) can see **the protected data** of the user. That info will be stored in a different repository administrated by the collective interested in the project the people is *pedaling* for in the *pedalodrome* (examples of the protected data could be *the email* account or *company phone number* of the user).

3. Only the user (and eventually others that have been granted by the user to have it) have access to the user's **private data**. That info will be in YAR (Yet Another Repository, the private one) and will store data as the personal telephone of the user or the MAC of her or his Smartphone.

Follows in doc/todoes_and_ideas.md

## Installation
Application written in Ruby+Sinatra (+ WebSockets to share "auidos" between people simultaneusly connected to the server).

If you want to test it make the next steps:

  1. bundle install
  2. bundle exec ruby app.rb
  3. you should have it ready to go on http://localhost:3003

## Config and run...

To generate pretty JSON files simply create a file in the *config* directory called **generate_pretty_json**.

A Auidrome site, or *"a drome"*, is launched running the *bin/auidrome.rb* script.

Any *drome* should have its configuration on the *config/dromes* directory.

If *auidrome.rb* runs with no arguments it will use config/dromes/*auidrome*.yml configuration file.

To use a diferent one we have to give it as argument. For instance:

    $ ./bin/auidrome.rb config/dromes/ripodrome.yml

Other files in the *config* directory should be self-explanatory.

## Things that can be done while using it

Once you've started a session (pushing the "it's me!" or "amadrinate" buttons) you can add key/values on any entry.

If you use "mustaches" as part of a key ({{LIKE-ME}}) its content is assumed to be a human being name and will be replaced with a link to the right drome entry while showing it (WIP).

## ActivityStream

It's possible to configure Auidrome so that it notifies every command[0] to an ActivityStream hosted in getStream[1].

In order to do so you need to have the right values in the following environment variables:

    AUIDROME_STREAM_ACTOR: with the name of the actor/user of the owner of
      the Auidrome instance.
    STREAM_KEY: with the API key in getStream.io.
    STREAM_SECRET: with the API secret.

At this moment only two actions are sent:

- New entries will be sent with the verb **tuit** and with the **name of the drome** as *target*.
- *Amadrinations* will be sent using **amadrinate** as verb, and the string **"this"** as *target*.

[0] http://rom-rb.org/introduction/commands

[1] http://getStream.io

## Dirty recipe

This is the recipe I use to run Auidrome in a different host:

    $ git clone http://github.com/Auidrome/auidrome.git
    $ cd auidrome
    $ # pull data/public, data/protected and data/private repos:
    $ git submodule update --init
    $ ./bin/symboliclones.sh
    $ ./bin/updatefromcommitted.sh
    $ ./bin/screenthemall.sh -S
    $ # => and launch ./bin/auidrome.sh on every screen

Using submodules for the *data* repos hasn't been a good idea and I'm thinking how to change the current implementation.

Those 3 repos are available in https://github.com/Auidrome, though data/protected and data/private are meant to be corporate and personal.

## Origin and Dedications

The project comes from a [Codetail](http://github.com/nando/piidos-compartidos-codetails) that use code from another one (http://github.com/samuelnp/banana-status-codetails) and is desired to be part of ANOTHER ONE MUCH MORE BIGGER that is about Twitter decentralization based on laguages and dialects spoken by the folks that are currently living in our planet ([OTAONY.com](http://OTAONY.com)).

After a personal Hackaton i've been able to finish an "alfa-but-working" first release into the last hours of the Human Rights Day, and i'll update OTAONY.com with a link to it tomorrow morning.

This has already been a great day for those of us who think and care about our rights on the Internet, since http://ind.ie has been able to meet and exceed the goal of raising 100,000 crowdfunded dollars.

Much more important than my economical contribution to that project is for me this shared present that is also for my mother, Ana (though her birthday has finished more than an hour ago... I almost did it! ;). I hope it'll become something joining to any other projects with the same or bigger goals.

And finally, just like many other good things Auidrome is built with [love, Internet style](http://www.youtube.com/watch?v=Xe1TZaElTAs).

## Copyright / License

Copyright 2015 The Cocktail Experience, S.L.

Licensed under the GNU General Public License Version 3.0 (or later); you may not use this work except in compliance with the License. You may obtain a copy of the License in the COPYING file, or at:

http://www.gnu.org/licenses/gpl-3.0.txt

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
