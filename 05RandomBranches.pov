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
This tree is generated step by step from the bottom to the top. In each step new elements are added to open connections. These new elements either are uunbranched (containing one new open connection on their end) 
or branched (containing two open connections on the ends). The chance for insertion of a branched element is sest to 40 % in this example. After the decision for a branched or non-branched new element, 
the respective element is placed on an old open connection and is rotated in various directions to a certain degree. The end(s) of this new element will become old open connections in the next step. 


*/
//--------------------------------------Makros--------------------------------

#macro PolarKoor (P1)                                              //This macro transforms cartesian coordinates of a given point P1 into polar coordinates. The two angles generated should be applied to 
                                                                   //a position on the y-axis with the distance vlength(P1) from the origin. PolarX signifies a rotation by the x-axis, PolarY a rotation 
    #declare PolarX = degrees(acos(P1.y/vlength(P1)));             //by the y-axis. 

    #if (P1.z <0)

        #declare PolarY = 180 - degrees(asin(P1.x/(vlength(P1)*sin(radians(PolarX)))));

    #else

        #declare PolarY = degrees(asin(P1.x/(vlength(P1)*sin(radians(PolarX)))));

    #end

#end


//-----------------------------------Scene settings (Camera, light, background)-------------------------------------------------

global_settings {
    assumed_gamma 1.0
    max_trace_level 5
}

background { 
    color rgb <1, 1, 1> 
}


// create a regular point light source
light_source {
    0*x                  // lights position (translated below)
    color rgb <1,1,1>    // lights color
    translate <20, 60, 20>
} 

// create a regular point light source
light_source {
    0*x                  // lights position (translated below)
    color rgb <1,1,1>    // lights color
    translate <60, 10, 0>
} 

//The camera

#declare Hauptkamera = camera {
    location  <21, 15, 21> 
    rotate<0, 90, 0>
    right     x*image_width/image_height
    look_at   <0, 14,  0.0>
}


camera {Hauptkamera} 

//-----------------------------------Initial values--------------------------------
#declare chance1 = seed(4);
#declare chance2 = seed(7);
#declare chance3 = seed(9);

#declare Start = <0, 0, 0>;
#declare StartAngle = <0, 0, 0>;

#declare counterOld = 1; //Counter for the number of branches

#declare PointOld = array[counterOld]; 
#declare AngleOld = array[counterOld]; 

#declare PointOld[0] = Start;
#declare AngleOld[0] = StartAngle;


#declare End1 = <0, 3, 0>;   

#declare Distanz1 = End1 - Start;


//-------------------------------------------Elements---------------------------------

#declare Element1 = union {
    cylinder { 
        Start, End1, 0.2 
        pigment {          // (---surface color---)
            color rgb <255/255,102/255,0/255>   // lights color
        }  
        finish {
            diffuse 0.9 
            specular 0.4 
            conserve_energy 
        }

    }
    sphere {
        <0, 3, 0>   0.3       
        pigment {          // (---surface color---)
            color rgb  <0/255, 208/255, 255/255>   // lights color
        }
    }
};      

#declare Element2 = union {
    cylinder { 
        Start, End1, 0.2 
        pigment {          // (---surface color---)
            color rgb <255/255,102/255,0/255>    // lights color
        }
        finish {
            diffuse 0.9 
            specular 0.4 
            conserve_energy 
        }
    }
    cylinder { 
        Start, 0.6*End1, 0.2 
        pigment {          // (---surface color---)
            color rgb <255/255,102/255,0/255>  // lights color
        } 
        finish {
            diffuse 0.9 
            specular 0.4 
            conserve_energy 
        }
        rotate <40, 0, 0>
    }
    sphere {
        End1   0.3       
        pigment {          // (---surface color---)
            color rgb  <0/255, 208/255, 255/255>    // lights color
        }
    }
    sphere {
        0.6 * End1   0.3       
        pigment {          // (---surface color---)
            color rgb  <0/255, 208/255, 255/255>    // lights color
        }
        rotate<40, 0, 0>
    }
};      


#declare End2a = End1; 

#declare Distanz2a = End2a - Start; //Distanz2a equals the vector for the non-branched element and for the main branch of the branched element


#declare Distanz2b = 0.6*Distanz1;

#declare Distanz2b = vrotate (Distanz2b, <40, 0, 0>);  //Distanz2b equals the vector for the lateral branch of the branched element


//-----------------------------------------------------------------------------------------------



#declare ticker = 0;

#while (ticker<10) //loop for the various layers


    #declare ticker2 = 0; //ticker2 counts the connecting points of the current layer
    #declare ticker3 = 0; //ticker3 counts the connecting points of the next layer (depending on whether branched or non-branched elements have been selected)

    #declare counterNew = pow(2,counterOld); //maximum number of new connecting points in the next layer
    #declare PointNew = array[counterNew]; //PointNew stores the connecting points from the next layer
    #declare AngleNew = array[counterNew]; //AngleNew stores the angles of elements in the next layer

    #while (ticker2<counterOld)  //loop over the various branches of the current layer

        #declare Angley = 360 * rand(chance2);                          //New elements are rotated randomly around the y-axis...
        #declare Anglex = 30 * (rand(chance1)-0.5);                     //and randomly up to 30 degrees around the x- ...
        #declare Anglez2 = 30 * (rand(chance2)-0.5);                    //... and z-axis. 

        #if (rand(chance1)<0.4)                                                 //Condition for placing element2 (a branched element)

            #declare Start = PointOld[ticker2];
            #declare Angle0 = AngleOld[ticker2];

            object {Element2                                                                           //Positioning the new element
                rotate <0, Angley, 0>
                rotate Angle0 + <Anglex, 0, Anglez2> // Angle0 
                translate Start
            } 

            #declare DistanzNew = vrotate (Distanz2a,<0, Angley, 0>);                                             //Calculating and storing the points for connection of the next layer...
                                                                                                                   //... and the angles of the new element towards the y-axis.
            #declare DistanzNew = vrotate (DistanzNew,(Angle0 + <Anglex, 0, Anglez2>)); 
            #declare StartNew = Start + DistanzNew;  

            PolarKoor(DistanzNew)                                                                                  //This function transforms the coordinate of the new branch into the angles...
                                                                                                                   //for reaching it when starting on the y-axis and first rotating around the x- and then the y-axis. 
            #declare AngleNew[ticker3] = <PolarX, PolarY, 0>;
            #declare PointNew[ticker3] = StartNew;
            #declare ticker3 = ticker3 + 1;                                                                        //Counting the newly created points of connections in the next layer

            #declare DistanzNew = vrotate (Distanz2b,<0, Angley, 0>);                                             //The same procedure for the second point of connection of this element
            #declare DistanzNew = vrotate (DistanzNew,(Angle0 + <Anglex, 0, Anglez2>)); 
            #declare StartNew = Start + DistanzNew;  

            PolarKoor(DistanzNew)  

            #declare AngleNew[ticker3] = <PolarX, PolarY, 0>;
            #declare PointNew[ticker3] = StartNew;
            #declare ticker3 = ticker3 + 1;//Muss bei jedem neu geschaffenen Endpunkt um 1 erhoeht werden




        #else //below a non-branched element is added



            #declare Start = PointOld[ticker2];
            #declare Angle0 = AngleOld[ticker2];



            object {Element1                                        //Positioning of the new element
                rotate Angle0 + <Anglex, 0, Anglez2>
                translate Start
            } 



            #declare DistanzNew = vrotate (Distanz1,(Angle0 + <Anglex, 0, Anglez2>));        //Calculating and storing the new point of connection
            #declare StartNew = Start + DistanzNew;  

            PolarKoor(DistanzNew)  

            #declare AngleNew[ticker3] = <PolarX, PolarY, 0>;
            #declare PointNew[ticker3] = StartNew;

            #declare ticker3 = ticker3 + 1;                                 //Keeps track of newly formed points of connections


        #end //end of elements

    #declare ticker2 = ticker2 + 1;  

    #end                //end of the loop over one layer

                        //All elements of the current layer have been installed, all new points of connections have been calculated.Now these new points will become the starting points for the next layer

    #declare counterOld = ticker3;      //Number of newly created points of connections

    #declare PointOld = array[counterOld];
    #declare AngleOld = array[counterOld];

    #declare PointOld = PointNew; 
    #declare AngleOld = AngleNew; 

#declare ticker = ticker + 1;

#end

