
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

clearance = 1;
min_width = 3;
min_height = 1;
max_height = 15;

cam_d = bearing_od + min_width + camshaft_d/2;
camshaft_hobbedrod_space = cam_d + clearance;
camshaft_bearing_space = camshaft_hobbedrod_space - bearing_od/2;

mockup();

module support(){
	difference(){
		hull(){
			cylinder(d=camshaft_d+2*min_width, h=bearing_h);
			translate(-(camshaft_hobbedrod_space+hobbedrod_d/2)*x)
			cylinder(d=hobbedrod_d+2*min_width, h=bearing_h);
			translate(max_height/2*z)
				translate((camshaft_hobbedrod_space+2)*y){
				cube([camshaft_d+2*min_width, camshaft_d+2*min_width, max_height], center=true);
				translate(-(camshaft_hobbedrod_space+hobbedrod_d/2)*x)
				cube([hobbedrod_d+2*min_width, camshaft_d+2*min_width, max_height], center=true);
			}
		}
		cylinder(d=camshaft_d, h=indeterminate, center=true);
		translate(-(camshaft_hobbedrod_space+hobbedrod_d/2)*x)
		cylinder(d=hobbedrod_d, h=indeterminate, center=true);
	}
}	


module mockup(){
	cylinder(d=camshaft_d, h=100);
	translate(-(camshaft_hobbedrod_space+hobbedrod_d/2)*x)
	cylinder(d=hobbedrod_d, h=100);

	for(i=[0:5])
		translate((bearing_h + 10)*i*z)
		rotate(360/6*i*z){
			cam();
			translate(camshaft_bearing_space*x)
				bearing();
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
			cylinder(d=camshaft_d+2*min_width, h=bearing_h);
			difference(){
				//outer wall
				translate(-min_height*z)
					cylinder(r=cam_d, h=bearing_h+min_height);
				//space savings
				translate(3*z)
					cylinder(r=cam_d-min_width, h=bearing_h);
			}
			//bearing wall
			intersection(){
				cylinder(r=cam_d, h=bearing_h);
				translate(camshaft_bearing_space*x)
					cylinder(d=bearing_od+2*(clearance+min_width), h=bearing_h);
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

		//space savings
		for(i=[1:3])
		rotate(360/4*i*z)
		translate(cam_d/2*x)
			cylinder(d=0.6*bearing_od, h=indeterminate, center=true);
	}
}

