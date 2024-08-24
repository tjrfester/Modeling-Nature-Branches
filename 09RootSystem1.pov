
// Persistence of Vision Ray Tracer Scene Description File

#version 3.5; // current version is 3.8

/* 
Information on Pov-Ray:
 
My personal introduction into Pov-Ray was the excellent book "3D-Welten, professionelle Animationen und fotorealistische Grafiken mit Raytracing" from 
Toni Lama by Carl Hanser Verlag München Wien, 2004. Apart of that I recommend the Pov-Ray-homepage (http://www.povray.org).

Further information on Pov-Ray can be found at https://sus.ziti.uni-heidelberg.de/Lehre/WS2021_Tools/POVRAY/POVRAY_PeterFischer.pdf,  
https://wiki.povray.org/content/Main_Page, https://de.wikibooks.org/wiki/Raytracing_mit_POV-Ray or, in german language, here: https://www.f-lohmueller.de/pov_tut/pov__ger.htm
*/ 
 
/*
---------------------------------------------------Modeling approach---------------------------------------------- 
Besides stepwise formation of branched structures, there is also another possibility, which is particularly useful for root systems with main and lateral roots: modeling 
root systems in the sequence of decreasing order of lateral roots. This approach starts by modeling the main root. From here several first order laterals are emerging, which are
modeled in a second step. These first order laterals give rise to second order laterals, which can be modeled in a third step. This example stops here for sake of simplicity, 
but the approach could continue to higher order of laterals. 

Technically I am using splines in first step for defining the "paths" of the roots. UJsing these splines has the big advantage that it's possible to easily address any point on the splines 
at any time. In a second step spheres are positioned on the points defined by the splines. These spheres are then combined into 
blobs. 

*/
//-----------------------------------Scene settings (Camera, light, background)-------------------------------------------------

global_settings {
    assumed_gamma 1.0
    max_trace_level 5
}


// create a regular point light source
light_source {
    0*x                  // lights position (translated below)
    color rgb <1,1,1>    // lights color
    translate <20, 60, -20>
} 

// create a regular point light source
light_source {
    0*x                  // lights position (translated below)
    color rgb <1,1,1>    // lights color
    translate <0, -10, -60>
} 


//The camera

#declare Hauptkamera = camera {
    location  <1, -10, -27> 
    right     x*image_width/image_height
    look_at   <0, -10,  0.0>
}


camera {
    Hauptkamera
} 


//-----------------------------------Objects--------------------------------
#declare chance1 = seed (7); 

//------------------------------------------------------------The main root---------------------------------------------------------

#declare TickerMax = 8; //Number of nodes for the root
#declare Var = 0.8;   //Variability of node positions
#declare Start = <0, 0, 0>; //Start and ...
#declare PEnd = <0, -18, 0>; //... end of the main root
 
#declare MainSpline = spline {                                                                   //Defining the spline: The spline runs from Start to End with 8 intermediate points with the given variance..  
    cubic_spline
   -2, <0, 2, 0>, // control point
   -1, <0, 1, 0>,// control point

    #declare tickerx = 0;
    tickerx, <0, 0, 0>, //Start, without variability

    #declare tickerx = 1;//Initiation of loop
    #while (tickerx < TickerMax)

        tickerx, Start + tickerx/(TickerMax - 1)*(PEnd - Start) + <Var*(rand(chance1)-0.5), Var*(rand(chance1)-0.5), Var*(rand(chance1)-0.5)>, //Variable term

    #declare tickerx =  tickerx + 1; 
    #end
   
    TickerMax , PEnd + <0, -2, 0>, // control point
    TickerMax + 1,  PEnd + <0, -4, 0>, // control point
} 



blob {
    threshold 0.6                                                                                //Showing the spline: The positions defined by the spline are occupied by spheres which are incorporated into a blob
    #declare ticker = 0; 
    #while (ticker < TickerMax) 

    sphere { 
        <0,0,0>, 0.2 - 0.02*ticker, 1
        scale<1,1,1>  
        rotate<0,0,0>  
        translate MainSpline (ticker)                                                            //This addresses all points on the spline (from MainSpline (0) to MainSpline (TickerMax) with a distance of 0.01 between individual points. 
    }  // end of sphere ----------------------------------- 

    #declare ticker =  ticker + 0.01; 
    #end  
    texture { 
        pigment { 
            color rgb <255/255,0/255,0/255> 
        }
        finish  { 
            specular 0.2  
        } 
    } // end of texture
}


//-------------------------------------------------------------------------------
                                                          
//----------------------------------------------------------------------------First order Lateral roots-------------------------------------------------------

//Initialize splines 9 Splines are initiated by declaring them and adding one first element. This first element is only a control point, which will not be displayed, but which will have an impact on 
//the slope of the start of the spline. I have chosen a point close to the start of the main root for this first control point.    

#declare Lateral00 = spline {
    cubic_spline
    -2, MainSpline (0.3), // control point
}; 

#declare Lateral01 = spline {
    cubic_spline
    -2, MainSpline (0.3), // control point
}; 
#declare Lateral02 = spline {
    cubic_spline
    -2, MainSpline (0.3), // control point
}; 
#declare Lateral03 = spline {
    cubic_spline
    -2, MainSpline (0.3), // control point
}; 
#declare Lateral04 = spline {
    cubic_spline
    -2, MainSpline (0.3), // control point
}; 
#declare Lateral05 = spline {   
    cubic_spline
    -2, MainSpline (0.3), // control point
}; 
#declare Lateral06 = spline {   
    cubic_spline
    -2, MainSpline (0.3), // control point
}; 
#declare Lateral07 = spline {
    cubic_spline
    -2, MainSpline (0.3), // control point
}; 
#declare Lateral08 = spline {   
    cubic_spline
    -2, MainSpline (0.3), // control point
}; 
#declare Lateral09 = spline {   
    cubic_spline
    -2, MainSpline (0.3), // control point
}; 
                     
                        

//Gather spline's names in an array
#declare FirstOrder = array [10] {
    Lateral00, Lateral01, Lateral02, Lateral03, Lateral04,Lateral05, Lateral06, Lateral07, Lateral08, Lateral09
}; 


//Loop for defining all first order lateral splines: The elements are added to all splines initiated above. They all start at a given location on the main root (MainSpline(Start), with Start 
//obtaining increasingly higher values. (I.e. they start increasingly further down the main root.) And they end at a certain distance from the main root, distributed over a random angle around 
//it and at a similar y-value. There number of nodes is decreasing along the main root's axis. I.e. laterals close to the soil surface are rather long with many nodes, while laterals further down be
//come shorter with less nodes. 

#declare ticker2 = 0 ; 
#while (ticker2 < 10) 

    #declare Start =  0.5 + 0.6*ticker2 + 0.5*(rand(chance1)-0.5) ; //Start on the main root
    #declare PEnd = MainSpline(Start) + <10-0.6*ticker2, -1.8-0.2*ticker2, 0>;//End point of roots 
    #declare PEnd = vrotate (PEnd, <0, 360*rand(chance1), 0>); 
    #declare TickerMax = 8;   
    #declare TickerMaxMod = TickerMax-0.3*ticker2; //Number of nodes per spline
    #declare Varb = 1.5-0.05*ticker2;  //Variability of splines

    #declare FirstOrder [ticker2]  = spline {
        cubic_spline
        -2, MainSpline (Start - 0.6), // control point
        -1, MainSpline (Start - 0.3),// control point

        #declare tickerx = 0;
 
        tickerx, MainSpline (Start), 

        #declare tickerx = 1;

        #while (tickerx < TickerMaxMod)

            tickerx, MainSpline (Start) + tickerx/(TickerMaxMod - 1)*(PEnd - MainSpline (Start)) + <Varb*(rand(chance1)-0.5), Varb*(rand(chance1)-0.5), Varb*(rand(chance1)-0.5)>, //Variability

        #declare tickerx =  tickerx + 1; 
        #end
   
        TickerMaxMod , MainSpline (Start) + 1.2*(PEnd - MainSpline (Start)), // control point
        TickerMaxMod + 1,  MainSpline (Start) + 1.4*(PEnd - MainSpline (Start)), // control point
    }

    //Extracting the current spline's name
    #declare AbleseArray = FirstOrder [ticker2]; 

    blob {                                                            //Spheres (forming blobs) are placed at the places defined by each of the lateral splines. 
        threshold 0.6
        #declare ticker = 0; 
        #while (ticker < TickerMaxMod) 

            sphere { 
                <0,0,0>, 0.12 - 0.008*ticker2 - 0.01*ticker, 1

                scale<1,1,1>  rotate<0,0,0>  translate AbleseArray (ticker)
            }// end of sphere ----------------------------------- 

        #declare ticker =  ticker + 0.005; 
        #end  
        texture { 
            pigment{ 
                color rgb <0/255, 208/255, 255/255>
            }
            finish { 
                specular 0.2 reflection 0.00
            }
        } // end of texture
    }

#declare ticker2 = ticker2 + 1; 
#end  




//-------------------------------------------------------------------------------------

//--------------------------------------Second order lateral roots-----------------------------------------------

//For each of the first order laterals several second order laterals are defined. 

//Initialize splines 

#declare ticker3 = 0;                                                     //This first loops works for all first order lateral roots
#while (ticker3<10)

    #declare ParentSpline = FirstOrder [ticker3];                         //The name of the current first order lateral is extracted from the array. 

  

    #declare Second00 = spline {                                          //These are the names of the second order laterals. These splines will be overwritten in the next loop. So possible third order laterals would have to be defined within this loop. 
        cubic_spline
        -2, ParentSpline (0.3), // control point
    }; 

    #declare Second01 = spline {
        cubic_spline
        -2, ParentSpline (0.3), // control point
    }; 

    #declare Second02 = spline {   
        cubic_spline
        -2, ParentSpline (0.3), // control point
    }; 

    #declare Second03 = spline {
        cubic_spline
        -2, ParentSpline (0.3), // control point
    }; 

    #declare Second04 = spline {
        cubic_spline
        -2, ParentSpline (0.3), // control point
    }; 

    #declare Second05 = spline {
        cubic_spline
        -2, ParentSpline (0.3), // control point
    }; 

    #declare Second06 = spline {
        cubic_spline
        -2, ParentSpline (0.3), // control point
    }; 

    #declare Second07 = spline {
        cubic_spline
        -2, ParentSpline (0.3), // control point
    }; 

    #declare Second08 = spline {
        cubic_spline
        -2, ParentSpline (0.3), // control point
    }; 

    #declare Second09 = spline {
        cubic_spline
        -2, ParentSpline (0.3), // control point
    }; 



    //Gather spline's names in an array
    #declare SecondOrder = array [10] {
        Second00, Second01, Second02, Second03, Second04,Second05, Second06, Second07, Second08, Second09
    }; 

    #declare ticker2 = 0 ;  //Loop of all second order laterals for one first order lateral
    #while (ticker2 < 10-0.5*ticker3) //Number of second order laterals, slowly decreasing

        #declare Axis = ParentSpline (3) - ParentSpline (0);//Axis of the parent root 
        #declare Start =  0.3 + 0.6*ticker2 + 0.3*(rand(chance1)-0.5);                                         //Start and end point of the second order lateral
        #declare PEnd = ParentSpline(Start) + <0, 3.5, 0> + (1.9-0.07*ticker2)*Axis; 
        #declare PEnd = vaxis_rotate (PEnd, ParentSpline(Start) + Axis, 60 + 240 *(rand(chance1))); 
        #declare TickerMax = 8;  
        #declare TickerMaxMod = TickerMax-0.4*ticker2; //Number of nodes per spline
        #declare Varb = 0.8-0.03*ticker2;

        #declare SecondOrder [ticker2]  =  //Each loop defines another spline  

        spline {                                                                                                //The positions for the spline
            cubic_spline
            -2, ParentSpline (Start - 0.6), // control point
            -1, ParentSpline (Start - 0.3),// control point
            #declare tickerx = 0;
            tickerx, ParentSpline (Start), //Start on the parent root (no variability) 
            #declare tickerx = 1;
            #while (tickerx < TickerMaxMod)
                tickerx, ParentSpline (Start) + tickerx/(TickerMaxMod - 1)*(PEnd - ParentSpline (Start)) + <Varb*(rand(chance1)-0.5), Varb*(rand(chance1)-0.5), Varb*(rand(chance1)-0.5)>, //Variabilty
            #declare tickerx =  tickerx + 1; 
            #end
            TickerMaxMod , ParentSpline (Start) + 1.2*(PEnd - ParentSpline (Start)), // control point
            TickerMaxMod + 1,  ParentSpline (Start) + 1.4*(PEnd - ParentSpline (Start)), // control point
        }
        //Extracting the current spline's name
        #declare AbleseArray = SecondOrder [ticker2]; 

        blob {
            threshold 0.6                                                                                       //and here comes the blob from spheres put on the spline's positions
            #declare ticker = 0; 
            #while (ticker < TickerMaxMod) 
                sphere { 
                    <0,0,0>, 0.07 - 0.008*ticker, 1

                    scale<1,1,1>  rotate<0,0,0>  translate AbleseArray (ticker)
                }  // end of sphere ----------------------------------- 


            #declare ticker =  ticker + 0.005; 
            #end  
            texture { 
                pigment { 
                    color rgb <255/255,102/255,0/255> 
                }
                finish  { 
                    specular 0.2  
                } 
            } // end of texture
        }

    #declare ticker2 = ticker2 + 1; 
    #end   

#declare ticker3 = ticker3 + 1; 
#end 


