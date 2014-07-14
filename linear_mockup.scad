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

clearance = 1;
min_width = 3;
min_height = 1;

leadscrew_hobbedrod_space = leadscrew_nut_d/2 + min_width + roller_bearing_od + hobbedrod_d/2;
leadscrew_guiderod_space = 42/2 + guiderod_d/2;

bull_r = 46*275/360;
pinion_r = 10*275/360;

mockup();

module mockup(){
	//leadscrew
	translate(-roller_bearing_h*z)
		cylinder(d=leadscrew_d, h=4*4*roller_bearing_h);
	//cam
	translate(1*4*roller_bearing_h*z)
	cam();

	//leadscrew motor
	translate(4*4*roller_bearing_h*z)
	mirror(z)
	motor();
	
	//guide rod
	translate(leadscrew_guiderod_space*x)
	translate(-roller_bearing_h*z)
		cylinder(d=guiderod_d, h=4*4*roller_bearing_h);

	translate(-(leadscrew_hobbedrod_space)*x){
		for(i=[0:3]){
			translate((roller_bearing_h+filament_d)/2*z-1.5*z)
			translate(4*roller_bearing_h*i*z){
				filament_guide();
				filament_idler();
			}
		}
	
		translate(-30*z){
			//hobbed rod
			cylinder(d=hobbedrod_d, h=5*4*roller_bearing_h);

			//power train
			rotate(-180*z){
				bull();
				translate((bull_r+pinion_r)*x)
				translate(20*z)
				mirror(z)
				rotate(180*z){
					//pinion
					pinion();
					motor(gear_h=0);
				}
			}
		}
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
			hub_thickness=22);
		//nut catch
		translate(8.5*x + (17-7/2)*z)
		translate(-7/2*(x+y))
			cube([3.2,7,indeterminate]);
		//set screw
		translate(17*z)
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
			hub_thickness=11);
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
			translate(((roller_bearing_od + hobbedrod_d)/2+2)*x)
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
		//structure
		translate([1,5,0])
		cube([roller_bearing_od+2*min_width, 2*roller_bearing_od, 3*roller_bearing_h], center=true);

		translate((hobbedrod_d-filament_d)/2*x){
			//guide
			rotate(90*x)
			cylinder(d=3.2, h=indeterminate, center=true, $fn=10);

			translate((roller_bearing_od)*y){
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
			cube([2*(3+2*min_width), roller_bearing_od + 2*(3 + 2*min_width), roller_bearing_h+min_height +filament_d], center=true);
		}
	}
}


module roller_bearing(){
	difference(){
		cylinder(d=roller_bearing_od, h=roller_bearing_h);
		cylinder(d=roller_bearing_id, h=roller_bearing_h);
	}
}
