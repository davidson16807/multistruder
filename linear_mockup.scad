include <relativity.scad>

linear_bearing_d = 15;
roller_bearing_id = 8;
roller_bearing_od = 22;
leadscrew_d = 5;
leadscrew_nut_d = 10;
clearance = 1;

//lead screw
rod(d=5, h=150)
	//lead screw nut
	rod(d=leadscrew_nut_d, h=5, anchor=center){
		align(y)
			//nut catch
			box($parent_size + [2,-1,2], anchor=y)
				align(x+y)
				orient(-y)
					//cam
					rod(d=11,h=$parent_size.y)
						orient(-y)
						align(x)
							//roller bearing
							rod(d=roller_bearing_od,h=7,anchor=-x){
								rod(d=roller_bearing_id, h=20, anchor=center);
								align(x)
									//hobbed thread
									rod(d=5, h=150, anchor=-x);
								translated(-25*z, [-1,-2,1,2])
									rod(d=roller_bearing_od, h=7, anchor=center)
										rod(d=roller_bearing_id, h=20, anchor=center);
							}
		align(-x+y){
			//linear bearing
			rod(d=linear_bearing_d, h=24, anchor=x+y){
				align(y)
					//bearing catch
					box($parent_size + [2,-1,2], anchor=y);
				//support rod
				rod(d=8, h=150, anchor=center);
			}
		}
	}
		
