EADitor
=======

EADitor is an open source, [XForms](http://en.wikipedia.org/wiki/XForms)-based editing and publication tool for [Encoded Archival Description (EAD)](http://www.loc.gov/ead/) finding aids. It is composed of other open source Java-based web services that run in a framework such as Apache Tomcat. [Orbeon](http://www.orbeon.com) is the XForms processor for creating, editing, and publishing EAD documents, interacting with web services to integrate linked open data controlled vocabulary and concepts defined by URIs. It is also the processor the powers the user interface. [Apache Solr](http://lucene.apache.org/solr/) is the search index and [eXist](http://exist-db.org/exist/apps/homepage/index.html) is the XML database for storing EAD files. EADitor also offers rudimentary support for the publication of MODS and TEI (focused primarily on the annotation of facsimile images with [Annotorious](http://annotorious.github.io/) and [OpenLayers](http://openlayers.org).

Controlled Vocabulary
---------------------
The XForms editing backend for EAD links to the following web services for controlled vocabulary and ingesting of URIs/authority file numbers:

* Corporate names: [VIAF](http://viaf.org/), [xEAC](https://github.com/ewg118/xEAC)
* Family names:  [xEAC](https://github.com/ewg118/xEAC)
* Functions: [Getty AAT]((http://vocab.getty.edu/aat/))
* Geographical names: [Geonames](http://www.geonames.org), [Pleiades](http://pleiades.stoa.org)
* Genres/formats: [LCGFT](http://id.loc.gov/authorities/genreForms), [Getty AAT](http://vocab.getty.edu/aat/)
* Occupations: [Getty AAT]((http://vocab.getty.edu/aat/))
* Personal names: [VIAF](http://viaf.org/), [xEAC](https://github.com/ewg118/xEAC)
* Subjects: [LCSH](http://id.loc.gov/authorities/subjects)

Lookup mechanisms for other Getty thesauri will be incorporated into EADitor once they become available through SPARQL.

Export/Alternative Data Models and Serializations
-------------------------------------------------
In addition to making the EAD XML available for download, EADitor provides alternative models (derived from both EAD finding aids and Solr query results):

* EAD->RDF/XML ([Arch ontology](http://gslis.simmons.edu/archival/arch/index.html))
* EAD->KML
* Solr->KML
* Solr->Atom
* Solr->Pelagios RDF/XML (for making content associated with ancient places defined by Pleiades)

Linked Data
-----------
EADitor optionally allows connection to an RDF triplestore and SPARQL endpoints to facilitate the publication of archival materials in the form of linked open data.

