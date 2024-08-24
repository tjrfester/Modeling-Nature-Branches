// Persistence of Vision Ray Tracer Scene Description File
// File: SnailShell.pov

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
In this file a structure with dichotomous branching is modeled. All positions, and angles are stored in arrays, since this information is necessary for calculating points in subsequent layers. 
Two angles are necessary for the model "Anglex" (rotation by the x-axis) and "Anglez" (rotation by the z-axis). In each subsequent layer the number of positions is doubled and the axis of rotation 
is changed. The structure is started by a rotation by the z-axis resulting in two position. For constructing the next layer, positions are rotated around the x-axis (resulting in 4 positions). For the next layer 
points are rotated around the z-axis again, resulting in 8 positions ... 

The positions stored in the array "Positions" are then used for placing sphere and cylinders. The resulting structure could be transformed into a blob as well. 
*/

global_settings {
  assumed_gamma 1.0
  max_trace_level 5
}
//-----------------------------------Scene settings (Camera, light, background)-------------------------------------------------

global_settings {
    assumed_gamma 1.0
    max_trace_level 5
}

#declare Camera = camera {
    location  <10, 12, 16> *0.8
    right     x*image_width/image_height
    look_at   <0,6,  0>
    rotate <0, 0, 0>
}

camera {Camera}

light_source {
    0*x                  // light's position (translated below)
    color rgb <1,1,1>    // light's color
    translate <20, 10, 20>
}
light_source {
    0*x                  // light's position (translated below)
    color rgb <1,1,1>    // light's color
    translate <0, 20, 20>
}

background { 
    color rgb <1, 1, 1> 
}

//------------------------Definition of initial values-----------------------------------------------

#declare Levels =10;
#declare Distance0 = 3;
#declare Anglex0 = 20;                                                             //Rotation by the x-axis
#declare Anglez0 = 20;                                                             //Rotation by the z-axis
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
 
#declare ticker2 = 1;                                                                   //Loop for all subsequent levels
#while ( ticker2 <Levels)

    #declare Elemente = pow (2, ticker2);                                              //Number of elements is doubled in subsequent levels
    #declare Distance = 0.4 + 1.5 * sin (pi/2 + ticker2 * pi/18);                     //Distances are slightly shortened for each layer
    #declare Anglex = Anglex0 - 10 * sin (ticker2 * pi/18);                          //Additional angles are decreased in each layer
    #declare Anglez = Anglez0 - 10 * sin (ticker2 * pi/18);                          //Additional angles are decreased in each layer

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
                #declare P1=<P0.x  + sin(radians(Angle0x + Anglex)) * Distance, P0.y + cos(radians(Angle0x + Anglex)) * cos(radians(Angle0z)) * Distance , P0.z + sin(radians(Angle0z)) * cos(radians(Angle0x + Anglex)) * Distance>;

            #else 

                #declare AAnglex [ticker2][ticker] = (Angle0x - Anglex);                           //New angles are defined and stored in the arrays
                #declare AAnglez [ticker2][ticker] = (Angle0z);                                    //New angles are defined and stored in the arrays
                #declare P1=<P0.x  + sin(radians(Angle0x - Anglex)) * Distance, P0.y + cos(radians(Angle0x - Anglex)) * cos(radians(Angle0z)) * Distance, P0.z + sin(radians(Angle0z)) * cos(radians(Angle0x + Anglex)) * Distance>;

            #end

        #else

            #if (mod(ticker, 2) >0)            //In the case of two elements with one common precursor element: One of them obtains a positive new angle, the other one a negative new angle.

                #declare AAnglex [ticker2][ticker] = (Angle0x);                                    //New angles are defined and stored in the arrays
                #declare AAnglez [ticker2][ticker] = (Angle0z + Anglez);                           //New angles are defined and stored in the arrays
                #declare P1=<P0.x  + sin(radians(Angle0x)) * Distance, P0.y + cos(radians(Angle0z + Anglez)) * cos(radians(Angle0x)) * Distance, P0.z + sin(radians(Angle0z + Anglez)) * cos(radians(Angle0x)) * Distance>;

            #else 

                #declare AAnglex [ticker2][ticker] = (Angle0x);                                    //New angles are defined and stored in the arrays
                #declare AAnglez [ticker2][ticker] = (Angle0z - Anglez);                           //New angles are defined and stored in the arrays
                #declare P1=<P0.x  + sin(radians(Angle0x)) * Distance, P0.y + cos(radians(Angle0z - Anglez)) * cos(radians(Angle0x)) * Distance, P0.z + sin(radians(Angle0z - Anglez)) * cos(radians(Angle0x)) * Distance>;

            #end

        #end
                                                                                    

        #declare Positions [ticker2][ticker] = P1;                                                  //New position is stored in the array

    #declare ticker = ticker + 1; 
    #end                                                                                                                                          

#declare ticker2 = ticker2 + 1; 
#end
  
//---------------------------------------------------------Setting up the structure as a blob; first the origin separated from the blob------------------------------------------------------ 
  
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
                P1, P0, 0.04 + 0.28 * sin (pi/2 + ticker2 * pi/18), StrengthVal // open
                texture {
                    pigment {
                        color rgb <255/255,102/255,0/255>     // solid color pigment
                    }
                    finish {
                        diffuse 0.9 
                        specular 0.4 
                        conserve_energy 
                    }
                }
            } 
        }
    
        sphere { 
            < P1.x, P1.y, P1.z>, 0.038 + 0.19 * sin (pi/2 + ticker2 * pi/18)
            pigment {
                color rgb <0/255, 208/255, 255/255>     // solid color pigment
            }
        } 

    #declare ticker = ticker + 1; 
    #end

#declare ticker2 = ticker2 + 1; 
#end


 





               
               
            