include <MCAD/involute_gears.scad>

indeterminate = 1e6;
infinitesimal = 0.001;
x = [1,0,0];
y = [0,1,0];
z = [0,0,1];


bearing_id = 8;
bearing_od = 22;
bearing_h = 7;

camshaft_d = 5;
hobbedrod_d = 8;
filament_d = 2;

clearance = 1;
min_width = 3;
min_height = 1;
max_height = 15;

cam_d = bearing_od + min_width + camshaft_d/2;
camshaft_hobbedrod_space = cam_d + clearance + hobbedrod_d/2;
camshaft_bearing_space = cam_d + clearance - bearing_od/2;

bull_r = 46*275/360;
pinion_r = 10*275/360;

mockup();

module mockup(){
	cylinder(d=camshaft_d, h=5*4*bearing_h);
	translate(-30*z)
	translate(-(camshaft_hobbedrod_space)*x)
	cylinder(d=hobbedrod_d, h=5*4*bearing_h);

	for(i=[0:4]){
		translate(4*bearing_h*i*z)
		rotate(360/6*i*z){
			cam();
			translate(camshaft_bearing_space*x)
				bearing();
		}

		translate((bearing_h+filament_d)/2*z-1.5*z)
		translate(-(camshaft_hobbedrod_space)*x)
		translate(4*bearing_h*i*z)
			filament_guide();
	}
	translate(5*4*bearing_h*z)
	mirror(z)
	motor();

	translate(-30*z)
	translate(-(camshaft_hobbedrod_space)*x)
	rotate(110*z){
		bull();
		translate((bull_r+pinion_r)*x)
		translate(20*z)
		mirror(z)
		rotate(-110*z){
			//pinion
			pinion();
			motor(gear_h=0);
		}
	}
}

module camshaft_motor_mount(){
	
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
		translate(8.5*x + (17-6/2)*z)
		translate(-6/2*(x+y))
			cube([2.4,6,indeterminate]);
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
		translate(6*x + (5+6/2)/2*z)
			cube([2.4,6,5+6/2], center=true);
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

module filament_guide(){
	difference(){
		//structure
		cube([bearing_od+2*min_width, bearing_od+2*min_width, 3*bearing_h], center=true);
		//hobbed rod
		cylinder(d=hobbedrod_d, h=indeterminate, center=true);
		//bearing 1
		translate(bearing_h*z)
		cylinder(d=bearing_od, h=bearing_h, center=true);
		//bearing 2
		translate(-bearing_h*z)
		cylinder(d=bearing_od, h=bearing_h, center=true);
		//cam
		translate((camshaft_hobbedrod_space)*x)
		cylinder(r=camshaft_hobbedrod_space-hobbedrod_d/2+filament_d, h=bearing_h+filament_d, center=true);
	}
}

module support(){
	difference(){
		hull(){
			cylinder(d=camshaft_d+2*min_width, h=bearing_h);
			translate(-(camshaft_hobbedrod_space)*x)
			cylinder(d=hobbedrod_d+2*min_width, h=bearing_h);
			translate(max_height/2*z)
				translate((camshaft_hobbedrod_space+2)*y){
				cube([camshaft_d+2*min_width, camshaft_d+2*min_width, max_height], center=true);
				translate(-(camshaft_hobbedrod_space)*x)
				cube([hobbedrod_d+2*min_width, camshaft_d+2*min_width, max_height], center=true);
			}
		}
		cylinder(d=camshaft_d, h=indeterminate, center=true);
		translate(-(camshaft_hobbedrod_space)*x)
		cylinder(d=hobbedrod_d, h=indeterminate, center=true);
	}
}	



module bearing(){
	difference(){
		cylinder(d=bearing_od, h=bearing_h);
		cylinder(d=bearing_id, h=bearing_h);
	}
}


module cam(){
	difference(){
		union(){
			//shaft interface
			cylinder(d=camshaft_d+2*min_width, h=bearing_h);
			//outer wall
			difference(){
				translate(-min_height*z)
					cylinder(r=cam_d, h=bearing_h+min_height);
				cylinder(r=cam_d-min_width, h=indeterminate, center=true);
			}
			//bearing wall
			translate(-min_height*z)
			intersection(){
				cylinder(r=cam_d, h=bearing_h+min_height);
				translate(camshaft_bearing_space*x)
					cylinder(d=bearing_od+2*(clearance+min_width), h=bearing_h+min_height);
			}
			//gear spokes
			difference(){
				translate(-min_height*z)
					cylinder(r=cam_d, h=3);

				for(i=[1:3])
				rotate(360/3*i*z)
				translate(camshaft_bearing_space*x)
					cylinder(d=bearing_od+2, h=indeterminate, center=true);
			}
		}
		translate(camshaft_bearing_space*x){
			//bearing
			difference(){
				cylinder(d=bearing_od+2*clearance, h=bearing_h);
				cylinder(d=bearing_id, h=bearing_h);
			}
			//screw
			cylinder(d=3, h=indeterminate, center=true);
		}
		//screw
		cylinder(d=camshaft_d, h=indeterminate, center=true);
	}
}
