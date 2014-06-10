EADitor
=======

EADitor is an open source, [XForms](http://en.wikipedia.org/wiki/XForms)-based editing and publication tool for [Encoded Archival Description (EAD)](http://www.loc.gov/ead/) finding aids. It is composed of other open source Java-based web services that run in a framework such as Apache Tomcat. EADitor also offers rudimentary support for the publication of MODS and TEI (focused primarily on the annotation of facsimile images with [Annotorious](http://annotorious.github.io/) and [OpenLayers](http://openlayers.org). At the moment, support for creating EAD 2002 XSD schema-compliant documents is fairly robust, but migration to [EAD 3](http://www2.archivists.org/groups/technical-subcommittee-on-encoded-archival-description-ead/ead-revision) is planned by 2015.

Controlled Vocabulary
---------------------
The XForms editing backend for EAD links to the following web services for controlled vocabulary and ingesting of URIs/authority file numbers:

* Corporate names: [VIAF](http://viaf.org/), [xEAC](https://github.com/ewg118/xEAC)
* Family names:  [xEAC](https://github.com/ewg118/xEAC)
* Functions: [Getty AAT](http://vocab.getty.edu/aat/)
* Geographical names: [Geonames](http://www.geonames.org), [Pleiades](http://pleiades.stoa.org)
* Genres/formats: [LCGFT](http://id.loc.gov/authorities/genreForms), [Getty AAT](http://vocab.getty.edu/aat/)
* Occupations: [Getty AAT](http://vocab.getty.edu/aat/)
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

Architecture
------------
xEAC is comprised of three server-side application which run in Apache Tomcat: [Orbeon](http://www.orbeon.com) (XForms processor and public user interface), [Solr](http://lucene.apache.org/solr/) (search index used for publication), and [eXist](http://exist-db.org/exist/apps/homepage/index.html) (XML database).  XForms submissions allow these three applications to communicate through REST.

Installation and Use
--------------------
Installation and usage instructions may be found in the xEAC wiki, hosted by the American Numismatic Society: [http://wiki.numismatics.org/eaditor:eaditor](http://wiki.numismatics.org/eaditor:eaditor)
