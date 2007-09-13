--
--  $Id$
--
--  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
--  project.
--
--  Copyright (C) 1998-2006 OpenLink Software
--
--  This project is free software; you can redistribute it and/or modify it
--  under the terms of the GNU General Public License as published by the
--  Free Software Foundation; only version 2 of the License, dated June 1991.
--
--  This program is distributed in the hope that it will be useful, but
--  WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--  General Public License for more details.
--
--  You should have received a copy of the GNU General Public License along
--  with this program; if not, write to the Free Software Foundation, Inc.,
--  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
--
USE DB;

-- what is one of : 'tables' or 'maps'
create procedure ODS_GET_APP_USER_RDF_VIEW_STR (in what varchar)
{
  declare ret, tmp any;
  ret := '';
  for select DB.DBA.wa_type_to_app (WAT_NAME) as suffix from DB.DBA.WA_TYPES do
    {
      declare p_name varchar;
      p_name := sprintf ('sioc.DBA.rdf_%s_view_str_%s', suffix, what);
      if (__proc_exists (p_name))
	  {
	    tmp := call (p_name) ();
	    ret := ret || tmp;
	  }
    }
  if (__proc_exists ('sioc.DBA.rdf_nntpf_view_str_'||what))
    {
      tmp := call ('sioc.DBA.rdf_nntpf_view_str_'||what) ();
      ret := ret || tmp;
    }
  return ret;
};


create procedure ODS_RDF_USER_VIEW_INIT (in fl int := 0)
{

sioc..ods_sioc_result ('Dropping old definition.');
ODS_SPARQL_QM_RUN ('drop quad map virtrdf:ODS_DS .', 0, 0);
sioc..ods_sioc_result ('Old graph dropped.');

sioc..ods_sioc_result ('Creating IRI classes.');
ODS_SPARQL_QM_RUN ('prefix ods: <http://www.openlinksw.com/virtuoso/ods/>
       create iri class ods:graph "http://^{URIQADefaultHost}^/dataspace/%U" (in uname varchar not null)
			    option (returns "http://^{URIQADefaultHost}^/dataspace/%U") .
       create iri class ods:user "http://^{URIQADefaultHost}^/dataspace/%U#user" (in uname varchar not null)
			    option (returns "http://^{URIQADefaultHost}^/dataspace/%U#user") .
       create iri class ods:user_group "http://^{URIQADefaultHost}^/dataspace/%U#group" (in uname varchar not null)
			    option (returns "http://^{URIQADefaultHost}^/dataspace/%U#group") .
       create iri class ods:person "http://^{URIQADefaultHost}^/dataspace/person/%U#this" (in uname varchar not null)
			    option (returns "http://^{URIQADefaultHost}^/dataspace/person/%U#this") .
       create iri class ods:mbox "mailto:%s" (in email varchar not null)
			    option (returns "mailto:%s") .
       create iri class ods:phone "tel:%s" (in tel varchar not null)
       			    option (returns "tel:%s") .
       create iri class ods:geo_point "http://^{URIQADefaultHost}^/dataspace/%U#geo" (in uname varchar not null)
       			    option (returns "http://^{URIQADefaultHost}^/dataspace/%U#geo") .
       create iri class ods:forum "http://^{URIQADefaultHost}^/dataspace/%U/%U/%U"
	     ( in uname varchar not null, in forum_type varchar not null, in forum_name varchar not null)
	    		    option (returns "http://^{URIQADefaultHost}^/dataspace/%U/%U/%U") .
       create iri class ods:proxy "http://^{URIQADefaultHost}^/proxy/%U" (in url varchar not null)
       			    option (returns  "http://^{URIQADefaultHost}^/proxy/%U") .
       create iri class ods:site "http://^{URIQADefaultHost}^/dataspace/%U#site" (in uname varchar not null)
       			    option (returns "http://^{URIQADefaultHost}^/dataspace/%U#site") .
       create iri class ods:role "http://^{URIQADefaultHost}^/dataspace/%U/%U/%U#%U"
	     ( in uname varchar not null, in tp varchar not null, in inst varchar not null, in role_name varchar not null)
			    option (returns  "http://^{URIQADefaultHost}^/dataspace/%U/%U/%U#%U" ) .
     	 create iri class ods:tag "http://^{URIQADefaultHost}^/dataspace/%U/concept#%U"
		   ( in uname varchar not null, in tag varchar not null)
          option (returns  "http://^{URIQADefaultHost}^/dataspace/%U/concept#%U") .
	# Blog
	create iri class ods:blog_forum "http://^{URIQADefaultHost}^/dataspace/%U/weblog/%U"
		(in uname varchar not null, in forum_name varchar not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/weblog/%U") .
	create iri class ods:blog_post "http://^{URIQADefaultHost}^/dataspace/%U/weblog/%U/%U"
		(in uname varchar not null, in forum_name varchar not null, in postid varchar not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/weblog/%U/%U" ) .
	create iri class ods:blog_comment "http://^{URIQADefaultHost}^/dataspace/%U/weblog/%U/%U/%d"
		(in uname varchar not null, in forum_name varchar not null, in postid varchar not null, in comment_id int not null)
 	  option (returns  "http://^{URIQADefaultHost}^/dataspace/%U/weblog/%U/%U/%d" ) .
	create iri class ods:blog_post_text "http://^{URIQADefaultHost}^/dataspace/%U/weblog-text/%U/%U"
		(in uname varchar not null, in forum_name varchar not null, in postid varchar not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/weblog-text/%U/%U" ) .
	# Feeds
	create iri class ods:feed "http://^{URIQADefaultHost}^/dataspace/feed/%d" (in feed_id integer not null)
          	option (returns "http://^{URIQADefaultHost}^/dataspace/feed/%d" ) .
	create iri class ods:feed_item "http://^{URIQADefaultHost}^/dataspace/feed/%d/%d" (in feed_id integer not null, in item_id integer not null)
	 	option (returns  "http://^{URIQADefaultHost}^/dataspace/feed/%d/%d" ) .
	create iri class ods:feed_item_text "http://^{URIQADefaultHost}^/dataspace/feed/%d/%d/text" (in feed_id integer not null, in item_id integer not null)
		option (returns  "http://^{URIQADefaultHost}^/dataspace/feed/%d/%d/text" ) .
	create iri class ods:feed_mgr "http://^{URIQADefaultHost}^/dataspace/%U/subscriptions/%U" (in uname varchar not null, in inst_name varchar not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/subscriptions/%U" ) .
	create iri class ods:feed_comment "http://^{URIQADefaultHost}^/dataspace/%U/subscriptions/%U/%d/%d"
		(in uname varchar not null, in inst_name varchar not null, in item_id integer not null, in comment_id integer not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/subscriptions/%U/%d/%d" ) .
	# Bookmark
	create iri class ods:bmk_post "http://^{URIQADefaultHost}^/dataspace/%U/bookmark/%U/%d"
		(in uname varchar not null, in inst_name varchar not null, in bmk_id integer not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/bookmark/%U/%d") .
	create iri class ods:bmk_post_text "http://^{URIQADefaultHost}^/dataspace/%U/bookmark/%U/%d/text"
		(in uname varchar not null, in inst_name varchar not null, in bmk_id integer not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/bookmark/%U/%d/text" ) .
	create iri class ods:bmk_forum "http://^{URIQADefaultHost}^/dataspace/%U/bookmark/%U"
		( in uname varchar not null, in forum_name varchar not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/bookmark/%U") .
	# Photo
	create iri class ods:photo_forum "http://^{URIQADefaultHost}^/dataspace/%U/photos/%U"
		(in uname varchar not null, in inst_name varchar not null)
		option (returns  "http://^{URIQADefaultHost}^/dataspace/%U/photos/%U") .
	create iri class ods:photo_post "http://^{URIQADefaultHost}^%s"
		(in path varchar not null) option (returns "http://^{URIQADefaultHost}^/DAV/%s") .
	create iri class ods:photo_post_text "http://^{URIQADefaultHost}^%s/text"
		(in path varchar not null) option (returns "http://^{URIQADefaultHost}^/DAV/%s/text") .
	create iri class ods:photo_comment "http://^{URIQADefaultHost}^%s:comment_%d"
		(in path varchar not null, in comment_id int not null)
		option (returns "http://^{URIQADefaultHost}^/DAV/%s:comment_%d") .
  # Polls
  create iri class ods:polls_forum "http://^{URIQADefaultHost}^/dataspace/%U/polls/%U"
    ( in uname varchar not null, in forum_name varchar not null) .
  create iri class ods:polls_post "http://^{URIQADefaultHost}^/dataspace/%U/polls/%U/%d"
    (in uname varchar not null, in inst_name varchar not null, in poll_id integer not null) .
  create iri class ods:polls_post_text "http://^{URIQADefaultHost}^/dataspace/%U/polls/%U/%d/text"
    (in uname varchar not null, in inst_name varchar not null, in poll_id integer not null) .
  # AddressBook
  create iri class ods:addressbook_contact "http://^{URIQADefaultHost}^/dataspace/%U/addressbook/%U/%d"
    (in uname varchar not null, in inst_name varchar not null, in contact_id integer not null) .
  create iri class ods:addressbook_contact_text "http://^{URIQADefaultHost}^/dataspace/%U/addressbook/%U/%d/text"
    (in uname varchar not null, in inst_name varchar not null, in contact_id integer not null) .
  create iri class ods:addressbook_forum "http://^{URIQADefaultHost}^/dataspace/%U/addressbook/%U"
    ( in uname varchar not null, in forum_name varchar not null) .
	# Community
	create iri class ods:community_forum "http://^{URIQADefaultHost}^/dataspace/%U/community/%U"
		(in uname varchar not null, in forum_name varchar not null)
		option (returns  "http://^{URIQADefaultHost}^/dataspace/%U/community/%U") .
	# Briefcase
	create iri class ods:odrive_forum "http://^{URIQADefaultHost}^/dataspace/%U/briefcase/%U"
		(in uname varchar not null, in inst_name varchar not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/briefcase/%U" ) .
	create iri class ods:odrive_post "http://^{URIQADefaultHost}^%s"
		(in path varchar not null) option (returns "http://^{URIQADefaultHost}^/DAV/%s") .
	create iri class ods:odrive_post_text "http://^{URIQADefaultHost}^%s/text"
		(in path varchar not null) option (returns "http://^{URIQADefaultHost}^/DAV/%s/text") .
	# Wiki
	create iri class ods:wiki_post "http://^{URIQADefaultHost}^/dataspace/%U/wiki/%U/%U"
		(in uname varchar not null, in inst_name varchar not null, in topic_id varchar not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/wiki/%U/%U") .
	create iri class ods:wiki_post_text "http://^{URIQADefaultHost}^/dataspace/%U/wiki/%U/%U/text"
		(in uname varchar not null, in inst_name varchar not null, in topic_id varchar not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/wiki/%U/%U/text" ) .
	create iri class ods:wiki_forum "http://^{URIQADefaultHost}^/dataspace/%U/wiki/%U"
		( in uname varchar not null, in forum_name varchar not null)
		option (returns  "http://^{URIQADefaultHost}^/dataspace/%U/wiki/%U" ) .
	# Calendar
	create iri class ods:calendar_event "http://^{URIQADefaultHost}^/dataspace/%U/calendar/%U/%d"
		(in uname varchar not null, in inst_name varchar not null, in calendar_id integer not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/calendar/%U/%d" ) .
	create iri class ods:calendar_event_text "http://^{URIQADefaultHost}^/dataspace/%U/calendar/%U/%d/text"
		(in uname varchar not null, in inst_name varchar not null, in calendar_id integer not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/%U/calendar/%U/%d/text" ) .
	create iri class ods:calendar_forum "http://^{URIQADefaultHost}^/dataspace/%U/calendar/%U"
		( in uname varchar not null, in forum_name varchar not null)
		option (returns  "http://^{URIQADefaultHost}^/dataspace/%U/calendar/%U") .
	# NNTPF
	create iri class ods:nntp_forum "http://^{URIQADefaultHost}^/dataspace/discussion/%U"
		( in forum_name varchar not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/discussion/%U").
	create iri class ods:nntp_post "http://^{URIQADefaultHost}^/dataspace/discussion/%U/%U"
		( in group_name varchar not null, in message_id varchar not null)
		option (returns  "http://^{URIQADefaultHost}^/dataspace/discussion/%U/%U" ) .
	create iri class ods:nntp_post_text "http://^{URIQADefaultHost}^/dataspace/discussion/%U/%U/text"
		( in group_name varchar not null, in message_id varchar not null)
		option (returns  "http://^{URIQADefaultHost}^/dataspace/discussion/%U/%U/text") .
	create iri class ods:nntp_role "http://^{URIQADefaultHost}^/dataspace/discussion/%U#reader"
		(in forum_name varchar not null)
		option (returns "http://^{URIQADefaultHost}^/dataspace/discussion/%U#reader") .', 1, fl)
       ;
sioc..ods_sioc_result ('IRI classes are created.');


    sioc..ods_sioc_result ('Creating the RDF view.');
ODS_SPARQL_QM_RUN ('
    prefix sioc: <http://rdfs.org/sioc/ns#>
    prefix sioct: <http://rdfs.org/sioc/types#>
    prefix atom: <http://atomowl.org/ontologies/atomrdf#>
    prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    prefix foaf: <http://xmlns.com/foaf/0.1/>
    prefix dc: <http://purl.org/dc/elements/1.1/>
    prefix dct: <http://purl.org/dc/terms/>
    prefix skos: <http://www.w3.org/2004/02/skos/core#>
    prefix geo: <http://www.w3.org/2003/01/geo/wgs84_pos#>
    prefix bm: <http://www.w3.org/2002/01/bookmark#>
    prefix exif: <http://www.w3.org/2003/12/exif/ns/>
    prefix ann: <http://www.w3.org/2000/10/annotation-ns#>
    prefix wikiont: <http://sw.deri.org/2005/04/wikipedia/wikiont.owl#>
    prefix calendar: <http://www.w3.org/2002/12/cal#>
    prefix ods: <http://www.openlinksw.com/virtuoso/ods/>

    alter quad storage virtrdf:DefaultQuadStorage
      from DB.DBA.SIOC_USERS as users
      from DB.DBA.SIOC_ODS_FORUMS as forums
      from DB.DBA.SIOC_ROLES as roles
      from DB.DBA.SIOC_ROLE_GRANTS as grants
      from DB.DBA.SIOC_KNOWS as knows
      from DB.DBA.ODS_FOAF_PERSON as person
      where (^{person.}^.U_NAME = ^{users.}^.U_NAME)
      where (^{forums.}^.U_NAME = ^{users.}^.U_NAME)
      where (^{knows.}^.TO_NAME = ^{users.}^.U_NAME)
      where (^{knows.}^.FROM_NAME = ^{users.}^.U_NAME)
      where (^{grants.}^.U_NAME = ^{users.}^.U_NAME)
      where (^{roles.}^.U_NAME = ^{users.}^.U_NAME) ' ||

      DB.DBA.ODS_GET_APP_USER_RDF_VIEW_STR ('tables') ||

      '
    {
	create virtrdf:ODS_DS as graph ods:graph (users.U_NAME) option (exclusive)
	  {
	    ods:user (users.U_NAME) a sioc:User ;
        sioc:id users.U_NAME ;
        sioc:name users.U_FULL_NAME ;
        sioc:email ods:mbox (users.E_MAIL) ;
        sioc:email_sha1 users.E_MAIL_SHA1 ;
        sioc:account_of ods:person (users.U_NAME) .

	    ods:person (person.U_NAME) a foaf:Person ;
        foaf:nick person.U_NAME ;
	      foaf:name person.U_FULL_NAME ;
	      foaf:mbox ods:mbox (person.E_MAIL) ;
        foaf:mbox_sha1sum person.E_MAIL_SHA1 ;
        foaf:holdsAccount ods:user (person.U_NAME) ;
        foaf:firstName person.FIRST_NAME ;
        foaf:family_name person.LAST_NAME ;
        foaf:gender person.GENDER ;
        foaf:icqChatID person.ICQ ;
        foaf:msnChatID person.MSN ;
        foaf:aimChatID person.AIM ;
        foaf:yahooChatID person.YAHOO ;
        foaf:birthday person.BIRTHDAY ;
        foaf:organization person.ORG ;
        foaf:phone ods:phone (person.PHONE) ;
	      foaf:based_near ods:geo_point (person.U_NAME)
	    .

	    ods:geo_point (person.U_NAME) a geo:Point ;
		    geo:lat person.LAT ;
		    geo:lng person.LNG .

	    ods:person (knows.FROM_NAME) foaf:knows ods:person (knows.TO_NAME) .
	    ods:person (knows.TO_NAME) foaf:knows ods:person (knows.FROM_NAME) .

	    ods:user_group (grants.G_NAME) a sioc:Usergroup ;
	    	sioc:id grants.G_NAME ;
		    sioc:has_member ods:user (grants.U_NAME) .
	      ods:user (grants.U_NAME)  sioc:member_of ods:user_group (grants.G_NAME) .

	    ods:role (roles.U_NAME, roles.APP_TYPE, roles.WAM_INST, roles.WMT_NAME)
	      sioc:has_scope ods:forum (roles.U_NAME, roles.APP_TYPE, roles.WAM_INST) ;
	      sioc:function_of ods:user (roles.U_NAME) .

      ods:forum (roles.U_NAME, roles.APP_TYPE, roles.WAM_INST)
	    	sioc:scope_of ods:role (roles.U_NAME, roles.APP_TYPE, roles.WAM_INST, roles.WMT_NAME) .
      ods:user (roles.U_NAME)
	    	sioc:has_function ods:role (roles.U_NAME, roles.APP_TYPE, roles.WAM_INST, roles.WMT_NAME) .

	    ods:forum (forums.U_NAME, forums.APP_TYPE, forums.WAM_INST) a sioc:Container ;
        sioc:id forums.WAM_INST ;
	      sioc:type forums.APP_TYPE ;
        sioc:description forums.WAI_DESCRIPTION ;
        sioc:link ods:proxy (forums.LINK) ;
        sioc:has_space ods:site (forums.U_NAME) . ' ||

        DB.DBA.ODS_GET_APP_USER_RDF_VIEW_STR ('maps') ||

	'
  } .
  } .', 1, fl)
;
  sioc..ods_sioc_result ('The RDF view is created.');
};

