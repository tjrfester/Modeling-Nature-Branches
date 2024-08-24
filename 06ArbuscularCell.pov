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
// ----------------------------------------
This model represents an arbuscule within a root cortex cell. Arbuscules are dichotomously branched fungal structures occuring in symbiotic interactions between plant roots from many different 
species with a small group of specialized fungi. Given their large surface, these structures are ideal for exchanging nutrients between root cells and fungal hyphae. This exchange, 
fungal mineral nutrients versus plant carbohydrates is the main driving force for the symbiotic interaction. 

Modeling these two structures has been shown in earlier models in this collection. Here the two respective models are somewhat simplified and then combined.  

*/

//-----------------------------------Scene settings (Camera, light, background)-------------------------------------------------

global_settings {
    assumed_gamma 1.0
    max_trace_level 5
}

#declare Hauptkamerax = 
camera {
    location  <-8.5, 0.3, 1.5>
    right     x*image_width/image_height
    look_at   <0, 0.8,  1.2>
    rotate <0, 0, 0>
}

camera {
    Hauptkamerax
}

// create a regular point light source
light_source {
     0*x                  // light's position (translated below)
    color rgb <0.7,0.7,0.7>    // light's color
    translate <-20, 2, 0>
    media_interaction off
}
light_source {
    0*x                  // light's position (translated below)
    color rgb <0.7,0.7,0.7>    // light's color
    translate <-80, 10, 10>
    media_interaction off
} 

light_source {
    0*x                  // light's position (translated below)
    color rgb <1,1,1>    // light's color
    media_interaction off
}

background { 
    color rgb <1, 1, 1> 
}


// ----------------------------------------

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

//Der Massstab

cylinder { <-1, -3, 0>, <-1, -3, 1>, 0.05 
  pigment {

    color rgb <1,1,0>     // solid color pigment
  }
} 

*/

//-------------Definition der Startwerte -------------------------------------------


#declare zNumber =5;
#declare yNumber =5;
#declare xNumber =3;
#declare Number =  xNumber*yNumber*zNumber;
#declare Variance =0.6;
#declare P0 = <-1.5, -4.5, -4>; 
#declare chance1 = seed (13);
#declare chance2 = seed (15);
#declare chance3 = seed (23);
#declare Positions = array [Number];
#declare Counter = 0; 




//---------------Definition of cellular positions--------------------------


//Three nested loops for creating a 3D cellular tissue

#declare ticker3 = 0; 
#while ( ticker3 <yNumber)

    #declare ticker2 = 0; 
    #while ( ticker2 <zNumber)

        #declare ticker = 0; 
        #while ( ticker <xNumber)

            #declare var1 = rand(chance1);
            #declare var2 = rand(chance2);
            #declare var3 = rand(chance3);

            #declare xDistance = 1.5;
            #declare yDistance = 1.5;
            #declare zDistance = 1.5;

            //if-statement for shifting every second column of cells ( only in z-direction) for half a cell diameter in y-direction.
            #if (mod(ticker2, 2) >0) 

                #declare P1=<P0.x + (ticker) * xDistance + Variance * var1, P0.y + (ticker3) * yDistance + Variance * var2, P0.z + (ticker2) * zDistance + Variance*var3>;

            #else

                #declare P1=<P0.x + (ticker) * xDistance + Variance * var1, P0.y + (ticker3) * yDistance+ yDistance/2  + Variance * var2, P0.z + (ticker2) * zDistance + Variance*var3>;


            #end

            #declare Positions [Counter] = P1;
            #declare Counter = Counter + 1; 
 
        #declare ticker = ticker + 1; 
        #end

    #declare ticker2 = ticker2 + 1; 
    #end
 
#declare ticker3 = ticker3 + 1; 
#end
  

//------------------Model of the cellular tissue---------------------------

//The positions defined above are used to invoke blobs where spheres from the neighbouring positions are substracted from a central sphere. This results in cell-like shapes. The cells are substracted from
//a box and this box with "hollow cells" is sectioned by another box to be able to look inside. One of the cells then will beused for hosting the arbuscule. 

#declare Zellverband = 

difference {
    difference {
        box {
            <0, -5, -5>  < 5,  5,  5>  // other corner position <X2 Y2 Z2>
        } 
        union {   //cells are put together into a union
            #declare ticker = 0; 
            #while ( ticker < Number)
                #declare P1 = Positions [ticker];//Der jeweilige Punkt 
                
                #declare RadiusVal   = 1.5; // (0 < RadiusVal) outer sphere of influence on other components
                #declare StrengthVal = 1.0; // (+ or -) strength of component's radiating density

                #declare RadiusVal2   = 1.2; // (0 < RadiusVal) outer sphere of influence on other components
                #declare StrengthVal2 = -0.8; // (+ or -) strength of component's radiating density 
                blob {
                    threshold 0.3
                    sphere { 
                        <0, 0, 0>, RadiusVal, StrengthVal
                        translate < P1.x, P1.y, P1.z> 
                    }
  
                    #declare ticker2 = 0;                              //Here comes the loop searching the array for adjacent cells
                    #while (ticker2 < Number) 
                                                   //Positions of these cells are caled P2
                        #declare P2 = Positions [ticker2]; 
                        #declare Distance = vlength (P2 - P1);

                        #if (Distance > 0)                                 //This excludes the Position P1 itself
                            #if (Distance < 1.7)                               //And this excludes all Positions to far away from P1

                                sphere { 
                                    <0, 0, 0>, RadiusVal2, StrengthVal2     //Sphere on these position are substracted from the central sphere
                                    translate P2
                                } 

                            #else
                            #end
                        #else
                        #end

                    #declare ticker2 = ticker2 + 1; 
                    #end

                    texture {
                        pigment {
                            color rgb <0.9,0.1,0>     // solid color pigment
                        }
                        normal {
                            bumps 1.2        // any pattern optionally followed by an intensity value [0.5]
                            scale 0.05       // any transformations
                        }
                        finish {
                            ambient 0.1          // ambient surface reflection color [0.1]
                            diffuse 0.3          // amount [0.6]
                            brilliance 0.7       // tightness of diffuse illumination [1.0]
                            roughness 0.9     // (~1.0..0.0005) (dull->highly polished) [0.05]
                        } // finish
                    }
                }

            #declare ticker = ticker + 1; 
            #end

        }
    }
    box {
        <-10, -10, -10>    < 1.35,  10,  10>  // other corner position <X2 Y2 Z2>
        texture {
            pigment {
                color rgb <0.7,0.7,0>     // solid color pigment
                transmit 0.3
            }
            normal {           // (---surface bumpiness---)
                crackle 3    // for use with normal{} (0...1 or more)
                scale 0.01
            }
            finish {           // (---surface finish---)
                ambient 0.2
                specular 0.2     // shiny
            }
        }
    }
}


//------------------------Definition of initial values-----------------------------------------------

#declare Levels =12;
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

union {
  
#declare ticker2 = 0; 
#declare ticker = 0; 
#declare P1 = Positions [ticker2][ticker];//The origin

sphere { 
    < P1.x, P1.y, P1.z>, 0.2 
    texture {
        pigment {
            color rgb <0/255, 208/255, 255/255>    // solid color pigment
        }
        finish {
            diffuse 0.3 
            specular 0.4 
            reflection { 
                0.8 metallic
            } 
            conserve_energy 
            phong 0.8 
        }
    }
}

//--------------------------Now the blob becomes defined-----------------------------------------

#declare StrengthVal = 1.; // (+ or -) strength of component's radiating density
  
#declare ticker2 = 1; 
#while ( ticker2 <Levels)

    #declare Elemente = pow (2, ticker2);

    #declare ticker = 0; 
    #while ( ticker <Elemente)
 
        #declare P1 = Positions [ticker2][ticker];                                 //The actual position
        #declare P0 = Positions [ticker2-1][int(ticker/2)];                        //the previous position

        #declare RadiusVal   = 0.5/ticker2; // Verkleinerung der Radius mit den Ebenen

        blob {
            threshold 0.3
            cylinder { 
                P1, P0, 0.3 - (0.2 * ticker2/(1 + ticker2)), StrengthVal // open
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
            } 
        }

    #declare ticker = ticker + 1; 
    #end

#declare ticker2 = ticker2 + 1; 
#end

scale < 0.5, 0.5, 0.5>
rotate <0, 16, 0>
translate <0, -2.5, 0.8>

}

//---------------------------Zusammenstellung der Szene-----------------------------


object {    
    Zellverband
    translate <-1.8, 0, -0.7>
    scale <5,5,5>
} 

 