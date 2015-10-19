<%--
  ~ The Shepherd Project - A Mark-Recapture Framework
  ~ Copyright (C) 2012 Jason Holmberg
  ~
  ~ This program is free software; you can redistribute it and/or
  ~ modify it under the terms of the GNU General Public License
  ~ as published by the Free Software Foundation; either version 2
  ~ of the License, or (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
  --%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page contentType="text/html; charset=utf-8" language="java"
         import="com.drew.imaging.jpeg.JpegMetadataReader,com.drew.metadata.Directory, 	   
java.lang.reflect.*,
org.ecocean.social.Relationship,
		 com.drew.metadata.Metadata,com.drew.metadata.Tag,org.ecocean.*,org.ecocean.servlet.ServletUtilities,java.io.File, java.util.*, org.ecocean.genetics.*" %>


<%!
	public String cleanString(Object obj) {
		if (obj == null) return "";
		return obj.toString();
	}
%>

<%

String context="context0";
context=ServletUtilities.getContext(request);

  //handle some cache-related security
  response.setHeader("Cache-Control", "no-cache"); //Forces caches to obtain a new copy of the page from the origin server
  response.setHeader("Cache-Control", "no-store"); //Directs caches not to store the page under any circumstance
  response.setDateHeader("Expires", 0); //Causes the proxy cache to see the page as "stale"
  response.setHeader("Pragma", "no-cache"); //HTTP 1.0 backward compatibility

  //setup data dir
  String rootWebappPath = getServletContext().getRealPath("/");
  File webappsDir = new File(rootWebappPath).getParentFile();
  File shepherdDataDir = new File(webappsDir, CommonConfiguration.getDataDirectoryName(context));
  //if(!shepherdDataDir.exists()){shepherdDataDir.mkdir();}
  File encountersDir=new File(shepherdDataDir.getAbsolutePath()+"/encounters");
  //if(!encountersDir.exists()){encountersDir.mkdir();}
  //File thisEncounterDir = new File(encountersDir, number);

//setup our Properties object to hold all properties
  Properties props = new Properties();
  //String langCode = "en";
  String langCode=ServletUtilities.getLanguageCode(request);
  


  //load our variables for the submit page

  //props.load(getClass().getResourceAsStream("/bundles/" + langCode + "/occurrence.properties"));
  props = ShepherdProperties.getProperties("occurrence.properties", langCode,context);

  String name = request.getParameter("number").trim();
  Shepherd myShepherd = new Shepherd(context);



  boolean isOwner = false;
  if (request.getUserPrincipal()!=null) {
    isOwner = true;
  }

%>

<html>
<head>

  <title><%=CommonConfiguration.getHTMLTitle(context) %>
  </title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  <meta name="Description"
        content="<%=CommonConfiguration.getHTMLDescription(context) %>"/>
  <meta name="Keywords"
        content="<%=CommonConfiguration.getHTMLKeywords(context) %>"/>
  <meta name="Author" content="<%=CommonConfiguration.getHTMLAuthor(context) %>"/>
  <link href="<%=CommonConfiguration.getCSSURLLocation(request,context) %>"
        rel="stylesheet" type="text/css"/>
  <link rel="shortcut icon"
        href="<%=CommonConfiguration.getHTMLShortcutIcon(context) %>"/>
        


 
  
  <style type="text/css">
    <!--
    .style1 {
      color: #000000;
      font-weight: bold;
    }

.col-relationships {
	width: 170px;
}

.enc-filename div {
	color: #666;
	font-size: 0.9em;
	width: 120px;
	padding-left: 3px;
	overflow-x: hidden;
	white-space: nowrap;
}

.relationship-none {
	position: relative;
	border-radius: 4px;
	padding: 2px 8px 2px 8px;
	background-color: #DDD;
	color: #AAA;
}

.relationship {
	border-radius: 4px;
	padding: 2px 8px 2px 8px;
	background-color: #888;
	color: #DDD;
}
.relationship:hover {
	background-color: #F98;
	color: #333;
}

.rel-partner {
	background-color: #FAA;
}

#relationships-form {
	width: 200px;
	z-index: 300;
	background-color: #FFC;
	position: absolute;
	left: -200px;
	top: 3px;
	display: none;
	padding: 3px;
	border: solid 2px #444;
	border-radius: 4px;
}


div.submit {
	padding: 30px;
	border-radius: 10px;
}
div.submit.changes-made {
	background-color: #FFA;
}

div.submit .note {
	margin-left: 20px;
	display: inline-block;
}

    div.scroll {
      height: 200px;
      overflow: auto;
      border: 1px solid #666;
      background-color: #ccc;
      padding: 8px;
    }

tr.enc-row {
	line-height: 22px;
}

tr.enc-row:hover {
	background-color: #AAA;
	cursor: pointer;
}

    -->
  </style>


  <!--
    1 ) Reference to the files containing the JavaScript and CSS.
    These files must be located on your server.
  -->

  <script type="text/javascript" src="highslide/highslide/highslide-with-gallery.js"></script>
  <link rel="stylesheet" type="text/css" href="highslide/highslide/highslide.css"/>

  <!--
    2) Optionally override the settings defined at the top
    of the highslide.js file. The parameter hs.graphicsDir is important!
  -->

  <script type="text/javascript">
    hs.graphicsDir = 'highslide/highslide/graphics/';
    hs.align = 'center';
    hs.transitions = ['expand', 'crossfade'];
    hs.outlineType = 'rounded-white';
    hs.fadeInOut = true;
    //hs.dimmingOpacity = 0.75;

    //define the restraining box
    hs.useBox = true;
    hs.width = 810;
    hs.height = 500;

    //block right-click user copying if no permissions available
    <%
    if(request.getUserPrincipal()==null){
    %>
    hs.blockRightClick = true;
    <%
    }
    %>

    // Add the controlbar
    hs.addSlideshow({
      //slideshowGroup: 'group1',
      interval: 5000,
      repeat: false,
      useControls: true,
      fixedControls: 'fit',
      overlayOptions: {
        opacity: 0.75,
        position: 'bottom center',
        hideOnMouseOut: true
      }
    });

  </script>
  
<link href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.4/themes/base/jquery-ui.css" rel="stylesheet" type="text/css" />

<!--  FACEBOOK LIKE BUTTON -->
<div id="fb-root"></div>
<script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>

<!-- GOOGLE PLUS-ONE BUTTON -->
<script type="text/javascript">
  (function() {
    var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
    po.src = 'https://apis.google.com/js/plusone.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
  })();
</script>




</head>

<body <%if (request.getParameter("noscript") == null) {%> onload="initialize()" onunload="GUnload()" <%}%>>
<div id="wrapper">
<div id="page">
<jsp:include page="header.jsp" flush="true">

	<jsp:param name="isAdmin" value="<%=request.isUserInRole(\"admin\")%>" />
</jsp:include>

<script src="http://code.jquery.com/ui/1.10.2/jquery-ui.js"></script>
  

<div id="main">


<div id="maincol-wide-solo">


<div id="maintext">
<%
  myShepherd.beginDBTransaction();
  try {
    if (myShepherd.isOccurrence(name)) {


      Occurrence sharky = myShepherd.getOccurrence(name);
      boolean hasAuthority = ServletUtilities.isUserAuthorizedForOccurrence(sharky, request);


    	Encounter[] dateSortedEncs = sharky.getDateSortedEncounters(false);
	int total = dateSortedEncs.length;

	HashMap<String,Encounter> encById = new HashMap<String,Encounter>();
	for (int i = 0; i < total; i++) {
		Encounter enc = dateSortedEncs[i];
		encById.put(enc.getCatalogNumber(), enc);
	}


	String saving = request.getParameter("save");
	String saveMessage = "";

	if (saving != null) {
		ArrayList<Encounter> changedEncs = new ArrayList<Encounter>();
		//myShepherd.beginDBTransaction();
		Enumeration en = request.getParameterNames();
		while (en.hasMoreElements()) {
			String pname = (String)en.nextElement();
			if (pname.indexOf("occ:") == 0) {
				String methodName = "set" + pname.substring(4,5).toUpperCase() + pname.substring(5);
				String value = request.getParameter(pname);
				//saveMessage += "<p>occ - " + methodName + "</P>";
				java.lang.reflect.Method method;
				if ((pname.indexOf("decimalL") > -1) || pname.equals("occ:distance") || pname.equals("occ:bearing")) {  //must call with Double value
					Double dbl = null;
					try {
						dbl = Double.parseDouble(value);
					} catch (Exception ex) {
						System.out.println("could not parse double from " + value + ", using null");
					}
					try {
						method = sharky.getClass().getMethod(methodName, Double.class);
						method.invoke(sharky, dbl);
					} catch (Exception ex) {
						System.out.println(methodName + " -> " + ex.toString());
					}
				} else if ((pname.indexOf("num") == 4) || pname.equals("occ:groupSize")) {  //int 
					Integer i = null;
					try {
						i = Integer.parseInt(value);
					} catch (Exception ex) {
						System.out.println("could not parse integer from " + value + ", using null");
					}
					try {
						method = sharky.getClass().getMethod(methodName, Integer.class);
						method.invoke(sharky, i);
					} catch (Exception ex) {
						System.out.println(methodName + " -> " + ex.toString());
					}
				} else {
					try {
						method = sharky.getClass().getMethod(methodName, String.class);
						method.invoke(sharky, value);
					} catch (Exception ex) {
						System.out.println(methodName + " -> " + ex.toString());
					}
				}

			} else if (pname.indexOf(":") > -1) {
				int i = pname.indexOf(":");
				String id = pname.substring(0, i);
				String methodName = "set" + pname.substring(i+1, i+2).toUpperCase() + pname.substring(i+2);
				String value = request.getParameter(pname);
				Encounter enc = encById.get(id);
				if (enc != null) {
					java.lang.reflect.Method method;
					if (methodName.equals("set_relMother")) {  //special case - make relationship
						if ((value != null) && !value.equals("") && (enc.getIndividualID() != null)) {
							MarkedIndividual partnerIndiv = myShepherd.getMarkedIndividual(value);
							if (partnerIndiv != null) {
								Relationship rel = new Relationship("familial", enc.getIndividualID(), value, "mother", "calf");  //TODO generalize, i guess
								myShepherd.getPM().makePersistent(rel);          
							}
						}


					} else if (methodName.equals("setAgeAtFirstSighting")) {  //need a Double, sets on individual
						Double dbl = null;
						try {
							dbl = Double.parseDouble(value);
						} catch (Exception ex) {
							System.out.println("could not parse double from " + value + ", using null");
						}
						if ((dbl != null) && (enc.getIndividualID() != null)) {
							MarkedIndividual ind = myShepherd.getMarkedIndividual(enc.getIndividualID());
							if (ind != null) {
								ind.setAgeAtFirstSighting(dbl);
							}
						}

					} else {  //string
						try {
							method = enc.getClass().getMethod(methodName, String.class);
							method.invoke(enc, value);
							if (!changedEncs.contains(enc)) changedEncs.add(enc);
						} catch (Exception ex) {
							System.out.println(methodName + " -> " + ex.toString());
						}
						//special case: we save the sex on the individual as well, if none is set there
						if (methodName.equals("setSex") && (value != null) && !value.equals("") && !value.equals("unknown") && (enc.getIndividualID() != null)) {
							MarkedIndividual ind = myShepherd.getMarkedIndividual(enc.getIndividualID());
							if ((ind != null) && ((ind.getSex() == null) || ind.getSex().equals("") || ind.getSex().equals("unknown"))) {
								ind.setSex(value);
								System.out.println("setting sex=" + value + " on indiv " + ind.getIndividualID());
							}
						}
					}
				}
			}
		}
		myShepherd.commitDBTransaction();
	}

%>

<div id="save-message">
<%=saveMessage%>
</div>

<table><tr>

<td valign="middle">
 <h1><strong><img align="absmiddle" src="images/occurrence.png" />&nbsp;<%=props.getProperty("occurrence") %></strong>: <%=sharky.getOccurrenceID()%></h1>
<p class="caption"><em><%=props.getProperty("description") %></em></p>
 <table><tr valign="middle">  
  <td>
    <!-- Google PLUS-ONE button -->
<g:plusone size="small" annotation="none"></g:plusone>
</td>
<td>
<!--  Twitter TWEET THIS button -->
<a href="https://twitter.com/share" class="twitter-share-button" data-count="none">Tweet</a>
<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
</td>
<td>
<!-- Facebook LIKE button -->
<div class="fb-like" data-send="false" data-layout="button_count" data-width="100" data-show-faces="false"></div>
</td>
</tr></table> </td></tr></table>

<form method="post" action="occurrence.jsp" id="occform">
<input name="number" type="hidden" value="<%=sharky.getOccurrenceID()%>" />



<p>
<strong>Habitat</strong>
<input name="occ:habitat" value="<%=cleanString(sharky.getHabitat())%>" />
</p>

<p>
<strong>Group Size</strong>
<input name="occ:groupSize" value="<%=cleanString(sharky.getGroupSize())%>" />
</p>

<p>
<strong>Number Territorial Males</strong>
<input name="occ:numTerMales" value="<%=cleanString(sharky.getNumTerMales())%>" />
</p>

<p>
<strong>Number Bachelor Males</strong>
<input name="occ:numBachMales" value="<%=cleanString(sharky.getNumBachMales())%>" />
</p>

<p>
<strong>Number Lactating Females</strong>
<input name="occ:numLactFemales" value="<%=cleanString(sharky.getNumLactFemales())%>" />
</p>

<p>
<strong>Number Non-lactating Females</strong>
<input name="occ:numNonLactFemales" value="<%=cleanString(sharky.getNumNonLactFemales())%>" />
</p>


<div style="position: relative; height: 40px;">

<div style="position: absolute; top: 0; left: 0;">
<strong>Decimal Latitude</strong>
<input name="occ:decimalLatitude" value="<%=cleanString(sharky.getDecimalLatitude())%>" />
</div>

<div style="position: absolute; top: 0; right: 0;">
<strong>Decimal Longitude</strong>
<input name="occ:decimalLongitude" value="<%=cleanString(sharky.getDecimalLongitude())%>" />
</div>

</div>

<p>
<strong>Distance (meters)</strong>
<input name="occ:distance" value="<%=cleanString(sharky.getDistance())%>" />
</p>

<p>
<strong>Bearing (degrees from north)</strong>
<input name="occ:bearing" value="<%=cleanString(sharky.getBearing())%>" />
</p>





<div class="submit">
<input type="submit" name="save" value="Save" />
<div class="note"></div>
</div>

</form>


<script type="text/javascript">
$(document).ready(function() {
	$('#occform input,#occform select').change(function() {
		$('.submit').addClass('changes-made');
		$('.submit .note').html('changes made. please save.');
	});
	$('span.relationship').hover(function(ev) {
//$('tr[data-indiv="07_091"]').hide();
console.log(ev);
		var jel = $(ev.target);
		if (ev.type == 'mouseenter') {
			var p = jel.data('partner');
			$('tr[data-indiv="' + p + '"]').addClass('rel-partner');
		} else {
			$('.rel-partner').removeClass('rel-partner');
		}
	});
	$('.enc-row').each(function(i, el) {
		var eid = el.getAttribute('data-id');
		el.setAttribute('title', 'click for: ' + eid);
	});
	$('.enc-row').click(function(el) {
		var eid = el.currentTarget.getAttribute('data-id');
		var w = window.open('encounters/encounter.jsp?number=' + eid, '_blank');
		w.focus();
		return false;
	});

	$('.col-sex').each(function(i, el) {
		var p = $('<select><option value="">select sex</option><option>unknown</option><option>male</option><option>female</option></select>');
		p.click( function(ev) { ev.stopPropagation(); } );
		p.change(function() {
			columnChange(this);
		});
		p.val($(el).html());
		$(el).html(p);
		//console.log('%o: %o', i, el);
	});

	$('.col-ageAtFirstSighting').each(function(i, el) {
		if (!$(el).parent().data('indiv')) return;
		var p = $('<input style="width: 30px;" placeholder="yrs" />');
		p.click( function(ev) { ev.stopPropagation(); } );
		p.change(function() {
			columnChange(this);
		});
		p.val($(el).html());
		$(el).html(p);
	});

	$('.col-zebraClass').each(function(i, el) {
		var p = $('<select><option value="Unknown">Unknown</option><option>LF</option><option>NLF</option><option>TM</option><option>BM</option><option>JUV</option><option>FOAL</option></select>');
		p.click( function(ev) { ev.stopPropagation(); } );
		p.change(function() {
			columnChange(this);
		});
		p.val($(el).html());
		$(el).html(p);
	});


});


function columnChange(el) {
	var jel = $(el);
	var prop = jel.parent().data('prop');
	var eid = jel.parent().parent().data('id');
	$('[name="' + eid + ':' + prop + '"]').remove();  //clear exisiting
	$('<input>').attr({
		name: eid + ':' + prop,
		type: 'hidden',
		value: jel.val(),
	}).appendTo($('#occform'));

	$('.submit').addClass('changes-made');
	$('.submit .note').html('changes made. please save.');
	
}


var relEid = false;
function relAdd(ev) {
console.log(ev);
	var jel = $(ev.target);
	var eid = jel.parent().parent().data('id');
	relEid = eid;
	ev.stopPropagation();
	$('#relationships-form input[type="text"]').val(undefined);
	$('#relationships-form select').val(undefined);
	$('#relationships-form').appendTo(ev.target).show();
	$('#relationships-form input[type="text"]').focus();
}

function relSave(ev) {
	ev.stopPropagation();
	if (!relEid) return;

	var partner = $('#rel-child-id').val();

	$('<input>').attr({
		name: relEid + ':_relMother',
		type: 'hidden',
		value: partner,
	}).appendTo($('#occform'));
	//$('#rel-child-id').val('');

	$('#row-enc-' + relEid + ' .col-relationships').prepend('<span data-partner="' + partner + '" class="relationship relType-familial relRole-mother">' + partner + '</span>');

	relEid = false;
	$('#relationships-form').hide();
	$('.submit').addClass('changes-made');
	$('.submit .note').html('changes made. please save.');
}

function relCancel(ev) {
	ev.stopPropagation();
	relEid = false;
	$('#relationships-form').hide();
}

</script>


<table id="encounter_report" width="100%">
<tr>

<td align="left" valign="top">

<p><strong><%=sharky.getNumberEncounters()%>
</strong>
  <%=props.getProperty("numencounters") %>
</p> 


<table style="border-spacing: 0;" id="results" width="100%">
  <tr class="lineitem">
      <td class="lineitem" align="left" valign="top" bgcolor="#99CCFF"><strong><%=props.getProperty("date") %></strong></td>
      <td class="lineitem" align="left" valign="top" bgcolor="#99CCFF"><strong><%=props.getProperty("filename") %></strong></td>
    <td class="lineitem" align="left" valign="top" bgcolor="#99CCFF"><strong><%=props.getProperty("individualID") %></strong></td>
    

    <td class="lineitem" align="left" valign="top" bgcolor="#99CCFF"><strong><%=props.getProperty("sex") %></strong></td>
    <td class="lineitem" align="left" valign="top" bgcolor="#99CCFF"><strong>Age first sighted</strong></td>
    <td class="lineitem" align="left" valign="top" bgcolor="#99CCFF"><strong>Class</strong></td>

 <td class="lineitem" align="left" valign="top" bgcolor="#99CCFF"><strong>Mother of</strong></td>
 
  </tr>
  <%

    for (int i = 0; i < total; i++) {
      Encounter enc = dateSortedEncs[i];
      
        Vector encImages = enc.getAdditionalImageNames();
        String imgName = "";
				String encSubdir = enc.subdir();

				MarkedIndividual indiv = null;
    		if((enc.getIndividualID()!=null)&&(!enc.getIndividualID().toLowerCase().equals("unassigned"))){
					indiv = myShepherd.getMarkedIndividual(enc.getIndividualID());
				}
        
          imgName = "/"+CommonConfiguration.getDataDirectoryName(context)+"/encounters/" + encSubdir + "/thumb.jpg";

  %>
  <tr id="row-enc-<%=enc.getEncounterNumber()%>" class="enc-row" data-id="<%=enc.getEncounterNumber()%>" data-indiv="<%=((indiv == null) ? "" : enc.getIndividualID())%>">
      <td class="lineitem enc-date">
<%=enc.getDate()%>
			</td>
			<td class="lineitem enc-filename">
<div title="<%=enc.getImageOriginalName()%>"><%=((enc.getImageOriginalName() == null) ? "" : enc.getImageOriginalName())%></div>
    </td>
    <td class="lineitem">
    	<%
    	if (indiv != null) {
    	%>
    	<a target="_new" onClick="event.stopPropagation(); return true;" href="individuals.jsp?number=<%=enc.getIndividualID()%>"><%=enc.getIndividualID()%></a>
    	<%
    	}
    	else{
    	%>
    	&nbsp;
    	<%
    	}
    	%>
    </td>
<!--
    <td width="100" height="32px" class="lineitem">
    	<a href="http://<%=CommonConfiguration.getURLLocation(request)%>/encounters/encounter.jsp?number=<%=enc.getEncounterNumber()%>">
    		
    		<%
    		//if the encounter has photos, show photo folder icon
    		if((enc.getImages()!=null) && (enc.getImages().size()>0)){
    		%>
    			<img src="images/Crystal_Clear_filesystem_folder_image.png" height="32px" width="*" />
    		<%
    		}
    		
    		//if the encounter has a tissue sample, show an icon
    		if((enc.getTissueSamples()!=null) && (enc.getTissueSamples().size()>0)){
    		%>
    			<img src="images/microscope.gif" height="32px" width="*" />
    		<%
    		}
    		//if the encounter has a measurement, show the measurement icon
    		if(enc.hasMeasurements()){
    		%>	
    			<img src="images/ruler.png" height="32px" width="*" />
        	<%	
    		}
    		%>
    		
    	</a>
    </td>
    <td class="lineitem"><a
      href="http://<%=CommonConfiguration.getURLLocation(request)%>/encounters/encounter.jsp?number=<%=enc.getEncounterNumber()%><%if(request.getParameter("noscript")!=null){%>&noscript=null<%}%>"><%=enc.getEncounterNumber()%>
    </a></td>
-->

<%
String sexValue="&nbsp;";
if(enc.getSex()!=null){sexValue=enc.getSex();}
%>
    <td data-prop="sex" class="col-sex lineitem"><%=sexValue %></td>


<%
	String ageAFS = "";
	if (indiv != null) {
		ageAFS = cleanString(indiv.getAgeAtFirstSighting());
	}
%>
<td class="col-ageAtFirstSighting lineitem" data-prop="ageAtFirstSighting"><%=ageAFS%></td>

<td class="col-zebraClass lineitem" data-prop="zebraClass"><%=cleanString(enc.getZebraClass())%></td>

  <td class="col-relationships lineitem">
    <%
	String iid = enc.getIndividualID();
	if ((iid != null) && !iid.equals("") && !iid.equals("Unassigned")) {
		ArrayList<Relationship> rels = myShepherd.getAllRelationshipsForMarkedIndividual(iid);
		if ((rels != null) && (rels.size() > 0)) {
			for (Relationship r : rels) {
				String partner = r.getMarkedIndividualName1();
				String role = r.getMarkedIndividualRole2();
				String type = r.getType();
				if (partner.equals(iid)) {
					partner = r.getMarkedIndividualName2();
					role = r.getMarkedIndividualRole1();
				}
				if (!role.equals("mother")) continue;  //for lewa, only showing offspring of mother
			%><span data-partner="<%=partner%>" class="relationship relType-<%=type%> relRole-<%=role%>"><%=partner%></span> <%
  			}
		}
  //private String markedIndividualName2;
  //private String markedIndividualRole2;
			%><span class="relationship-none" title="add a relationship" onClick="return relAdd(event);">add</span><%
	}
    %>
    </td>
  </tr>
  <%
      
    } //end for

  %>


</table>


<!-- Start thumbnail gallery -->

<br />
<p>
  <strong><%=props.getProperty("imageGallery") %>
  </strong></p>

    <%
    String[] keywords=keywords=new String[0];
		int numThumbnails = myShepherd.getNumThumbnails(sharky.getEncounters().iterator(), keywords);
		if(numThumbnails>0){	
		%>

<table id="results" border="0" width="100%">
    <%

			
			int countMe=0;
			//Vector thumbLocs=new Vector();
			ArrayList<SinglePhotoVideo> thumbLocs=new ArrayList<SinglePhotoVideo>();
			
			int  numColumns=3;
			int numThumbs=0;
			  if (CommonConfiguration.allowAdoptions(context)) {
				  ArrayList adoptions = myShepherd.getAllAdoptionsForMarkedIndividual(name,context);
				  int numAdoptions = adoptions.size();
				  if(numAdoptions>0){
					  numColumns=2;
				  }
			  }

			try {
				thumbLocs=myShepherd.getThumbnails(request, sharky.getEncounters().iterator(), 1, 99999, keywords);
				numThumbs=thumbLocs.size();
			%>

  <tr valign="top">
 <td>
 <!-- HTML Codes by Quackit.com -->
<div style="text-align:left;border:1px solid black;width:100%;height:400px;overflow-y:scroll;overflow-x:scroll;">

      <%
      						while(countMe<numThumbs){
							//for(int columns=0;columns<numColumns;columns++){
								if(countMe<numThumbs) {
									//String combined ="";
									//if(myShepherd.isAcceptableVideoFile(thumbLocs.get(countMe).getFilename())){
									//	combined = "http://" + CommonConfiguration.getURLLocation(request) + "/images/video.jpg" + "BREAK" + thumbLocs.get(countMe).getCorrespondingEncounterNumber() + "BREAK" + thumbLocs.get(countMe).getFilename();
									//}
									//else{
									//	combined= thumbLocs.get(countMe).getCorrespondingEncounterNumber() + "/" + thumbLocs.get(countMe).getDataCollectionEventID() + ".jpg" + "BREAK" + thumbLocs.get(countMe).getCorrespondingEncounterNumber() + "BREAK" + thumbLocs.get(countMe).getFilename();
							              
									//}

									//StringTokenizer stzr=new StringTokenizer(combined,"BREAK");
									//String thumbLink=stzr.nextToken();
									//String encNum=stzr.nextToken();
									//int fileNamePos=combined.lastIndexOf("BREAK")+5;
									//String fileName=combined.substring(fileNamePos).replaceAll("%20"," ");
									String thumbLink="";
									boolean video=true;
									if(!myShepherd.isAcceptableVideoFile(thumbLocs.get(countMe).getFilename())){
										thumbLink="/"+CommonConfiguration.getDataDirectoryName(context)+"/encounters/"+Encounter.subdir(thumbLocs.get(countMe).getCorrespondingEncounterNumber())+"/"+thumbLocs.get(countMe).getDataCollectionEventID()+".jpg";
										video=false;
									}
									else{
										thumbLink="http://"+CommonConfiguration.getURLLocation(request)+"/images/video.jpg";
										
									}
									String link="/"+CommonConfiguration.getDataDirectoryName(context)+"/encounters/"+Encounter.subdir(thumbLocs.get(countMe).getCorrespondingEncounterNumber())+"/"+thumbLocs.get(countMe).getFilename();
						
							%>

   
    
      <table align="left" width="<%=100/numColumns %>%">
        <tr>
          <td valign="top">
			
              <%
			if(isOwner){
												%>
            <a href="<%=link%>" 
            <%
            if(thumbLink.indexOf("video.jpg")==-1){
            %>
            	class="highslide" onclick="return hs.expand(this)"
            <%
            }
            %>
            >
            <%
            }
             %>
              <img src="<%=thumbLink%>" alt="photo" border="1" title="Click to enlarge"/>
              <%
                if (isOwner) {
              %>
            </a>
              <%
			}
            
			%>

            <div 
            <%
            if(!thumbLink.endsWith("video.jpg")){
            %>
            class="highslide-caption"
            <%
            }
            %>
            >

              <table>
                <tr>
                  <td align="left" valign="top">

                    <table>
                      <%

                        int kwLength = keywords.length;
                        Encounter thisEnc = myShepherd.getEncounter(thumbLocs.get(countMe).getCorrespondingEncounterNumber());
                      %>
                      
                      

                      <tr>
                        <td><span
                          class="caption"><%=props.getProperty("location") %>: <%=thisEnc.getLocation() %></span>
                        </td>
                      </tr>
                      <tr>
                        <td><span
                          class="caption"><%=props.getProperty("locationID") %>: <%=thisEnc.getLocationID() %></span>
                        </td>
                      </tr>
                      <tr>
                        <td><span
                          class="caption"><%=props.getProperty("date") %>: <%=thisEnc.getDate() %></span>
                        </td>
                      </tr>
                      <tr>
                        <td><span class="caption"><%=props.getProperty("catalogNumber") %>: <a
                          href="encounters/encounter.jsp?number=<%=thisEnc.getCatalogNumber() %>"><%=thisEnc.getCatalogNumber() %>
                        </a></span></td>
                      </tr>
                        <tr>
                        <td><span class="caption"><%=props.getProperty("individualID") %>: 
                        
                        <%
                        		if((thisEnc.getIndividualID()!=null)&&(!thisEnc.getIndividualID().toLowerCase().equals("unassigned"))){
                        		%>
                        			<a href="individuals.jsp?number=<%=thisEnc.getIndividualID() %>"><%=thisEnc.getIndividualID() %></a>
                        		<%
                        		}
                        		%>
                        
                        </span></td>
                      </tr>
                      <%
                        if (thisEnc.getVerbatimEventDate() != null) {
                      %>
                      <tr>

                        <td><span
                          class="caption"><%=props.getProperty("verbatimEventDate") %>: <%=thisEnc.getVerbatimEventDate() %></span>
                        </td>
                      </tr>
                      <%
                        }
                      %>
                      <tr>
                        <td><span class="caption">
											<%=props.getProperty("matchingKeywords") %>
											<%
											 //while (allKeywords2.hasNext()) {
					                          //Keyword word = (Keyword) allKeywords2.next();
					                          
					                          
					                          //if (word.isMemberOf(encNum + "/" + fileName)) {
											  //if(thumbLocs.get(countMe).getKeywords().contains(word)){
					                        	  
					                            //String renderMe = word.getReadableName();
												List<Keyword> myWords = thumbLocs.get(countMe).getKeywords();
												int myWordsSize=myWords.size();
					                            for (int kwIter = 0; kwIter<myWordsSize; kwIter++) {
					                              //String kwParam = keywords[kwIter];
					                              //if (kwParam.equals(word.getIndexname())) {
					                              //  renderMe = "<strong>" + renderMe + "</strong>";
					                              //}
					                      		 	%>
					 								<br/><%= ("<strong>" + myWords.get(kwIter).getReadableName() + "</strong>")%>
					 								<%
					                            }




					                          //    }
					                       // } 

                          %>
										</span></td>
                      </tr>
                    </table>
                    <br/>

                    <%
                      if (CommonConfiguration.showEXIFData(context)) {
                   
            	if(!thumbLink.endsWith("video.jpg")){
           		 %>							
					<span class="caption">
						<div class="scroll">	
						<span class="caption">
					<%
            if ((thumbLocs.get(countMe).getFilename().toLowerCase().endsWith("jpg")) || (thumbLocs.get(countMe).getFilename().toLowerCase().endsWith("jpeg"))) {
              File exifImage = new File(encountersDir.getAbsolutePath() + "/" + Encounter.subdir(thisEnc.getCatalogNumber()) + "/" + thumbLocs.get(countMe).getFilename());
              	%>
            	<%=Util.getEXIFDataFromJPEGAsHTML(exifImage) %>
            	<%
               }
                %>
   									
   								
   								</span>
            </div>
   								</span>
   			<%
            	}
   			%>


                  </td>
                  <%
                    }
                  %>
                </tr>
              </table>
            </div>
            

</td>
</tr>

 <%
            if(!thumbLink.endsWith("video.jpg")){
 %>
<tr>
  <td><span class="caption"><%=props.getProperty("location") %>: <%=thisEnc.getLocation() %></span>
  </td>
</tr>
<tr>
  <td><span
    class="caption"><%=props.getProperty("locationID") %>: <%=thisEnc.getLocationID() %></span></td>
</tr>
<tr>
  <td><span class="caption"><%=props.getProperty("date") %>: <%=thisEnc.getDate() %></span></td>
</tr>
<tr>
  <td><span class="caption"><%=props.getProperty("catalogNumber") %>: <a
    href="encounters/encounter.jsp?number=<%=thisEnc.getCatalogNumber() %>"><%=thisEnc.getCatalogNumber() %>
  </a></span></td>
</tr>
                        <tr>
                        	<td>
                        		<span class="caption"><%=props.getProperty("individualID") %>: 
                        		<%
                        		if((thisEnc.getIndividualID()!=null)&&(!thisEnc.getIndividualID().toLowerCase().equals("unassigned"))){
                        		%>
                        			<a href="individuals.jsp?number=<%=thisEnc.getIndividualID() %>"><%=thisEnc.getIndividualID() %></a>
                        		<%
                        		}
                        		%>
                        		</span>
                        	</td>
                      </tr>
<tr>
  <td><span class="caption">
											<%=props.getProperty("matchingKeywords") %>
											<%
                        //int numKeywords=myShepherd.getNumKeywords();
											 //while (allKeywords2.hasNext()) {
					                          //Keyword word = (Keyword) allKeywords2.next();
					                          
					                          
					                          //if (word.isMemberOf(encNum + "/" + fileName)) {
											  //if(thumbLocs.get(countMe).getKeywords().contains(word)){
					                        	  
					                            //String renderMe = word.getReadableName();
												//List<Keyword> myWords = thumbLocs.get(countMe).getKeywords();
												//int myWordsSize=myWords.size();
					                            for (int kwIter = 0; kwIter<myWordsSize; kwIter++) {
					                              //String kwParam = keywords[kwIter];
					                              //if (kwParam.equals(word.getIndexname())) {
					                              //  renderMe = "<strong>" + renderMe + "</strong>";
					                              //}
					                      		 	%>
					 								<br/><%= ("<strong>" + myWords.get(kwIter).getReadableName() + "</strong>")%>
					 								<%
					                            }




					                          //    }
					                       // } 

                          %>
										</span></td>
</tr>
<%

            }
%>
</table>

<%

      countMe++;
    } //end if
  } //endFor
%>
</div>

</td>
</tr>
<%



} catch (Exception e) {
  e.printStackTrace();
%>
<tr>
  <td>
    <p><%=props.getProperty("error")%>
    </p>.
  </td>
</tr>
<%
  }
%>

</table>
</div>
<%
} else {
%>

<p><%=props.getProperty("noImages")%></p>

<%
  }
%>

</table>
<!-- end thumbnail gallery -->



<br/>



<%

  if (isOwner) {
%>
<br />


<br />
<p><img align="absmiddle" src="images/Crystal_Clear_app_kaddressbook.gif"> <strong><%=props.getProperty("researcherComments") %>
</strong>: </p>

<div style="text-align:left;border:1px solid black;width:100%;height:400px;overflow-y:scroll;overflow-x:scroll;">

<p><%=sharky.getComments().replaceAll("\n", "<br>")%>
</p>
</div>
<%
  if (CommonConfiguration.isCatalogEditable(context)) {
%>
<p>

<form action="OccurrenceAddComment" method="post" name="addComments">
  <input name="user" type="hidden" value="<%=request.getRemoteUser()%>" id="user">
  <input name="number" type="hidden" value="<%=sharky.getOccurrenceID()%>" id="number">
  <input name="action" type="hidden" value="comments" id="action">

  <p><textarea name="comments" cols="60" id="comments"></textarea> <br>
    <input name="Submit" type="submit" value="<%=props.getProperty("addComments") %>">
</form>
</p>
<%
    } //if isEditable


  } //if isOwner
%>


</p>


</td>
</tr>


</table>

</td>
</tr>
</table>
</div><!-- end maintext -->
</div><!-- end main-wide -->



<div id="relationships-form" onClick="event.stopPropagation(); return false;">
	<div class="rel-sub">
	<b>Mother</b> of individual ID:<br />
	<input type="text" id="rel-child-id" />
	</div>

	<input type="button" value="OK" onClick="return relSave(event)" />

	<input type="button" value="cancel" onClick="return relCancel(event)" />
</div>

<!-- old complete one for prosperity
<div class="rel-sub">
<label for="rel-type">type</label>
<select id="rel-type">
<option>familial</option>
<option>social grouping</option>
</select>
</div>

<div class="rel-sub">
<label>this individual's role:</label>
<select id="rel-this-role">
<option>member</option>
<option>mother</option>
<option>calf</option>
</select>
</div>

<div class="rel-sub">
<label>other individual:</label>
<input type="text" id="rel-other-id" />
<label>role:</label>
<select id="rel-other-role">
<option>member</option>
<option>mother</option>
<option>calf</option>
</select>
</div>

<div class="rel-sub">
<label>social unit name:</label>
<input type="text" id="rel-social-unit-name" />
</div>

<input type="button" value="save" onClick="return relSave(event)" />
<input type="button" value="cancel" onClick="return relCancel(event)" />

</div>
-->




<br />
<table>
<tr>
<td>

      <jsp:include page="individualMapEmbed.jsp" flush="true">
        <jsp:param name="occurrence_number" value="<%=name%>"/>
      </jsp:include>
</td>
</tr>
</table>
<%

} 

//could not find the specified individual!
else {



%>


<p><%=props.getProperty("matchingRecord") %>:
<br /><strong><%=request.getParameter("number")%>
</strong><br/><br />
  <%=props.getProperty("tryAgain") %>
</p>


<%
      }
	  %>
      </td>
</tr>
</table>

</div><!-- end maintext -->
<jsp:include page="footer.jsp" flush="true"/>
</div><!-- end main-wide -->
      
      <%
    
  } catch (Exception eSharks_jsp) {
    System.out.println("Caught and handled an exception in occurrence.jsp!");
    eSharks_jsp.printStackTrace();
  }



  myShepherd.rollbackDBTransaction();
  myShepherd.closeDBTransaction();

%>

</div>

</div>

<!-- end page -->
<!--end wrapper -->
</body>
</html>

