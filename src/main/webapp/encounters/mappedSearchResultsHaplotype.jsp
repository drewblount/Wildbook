<%@ page contentType="text/html; charset=utf-8" language="java"
         import="org.ecocean.servlet.ServletUtilities,java.util.Vector,java.util.Properties,org.ecocean.genetics.*,java.util.*,java.net.URI, org.ecocean.*" %>


  <%
  String context="context0";
  context=ServletUtilities.getContext(request);

    String langCode=ServletUtilities.getLanguageCode(request);
    
    Properties encprops = new Properties();
    //encprops.load(getClass().getResourceAsStream("/bundles/" + langCode + "/mappedSearchResults.properties"));
    encprops=ShepherdProperties.getProperties("mappedSearchResults.properties", langCode, context);

    
    
    Properties haploprops = new Properties();
    //haploprops.load(getClass().getResourceAsStream("/bundles/haplotypeColorCodes.properties"));
	haploprops=ShepherdProperties.getProperties("haplotypeColorCodes.properties", "",context);
    
    //get our Shepherd
    Shepherd myShepherd = new Shepherd(context);





    //set up paging of results
    int startNum = 1;
    int endNum = 10;
    try {

      if (request.getParameter("startNum") != null) {
        startNum = (new Integer(request.getParameter("startNum"))).intValue();
      }
      if (request.getParameter("endNum") != null) {
      
        endNum = (new Integer(request.getParameter("endNum"))).intValue();
      }

    } catch (NumberFormatException nfe) {
      startNum = 1;
      endNum = 10;
    }
    int numResults = 0;

    //set up the vector for matching encounters
    Vector rEncounters = new Vector();

    //kick off the transaction
    myShepherd.beginDBTransaction();

    //start the query and get the results
    String order = "";
    request.setAttribute("gpsOnly", "yes");
    EncounterQueryResult queryResult = EncounterQueryProcessor.processQuery(myShepherd, request, order);
    rEncounters = queryResult.getResult();
    
    //let's prep the HashTable for the pie chart
    List<String> allHaplos2=myShepherd.getAllHaplotypes(); 
    int numHaplos2 = allHaplos2.size();
	
    		
  %>

  
<style type="text/css">
.full_screen_map {
position: absolute !important;
top: 0px !important;
left: 0px !important;
z-index: 1 !imporant;
width: 100% !important;
height: 100% !important;
margin-top: 0px !important;
margin-bottom: 8px !important;
</style>
  

<style type="text/css">
  #tabmenu {
    color: #000;
    border-bottom: 1px solid #CDCDCD;
    margin: 12px 0px 0px 0px;
    padding: 0px;
    z-index: 1;
    padding-left: 10px
  }

  #tabmenu li {
    display: inline;
    overflow: hidden;
    list-style-type: none;
  }

  #tabmenu a, a.active {
    color: #000;
    background: #E6EEEE;
    font: 0.5em "Arial, sans-serif;
    border: 1px solid #CDCDCD;
    padding: 2px 5px 0px 5px;
    margin: 0;
    text-decoration: none;
    border-bottom: 0px solid #FFFFFF;
  }

  #tabmenu a.active {
    background: #8DBDD8;
    color: #000000;
    border-bottom: 1px solid #8DBDD8;
  }

  #tabmenu a:hover {
    color: #000;
    background: #8DBDD8;
  }

  #tabmenu a:visited {
    
  }

  #tabmenu a.active:hover {
    color: #000;
    border-bottom: 1px solid #8DBDD8;
  }
  
</style>
  
      <script>
        function getQueryParameter(name) {
          name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
          var regexS = "[\\?&]" + name + "=([^&#]*)";
          var regex = new RegExp(regexS);
          var results = regex.exec(window.location.href);
          if (results == null)
            return "";
          else
            return results[1];
        }
  </script>
  
  
  <jsp:include page="../header.jsp" flush="true"/>

    <script src="http://maps.google.com/maps/api/js?sensor=false"></script>
 



    <script type="text/javascript">
      function initialize() {
        var center = new google.maps.LatLng(0,0);
        var mapZoom = 3;
    	if($("#map_canvas").hasClass("full_screen_map")){mapZoom=3;}
    	var bounds = new google.maps.LatLngBounds();

        var map = new google.maps.Map(document.getElementById('map_canvas'), {
          zoom: mapZoom,
          center: center,
          mapTypeId: google.maps.MapTypeId.HYBRID
        });
    	  //adding the fullscreen control to exit fullscreen
    	  var fsControlDiv = document.createElement('DIV');
    	  var fsControl = new FSControl(fsControlDiv, map);
    	  fsControlDiv.index = 1;
    	  map.controls[google.maps.ControlPosition.TOP_RIGHT].push(fsControlDiv);
        var markers = [];
 
 
        
        <%
        //Vector haveGPSData = new Vector();
        int rEncountersSize=rEncounters.size();
        int count = 0;
      

          
      
        
      
if(rEncounters.size()>0){
	int havegpsSize=rEncounters.size();
 for(int y=0;y<havegpsSize;y++){
	 Encounter thisEnc=(Encounter)rEncounters.get(y);
		String encSubdir = thisEnc.subdir();
	 

 %>
          
          var latLng = new google.maps.LatLng(<%=thisEnc.getDecimalLatitude()%>, <%=thisEnc.getDecimalLongitude()%>);
          bounds.extend(latLng);
           <%
           

           
           //currently unused programatically
           String markerText="";
           
           String haploColor="CC0000";
           if((encprops.getProperty("defaultMarkerColor")!=null)&&(!encprops.getProperty("defaultMarkerColor").trim().equals(""))){
        	   haploColor=encprops.getProperty("defaultMarkerColor");
           }
           
           
           if((thisEnc.getHaplotype()!=null)&&(haploprops.getProperty(thisEnc.getHaplotype())!=null)){
        	  if(!haploprops.getProperty(thisEnc.getHaplotype()).trim().equals("")){ haploColor = haploprops.getProperty(thisEnc.getHaplotype());}
           }

           
           %>
           var marker<%=y%> = new google.maps.Marker({
        	   icon: 'https://chart.googleapis.com/chart?chst=d_map_pin_letter&chld=|<%=haploColor%>',
        	   position:latLng,
        	   map:map
        	   });

           google.maps.event.addListener(marker<%=y%>,'click', function() {
           	
          
          
         
      	<%
    	String individualLinkString="";
    	//if this is a MarkedIndividual, provide a link to it
    	if((thisEnc.isAssignedToMarkedIndividual()!=null)&&(!thisEnc.isAssignedToMarkedIndividual().toLowerCase().equals("unassigned"))){
    		individualLinkString="<strong><a target=\"_blank\" href=\"http://"+CommonConfiguration.getURLLocation(request)+"/individuals.jsp?number="+thisEnc.isAssignedToMarkedIndividual()+"\">"+thisEnc.isAssignedToMarkedIndividual()+"</a></strong><br />";
    	}
    	%>
    	(new google.maps.InfoWindow({content: '<%=individualLinkString %><table><tr><td><img align=\"top\" border=\"1\" src=\"/<%=CommonConfiguration.getDataDirectoryName(context)%>/encounters/<%=encSubdir%>/thumb.jpg\"></td><td>Date: <%=thisEnc.getDate()%><%if(thisEnc.getSex()!=null){%><br />Sex: <%=thisEnc.getSex()%><%}%><%if(thisEnc.getSizeAsDouble()!=null){%><br />Size: <%=thisEnc.getSize()%> m<%}%><br /><br /><a target=\"_blank\" href=\"http://<%=CommonConfiguration.getURLLocation(request)%>/encounters/encounter.jsp?number=<%=thisEnc.getEncounterNumber()%>\" >Go to encounter</a></td></tr></table>'})).open(map, this);
 
          
           
           });
 
	
          markers.push(marker<%=y%>);
          map.fitBounds(bounds); 
 
 <%
 
	 }
} 

myShepherd.rollbackDBTransaction();
 %>
 
 //markerClusterer = new MarkerClusterer(map, markers, {gridSize: 10});

      }
      
     
      
      function fullScreen(){
    		$("#map_canvas").addClass('full_screen_map');
    		$('html, body').animate({scrollTop:0}, 'slow');
    		initialize();
    		
    		//hide header
    		$("#header_menu").hide();
    		
    		if(overlaysSet){overlaysSet=false;setOverlays();}
    		//alert("Trying to execute fullscreen!");
    	}


    	function exitFullScreen() {
    		$("#header_menu").show();
    		$("#map_canvas").removeClass('full_screen_map');

    		initialize();
    		if(overlaysSet){overlaysSet=false;setOverlays();}
    		//alert("Trying to execute exitFullScreen!");
    	}


    	//making the exit fullscreen button
    	function FSControl(controlDiv, map) {

    	  // Set CSS styles for the DIV containing the control
    	  // Setting padding to 5 px will offset the control
    	  // from the edge of the map
    	  controlDiv.style.padding = '5px';

    	  // Set CSS for the control border
    	  var controlUI = document.createElement('DIV');
    	  controlUI.style.backgroundColor = '#f8f8f8';
    	  controlUI.style.borderStyle = 'solid';
    	  controlUI.style.borderWidth = '1px';
    	  controlUI.style.borderColor = '#a9bbdf';;
    	  controlUI.style.boxShadow = '0 1px 3px rgba(0,0,0,0.5)';
    	  controlUI.style.cursor = 'pointer';
    	  controlUI.style.textAlign = 'center';
    	  controlUI.title = 'Toggle the fullscreen mode';
    	  controlDiv.appendChild(controlUI);

    	  // Set CSS for the control interior
    	  var controlText = document.createElement('DIV');
    	  controlText.style.fontSize = '12px';
    	  controlText.style.fontWeight = 'bold';
    	  controlText.style.color = '#000000';
    	  controlText.style.paddingLeft = '4px';
    	  controlText.style.paddingRight = '4px';
    	  controlText.style.paddingTop = '3px';
    	  controlText.style.paddingBottom = '2px';
    	  controlUI.appendChild(controlText);
    	  //toggle the text of the button
    	   if($("#map_canvas").hasClass("full_screen_map")){
    	      controlText.innerHTML = 'Exit Fullscreen';
    	    } else {
    	      controlText.innerHTML = 'Fullscreen';
    	    }

    	  // Setup the click event listeners: toggle the full screen

    	  google.maps.event.addDomListener(controlUI, 'click', function() {

    	   if($("#map_canvas").hasClass("full_screen_map")){
    	    exitFullScreen();
    	    } else {
    	    fullScreen();
    	    }
    	  });

    	}

      
      
      google.maps.event.addDomListener(window, 'load', initialize);
    </script>
    
<div class="container maincontent">

 
       <h1 class="intro"><%=encprops.getProperty("title")%></h1>
      
 <ul id="tabmenu">
 
   <li><a href="searchResults.jsp?<%=request.getQueryString() %>"><%=encprops.getProperty("table")%>
   </a></li>
   <li><a
     href="thumbnailSearchResults.jsp?<%=request.getQueryString() %>"><%=encprops.getProperty("matchingImages")%>
   </a></li>
   <li><a class="active"><%=encprops.getProperty("mappedResults") %>
   </a></li>
   <li><a
     href="../xcalendar/calendar2.jsp?<%=request.getQueryString() %>"><%=encprops.getProperty("resultsCalendar")%>
   </a></li>
         <li><a
     href="searchResultsAnalysis.jsp?<%=request.getQueryString() %>"><%=encprops.getProperty("analysis")%>
   </a></li>
    <li><a
     href="exportSearchResults.jsp?<%=request.getQueryString() %>"><%=encprops.getProperty("export")%>
   </a></li>
 </ul>

 
 
 
 
 <br />
 

 <%
 
 Properties map_props = new Properties();
 //map_props.load(getClass().getResourceAsStream("/bundles/" + langCode + "/mappedSearchResults.properties"));
 map_props=ShepherdProperties.getProperties("mappedSearchResults.properties", langCode);

 //read from the encprops property file the value determining how many entries to map. Thousands can cause map delay or failure from Google.
 int numberResultsToMap = -1;

 %>
 
 <p><%=map_props.getProperty("aspects") %>:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
  <%
  boolean hasMoreProps=true;
  int propsNum=0;
  while(hasMoreProps){
	if((map_props.getProperty("displayAspectName"+propsNum)!=null)&&(map_props.getProperty("displayAspectFile"+propsNum)!=null)){
		%>
		<a href="<%=map_props.getProperty("displayAspectFile"+propsNum)%>?<%=request.getQueryString()%>"><%=map_props.getProperty("displayAspectName"+propsNum) %></a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		
		<%
		propsNum++;
	}
	else{hasMoreProps=false;}
  }
  %>
</p>
 <%
   if (rEncounters.size() > 0) {
     myShepherd.beginDBTransaction();
     try {
 %>
 
<p><%=encprops.getProperty("mapNote")%></p>
 
 <div id="map-container">
 
 
 <table cellpadding="3">
 <tr>
 <td valign="top">
<div id="map_canvas" style="width: 770px; height: 510px; "> </div>
 </td>
 <td valign="top">
 <table>
 <tr><th>Haplotype Color Key</th></tr>
                    <%
                    String haploColor="CC0000";
                   if((encprops.getProperty("defaultMarkerColor")!=null)&&(!encprops.getProperty("defaultMarkerColor").trim().equals(""))){
                	   haploColor=encprops.getProperty("defaultMarkerColor");
                   }   
                   for(int yy=0;yy<numHaplos2;yy++){
                       String haplo=allHaplos2.get(yy);
                       if((haploprops.getProperty(haplo)!=null)&&(!haploprops.getProperty(haplo).trim().equals(""))){
                     	  haploColor = haploprops.getProperty(haplo);
                        }
					%>
					<tr bgcolor="#<%=haploColor%>"><td><strong><%=haplo %></strong></td></tr>
					<%
                   }
                   if((encprops.getProperty("defaultMarkerColor")!=null)&&(!encprops.getProperty("defaultMarkerColor").trim().equals(""))){
                	   haploColor=encprops.getProperty("defaultMarkerColor");
                	   %>
                	   <tr bgcolor="#<%=haploColor%>"><td><strong>Unknown</strong></td></tr>
                	   <%
                   }  
                   
                   %>

 </table>
 </td>
 </tr>
 </table>

 </div>
 

 
 <%
 
     } 
     catch (Exception e) {
       e.printStackTrace();
     }
 
   }
 else {
 %>
 <p><%=encprops.getProperty("noGPS")%></p>
 <%
 }  

 
 
   myShepherd.rollbackDBTransaction();
   myShepherd.closeDBTransaction();
   rEncounters = null;
   //haveGPSData = null;
 
%>
 <table>
  <tr>
    <td align="left">

      <p><strong><%=encprops.getProperty("queryDetails")%>
      </strong></p>

      <p class="caption"><strong><%=encprops.getProperty("prettyPrintResults") %>
      </strong><br/>
        <%=queryResult.getQueryPrettyPrint().replaceAll("locationField", encprops.getProperty("location")).replaceAll("locationCodeField", encprops.getProperty("locationID")).replaceAll("verbatimEventDateField", encprops.getProperty("verbatimEventDate")).replaceAll("alternateIDField", encprops.getProperty("alternateID")).replaceAll("behaviorField", encprops.getProperty("behavior")).replaceAll("Sex", encprops.getProperty("sex")).replaceAll("nameField", encprops.getProperty("nameField")).replaceAll("selectLength", encprops.getProperty("selectLength")).replaceAll("numResights", encprops.getProperty("numResights")).replaceAll("vesselField", encprops.getProperty("vesselField"))%>
      </p>

      <p class="caption"><strong><%=encprops.getProperty("jdoql")%>
      </strong><br/>
        <%=queryResult.getJDOQLRepresentation()%>
      </p>

    </td>
  </tr>
</table>
</div>

 
 <jsp:include page="../footer.jsp" flush="true"/>

