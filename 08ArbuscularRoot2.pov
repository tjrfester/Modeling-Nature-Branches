// Persistence of Vision Ray Tracer Scene Description File

#version 3.6; // current version is 3.8

/* 
Information on Pov-Ray:
 
My personal introduction into Pov-Ray was the excellent book "3D-Welten, professionelle Animationen und fotorealistische Grafiken mit Raytracing" from 
Toni Lama by Carl Hanser Verlag München Wien, 2004. Apart of that I recommend the Pov-Ray-homepage (http://www.povray.org).

Further information on Pov-Ray can be found at https://sus.ziti.uni-heidelberg.de/Lehre/WS2021_Tools/POVRAY/POVRAY_PeterFischer.pdf,  
https://wiki.povray.org/content/Main_Page, https://de.wikibooks.org/wiki/Raytracing_mit_POV-Ray or, in german language, here: https://www.f-lohmueller.de/pov_tut/pov__ger.htm
*/ 
 
/*
---------------------------------------------------Modeling approach---------------------------------------------- 
This model represents arbuscules within a plant root, with a transparent cortex and the central cylinder given as a tube-like structure. Arbuscules are dichotomously branched fungal structures occuring in symbiotic interactions between plant roots from many different 
species with a small group of specialized fungi. Given their large surface, these structures are ideal for exchanging nutrients between root cells and fungal hyphae. This exchange, 
fungal mineral nutrients versus plant carbohydrates, is the main driving force for the symbiotic interaction. 

Modeling arbuscules has been shown in earlier models in this collection. Here they are defined as objects and then distributed along the root axis close to the central cylinder. In addition I have added some 
longer fungal hyphae (with and without arbuscules). 


*/

//-----------------------------------Scene settings (Camera, light, background)-------------------------------------------------

global_settings {
    assumed_gamma 1.0
    max_trace_level 5
}

#declare Hauptkameraz = camera {
    location  <0.4, 0.4, 10>
    right     x*image_width/image_height
    look_at   <-0.1, -0.15,  5>
}

#declare Hauptkamerax = camera {
    location  <10, 0.4, 20>
    right     x*image_width/image_height
    look_at   <0, 0,  20>
}

camera {Hauptkamerax}

// create a regular point light source
light_source {
    0*x                  // light's position (translated below)
    color rgb <1,1,1>    // light's color
    translate <100, 20, -100>
}
light_source {
     0*x                  // light's position (translated below)
    color rgb <1,1,1>    // light's color
    translate <00, 10, -30>
}
light_source {
    0*x                  // light's position (translated below)
    color rgb <1,1,1>    // light's color
    translate <-100, 10, -100>
}
light_source {
    0*x                  // light's position (translated below)
    color rgb <1,1,1>    // light's color
    translate <0, 20, 20>
}

sky_sphere {
  pigment {
    gradient y
    color_map { [0.0 color rgb <0.01,0.01,0>] [0.4 color rgb <0.01,0.01,0>] [0.65 color rgb <0.01,0.01,0>] }
  scale 2
  translate -1
  }
}

/*
//Das Koordinatensystem


cylinder { <-100, 0, 0>, <100, 0, 0>, 0.05 
  pigment {

    color rgb <1,0,0>     // solid color pigment
  }
}

cylinder { <0, -100, 0>, <0, 100, 0>, 0.05 
  pigment {

    color rgb <0,1,0>     // solid color pigment
  }
}

cylinder { <0, 0, -100>, <0, 0, 100>, 0.05 
  pigment {

    color rgb <0,0,1>     // solid color pigment
  }
}
*/


//------------------------------------------------------------------------
//----------------Definition of the arbuscule-----------------------------------------------


#declare Levels =9;
#declare Distance0 = 3;
#declare Anglex0 = 30;                                                             //Rotation by the x-axis
#declare Anglez0 = 30;                                                             //Rotation by the z-axis
#declare P0 = <0, 0, 0>;                                                            //Start

//------------------------------------------------Arrays for storing positions and angles---------------------------------

#declare Positions = array [Levels][pow(2, Levels)];
#declare AAnglex = array [Levels][pow(2, Levels)];
#declare AAnglez = array [Levels][pow(2, Levels)];

//----------------------------------------------Definition of positions---------------------------------------------------------- 

#declare ticker2 = 0;                                                               //The origin
#declare ticker = 0; 
#declare P1 = P0;
#declare Positions [ticker2][ticker] = P1;
#declare AAnglex [ticker2][ticker] = 0;
#declare AAnglez [ticker2][ticker] = 0;
#declare Variance = 0.5;

#declare chance1 = seed(6);  
 
#declare ticker2 = 1;                                                                   //Loop for all subsequent levels
#while ( ticker2 <Levels)

    #declare Elemente = pow (2, ticker2);                                              //Number of elements is doubled in subsequent levels
    #declare Distance = Distance0 - (2.3 * ticker2/(1 + ticker2));                     //Distances are slightly shortened for each layer
    #declare Anglex = Anglex0 - (14 * ticker2/(1 + ticker2));                          //Additional angles are decreased in each layer
    #declare Anglez = Anglez0 - (14 * ticker2/(1 + ticker2));                          //Additional angles are decreased in each layer

    #declare ticker = 0;                                                               //Loop for all elements of a given level
    #while ( ticker <Elemente)
                                                                                    //Reading of values for the previous layer
        #declare P0 = Positions [ticker2-1][int(ticker/2)];
        #declare Angle0x = AAnglex [ticker2-1][int(ticker/2)];
        #declare Angle0z = AAnglez [ticker2-1][int(ticker/2)];

        #if (mod(ticker2, 2) >0)                                                           //Alternating rotations in each subsequent layer 

            #if (mod(ticker, 2) >0)                                                            //In the case of two elements with one common precursor element: One of them obtains a positive new angle, the other one a negative new angle. 

                #declare AAnglex [ticker2][ticker] = (Angle0x + Anglex);                           //New angles are defined and stored in the arrays
                #declare AAnglez [ticker2][ticker] = (Angle0z);                                    //New angles are defined and stored in the arrays
                #declare P1=<P0.x  + sin(radians(Angle0x + Anglex)) * Distance, P0.y + cos(radians(Angle0x + Anglex)) * cos(radians(Angle0z)) * Distance , P0.z + sin(radians(Angle0z)) * cos(radians(Angle0x + Anglex)) * Distance> + < Variance*(rand(chance1)-0.5), Variance*(rand(chance1)-0.5), Variance*(rand(chance1)-0.5)>;

            #else 

                #declare AAnglex [ticker2][ticker] = (Angle0x - Anglex);                           //New angles are defined and stored in the arrays
                #declare AAnglez [ticker2][ticker] = (Angle0z);                                    //New angles are defined and stored in the arrays
                #declare P1=<P0.x  + sin(radians(Angle0x - Anglex)) * Distance, P0.y + cos(radians(Angle0x - Anglex)) * cos(radians(Angle0z)) * Distance, P0.z + sin(radians(Angle0z)) * cos(radians(Angle0x + Anglex)) * Distance> + < Variance*(rand(chance1)-0.5), Variance*(rand(chance1)-0.5), Variance*(rand(chance1)-0.5)>;

            #end

        #else

            #if (mod(ticker, 2) >0)            //In the case of two elements with one common precursor element: One of them obtains a positive new angle, the other one a negative new angle.

                #declare AAnglex [ticker2][ticker] = (Angle0x);                                    //New angles are defined and stored in the arrays
                #declare AAnglez [ticker2][ticker] = (Angle0z + Anglez);                           //New angles are defined and stored in the arrays
                #declare P1=<P0.x  + sin(radians(Angle0x)) * Distance, P0.y + cos(radians(Angle0z + Anglez)) * cos(radians(Angle0x)) * Distance, P0.z + sin(radians(Angle0z + Anglez)) * cos(radians(Angle0x)) * Distance> + < Variance*(rand(chance1)-0.5), Variance*(rand(chance1)-0.5), Variance*(rand(chance1)-0.5)>;

            #else 

                #declare AAnglex [ticker2][ticker] = (Angle0x);                                    //New angles are defined and stored in the arrays
                #declare AAnglez [ticker2][ticker] = (Angle0z - Anglez);                           //New angles are defined and stored in the arrays
                #declare P1=<P0.x  + sin(radians(Angle0x)) * Distance, P0.y + cos(radians(Angle0z - Anglez)) * cos(radians(Angle0x)) * Distance, P0.z + sin(radians(Angle0z - Anglez)) * cos(radians(Angle0x)) * Distance> + < Variance*(rand(chance1)-0.5), Variance*(rand(chance1)-0.5), Variance*(rand(chance1)-0.5)>;

            #end

        #end
                                                                                    

        #declare Positions [ticker2][ticker] = P1;                                                  //New position is stored in the array

    #declare ticker = ticker + 1; 
    #end                                                                                                                                          

#declare ticker2 = ticker2 + 1; 
#end
  
//---------------------------------------------------------Setting up the structure as a blob; first the origin separated from the blob------------------------------------------------------ 

#declare arbuscule = blob {
    threshold 0.3
  
    #declare ticker2 = 0; 
    #declare ticker = 0; 
    #declare P1 = Positions [ticker2][ticker];//The origin

    cylinder { 
        <0, -2, 0>, < P1.x, P1.y, P1.z>, 0.3, 1 
    }

    #declare StrengthVal = 1.; // (+ or -) strength of component's radiating density
  
    #declare ticker2 = 1; 
    #while ( ticker2 <Levels)

        #declare Elemente = pow (2, ticker2);

        #declare ticker = 0; 
        #while ( ticker <Elemente)
 
            #declare P1 = Positions [ticker2][ticker];                                 //The actual position
            #declare P0 = Positions [ticker2-1][int(ticker/2)];                        //the previous position

            #declare RadiusVal   = 0.5/ticker2; // Verkleinerung der Radius mit den Ebenen

            cylinder { 
                P1, P0, 0.3 - (0.2 * ticker2/(1 + ticker2)), StrengthVal // open
            } 

        #declare ticker = ticker + 1; 
        #end

    #declare ticker2 = ticker2 + 1; 
    #end

    texture {
        pigment {
            color rgb <0.2+ (ticker2 * 0.04),0.2 + (ticker2 * 0.04),0.2+ (ticker2 * 0.04)>     // solid color pigment
        }
        finish {
            ambient 0.2          // ambient surface reflection color [0.1]
            diffuse 0.9          // amount [0.6]
            brilliance 1.0       // tightness of diffuse illumination [1.0]
            phong 0.3          // amount [0.0]
            specular 0.9       // amount [0.0]
            metallic 0.9  // give highlight color of surface
            crand 0.5                  // randomly speckle the surface [0.0]
        } // finish
    }
    translate <0, 1.8, 0>

}



//---------------------------------------Wurzelartiges Objekt auf der positiven z-Achse
#declare chance1 = seed(2);
#declare chance2 = seed(5);
#declare chance3 = seed(7);

#declare Number = 19;
#declare Spacing = 3;
#declare Varianz = 0.8;

#declare Start = <0, 0, 0>; //Start and ...
 
#declare MainSpline = spline {                                                                   //Defining the spline  
    cubic_spline
   -2, Start + <0, 0, -2>, // control point
   -1, Start + <0, 0, -1>,// control point

    #declare tickerx = 0;
    #while (tickerx < Number)
        
        #declare P1 = Start + <Varianz *(rand(chance1) - 0.5), Varianz *(rand(chance2) - 0.5), tickerx * Spacing + Varianz *(rand(chance3) - 0.5)>;
        tickerx, P1, //Variable term

    #declare tickerx =  tickerx + 1; 
    #end
   
    Number , P1 + <0, 0, +1>, // control point
    Number + 1,  P1 + <0, 0, +2>, // control point
} 


//The central cylinder

#declare RadiusZ = 0.25;

blob {
    threshold 0.6                                                                                //Showing the spline: The positions defined by the spline are occupied by spheres which are incorporated into a blob
    #declare ticker = 0; 
    #while (ticker < Number) 

    sphere { 
        <0,0,0>, RadiusZ, 1
        scale<1,1,1>  
        rotate<0,0,0>  
        translate MainSpline (ticker)                                                            //This addresses all points on the spline (from MainSpline (0) to MainSpline (TickerMax) with a distance of 0.01 between individual points. 
    }  // end of sphere ----------------------------------- 

    #declare ticker =  ticker + 0.01; 
    #end  
    texture {
        pigment {
            color rgb <1, 0.7, 0>
        } 
        normal {
            bumps 2         // any pattern optionally followed by an intensity value [0.5]
            scale 0.003       // any transformations
        }
        finish {
            ambient 0.01          // ambient surface reflection color [0.1]
            diffuse 0.6          // amount [0.6]
            brilliance 1.0       // tightness of diffuse illumination [1.0]
            phong 0.1          // amount [0.0]
            specular 0.02       // amount [0.0]
        } // finish
    } 
}

//Root cortex


#declare Radius = 1.5;

blob {
    threshold 0.6                                                                                //Showing the spline: The positions defined by the spline are occupied by spheres which are incorporated into a blob
    #declare ticker = 0; 
    #while (ticker < Number) 

    sphere { 
        <0,0,0>, Radius, 1
        scale<1,1,1>  
        rotate<0,0,0>  
        translate MainSpline (ticker)                                                            //This addresses all points on the spline (from MainSpline (0) to MainSpline (TickerMax) with a distance of 0.01 between individual points. 
    }  // end of sphere ----------------------------------- 

    #declare ticker =  ticker + 0.01; 
    #end  
    texture {
        pigment {
            brick color rgb <0.2, 0.1, 0>, 
            color rgbt <0.8, 0.5, 0, 0.99>
            mortar 0.2
            turbulence 0.5   // some turbulence
            scale <0.0008, 0.0008, 0.005>   // transformations
        } 
        normal {           // (---surface bumpiness---)
            brick 100      // some pattern (and intensity)
            mortar 0.2
            turbulence 0.5   // some turbulence
            scale <0.05, 0.05, 0.3>   // transformations
        }
        finish {
            ambient 0.01          // ambient surface reflection color [0.1]
            diffuse 0.6          // amount [0.6]
            brilliance 1.0       // tightness of diffuse illumination [1.0]
            phong 0.1          // amount [0.0]
            specular 0.02       // amount [0.0]
        } // finish
    scale <60, 60, 60>
    } 
}




//--------------------------------------Innere Hyphen----------------------------------------------------------------------

#declare VarianceHyphae = 0.02; 

#declare ticker2 = 0; 
#while (ticker2 < 5)

    #declare HypheSpline = spline {                                                                   //Defining the spline: The spline runs from Start to End with 8 intermediate points with the given variance..  
        cubic_spline
        -2, Start + <0, 0, -2>, // control point
        -1, Start + <0, 0, -1>,// control point

        #declare tickerx = 0;
        #while (tickerx < Number)

            #declare P0 = <0, 0.55 ,0>;
            #declare P0 = vrotate (P0, <0, 0, 72 *ticker2 + 5 * (rand(chance1) - 0.5) >); 
            #declare P1 = P0 + MainSpline (tickerx) + <VarianceHyphae *(rand(chance1) - 0.5), VarianceHyphae *(rand(chance2) - 0.5), VarianceHyphae *(rand(chance3) - 0.5)> ;
            //#declare P1 = vrotate (P1, <0, 0, 72 *ticker2 + 5 * (rand(chance1) - 0.5) >); 
            tickerx, P1, //Variable term

        #declare tickerx =  tickerx + 1; 
        #end
   
        Number , P1 + <0, 0, +1>, // control point
        Number + 1,  P1 + <0, 0, +2>, // control point
    } 

    #declare RadiusHyphe = 0.03;

    blob {
        threshold 0.6                                                                                //Showing the spline: The positions defined by the spline are occupied by spheres which are incorporated into a blob
        #declare ticker = 0; 
        #while (ticker < Number) 

            sphere { 
                <0,0,0>, RadiusHyphe, 1
                scale<1,1,1>  
                rotate<0,0,0>  
                translate HypheSpline (ticker)                                                            //This addresses all points on the spline (from MainSpline (0) to MainSpline (TickerMax) with a distance of 0.01 between individual points. 
            }  // end of sphere ----------------------------------- 

        #declare ticker =  ticker + 0.002; 
        #end  
        texture {
            pigment { 
                color rgb <0.8, 0.8, 0.8> 
            } 
            finish {
                ambient 0.01          // ambient surface reflection color [0.1]
                diffuse 0.6          // amount [0.6]
                brilliance 1.0       // tightness of diffuse illumination [1.0]
                phong 0.1          // amount [0.0]
                specular 0.02       // amount [0.0]
            } // finish
        } 
    }

//-----------------------------------Die Arbuskel--------------------------------------------------------------------

    #declare ticker = 0 + rand (chance1) * 0.15;
    #while (ticker <Number)  

        #declare P1 = HypheSpline(ticker);

        object {
            arbuscule
            scale 0.035
            rotate <0, 360 * rand(chance1), 0> 
            rotate <0, 0, 180 + 72 * ticker2>
            translate P1
        }

    #declare ticker = ticker + 0.15;
    #end

#declare ticker2 = ticker2 + 1; 
#end

