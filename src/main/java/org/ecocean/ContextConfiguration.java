/*
 * The Shepherd Project - A Mark-Recapture Framework
 * Copyright (C) 2011 Jason Holmberg
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package org.ecocean;


import java.util.Properties;

public class ContextConfiguration {
  
  private static final String CONTEXTS_PROPERTIES = "/bundles/contexts.properties";
  
  //class setup
  private static Properties props = new Properties();
  
  private static volatile int propsSize = 0;

public static Properties getContexts(){
  initialize();
  return props;
}
  
  private static void initialize() {
    //set up the file input stream
    if (propsSize == 0) {
      loadProps();
    }
  }

  public static synchronized void refresh() {
      props.clear();
      propsSize = 0;
      loadProps();
  }
  
  private static void loadProps(){
    
    Properties localesProps = new Properties();
    
      try {
        localesProps.load(ContextConfiguration.class.getResourceAsStream(CONTEXTS_PROPERTIES));
        props=localesProps;
        propsSize=props.size();
        } 
      catch (Exception ioe) {
        System.out.println("Hit an error loading contexts.properties.");
        ioe.printStackTrace();
      }
    
  }
  
  public static String getDataDirForContext(String context){
    if(props.getProperty(context)!=null){return props.getProperty(context);}
    return null;
  }
  
}

  
  

  
  