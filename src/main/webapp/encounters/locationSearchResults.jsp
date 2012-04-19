<%--
  ~ The Shepherd Project - A Mark-Recapture Framework
  ~ Copyright (C) 2011 Jason Holmberg
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
         import="javax.jdo.Query,org.springframework.mock.web.MockHttpServletRequest,java.util.Vector,java.util.Properties,org.ecocean.genetics.*,java.util.*,java.net.URI, org.ecocean.*" %>



<html>
<head>

<%!
public double getHaplotypeFrequencyForSubpopulation(List rIndividuals, String haplotype, Shepherd myShepherd){
	System.out.println("Starting getHaplotypeFreq...");
	double numMatches=0;
	int numIndies=rIndividuals.size();
	int numIndiesWithHaplotypes=0;
	for(int p=0;p<numIndies;p++){
		//String indie=(String)rIndividuals.get(p);
		MarkedIndividual mi= (MarkedIndividual)rIndividuals.get(p);
		if(mi.getHaplotype()!=null){numIndiesWithHaplotypes++;}
		if((mi.getHaplotype()!=null)&&(mi.getHaplotype().trim().equals(haplotype.trim()))){
			numMatches++;
		}
	}
	//System.out.println("Haplotype freq for "+haplotype+": "+(numMatches/numIndies));
	return (numMatches/numIndiesWithHaplotypes);
}
%>



  <%


    //let's load encounterSearch.properties
    String langCode = "en";
    if (session.getAttribute("langCode") != null) {
      langCode = (String) session.getAttribute("langCode");
    }
    Properties encprops = new Properties();
    encprops.load(getClass().getResourceAsStream("/bundles/" + langCode + "/locationSearchResults.properties"));

    Properties haploprops = new Properties();
    haploprops.load(getClass().getResourceAsStream("/bundles/haplotypeColorCodes.properties"));

    
    //get our Shepherd
    Shepherd myShepherd = new Shepherd();






    int numResults = 0;

    //set up the vector for matching encounters
    Vector rEncounters3 = new Vector();
    Vector rEncounters4 = new Vector();

    //kick off the transaction
    myShepherd.beginDBTransaction();

    //start the query and get the results
    String order = "";
    //EncounterQueryResult queryResult1 = EncounterQueryProcessor.processQuery(myShepherd, request, order);
    HttpServletRequest request1=(MockHttpServletRequest)session.getAttribute("locationSearch1");
    MarkedIndividualQueryResult queryResult1 = IndividualQueryProcessor.processQuery(myShepherd, request1, order);
    //System.out.println(((MockHttpServletRequest)session.getAttribute("locationSearch1")).getQueryString());
    rEncounters3 = queryResult1.getResult();
    MarkedIndividualQueryResult queryResult2 = IndividualQueryProcessor.processQuery(myShepherd, request, order);
    rEncounters4 = queryResult2.getResult();
    
    //let's also get lists of marked individuals
    // Query query1=myShepherd.getPM().newQuery(queryResult1.getJDOQLRepresentation().replaceFirst("SELECT FROM", "SELECT DISTINCT individualID FROM") + " && (individualID != \"Unassigned\")");
    // List query1Results = (List)query1.execute();
    
    //Query query2=myShepherd.getPM().newQuery(queryResult2.getJDOQLRepresentation().replaceFirst("SELECT FROM", "SELECT DISTINCT individualID FROM") + " && (individualID != \"Unassigned\")");
    //List query2Results = (List)query2.execute(); 
    
    List matchedIndividuals = new ArrayList();
    int query1Size=rEncounters3.size();
    for(int y=0;y<query1Size;y++){
    	matchedIndividuals.add(rEncounters3.get(y));
    }
    
   //for(int y=0;y<matchedIndividuals.size();y++){
   // 	if(!query2Results.contains(matchedIndividuals.get(y))){matchedIndividuals.remove(y);y--;}
   //}
    
    matchedIndividuals.retainAll(rEncounters4);
    int numMatchedIndividuals=matchedIndividuals.size();
    
    //let's prep the HashTable for the haplo pie chart
    ArrayList<String> allHaplos2=myShepherd.getAllHaplotypes(); 
    int numHaplos2 = allHaplos2.size();
    Hashtable<String,Integer> pieHashtable1 = new Hashtable<String,Integer>();
    Hashtable<String,Integer> pieHashtable2 = new Hashtable<String,Integer>();
 	for(int gg=0;gg<numHaplos2;gg++){
 		String thisHaplo=allHaplos2.get(gg);
 		pieHashtable1.put(thisHaplo, new Integer(0));
 		pieHashtable2.put(thisHaplo, new Integer(0));
 	}
    
 	//let's prep the HashTables for the sex pie charts
 	Hashtable<String,Integer> sexHashtable1 = new Hashtable<String,Integer>();
 	sexHashtable1.put("male", new Integer(0));
 	sexHashtable1.put("female", new Integer(0));
 	sexHashtable1.put("unknown", new Integer(0));
 	
 	Hashtable<String,Integer> sexHashtable2 = new Hashtable<String,Integer>();
 	sexHashtable2.put("male", new Integer(0));
 	sexHashtable2.put("female", new Integer(0));
 	sexHashtable2.put("unknown", new Integer(0));
 	
 	
 	int resultSize1=rEncounters3.size();
 	int resultSize2=rEncounters4.size();
 	
	//more results1 analysis 	
 	 ArrayList<String> markedIndividuals1=new ArrayList<String>();
 	 for(int y=0;y<resultSize1;y++){
 		 MarkedIndividual thisEnc=(MarkedIndividual)rEncounters3.get(y);
 		 if((!markedIndividuals1.contains(thisEnc.getIndividualID()))){markedIndividuals1.add(thisEnc.getIndividualID());}
 		 //haplotype ie chart prep
 		 if(thisEnc.getHaplotype()!=null){
      	   if(pieHashtable1.containsKey(thisEnc.getHaplotype().trim())){
      		   Integer thisInt = pieHashtable1.get(thisEnc.getHaplotype().trim())+1;
      		   pieHashtable1.put(thisEnc.getHaplotype().trim(), thisInt);
      	   }
 	 	}
 		 
 	    //sex pie chart 	 
 		if(thisEnc.getSex().equals("male")){
 		   Integer thisInt = sexHashtable1.get("male")+1;
  		   sexHashtable1.put("male", thisInt);
 		}
 		else if(thisEnc.getSex().equals("female")){
  		   Integer thisInt = sexHashtable1.get("female")+1;
  		   sexHashtable1.put("female", thisInt);
 		}
 	    else{
 	    	Integer thisInt = sexHashtable1.get("unknown")+1;
   		    sexHashtable1.put("unknown", thisInt);
 	    }
 		 
 	 }	
 	 //end results analysis 1
 	 
 	 //more results2 analysis 	
 	 ArrayList<String> markedIndividuals2=new ArrayList<String>();
 	 for(int y=0;y<resultSize2;y++){
 		 MarkedIndividual thisEnc=(MarkedIndividual)rEncounters4.get(y);
 		 if((!markedIndividuals2.contains(thisEnc.getIndividualID()))){markedIndividuals2.add(thisEnc.getIndividualID());}
 		 //haplotype ie chart prep
 		 if(thisEnc.getHaplotype()!=null){
      	   if(pieHashtable2.containsKey(thisEnc.getHaplotype().trim())){
      		   Integer thisInt = pieHashtable2.get(thisEnc.getHaplotype().trim())+1;
      		   pieHashtable2.put(thisEnc.getHaplotype().trim(), thisInt);
      	   }
 	 	}
 		 
 	    //sex pie chart 	 
 		if(thisEnc.getSex().equals("male")){
 		   Integer thisInt = sexHashtable2.get("male")+1;
  		   sexHashtable2.put("male", thisInt);
 		}
 		else if(thisEnc.getSex().equals("female")){
  		   Integer thisInt = sexHashtable2.get("female")+1;
  		   sexHashtable2.put("female", thisInt);
 		}
 	    else{
 	    	Integer thisInt = sexHashtable2.get("unknown")+1;
   		    sexHashtable2.put("unknown", thisInt);
 	    }
 		 
 	 }	
 	 //end results analysis 2
 	 
 
 	 
  %>

  <title><%=CommonConfiguration.getHTMLTitle()%>
  </title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  <meta name="Description" content="<%=CommonConfiguration.getHTMLDescription()%>"/>
  <meta name="Keywords" content="<%=CommonConfiguration.getHTMLKeywords()%>"/>
  <meta name="Author" content="<%=CommonConfiguration.getHTMLAuthor()%>"/>
  <link href="<%=CommonConfiguration.getCSSURLLocation(request)%>" rel="stylesheet" type="text/css"/>
  <link rel="shortcut icon" href="<%=CommonConfiguration.getHTMLShortcutIcon()%>"/>


    <style type="text/css">
      body {
        margin: 0;
        padding: 10px 20px 20px;
        font-family: Arial;
        font-size: 16px;
      }



      #map {
        width: 600px;
        height: 400px;
      }
      
      table.comparison tr td{
      	vertical-align: top;
      }
      
      table.comparison tr{
      	vertical-align: top;
      }

    </style>
  


  


<script src="http://maps.google.com/maps/api/js?sensor=false"></script>
    
<script type="text/javascript" src="https://www.google.com/jsapi"></script>

<script type="text/javascript">

//let's build some maps

var center = new google.maps.LatLng(0, 0);
var map1;
var map2;

var selectedRectangle1;
var selectedRectangle2;

  function initialize() {
	//alert("initializing map!");
	//overlaysSet=false;
	var mapZoom = 1;



	  



		
		<%
		
        //set the previous maps search box if set
        if((request1.getParameter("ne_lat")!=null) && (request1.getParameter("ne_long")!=null) && (request1.getParameter("sw_lat")!=null) && (request1.getParameter("ne_long")!=null)&&(!request1.getParameter("ne_lat").trim().equals("")) &&(!request1.getParameter("ne_long").trim().equals("")) && (!request1.getParameter("sw_lat").trim().equals("")) && (!request1.getParameter("sw_long").trim().equals(""))){
        %>    
        
    	  map1 = new google.maps.Map(document.getElementById('map_canvas1'), {
    		  zoom: mapZoom,
    		  center: center,
    		  mapTypeId: google.maps.MapTypeId.HYBRID
    		});
      	  
      	  
        	//create the selection response rectangle
      	  selectedRectangle1 = new google.maps.Rectangle({
      	  	map: map1,
      	  	visible: true,
      	      strokeColor: "#0000FF",
      	      fillColor: "#0000FF"
      	  });
        	
            	//create the coordinates
            	var neCoord=new google.maps.LatLng(<%=request1.getParameter("ne_lat")%>,<%=request1.getParameter("ne_long")%>);
            	var swCoord=new google.maps.LatLng(<%=request1.getParameter("sw_lat")%>,<%=request1.getParameter("sw_long")%>);
            	var search1Bounds = new google.maps.LatLngBounds(
            		swCoord,
            		neCoord
            	);

            	//create the rectangle
            	var search1Rectangle = new google.maps.Rectangle({
            		bounds:search1Bounds,
            		map: map1,
            	    strokeColor: "#ff0000",
            	    fillColor: "#ff0000"
            	});
            	map1.fitBounds(search1Bounds);
            	
            <%
        	}
			if((request.getParameter("ne_lat")!=null) && (request.getParameter("ne_long")!=null) && (request.getParameter("sw_lat")!=null) && (request.getParameter("ne_long")!=null)&&(!request.getParameter("ne_lat").trim().equals("")) &&(!request.getParameter("ne_long").trim().equals("")) && (!request.getParameter("sw_lat").trim().equals("")) && (!request.getParameter("sw_long").trim().equals(""))){
		       
            %>
      	  map2 = new google.maps.Map(document.getElementById('map_canvas2'), {
    		  zoom: mapZoom,
    		  center: center,
    		  mapTypeId: google.maps.MapTypeId.HYBRID
    		});



    	
    		//create the selection response rectangle
    	  selectedRectangle2 = new google.maps.Rectangle({
    	  	map: map2,
    	  	visible: true,
    	      strokeColor: "#0000FF",
    	      fillColor: "#0000FF"
    	  });
    		
        	//create the coordinates
        	var neCoord2=new google.maps.LatLng(<%=request.getParameter("ne_lat")%>,<%=request.getParameter("ne_long")%>);
        	var swCoord2=new google.maps.LatLng(<%=request.getParameter("sw_lat")%>,<%=request.getParameter("sw_long")%>);
        	var search2Bounds = new google.maps.LatLngBounds(
        		swCoord2,
        		neCoord2
        	);

        	//create the rectangle 2
        	var search2Rectangle = new google.maps.Rectangle({
        		bounds:search2Bounds,
        		map: map2,
        	    strokeColor: "#ff0000",
        	    fillColor: "#ff0000"
        	});
	        map2.fitBounds(search2Bounds);
        <%    
        }		
		%>

  }   //end initialize function          
  
  google.maps.event.addDomListener(window, 'load', initialize);
  

</script>
<script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawHaploChart1);
      function drawHaploChart1() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Haplotype');
        data.addColumn('number', 'No. Recorded');
        data.addRows([
          <%
          ArrayList<String> allHaplos1=myShepherd.getAllHaplotypes(); 
          int numHaplos1 = allHaplos1.size();
          

          
          for(int hh=0;hh<numHaplos1;hh++){
          %>
          ['<%=allHaplos1.get(hh)%>',    <%=pieHashtable1.get(allHaplos1.get(hh))%>],
		  <%
          }
		  %>
          
        ]);

        var options = {
          width: 450, height: 300,
          title: 'Haplotype Distribution in Marked Individuals',
          colors: [
                   <%
                   String haploColor="CC0000";
                   if((encprops.getProperty("defaultMarkerColor")!=null)&&(!encprops.getProperty("defaultMarkerColor").trim().equals(""))){
                	   haploColor=encprops.getProperty("defaultMarkerColor");
                   }   

                   
                   for(int yy=0;yy<numHaplos1;yy++){
                       String haplo=allHaplos1.get(yy);
                       if((haploprops.getProperty(haplo)!=null)&&(!haploprops.getProperty(haplo).trim().equals(""))){
                     	  haploColor = haploprops.getProperty(haplo);
                        }
					%>
					'#<%=haploColor%>',
					<%
                   }
                   %>
                   
                   
          ]
        };

        var chart1 = new google.visualization.PieChart(document.getElementById('chart_div1'));
        chart1.draw(data, options);

      }
      
      google.setOnLoadCallback(drawSexChart);
      function drawSexChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Sex');
        data.addColumn('number', 'No. Recorded');
        data.addRows([

          ['male',    <%=sexHashtable1.get("male")%>],
           ['female',    <%=sexHashtable1.get("female")%>],
           ['unknown',    <%=sexHashtable1.get("unknown")%>],
          
        ]);

        <%
        haploColor="CC0000";
        if((encprops.getProperty("defaultMarkerColor")!=null)&&(!encprops.getProperty("defaultMarkerColor").trim().equals(""))){
     	   haploColor=encprops.getProperty("defaultMarkerColor");
        }
        
        %>
        var options = {
          width: 450, height: 300,
          title: 'Sex Distribution in Marked Individuals',
          colors: ['#0000FF','#FF00FF','<%=haploColor%>']
        };

        var chart1 = new google.visualization.PieChart(document.getElementById('sexchart_div1'));
        chart1.draw(data, options);
      }
      
      
</script>

<script type="text/javascript">
      google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawHaploChart2);
      function drawHaploChart2() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Haplotype');
        data.addColumn('number', 'No. Recorded');
        data.addRows([
          <%
          ArrayList<String> allHaplos2a=myShepherd.getAllHaplotypes(); 
          int numHaplos2a = allHaplos2a.size();
          

          
          for(int hh=0;hh<numHaplos2a;hh++){
          %>
          ['<%=allHaplos2a.get(hh)%>',    <%=pieHashtable2.get(allHaplos2a.get(hh))%>],
		  <%
          }
		  %>
          
        ]);

        var options = {
          width: 450, height: 300,
          title: 'Haplotype Distribution in Marked Individuals',
          colors: [
                   <%
                   haploColor="CC0000";
                   if((encprops.getProperty("defaultMarkerColor")!=null)&&(!encprops.getProperty("defaultMarkerColor").trim().equals(""))){
                	   haploColor=encprops.getProperty("defaultMarkerColor");
                   }   

                   
                   for(int yy=0;yy<numHaplos2a;yy++){
                       String haplo=allHaplos2a.get(yy);
                       if((haploprops.getProperty(haplo)!=null)&&(!haploprops.getProperty(haplo).trim().equals(""))){
                     	  haploColor = haploprops.getProperty(haplo);
                        }
					%>
					'#<%=haploColor%>',
					<%
                   }
                   %>
                   
                   
          ]
        };

        var chart2 = new google.visualization.PieChart(document.getElementById('chart_div2'));
        chart2.draw(data, options);
      }
      
      google.setOnLoadCallback(drawSexChart);
      function drawSexChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Sex');
        data.addColumn('number', 'No. Recorded');
        data.addRows([

          ['male',    <%=sexHashtable2.get("male")%>],
           ['female',    <%=sexHashtable2.get("female")%>],
           ['unknown',    <%=sexHashtable2.get("unknown")%>],
          
        ]);

        <%
        haploColor="CC0000";
        if((encprops.getProperty("defaultMarkerColor")!=null)&&(!encprops.getProperty("defaultMarkerColor").trim().equals(""))){
     	   haploColor=encprops.getProperty("defaultMarkerColor");
        }
        
        %>
        var options = {
          width: 450, height: 300,
          title: 'Sex Distribution in Marked Individuals',
          colors: ['#0000FF','#FF00FF','<%=haploColor%>']
        };

        var chart2 = new google.visualization.PieChart(document.getElementById('sexchart_div2'));
        chart2.draw(data, options);
      }
      
      
</script>



    
  </head>
 <body onunload="GUnload()">
 <div id="wrapper">
 <div id="page">
<jsp:include page="../header.jsp" flush="true">

  <jsp:param name="isAdmin" value="<%=request.isUserInRole(\"admin\")%>" />
</jsp:include>
 <div id="main">
 
 <table width="810px" border="0" cellspacing="0" cellpadding="0">
   <tr>
     <td>
       <br/>
 
       <h1 class="intro"><%=encprops.getProperty("title")%>
       </h1>
     </td>
   </tr>
</table>
<table width="810px">
	<tr>
		<td bgcolor="#EEEEFF">
			<p><strong>Comparison Overview</strong></p>
			<p>Shared marked individuals: <%=numMatchedIndividuals%></p>
			
			 <%
 			//now we need to calculate some inbreeding statistics using haplotypes
 			
 			//first get all haplotypes
 			ArrayList<String> allHaplos=myShepherd.getAllHaplotypes();
			 int numHaplosHere=allHaplos.size();
 			
			//next we need to calculate the combined population size, since there are overlapping individuals
			//first, let's get the combined ist of marked individuals
			ArrayList<MarkedIndividual> totalPopulation = new ArrayList<MarkedIndividual>();
    		for(int y=0;y<query1Size;y++){
    			totalPopulation.add(((MarkedIndividual)rEncounters3.get(y)));
    		}
    		int query2Size=rEncounters4.size();
    		for(int y=0;y<query2Size;y++){
    			if(!totalPopulation.contains(((MarkedIndividual)rEncounters4.get(y)))){totalPopulation.add(((MarkedIndividual)rEncounters4.get(y)));}
    		}
			int totalPopulationSize=totalPopulation.size();
			
			double HT=0;
			double HeSearch1=0;
			double HeSearch2=0;
			double pTotalT=0;
			double pTotal1=0;
			double pTotal2=0;
			
			for(int y=0;y<numHaplosHere;y++){
				
				if(!allHaplos.get(y).equals("HET")){
				
					double freqTotal=getHaplotypeFrequencyForSubpopulation(totalPopulation, allHaplos.get(y), myShepherd);
					double qTotal=1-freqTotal;
					HT+=(freqTotal*freqTotal);
					pTotalT+=freqTotal;
				
				
					double freq1=getHaplotypeFrequencyForSubpopulation(rEncounters3, allHaplos.get(y), myShepherd);
					double q1=1-freq1;
					HeSearch1+=(freq1*freq1);
					pTotal1+=freq1;
				
				
					double freq2=getHaplotypeFrequencyForSubpopulation(rEncounters4, allHaplos.get(y), myShepherd);
					double q2=1-freq2;
					HeSearch2+=(freq2*freq2);
					pTotal2+=freq2;
				}
				
				

			}
 			
			HT=1-HT;
			HeSearch1=1-HeSearch1;
			HeSearch2=1-HeSearch2;
			//double HeAvg = (HeSearch1*query1Size+HeSearch2*query2Size)/totalPopulationSize;
			double HeAvg = HeSearch1/2+HeSearch2/2;
			
			double Fst = (HT-HeAvg)/HT;
			%>
			
			<p>F<sub>st</sub> (Haplotype)= <%=Fst %><br />
			H<sub>T</sub>: <%=HT %> <br />H<sub>S</sub>: <%=HeAvg %><br />
			H<sub>expSearch1</sub>: <%=HeSearch1 %><br />
			H<sub>expSearch2</sub>: <%=HeSearch2 %> <br />
			p<sub>Total</sub>: <%=pTotalT %> <br />
			p<sub>1</sub>: <%=pTotal1 %> <br />
			p<sub>2</sub>: <%=pTotal2 %> <br />
			</p>

		<%
			
			

			

 			%>
			</td>
	</tr>
</table>


<%

     try {
 %>
 
<table class="comparison">
<tr><th><%=encprops.getProperty("search1Results") %></th><th><%=encprops.getProperty("search2Results") %></th></tr>
<tr>
	<td>
		<p>No. matching marked individuals: <%=rEncounters3.size() %></p>
	</td>
	<td>
		<p>No. matching marked individuals: <%=rEncounters4.size() %></p>
	</td>
</tr>
<tr>
	<td>
	<table class="comparison"><tr><td>
	
 			<div id="chart_div1"></div>
 		

 		
 		</td></tr></table>
 	</td>
 	<td>
 	<table class="comparison"><tr><td>
 		 <div id="chart_div2"></div>
 		 </td></tr></table>
 	</td>
 </tr>		
<tr>
	<td>
	<table class="comparison"><tr><td>
		<div id="sexchart_div1"></div>
		</td></tr></table>
	</td>
	<td>
	<table class="comparison"><tr><td>
		<div id="sexchart_div2"></div>
		</td></tr></table>
	</td>
</tr>
<tr>
	<td>
		<%
        //set the previous maps search box if set
        if((request1.getParameter("ne_lat")!=null) && (request1.getParameter("ne_long")!=null) && (request1.getParameter("sw_lat")!=null) && (request1.getParameter("ne_long")!=null)&&(!request1.getParameter("ne_lat").trim().equals("")) &&(!request1.getParameter("ne_long").trim().equals("")) && (!request1.getParameter("sw_lat").trim().equals("")) && (!request1.getParameter("sw_long").trim().equals(""))){
        %>   
        <table class="comparison"><tr><td>
			<div id="map_canvas1" style="width: 300px; height: 200px; "></div>
			</td></tr></table>
		<%
        }
        else{
		%>
		<table class="comparison"><tr><td>
			<p><%=encprops.getProperty("noGPS") %></p>
			</td></tr></table>
		<%
        }
		%>
	</td>
	<td>
		<%
        //set the previous maps search box if set
        if((request.getParameter("ne_lat")!=null) && (request.getParameter("ne_long")!=null) && (request.getParameter("sw_lat")!=null) && (request.getParameter("ne_long")!=null)&&(!request.getParameter("ne_lat").trim().equals("")) &&(!request.getParameter("ne_long").trim().equals("")) && (!request.getParameter("sw_lat").trim().equals("")) && (!request.getParameter("sw_long").trim().equals(""))){
        %>   
        <table class="comparison"><tr><td>
			<div id="map_canvas2" style="width: 300px; height: 200px; "></div>
			</td></tr></table>
		<%
        }
        else{
		%>
			<table class="comparison"><tr><td>
				<p><%=encprops.getProperty("noGPS") %></p>
			</td></tr></table>
		<%
        }
		%>
	</td>		
</tr>
<tr>
	<td>	
	<table class="comparison"><tr><td>		
		<div>
      		<p><strong><%=encprops.getProperty("queryDetails")%></strong></p>

      		<p class="caption"><strong><%=encprops.getProperty("prettyPrintResults") %></strong><br/>
        		<%=queryResult1.getQueryPrettyPrint().replaceAll("locationField", encprops.getProperty("location")).replaceAll("locationCodeField", encprops.getProperty("locationID")).replaceAll("verbatimEventDateField", encprops.getProperty("verbatimEventDate")).replaceAll("alternateIDField", encprops.getProperty("alternateID")).replaceAll("behaviorField", encprops.getProperty("behavior")).replaceAll("Sex", encprops.getProperty("sex")).replaceAll("nameField", encprops.getProperty("nameField")).replaceAll("selectLength", encprops.getProperty("selectLength")).replaceAll("numResights", encprops.getProperty("numResights")).replaceAll("vesselField", encprops.getProperty("vesselField"))%>
      		</p>

      		<p class="caption"><strong><%=encprops.getProperty("jdoql")%>
      </strong><br/>
        <%=queryResult1.getJDOQLRepresentation()%>
      </p>
      </td></tr></table>
</div>
</td>

<td>

 


<div>
		<table class="comparison"><tr><td>
      <p><strong><%=encprops.getProperty("queryDetails")%>
      </strong></p>

      <p class="caption"><strong><%=encprops.getProperty("prettyPrintResults") %>
      </strong><br/>
        <%=queryResult2.getQueryPrettyPrint().replaceAll("locationField", encprops.getProperty("location")).replaceAll("locationCodeField", encprops.getProperty("locationID")).replaceAll("verbatimEventDateField", encprops.getProperty("verbatimEventDate")).replaceAll("alternateIDField", encprops.getProperty("alternateID")).replaceAll("behaviorField", encprops.getProperty("behavior")).replaceAll("Sex", encprops.getProperty("sex")).replaceAll("nameField", encprops.getProperty("nameField")).replaceAll("selectLength", encprops.getProperty("selectLength")).replaceAll("numResights", encprops.getProperty("numResights")).replaceAll("vesselField", encprops.getProperty("vesselField"))%>
      </p>

      <p class="caption"><strong><%=encprops.getProperty("jdoql")%>
      </strong><br/>
        <%=queryResult2.getJDOQLRepresentation()%>
      </p>
      </td></tr></table>
</div>
 </td>
 </tr>
 
 </table>
 
 <%
 
     } 
     catch (Exception e) {
       e.printStackTrace();
       %>
       <script type="text\jvascript">
       		alert("I hit an exception!");
       </script>
       <%
       
     }
 



 
 
   myShepherd.rollbackDBTransaction();
   myShepherd.closeDBTransaction();
   rEncounters3 = null;
   rEncounters4 = null;
 
%>

 
 <jsp:include page="../footer.jsp" flush="true"/>
</div>
</div>
<!-- end page --></div>
<!--end wrapper -->

</body>
</html>
