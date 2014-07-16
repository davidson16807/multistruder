include <MCAD/involute_gears.scad>

indeterminate = 1e6;
infinitesimal = 0.001;
x = [1,0,0];
y = [0,1,0];
z = [0,0,1];


roller_bearing_id = 8;
roller_bearing_od = 22;
roller_bearing_h = 7;

linear_bearing_id = 8;
linear_bearing_od = 15;
linear_bearing_h = 24;

leadscrew_d = 5;
leadscrew_nut_d = 9;
leadscrew_nut_h = 5;

guiderod_d = 8;
hobbedrod_d = 8;

filament_d = 2;
filament_n = 4;
filament_space = 4*roller_bearing_h;

clearance = 1;
min_width = 3;
min_height = 1;

leadscrew_hobbedrod_space = leadscrew_nut_d/2 + 2*min_width + roller_bearing_od + hobbedrod_d/2;
leadscrew_guiderod_space = linear_bearing_od+2*min_width;

bull_r = 45*275/360;
pinion_r = 10*275/360;

powertrain_angle = 135;		//angle formed between leadscrew, hobbed rod, and pinion of powertrain motor


mockup();

module mockup(){

	translate(-filament_space/2*z){
		//leadscrew
		cylinder(d=leadscrew_d, h=filament_n*filament_space);
	
		//guide rod
		translate(leadscrew_guiderod_space*x)
			cylinder(d=guiderod_d, h=(filament_n+1)*filament_space);
	}

	translate(-2*roller_bearing_h*z){
		powertrain_motor_mount();
	}

	//cam
	translate(1*filament_space*z)
	cam();

	translate(filament_n*filament_space*z){
		//leadscrew motor
		mirror(z)
		rotate(-powertrain_angle*z)
		motor();

		//leadscrew motor mount
		leadscrew_motor_mount();
	}

	translate(-(leadscrew_hobbedrod_space)*x){
		//filament guides
		for(i=[0:filament_n-1]){
			translate(((roller_bearing_h+filament_d)/2-1.5)*z)
			translate(i*filament_space*z){
				filament_guide();
				filament_idler();
			}
		}

		translate(-filament_space*z){
			//hobbed rod
			cylinder(d=hobbedrod_d, h=(filament_n+1)*filament_space);

			//power train
			rotate(-powertrain_angle*z){
				bull();
				translate((bull_r+pinion_r)*x)
				translate(20*z)
				mirror(z){
					//pinion
					pinion();
					motor(gear_h=0);
				}
			}
		}
	}
}

module powertrain_motor_mount(){
	difference(){
		motor_mount_template();
		
		cylinder(d=leadscrew_d+2*clearance, h=indeterminate);	
		*rotate(-powertrain_angle*z)
			motor();
		translate(leadscrew_guiderod_space*x)
			cylinder(d=guiderod_d, h=indeterminate);
		translate(-(leadscrew_hobbedrod_space)*x){
			cylinder(d=roller_bearing_od, h=indeterminate);
			rotate(-powertrain_angle*z)
			translate((bull_r+pinion_r)*x)
			translate(-infinitesimal*z)
				motor();
		}
		translate(leadscrew_guiderod_space*x)
			cylinder(d=guiderod_d, h=indeterminate);
	}
}

module leadscrew_motor_mount(){
	mirror(z)
	difference(){
		motor_mount_template();

		*cylinder(d=leadscrew_d+2*clearance, h=indeterminate);	
		rotate(-powertrain_angle*z)
			motor();
		translate(leadscrew_guiderod_space*x)
			cylinder(d=guiderod_d, h=indeterminate);
		translate(-(leadscrew_hobbedrod_space)*x){
			cylinder(d=roller_bearing_od, h=indeterminate);
			*rotate(-powertrain_angle*z)
			translate((bull_r+pinion_r)*x)
			translate(-infinitesimal*z)
				motor();
		}
		translate(leadscrew_guiderod_space*x)
			cylinder(d=guiderod_d, h=indeterminate);
	}
}

module motor_mount_template(){
	union(){
		linear_extrude(height=roller_bearing_h)
		//powertrain motor mount
		projection(cut=false)
		hull(){
			cylinder(d=leadscrew_d+2*(clearance+min_width), h=indeterminate);	
			rotate(-powertrain_angle*z)
				motor();
			translate(leadscrew_guiderod_space*x)
				cylinder(d=guiderod_d+2*min_width, h=indeterminate);
			translate(-(leadscrew_hobbedrod_space)*x){
				filament_guide();
				rotate(-powertrain_angle*z)
				translate((bull_r+pinion_r)*x)
					motor();
			}
		}
		translate(leadscrew_guiderod_space*x)
			cylinder(d=guiderod_d+2*min_width, h=linear_bearing_h);
	}
}

module cam(){
	difference(){
		//body
		hull(){
			rotate(90*x)
			cylinder(d=leadscrew_nut_d+2*min_width, h=linear_bearing_od + 2*min_width, center=true);

			translate(leadscrew_guiderod_space*x)
				cube([linear_bearing_od + 2*min_width, linear_bearing_od + 2*min_width, linear_bearing_h], center=true);
		}
		//leadscrew
			cylinder(d=leadscrew_d, h=indeterminate, center=true);
		//nut catch
		translate(-[leadscrew_nut_d, leadscrew_nut_d, leadscrew_nut_h]/2)
			cube([leadscrew_nut_d, indeterminate, leadscrew_nut_h]);
		//bearing
		translate(leadscrew_guiderod_space*x)
			cylinder(d=linear_bearing_od, h=indeterminate, center=true);
	}
}



module bull(){
	difference(){
		gear (number_of_teeth=45,
			circular_pitch=275,
			circles=5,
				bore_diameter=8,
			rim_thickness=8,
			hub_diameter=20,
			hub_thickness=15);
		//nut catch
		translate(8.5*x + (17-7/2)*z)
		translate(-7/2*(x+y))
			cube([3.2,7,indeterminate]);
		//set screw
		translate(10*z)
		rotate(90*y)
			cylinder(d=3, h=indeterminate,$fn=10);
	}
}

module pinion(){
	difference(){
		gear (number_of_teeth=10,
			circular_pitch=275,
			circles=0,
			rim_thickness=20,
			gear_thickness=0,
			hub_diameter=20,
			hub_thickness=10);
		//nut catch
		translate(6*x + (5+7/2)/2*z)
			cube([3.2,7,5+7/2], center=true);
		//set screw
		translate(5*z)
		rotate(90*y)
			cylinder(d=3, h=indeterminate,$fn=10);
	}
}

module motor(gear_h=10){
	translate(-42/2*z)
	cube(42, center=true);
	cylinder(d=22,h=gear_h);
	for(i=[-1,1])
		for(j=[-1,1])
			translate([15.5*i,15.5*j,0])
			cylinder(d=3,h=10);
}

module filament_idler(){
	translate(-min_height*z)
	difference(){
		hull(){
			translate([roller_bearing_od/2, -(roller_bearing_od + min_width)/2, 0])
				cylinder(d=3+2*min_width, h=roller_bearing_h+min_height, center=true);
			translate(((roller_bearing_od + hobbedrod_d)/2+min_width)*x)
				cylinder(d=roller_bearing_od, h=roller_bearing_h+min_height, center=true);
		}

		translate([roller_bearing_od/2, -(roller_bearing_od + min_width)/2, 0])
			cylinder(d=3,h=30,center=true);
		translate(((roller_bearing_od + hobbedrod_d)/2)*x)
		translate(min_height*z)
			difference(){
				cylinder(d=roller_bearing_od+clearance, h=roller_bearing_h+min_height, center=true);
				cylinder(d=roller_bearing_id, h=indeterminate, center=true);
			}
	}
}

module filament_guide(){
	difference(){
		intersection(){
			//structure
			cube([roller_bearing_od+2*min_width, indeterminate, 3*roller_bearing_h], center=true);

			cylinder(r=bull_r+pinion_r-42/2-clearance, h=indeterminate, center=true);
		}
		translate((hobbedrod_d-filament_d)/2*x){
			//guide
			rotate(90*x)
			cylinder(d=3.2, h=indeterminate, center=true, $fn=10);

			translate((roller_bearing_od/2+5)*y){
				//nut catch
				translate([-3.5,-1.6,-3.5])
				cube([7,3.2,indeterminate]);

				//funnel
				rotate(-90*x)
				cylinder(d=4.1, h=6, $fn=10);
			}
		}
		//hobbed rod
		cylinder(d=hobbedrod_d, h=indeterminate, center=true);
		//roller_bearing 1
		translate(roller_bearing_h*z)
		cylinder(d=roller_bearing_od, h=roller_bearing_h, center=true);
		//roller_bearing 2
		translate(-roller_bearing_h*z)
		cylinder(d=roller_bearing_od, h=roller_bearing_h, center=true);
		//roller_bearing clamp clearance

		//clamp
		translate((roller_bearing_od + hobbedrod_d)/2*x - min_height*z){
			//axle
			cylinder(d=roller_bearing_id + 2*(clearance+min_width), h=indeterminate, center=true);
			//roller_bearing
			cylinder(r=roller_bearing_od/2 + filament_d, h=roller_bearing_h + min_height +filament_d, center=true);
			//clamp proper
			translate(-(3+2*min_width)*y)
			cube( [2*(3+2*min_width), 
					roller_bearing_od + 2*(3 + 2*min_width), 
roller_bearing_h+min_height +filament_d], center=true);
		}
		//screw
		translate([roller_bearing_od/2, -(roller_bearing_od + min_width)/2, 0])
			cylinder(d=3,h=30,center=true);
	}
}


module roller_bearing(){
	difference(){
		cylinder(d=roller_bearing_od, h=roller_bearing_h);
		cylinder(d=roller_bearing_id, h=roller_bearing_h);
	}
}
